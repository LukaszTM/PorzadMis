import { Firestore, FieldValue } from "firebase-admin/firestore";

export type ChoreRecurrenceType = "daily" | "weekly" | "monthly" | "customDates";

export interface ChoreRecurrence {
  type: ChoreRecurrenceType;
  interval?: number;
  weekdays?: number[]; // 1 = poniedziałek … 7 = niedziela
  monthDay?: number;
  dates?: string[]; // yyyy-MM-dd
  until?: string | null;
}

export interface ChoreRule {
  title: string;
  assigneeId: string | null;
  mode: "once" | "recurring";
  startDate: string; // yyyy-MM-dd
  recurrence?: ChoreRecurrence | null;
}

export const HORIZON_DAYS = 90;

/** Data kalendarzowa bez strefy: liczymy w UTC, żeby nie było przesunięć o dobę. */
export function parseDay(s: string): Date {
  const [y, m, d] = s.split("-").map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

export function formatDay(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function addDays(d: Date, n: number): Date {
  return new Date(d.getTime() + n * 86_400_000);
}

/** 1 = poniedziałek … 7 = niedziela. */
function isoWeekday(d: Date): number {
  const w = d.getUTCDay();
  return w === 0 ? 7 : w;
}

function addMonthsExact(d: Date, months: number, day: number): Date | null {
  const total = d.getUTCMonth() + months;
  const year = d.getUTCFullYear() + Math.floor(total / 12);
  const month = ((total % 12) + 12) % 12;
  const candidate = new Date(Date.UTC(year, month, day));
  return candidate.getUTCMonth() === month ? candidate : null;
}

/**
 * Dni wystąpień reguły w przedziale [from, to] (włącznie, teksty yyyy-MM-dd).
 * Czysta funkcja: ta sama logika w teście i w funkcji chmurowej.
 */
export function occurrenceDays(rule: ChoreRule, from: string, to: string): string[] {
  const start = parseDay(rule.startDate);
  const fromD = parseDay(from);
  const toD = parseDay(to);
  const inRange = (d: Date) => d >= fromD && d <= toD;

  if (rule.mode === "once" || !rule.recurrence) {
    return inRange(start) ? [rule.startDate] : [];
  }
  const r = rule.recurrence;
  const until = r.until ? parseDay(r.until) : null;
  const interval = Math.max(1, Math.floor(r.interval ?? 1));
  const limit = until && until < toD ? until : toD;
  const out: string[] = [];

  switch (r.type) {
    case "customDates": {
      for (const s of [...new Set(r.dates ?? [])].sort()) {
        const d = parseDay(s);
        if (inRange(d) && (!until || d <= until)) out.push(s);
      }
      return out;
    }
    case "daily": {
      for (let d = start; d <= limit; d = addDays(d, interval)) {
        if (d >= fromD) out.push(formatDay(d));
      }
      return out;
    }
    case "weekly": {
      const weekdays = (r.weekdays ?? []).length > 0 ? r.weekdays! : [isoWeekday(start)];
      // Tydzień 0 zaczyna się w poniedziałek tygodnia startu; co `interval` tygodni.
      const weekStart = addDays(start, 1 - isoWeekday(start));
      for (let d = start; d <= limit; d = addDays(d, 1)) {
        const weekIndex = Math.floor((d.getTime() - weekStart.getTime()) / (7 * 86_400_000));
        if (weekIndex % interval !== 0) continue;
        if (!weekdays.includes(isoWeekday(d))) continue;
        if (d >= fromD) out.push(formatDay(d));
      }
      return out;
    }
    case "monthly": {
      const day = r.monthDay ?? start.getUTCDate();
      for (let i = 0; i < 1200; i++) {
        const d = addMonthsExact(start, i * interval, day);
        if (d === null) continue;
        if (d > limit) break;
        if (d < start) continue;
        if (d >= fromD) out.push(formatDay(d));
      }
      return out;
    }
  }
  return out;
}

/** Zakres generowania: od dziś (czas domu) do 90 dni w przód. */
export function horizon(today: string): { from: string; to: string } {
  return { from: today, to: formatDay(addDays(parseDay(today), HORIZON_DAYS)) };
}

export function todayInZone(timeZone: string, now: Date = new Date()): string {
  const parts = new Intl.DateTimeFormat("en-CA", { timeZone, year: "numeric", month: "2-digit", day: "2-digit" })
    .formatToParts(now);
  const get = (t: string) => parts.find((p) => p.type === t)!.value;
  return `${get("year")}-${get("month")}-${get("day")}`;
}

/**
 * Regeneruje wystąpienia reguły: usuwa przyszłe `todo`, zostawia odhaczone i pominięte,
 * tworzy brakujące do horyzontu. Identyfikator `${ruleId}_${date}` chroni przed duplikatami.
 */
export async function regenerateRule(
  db: Firestore,
  hid: string,
  ruleId: string,
  rule: ChoreRule | null,
  today: string,
): Promise<{ created: number; deleted: number }> {
  const col = db.collection(`households/${hid}/choreOccurrences`);
  const existing = await col.where("ruleId", "==", ruleId).get();
  const batch = db.batch();
  let created = 0;
  let deleted = 0;

  const wanted = rule ? new Set(occurrenceDays(rule, horizon(today).from, horizon(today).to)) : new Set<string>();
  const keep = new Set<string>();

  for (const doc of existing.docs) {
    const date = doc.get("date") as string;
    const status = doc.get("status") as string;
    const future = date >= today;
    if (!rule) {
      batch.delete(doc.ref);
      deleted++;
    } else if (future && status === "todo" && !wanted.has(date)) {
      batch.delete(doc.ref);
      deleted++;
    } else {
      keep.add(date);
      if (future && status === "todo") {
        // Odśwież tytuł i przypisanie z reguły.
        batch.update(doc.ref, { title: rule.title, assigneeId: rule.assigneeId });
      }
    }
  }
  if (rule) {
    for (const date of wanted) {
      if (keep.has(date)) continue;
      batch.set(col.doc(`${ruleId}_${date}`), {
        ruleId,
        date,
        title: rule.title,
        assigneeId: rule.assigneeId,
        status: "todo",
        doneBy: null,
        doneAt: null,
        createdAt: FieldValue.serverTimestamp(),
      });
      created++;
    }
  }
  await batch.commit();
  return { created, deleted };
}

/** Codzienne dogenerowanie dla wszystkich domów (horyzont przesuwa się o dzień). */
export async function regenerateAll(db: Firestore, now: Date = new Date()): Promise<number> {
  const households = await db.collection("households").get();
  let rules = 0;
  for (const h of households.docs) {
    const tz = (h.get("timezone") as string | undefined) ?? "Europe/Warsaw";
    const today = todayInZone(tz, now);
    const ruleDocs = await db.collection(`households/${h.id}/choreRules`).get();
    for (const r of ruleDocs.docs) {
      await regenerateRule(db, h.id, r.id, r.data() as ChoreRule, today);
      rules++;
    }
  }
  return rules;
}

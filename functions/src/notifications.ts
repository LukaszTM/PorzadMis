import { Firestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

export type PrefKey = "chores" | "events" | "shopping" | "members" | "budget";

/** Domyślne preferencje: wszystko włączone poza zakupami (PLAN.md). */
export const DEFAULT_PREFS: Record<PrefKey, boolean> = {
  chores: true,
  events: true,
  shopping: false,
  members: true,
  budget: true,
};

export interface PushMessage {
  title: string;
  body: string;
  route: string;
}

export function prefEnabled(prefs: unknown, key: PrefKey): boolean {
  if (prefs && typeof prefs === "object" && key in (prefs as Record<string, unknown>)) {
    return (prefs as Record<string, unknown>)[key] === true;
  }
  return DEFAULT_PREFS[key];
}

/** Treści komunikatów (GUI 5.12): tytuł = co i kiedy, treść = jedno zdanie, bez wykrzykników. */
export const messages = {
  choreAssigned: (title: string, by: string): PushMessage => ({
    title: `Nowy obowiązek: ${title}`,
    body: by ? `${by} przypisał(a) go Tobie.` : "Został przypisany Tobie.",
    route: "/chores",
  }),
  memberJoined: (name: string): PushMessage => ({
    title: "Nowy domownik",
    body: `${name} dołączył(a) do domu.`,
    route: "/members",
  }),
  shoppingAdded: (item: string, by: string): PushMessage => ({
    title: "Lista zakupów",
    body: by ? `${by} dopisał(a) „${item}”.` : `Dopisano „${item}”.`,
    route: "/shopping",
  }),
  budgetExceeded: (month: string, spent: string, plan: string): PushMessage => ({
    title: "Plan budżetu przekroczony",
    body: `W tym miesiącu wydano ${spent} z ${plan}.`,
    route: "/budget",
  }),
};

export function formatPln(grosze: number): string {
  const zl = Math.floor(Math.abs(grosze) / 100);
  const gr = Math.abs(grosze) % 100;
  const digits = zl.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ");
  return `${grosze < 0 ? "-" : ""}${digits},${gr.toString().padStart(2, "0")} zł`;
}

/**
 * Czy po dodaniu wydatku suma przekroczyła plan (przejście z „pod” na „nad”). Zwraca true tylko
 * przy pierwszym przekroczeniu, żeby nie wysyłać alertu przy każdym kolejnym wydatku.
 */
export function crossedPlan(previousTotal: number, newTotal: number, plan: number): boolean {
  return plan > 0 && previousTotal <= plan && newTotal > plan;
}

/** Wysyła push do wskazanych użytkowników z włączoną preferencją; sprząta nieaktywne tokeny. */
export async function sendToUsers(
  db: Firestore,
  uids: string[],
  pref: PrefKey,
  message: PushMessage,
): Promise<number> {
  const unique = [...new Set(uids)];
  if (unique.length === 0) return 0;
  const users = await Promise.all(unique.map((uid) => db.doc(`users/${uid}`).get()));
  let sent = 0;
  for (const user of users) {
    if (!user.exists) continue;
    if (!prefEnabled(user.get("notificationPrefs"), pref)) continue;
    const tokens: string[] = user.get("fcmTokens") ?? [];
    if (tokens.length === 0) continue;
    const res = await getMessaging().sendEachForMulticast({
      tokens,
      notification: { title: message.title, body: message.body },
      data: { route: message.route },
      android: {
        priority: "high",
        notification: { channelId: "porzadmis_default", icon: "ic_notification" },
      },
    });
    sent += res.successCount;
    const stale = tokens.filter((_, i) => {
      const code = res.responses[i].error?.code ?? "";
      return code.includes("registration-token-not-registered") || code.includes("invalid-argument");
    });
    if (stale.length > 0) {
      await user.ref.update({ fcmTokens: FieldValue.arrayRemove(...stale) });
    }
  }
  return sent;
}

export async function memberUids(db: Firestore, hid: string): Promise<string[]> {
  const snap = await db.collection(`households/${hid}/members`).get();
  return snap.docs.map((d) => d.id);
}

export async function adminUids(db: Firestore, hid: string): Promise<string[]> {
  const snap = await db.collection(`households/${hid}/members`).where("role", "==", "admin").get();
  return snap.docs.map((d) => d.id);
}

export async function displayName(db: Firestore, hid: string, uid: string | null | undefined): Promise<string> {
  if (!uid) return "";
  const m = await db.doc(`households/${hid}/members/${uid}`).get();
  return (m.get("displayName") as string | undefined) ?? "";
}

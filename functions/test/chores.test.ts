import { randomUUID } from "crypto";
import { getApps, initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { ChoreRule, occurrenceDays, regenerateRule, todayInZone } from "../src/chores";

if (getApps().length === 0) initializeApp({ projectId: "porzadmis-fn-test" });
const db = getFirestore();

const once: ChoreRule = { title: "Umyć okna", assigneeId: "u1", mode: "once", startDate: "2026-11-10" };
const rec = (recurrence: ChoreRule["recurrence"], startDate = "2026-11-02"): ChoreRule => ({
  title: "Śmieci", assigneeId: null, mode: "recurring", startDate, recurrence,
});

describe("occurrenceDays", () => {
  test("jednorazowy: tylko w swoim dniu", () => {
    expect(occurrenceDays(once, "2026-11-01", "2026-11-30")).toEqual(["2026-11-10"]);
    expect(occurrenceDays(once, "2026-11-11", "2026-11-30")).toEqual([]);
  });
  test("codziennie co 2 dni od startu, od `from`", () => {
    expect(occurrenceDays(rec({ type: "daily", interval: 2 }), "2026-11-05", "2026-11-10"))
      .toEqual(["2026-11-06", "2026-11-08", "2026-11-10"]);
  });
  test("co tydzień we wtorki i piątki (start w poniedziałek 2.11)", () => {
    expect(occurrenceDays(rec({ type: "weekly", weekdays: [2, 5] }), "2026-11-02", "2026-11-15"))
      .toEqual(["2026-11-03", "2026-11-06", "2026-11-10", "2026-11-13"]);
  });
  test("co 2 tygodnie bez dni tygodnia = dzień tygodnia startu", () => {
    expect(occurrenceDays(rec({ type: "weekly", interval: 2 }), "2026-11-01", "2026-12-01"))
      .toEqual(["2026-11-02", "2026-11-16", "2026-11-30"]);
  });
  test("co miesiąc 31. pomija krótsze miesiące; `until` kończy", () => {
    expect(occurrenceDays(rec({ type: "monthly", monthDay: 31, until: "2027-03-31" }, "2026-10-31"), "2026-10-01", "2027-12-31"))
      .toEqual(["2026-10-31", "2026-12-31", "2027-01-31", "2027-03-31"]);
  });
  test("wybrane daty: tylko one, posortowane, bez duplikatów, w zakresie", () => {
    expect(occurrenceDays(rec({ type: "customDates", dates: ["2026-11-20", "2026-11-05", "2026-11-05", "2027-01-01"] }), "2026-11-01", "2026-12-31"))
      .toEqual(["2026-11-05", "2026-11-20"]);
  });
  test("todayInZone liczy dzień w strefie domu", () => {
    expect(todayInZone("Europe/Warsaw", new Date("2026-11-02T23:30:00Z"))).toBe("2026-11-03");
    expect(todayInZone("UTC", new Date("2026-11-02T23:30:00Z"))).toBe("2026-11-02");
  });
});

describe("regenerateRule", () => {
  const col = (hid: string) => db.collection(`households/${hid}/choreOccurrences`);

  test("tworzy wystąpienia do 90 dni z deterministycznym id i nie dubluje przy ponownym uruchomieniu", async () => {
    const hid = randomUUID();
    const rule = rec({ type: "daily", interval: 30 });
    const first = await regenerateRule(db, hid, "r1", rule, "2026-11-02");
    expect(first.created).toBe(4); // 2.11, 2.12, 1.01, 31.01
    const ids = (await col(hid).get()).docs.map((d) => d.id).sort();
    expect(ids[0]).toBe("r1_2026-11-02");
    const second = await regenerateRule(db, hid, "r1", rule, "2026-11-02");
    expect(second.created).toBe(0);
    expect(second.deleted).toBe(0);
    expect((await col(hid).get()).size).toBe(4);
  });

  test("edycja reguły usuwa przyszłe nieodhaczone, zostawia odhaczone, odświeża tytuł", async () => {
    const hid = randomUUID();
    await regenerateRule(db, hid, "r2", rec({ type: "daily" }), "2026-11-02");
    await col(hid).doc("r2_2026-11-03").update({ status: "done", doneBy: "u1" });
    const changed = rec({ type: "weekly", weekdays: [1] });
    changed.title = "Nowy tytuł";
    const res = await regenerateRule(db, hid, "r2", changed, "2026-11-02");
    const docs = (await col(hid).get()).docs;
    expect(docs.find((d) => d.id === "r2_2026-11-03")!.get("status")).toBe("done");
    expect(docs.find((d) => d.id === "r2_2026-11-04")).toBeUndefined();
    expect(docs.find((d) => d.id === "r2_2026-11-09")!.get("title")).toBe("Nowy tytuł");
    expect(res.deleted).toBeGreaterThan(0);
  });

  test("usunięcie reguły usuwa wszystkie jej wystąpienia", async () => {
    const hid = randomUUID();
    await regenerateRule(db, hid, "r3", rec({ type: "daily" }), "2026-11-02");
    await regenerateRule(db, hid, "r3", null, "2026-11-02");
    expect((await col(hid).get()).size).toBe(0);
  });

  test("przesunięcie „dziś” dogenerowuje kolejne dni bez ruszania przeszłości", async () => {
    const hid = randomUUID();
    await regenerateRule(db, hid, "r4", rec({ type: "daily", interval: 45 }), "2026-11-02");
    await regenerateRule(db, hid, "r4", rec({ type: "daily", interval: 45 }), "2026-12-20");
    const ids = (await col(hid).get()).docs.map((d) => d.id).sort();
    expect(ids).toEqual(["r4_2026-11-02", "r4_2026-12-17", "r4_2027-01-31", "r4_2027-03-17"]);
  });
});

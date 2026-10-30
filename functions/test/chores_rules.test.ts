import { readFileSync } from "fs";
import { resolve } from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDocs, setDoc, updateDoc, deleteDoc, collection, serverTimestamp, Timestamp } from "firebase/firestore";

const HID = "33333333-3333-4333-8333-333333333333";
let env: RulesTestEnvironment;

const rule = (over: Record<string, unknown> = {}) => ({
  title: "Śmieci",
  description: "",
  assigneeId: "member1",
  mode: "recurring",
  startDate: "2026-11-02",
  recurrence: { type: "weekly", interval: 1, weekdays: [2, 5] },
  reminderTime: "08:00",
  createdBy: "admin1",
  updatedAt: serverTimestamp(),
  ...over,
});

const occ = (assigneeId: string | null) => ({
  ruleId: "r1", date: "2026-11-03", title: "Śmieci", assigneeId, status: "todo", doneBy: null, doneAt: null,
});

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "porzadmis-rules-test-3",
    firestore: { rules: readFileSync(resolve(__dirname, "../../firestore.rules"), "utf8") },
  });
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, `households/${HID}`), { name: "Dom", createdBy: "admin1" });
    await setDoc(doc(db, `households/${HID}/members/admin1`), { role: "admin" });
    await setDoc(doc(db, `households/${HID}/members/member1`), { role: "member" });
    await setDoc(doc(db, `households/${HID}/members/member2`), { role: "member" });
    await setDoc(doc(db, `households/${HID}/choreRules/r1`), { ...rule(), updatedAt: Timestamp.now() });
    await setDoc(doc(db, `households/${HID}/choreOccurrences/r1_2026-11-03`), occ("member1"));
    await setDoc(doc(db, `households/${HID}/choreOccurrences/r2_2026-11-03`), occ(null));
  });
});

describe("choreRules", () => {
  test("allow: członek czyta; Administrator tworzy, edytuje, usuwa", async () => {
    const m = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(m, `households/${HID}/choreRules`)));
    const a = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(setDoc(doc(a, `households/${HID}/choreRules/r2`), rule({ mode: "once", recurrence: null, assigneeId: null })));
    await assertSucceeds(setDoc(doc(a, `households/${HID}/choreRules/r3`), rule({ recurrence: { type: "customDates", dates: ["2026-11-05"], until: null } })));
    await assertSucceeds(updateDoc(doc(a, `households/${HID}/choreRules/r1`), { title: "Kosz", updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(doc(a, `households/${HID}/choreRules/r1`)));
  });
  test("deny: Domownik nie tworzy, nie edytuje, nie usuwa; obcy nie czyta", async () => {
    const m = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(m, `households/${HID}/choreRules/x`), rule({ createdBy: "member1" })));
    await assertFails(updateDoc(doc(m, `households/${HID}/choreRules/r1`), { title: "X", updatedAt: serverTimestamp() }));
    await assertFails(deleteDoc(doc(m, `households/${HID}/choreRules/r1`)));
    await assertFails(getDocs(collection(env.authenticatedContext("obcy").firestore(), `households/${HID}/choreRules`)));
  });
  test("deny: złe dane reguły", async () => {
    const a = env.authenticatedContext("admin1").firestore();
    const bad = (id: string, over: Record<string, unknown>) =>
      assertFails(setDoc(doc(a, `households/${HID}/choreRules/${id}`), rule(over)));
    await bad("b1", { title: "" });
    await bad("b2", { startDate: "2.11.2026" });
    await bad("b3", { mode: "once" }); // once z recurrence
    await bad("b4", { mode: "recurring", recurrence: null });
    await bad("b5", { recurrence: { type: "hourly" } });
    await bad("b6", { recurrence: { type: "daily", interval: 0 } });
    await bad("b7", { recurrence: { type: "monthly", monthDay: 32 } });
    await bad("b8", { assigneeId: "nikt" });
    await bad("b9", { reminderTime: "8 rano" });
    await bad("b10", { createdBy: "member1" });
    await bad("b11", { extra: 1 });
  });
});

describe("choreOccurrences", () => {
  const path = (id: string) => `households/${HID}/choreOccurrences/${id}`;
  test("allow: przypisany odhacza i cofa; każdy odhacza obowiązek dla „kogoś”; Administrator cudzy", async () => {
    const m1 = env.authenticatedContext("member1").firestore();
    await assertSucceeds(updateDoc(doc(m1, path("r1_2026-11-03")), { status: "done", doneBy: "member1", doneAt: serverTimestamp() }));
    await assertSucceeds(updateDoc(doc(m1, path("r1_2026-11-03")), { status: "todo", doneBy: null, doneAt: null }));
    const m2 = env.authenticatedContext("member2").firestore();
    await assertSucceeds(updateDoc(doc(m2, path("r2_2026-11-03")), { status: "done", doneBy: "member2", doneAt: serverTimestamp() }));
    const a = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(updateDoc(doc(a, path("r1_2026-11-03")), { status: "skipped", doneBy: "admin1", doneAt: serverTimestamp() }));
  });
  test("deny: inny domownik nie odhacza cudzego; klient nie tworzy ani nie usuwa", async () => {
    const m2 = env.authenticatedContext("member2").firestore();
    await assertFails(updateDoc(doc(m2, path("r1_2026-11-03")), { status: "done", doneBy: "member2", doneAt: serverTimestamp() }));
    await assertFails(setDoc(doc(m2, path("r9_2026-11-03")), occ("member2")));
    await assertFails(deleteDoc(doc(m2, path("r2_2026-11-03"))));
  });
  test("deny: odhaczenie na cudze konto, bez doneAt, zmiana tytułu lub daty", async () => {
    const m1 = env.authenticatedContext("member1").firestore();
    await assertFails(updateDoc(doc(m1, path("r1_2026-11-03")), { status: "done", doneBy: "admin1", doneAt: serverTimestamp() }));
    await assertFails(updateDoc(doc(m1, path("r1_2026-11-03")), { status: "done", doneBy: "member1" }));
    await assertFails(updateDoc(doc(m1, path("r1_2026-11-03")), { title: "Inny" }));
    await assertFails(updateDoc(doc(m1, path("r1_2026-11-03")), { date: "2026-11-04" }));
    await assertFails(updateDoc(doc(m1, path("r1_2026-11-03")), { status: "zrobione", doneBy: "member1", doneAt: serverTimestamp() }));
  });
});

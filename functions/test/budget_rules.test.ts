import { readFileSync } from "fs";
import { resolve } from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, getDocs, setDoc, updateDoc, deleteDoc, collection, serverTimestamp, Timestamp } from "firebase/firestore";

const HID = "44444444-4444-4444-8444-444444444444";
let env: RulesTestEnvironment;

const category = (over: Record<string, unknown> = {}) => ({ name: "Jedzenie", icon: "food", colorIndex: 0, order: 0, ...over });
const expense = (over: Record<string, unknown> = {}) => ({
  amount: 1250, date: "2026-11-03", month: "2026-11", categoryId: "c1", note: "", paidBy: "member1",
  createdBy: "admin1", createdAt: serverTimestamp(), ...over,
});
const plan = (over: Record<string, unknown> = {}) => ({ limits: { c1: 50000 }, total: 200000, updatedAt: serverTimestamp(), ...over });

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "porzadmis-rules-test-4",
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
    await setDoc(doc(db, `households/${HID}/categories/c1`), category());
    await setDoc(doc(db, `households/${HID}/expenses/e1`), { ...expense(), createdAt: Timestamp.now() });
    await setDoc(doc(db, `households/${HID}/budgetPlans/2026-11`), { ...plan(), updatedAt: Timestamp.now() });
  });
});

describe("budżet – dostęp", () => {
  test("allow: Administrator czyta i pisze wydatki, plany, kategorie", async () => {
    const a = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(getDocs(collection(a, `households/${HID}/expenses`)));
    await assertSucceeds(setDoc(doc(a, `households/${HID}/expenses/e2`), expense()));
    await assertSucceeds(updateDoc(doc(a, `households/${HID}/expenses/e1`), { amount: 999, note: "x" }));
    await assertSucceeds(deleteDoc(doc(a, `households/${HID}/expenses/e1`)));
    await assertSucceeds(getDoc(doc(a, `households/${HID}/budgetPlans/2026-11`)));
    await assertSucceeds(setDoc(doc(a, `households/${HID}/budgetPlans/2026-12`), plan()));
    await assertSucceeds(setDoc(doc(a, `households/${HID}/categories/c2`), category({ name: "Dom", order: 1 })));
    await assertSucceeds(deleteDoc(doc(a, `households/${HID}/categories/c2`)));
  });
  test("deny: Domownik nie czyta ani nie pisze wydatków i planów (również pojedynczych dokumentów)", async () => {
    const m = env.authenticatedContext("member1").firestore();
    await assertFails(getDocs(collection(m, `households/${HID}/expenses`)));
    await assertFails(getDoc(doc(m, `households/${HID}/expenses/e1`)));
    await assertFails(setDoc(doc(m, `households/${HID}/expenses/x`), expense({ createdBy: "member1" })));
    await assertFails(getDoc(doc(m, `households/${HID}/budgetPlans/2026-11`)));
    await assertFails(getDocs(collection(m, `households/${HID}/budgetPlans`)));
    await assertFails(setDoc(doc(m, `households/${HID}/budgetPlans/2026-12`), plan()));
  });
  test("allow: Domownik czyta kategorie; deny: nie pisze ich", async () => {
    const m = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(m, `households/${HID}/categories`)));
    await assertFails(setDoc(doc(m, `households/${HID}/categories/c9`), category()));
    await assertFails(deleteDoc(doc(m, `households/${HID}/categories/c1`)));
  });
  test("deny: obcy nic", async () => {
    const o = env.authenticatedContext("obcy").firestore();
    await assertFails(getDocs(collection(o, `households/${HID}/categories`)));
    await assertFails(getDocs(collection(o, `households/${HID}/expenses`)));
  });
});

describe("budżet – walidacja", () => {
  test("deny: kwota zero/ujemna/float, zły miesiąc, zła data, obce pole, cudzy autor", async () => {
    const a = env.authenticatedContext("admin1").firestore();
    const bad = (id: string, over: Record<string, unknown>) =>
      assertFails(setDoc(doc(a, `households/${HID}/expenses/${id}`), expense(over)));
    await bad("b1", { amount: 0 });
    await bad("b2", { amount: -5 });
    await bad("b3", { amount: 12.5 });
    await bad("b4", { month: "2026-12" });
    await bad("b5", { date: "3.11.2026", month: "3.11" });
    await bad("b6", { currency: "PLN" });
    await bad("b7", { createdBy: "member1" });
    await bad("b8", { paidBy: "nikt" });
  });
  test("deny: zmiana autora/czasu utworzenia wydatku", async () => {
    const a = env.authenticatedContext("admin1").firestore();
    await assertFails(updateDoc(doc(a, `households/${HID}/expenses/e1`), { createdBy: "member1" }));
    await assertFails(updateDoc(doc(a, `households/${HID}/expenses/e1`), { createdAt: Timestamp.fromMillis(1) }));
  });
  test("deny: plan z ujemną sumą, złym kluczem miesiąca, obcym polem; kategoria z kolorem spoza 0–4", async () => {
    const a = env.authenticatedContext("admin1").firestore();
    await assertFails(setDoc(doc(a, `households/${HID}/budgetPlans/2026-12`), plan({ total: -1 })));
    await assertFails(setDoc(doc(a, `households/${HID}/budgetPlans/grudzien`), plan()));
    await assertFails(setDoc(doc(a, `households/${HID}/budgetPlans/2026-12`), plan({ note: "x" })));
    await assertFails(setDoc(doc(a, `households/${HID}/categories/c3`), category({ colorIndex: 5 })));
    await assertFails(setDoc(doc(a, `households/${HID}/categories/c4`), category({ name: "" })));
  });
});

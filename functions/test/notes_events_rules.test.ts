import { readFileSync } from "fs";
import { resolve } from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  doc, getDoc, setDoc, updateDoc, deleteDoc, collection, getDocs, serverTimestamp, Timestamp,
} from "firebase/firestore";

const HID = "22222222-2222-4222-8222-222222222222";
let env: RulesTestEnvironment;

const sharedNote = (over: Record<string, unknown> = {}) => ({
  title: "Lista", body: "treść", pinned: false, createdBy: "member1", updatedAt: serverTimestamp(), ...over,
});
const privNote = (over: Record<string, unknown> = {}) => ({
  title: "Moje", body: "", pinned: true, updatedAt: serverTimestamp(), ...over,
});
const start = Timestamp.fromDate(new Date("2026-11-02T10:00:00Z"));
const end = Timestamp.fromDate(new Date("2026-11-02T11:00:00Z"));
const sharedEvent = (over: Record<string, unknown> = {}) => ({
  title: "Dentysta", start, end, allDay: false, location: "", description: "", participants: ["member1"],
  reminderMinutes: 60, recurrence: null, createdBy: "member1", ...over,
});
const privEvent = (over: Record<string, unknown> = {}) => ({
  title: "Siłownia", start, end, allDay: false, recurrence: { type: "weekly" }, ...over,
});

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "porzadmis-rules-test-2",
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
    await setDoc(doc(db, `households/${HID}/notes/n1`), { ...sharedNote(), updatedAt: Timestamp.now() });
    await setDoc(doc(db, `households/${HID}/events/e1`), sharedEvent());
    await setDoc(doc(db, `users/member1/privateNotes/p1`), { ...privNote(), updatedAt: Timestamp.now() });
    await setDoc(doc(db, `users/member1/privateEvents/pe1`), privEvent());
  });
});

describe("notatki wspólne", () => {
  test("allow: członek czyta, tworzy swoją, autor edytuje i usuwa", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(db, `households/${HID}/notes`)));
    await assertSucceeds(setDoc(doc(db, `households/${HID}/notes/n2`), sharedNote()));
    await assertSucceeds(updateDoc(doc(db, `households/${HID}/notes/n1`), { body: "nowa", updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(doc(db, `households/${HID}/notes/n1`)));
  });
  test("allow: Administrator edytuje i usuwa cudzą notatkę", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(updateDoc(doc(db, `households/${HID}/notes/n1`), { pinned: true, updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(doc(db, `households/${HID}/notes/n1`)));
  });
  test("deny: inny domownik czyta, ale nie edytuje ani nie usuwa cudzej notatki", async () => {
    const db = env.authenticatedContext("member2").firestore();
    await assertSucceeds(getDoc(doc(db, `households/${HID}/notes/n1`)));
    await assertFails(updateDoc(doc(db, `households/${HID}/notes/n1`), { body: "x", updatedAt: serverTimestamp() }));
    await assertFails(deleteDoc(doc(db, `households/${HID}/notes/n1`)));
  });
  test("deny: obcy, cudzy autor, zmiana autora, pusta notatka, obce pole", async () => {
    await assertFails(getDocs(collection(env.authenticatedContext("obcy").firestore(), `households/${HID}/notes`)));
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(db, `households/${HID}/notes/x1`), sharedNote({ createdBy: "admin1" })));
    await assertFails(updateDoc(doc(db, `households/${HID}/notes/n1`), { createdBy: "admin1" }));
    await assertFails(setDoc(doc(db, `households/${HID}/notes/x2`), sharedNote({ title: "", body: "" })));
    await assertFails(setDoc(doc(db, `households/${HID}/notes/x3`), sharedNote({ secret: true })));
  });
});

describe("notatki prywatne", () => {
  test("allow: właściciel robi wszystko", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(db, "users/member1/privateNotes")));
    await assertSucceeds(setDoc(doc(db, "users/member1/privateNotes/p2"), privNote()));
    await assertSucceeds(updateDoc(doc(db, "users/member1/privateNotes/p1"), { body: "x", updatedAt: serverTimestamp() }));
    await assertSucceeds(deleteDoc(doc(db, "users/member1/privateNotes/p1")));
  });
  test("deny: Administrator ani nikt inny nie czyta cudzych prywatnych", async () => {
    const admin = env.authenticatedContext("admin1").firestore();
    await assertFails(getDoc(doc(admin, "users/member1/privateNotes/p1")));
    await assertFails(getDocs(collection(admin, "users/member1/privateNotes")));
    await assertFails(deleteDoc(doc(admin, "users/member1/privateNotes/p1")));
    await assertFails(setDoc(doc(admin, "users/member1/privateNotes/zz"), privNote()));
  });
  test("deny: pole createdBy w prywatnej notatce", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(db, "users/member1/privateNotes/p3"), privNote({ createdBy: "member1" })));
  });
});

describe("wydarzenia wspólne", () => {
  test("allow: członek czyta, tworzy, autor edytuje i usuwa; cykliczne z until", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(db, `households/${HID}/events`)));
    await assertSucceeds(setDoc(doc(db, `households/${HID}/events/e2`), sharedEvent({
      recurrence: { type: "monthly", until: Timestamp.fromDate(new Date("2027-01-01T00:00:00Z")) },
    })));
    await assertSucceeds(updateDoc(doc(db, `households/${HID}/events/e1`), { title: "Nowy" }));
    await assertSucceeds(deleteDoc(doc(db, `households/${HID}/events/e1`)));
  });
  test("allow: Administrator edytuje cudze; deny: inny domownik", async () => {
    const admin = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(updateDoc(doc(admin, `households/${HID}/events/e1`), { location: "Dom" }));
    const other = env.authenticatedContext("member2").firestore();
    await assertFails(updateDoc(doc(other, `households/${HID}/events/e1`), { location: "X" }));
    await assertFails(deleteDoc(doc(other, `households/${HID}/events/e1`)));
  });
  test("deny: koniec przed początkiem, zły typ cyklu, pusty tytuł, cudzy autor, zły typ przypomnienia, obcy", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(db, `households/${HID}/events/x1`), sharedEvent({ start: end, end: start })));
    await assertFails(setDoc(doc(db, `households/${HID}/events/x2`), sharedEvent({ recurrence: { type: "daily" } })));
    await assertFails(setDoc(doc(db, `households/${HID}/events/x3`), sharedEvent({ title: "" })));
    await assertFails(setDoc(doc(db, `households/${HID}/events/x4`), sharedEvent({ createdBy: "admin1" })));
    await assertFails(setDoc(doc(db, `households/${HID}/events/x5`), sharedEvent({ reminderMinutes: "60" })));
    await assertFails(getDocs(collection(env.authenticatedContext("obcy").firestore(), `households/${HID}/events`)));
  });
});

describe("wydarzenia prywatne", () => {
  test("allow: właściciel; deny: Administrator", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(setDoc(doc(db, "users/member1/privateEvents/pe2"), privEvent({ allDay: true })));
    await assertSucceeds(getDocs(collection(db, "users/member1/privateEvents")));
    await assertSucceeds(deleteDoc(doc(db, "users/member1/privateEvents/pe1")));
    const admin = env.authenticatedContext("admin1").firestore();
    await assertFails(getDoc(doc(admin, "users/member1/privateEvents/pe1")));
    await assertFails(setDoc(doc(admin, "users/member1/privateEvents/zz"), privEvent()));
  });
  test("deny: participants i createdBy w prywatnym wydarzeniu", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(db, "users/member1/privateEvents/pe3"), privEvent({ participants: [] })));
    await assertFails(setDoc(doc(db, "users/member1/privateEvents/pe4"), privEvent({ createdBy: "member1" })));
  });
});

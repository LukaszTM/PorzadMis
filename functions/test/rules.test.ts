import { readFileSync } from "fs";
import { resolve } from "path";
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
  RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc, deleteDoc, collection, getDocs } from "firebase/firestore";

const HID = "11111111-1111-4111-8111-111111111111";
let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await initializeTestEnvironment({
    projectId: "porzadmis-rules-test",
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
    await setDoc(doc(db, `households/${HID}/invites/ABC234`), { code: "ABC234" });
    await setDoc(doc(db, `users/member1`), { displayName: "M", householdId: HID });
  });
});

describe("users", () => {
  test("allow: właściciel czyta swój profil", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDoc(doc(db, "users/member1")));
  });
  test("deny: cudzy profil", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(getDoc(doc(db, "users/admin1")));
  });
  test("allow: tworzenie własnego profilu bez householdId", async () => {
    const db = env.authenticatedContext("new1").firestore();
    await assertSucceeds(setDoc(doc(db, "users/new1"), { displayName: "N" }));
  });
  test("deny: samodzielne ustawienie householdId przy tworzeniu", async () => {
    const db = env.authenticatedContext("new1").firestore();
    await assertFails(setDoc(doc(db, "users/new1"), { displayName: "N", householdId: HID }));
  });
  test("deny: zmiana householdId w istniejącym profilu", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(updateDoc(doc(db, "users/member1"), { householdId: "inny" }));
  });
  test("allow: zmiana displayName", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(updateDoc(doc(db, "users/member1"), { displayName: "Nowe" }));
  });
});

describe("households", () => {
  test("allow: członek czyta dom", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDoc(doc(db, `households/${HID}`)));
  });
  test("deny: obcy i niezalogowany nie czytają domu", async () => {
    await assertFails(getDoc(doc(env.authenticatedContext("obcy").firestore(), `households/${HID}`)));
    await assertFails(getDoc(doc(env.unauthenticatedContext().firestore(), `households/${HID}`)));
  });
  test("allow: admin zmienia ustawienia domu", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(updateDoc(doc(db, `households/${HID}`), { name: "Nowa nazwa" }));
  });
  test("deny: domownik zmienia ustawienia domu", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(updateDoc(doc(db, `households/${HID}`), { name: "X" }));
  });
  test("deny: klient nie zakłada ani nie usuwa domu", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertFails(setDoc(doc(db, "households/nowy"), { name: "X", createdBy: "admin1" }));
    await assertFails(deleteDoc(doc(db, `households/${HID}`)));
  });
});

describe("members", () => {
  test("allow: członek czyta listę domowników", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(db, `households/${HID}/members`)));
  });
  test("deny: obcy nie czyta listy domowników", async () => {
    const db = env.authenticatedContext("obcy").firestore();
    await assertFails(getDocs(collection(db, `households/${HID}/members`)));
  });
  test("deny: nawet admin nie zmienia ról z klienta", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertFails(updateDoc(doc(db, `households/${HID}/members/member1`), { role: "admin" }));
  });
  test("deny: domownik nie nadaje sobie roli admina", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(updateDoc(doc(db, `households/${HID}/members/member1`), { role: "admin" }));
  });
});

describe("invites", () => {
  test("allow: admin czyta zaproszenia", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(getDocs(collection(db, `households/${HID}/invites`)));
  });
  test("deny: domownik nie czyta zaproszeń", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(getDocs(collection(db, `households/${HID}/invites`)));
  });
  test("deny: klient nie tworzy zaproszeń", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertFails(setDoc(doc(db, `households/${HID}/invites/ZZZ999`), { code: "ZZZ999" }));
  });
});

describe("domyślne odrzucenie", () => {
  test("deny: nieznana kolekcja", async () => {
    const db = env.authenticatedContext("admin1").firestore();
    await assertFails(getDoc(doc(db, "cokolwiek/1")));
  });
});

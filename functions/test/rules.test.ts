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

describe("lista zakupów", () => {
  const item = (id: string) => `households/${HID}/shoppingLists/main/items/${id}`;
  const newItem = (over: Record<string, unknown> = {}) => ({
    name: "Mleko",
    quantity: "2",
    unit: "szt",
    storeCategory: "dairy",
    checked: false,
    checkedBy: null,
    addedBy: "member1",
    createdAt: serverTimestamp(),
    ...over,
  });

  beforeEach(async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), item("i1")), {
        name: "Chleb", quantity: "", unit: "", storeCategory: "bakery", checked: false,
        checkedBy: null, addedBy: "admin1", createdAt: Timestamp.now(),
      });
    });
  });

  test("allow: członek czyta listę i dodaje pozycję", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(getDocs(collection(db, `households/${HID}/shoppingLists/main/items`)));
    await assertSucceeds(setDoc(doc(db, item("i2")), newItem()));
  });
  test("allow: członek odhacza cudzą pozycję i cofa odhaczenie", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(updateDoc(doc(db, item("i1")), { checked: true, checkedBy: "member1" }));
    await assertSucceeds(updateDoc(doc(db, item("i1")), { checked: false, checkedBy: null }));
  });
  test("allow: edycja nazwy, ilości i działu oraz usunięcie", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(updateDoc(doc(db, item("i1")), { name: "Chleb żytni", quantity: "1", storeCategory: "bakery" }));
    await assertSucceeds(deleteDoc(doc(db, item("i1"))));
  });
  test("allow: przywrócenie pozycji z dawnym czasem i autorem-domownikiem (Cofnij)", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertSucceeds(setDoc(doc(db, item("i3")), newItem({
      addedBy: "admin1", checked: true, checkedBy: "member1", createdAt: Timestamp.fromMillis(Date.now() - 60_000),
    })));
  });
  test("deny: obcy nie czyta, nie pisze i nie usuwa", async () => {
    const db = env.authenticatedContext("obcy").firestore();
    await assertFails(getDocs(collection(db, `households/${HID}/shoppingLists/main/items`)));
    await assertFails(setDoc(doc(db, item("x")), newItem({ addedBy: "obcy" })));
    await assertFails(updateDoc(doc(db, item("i1")), { checked: true, checkedBy: "obcy" }));
    await assertFails(deleteDoc(doc(db, item("i1"))));
  });
  test("deny: niezalogowany", async () => {
    const db = env.unauthenticatedContext().firestore();
    await assertFails(getDoc(doc(db, item("i1"))));
    await assertFails(setDoc(doc(db, item("x")), newItem()));
  });
  test("deny: pusta, za długa nazwa i nadmiarowe pole", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(db, item("a")), newItem({ name: "" })));
    await assertFails(setDoc(doc(db, item("b")), newItem({ name: "x".repeat(101) })));
    await assertFails(setDoc(doc(db, item("c")), newItem({ sekret: "1" })));
  });
  test("deny: autor niebędący członkiem domu i data z przyszłości", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(setDoc(doc(db, item("d")), newItem({ addedBy: "nikt" })));
    await assertFails(setDoc(doc(db, item("e")), newItem({ createdAt: Timestamp.fromMillis(Date.now() + 86_400_000) })));
  });
  test("deny: odhaczenie na cudze konto, zmiana autora i daty", async () => {
    const db = env.authenticatedContext("member1").firestore();
    await assertFails(updateDoc(doc(db, item("i1")), { checked: true, checkedBy: "admin1" }));
    await assertFails(updateDoc(doc(db, item("i1")), { checked: true }));
    await assertFails(updateDoc(doc(db, item("i1")), { addedBy: "member1" }));
    await assertFails(updateDoc(doc(db, item("i1")), { createdAt: Timestamp.fromMillis(1) }));
  });

  describe("historia podpowiedzi", () => {
    const hist = (key: string) => `households/${HID}/shoppingHistory/${key}`;
    const entry = (over: Record<string, unknown> = {}) => ({
      name: "Mleko", count: 1, lastAddedAt: serverTimestamp(), storeCategory: "dairy", quantity: "", unit: "", ...over,
    });
    test("allow: członek zapisuje, czyta i usuwa wpis", async () => {
      const db = env.authenticatedContext("member1").firestore();
      await assertSucceeds(setDoc(doc(db, hist("mleko")), entry()));
      await assertSucceeds(getDoc(doc(db, hist("mleko"))));
      await assertSucceeds(deleteDoc(doc(db, hist("mleko"))));
    });
    test("deny: obcy, pusta nazwa, zły licznik i obce pole", async () => {
      const outsider = env.authenticatedContext("obcy").firestore();
      await assertFails(setDoc(doc(outsider, hist("mleko")), entry()));
      await assertFails(getDoc(doc(outsider, hist("mleko"))));
      const db = env.authenticatedContext("member1").firestore();
      await assertFails(setDoc(doc(db, hist("a")), entry({ name: "" })));
      await assertFails(setDoc(doc(db, hist("b")), entry({ count: 0 })));
      await assertFails(setDoc(doc(db, hist("c")), entry({ count: "1" })));
      await assertFails(setDoc(doc(db, hist("d")), entry({ extra: true })));
    });
  });
});

describe("zmiana imienia domownika", () => {
  test("allow: Administrator zmienia cudze imię, domownik własne", async () => {
    const a = env.authenticatedContext("admin1").firestore();
    await assertSucceeds(updateDoc(doc(a, `households/${HID}/members/member1`), { displayName: "Ania" }));
    const m = env.authenticatedContext("member1").firestore();
    await assertSucceeds(updateDoc(doc(m, `households/${HID}/members/member1`), { displayName: "Anna" }));
  });
  test("deny: domownik cudze; puste imię; zmiana roli tą drogą; obcy", async () => {
    const m = env.authenticatedContext("member1").firestore();
    await assertFails(updateDoc(doc(m, `households/${HID}/members/admin1`), { displayName: "X" }));
    await assertFails(updateDoc(doc(m, `households/${HID}/members/member1`), { displayName: "" }));
    await assertFails(updateDoc(doc(m, `households/${HID}/members/member1`), { displayName: "A", role: "admin" }));
    const a = env.authenticatedContext("admin1").firestore();
    await assertFails(updateDoc(doc(a, `households/${HID}/members/member1`), { role: "admin" }));
    await assertFails(updateDoc(doc(env.authenticatedContext("obcy").firestore(), `households/${HID}/members/member1`), { displayName: "X" }));
  });
});

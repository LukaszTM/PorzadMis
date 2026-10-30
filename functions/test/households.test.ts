import { randomUUID } from "crypto";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as h from "../src/households";

initializeApp({ projectId: "porzadmis-fn-test" });
const db = getFirestore();

async function setup() {
  const hid = randomUUID();
  const admin = `admin-${hid}`;
  await h.createHousehold(db, admin, { householdId: hid, name: "Dom", displayName: "Ala" });
  return { hid, admin };
}

async function expectCode(p: Promise<unknown>, code: string) {
  await expect(p).rejects.toMatchObject({ code });
}

describe("createHousehold", () => {
  test("zakładający zostaje administratorem", async () => {
    const { hid, admin } = await setup();
    expect((await db.doc(`households/${hid}/members/${admin}`).get()).get("role")).toBe("admin");
    expect((await db.doc(`users/${admin}`).get()).get("householdId")).toBe(hid);
    const house = await db.doc(`households/${hid}`).get();
    expect(house.get("currency")).toBe("PLN");
    expect(house.get("weekStartsOn")).toBe(1);
  });
  test("odrzuca użytkownika, który ma już dom", async () => {
    const { admin } = await setup();
    await expectCode(
      h.createHousehold(db, admin, { householdId: randomUUID(), name: "Drugi", displayName: "Ala" }),
      "failed-precondition",
    );
  });
  test("odrzuca identyfikator niebędący UUID", async () => {
    await expectCode(
      h.createHousehold(db, "u1", { householdId: "abc", name: "Dom", displayName: "X" }),
      "invalid-argument",
    );
  });
});

describe("zaproszenia", () => {
  test("domownik dołącza kodem tekstowym (też małymi literami)", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    expect(inv.code).toMatch(/^[A-Z0-9]{6}$/);
    const res = await h.redeemInvite(db, "gosc1", { code: inv.code.toLowerCase(), displayName: "Gość" });
    expect(res.householdId).toBe(hid);
    expect((await db.doc(`households/${hid}/members/gosc1`).get()).get("role")).toBe("member");
  });
  test("domownik dołącza tokenem z QR", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    const res = await h.redeemInvite(db, "gosc2", { qrToken: inv.qrToken, displayName: "Gość" });
    expect(res.householdId).toBe(hid);
  });
  test("jednorazowe zaproszenie nie działa drugi raz", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid, multiUse: false });
    await h.redeemInvite(db, "g1", { code: inv.code, displayName: "A" });
    await expectCode(h.redeemInvite(db, "g2", { code: inv.code, displayName: "B" }), "failed-precondition");
  });
  test("wielokrotne zaproszenie działa dla kilku osób", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid, multiUse: true });
    await h.redeemInvite(db, "m1", { code: inv.code, displayName: "A" });
    await h.redeemInvite(db, "m2", { code: inv.code, displayName: "B" });
    const used = (await db.doc(`households/${hid}/invites/${inv.code}`).get()).get("usedBy");
    expect(used).toEqual(expect.arrayContaining(["m1", "m2"]));
  });
  test("wygasłe zaproszenie jest odrzucane", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await db
      .doc(`households/${hid}/invites/${inv.code}`)
      .update({ expiresAt: Timestamp.fromMillis(Date.now() - 1000) });
    await expectCode(h.redeemInvite(db, "g3", { code: inv.code, displayName: "A" }), "failed-precondition");
  });
  test("unieważnione zaproszenie jest odrzucane", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.revokeInvite(db, admin, { householdId: hid, code: inv.code });
    await expectCode(h.redeemInvite(db, "g4", { code: inv.code, displayName: "A" }), "failed-precondition");
  });
  test("nieistniejący kod daje not-found", async () => {
    await expectCode(h.redeemInvite(db, "g5", { code: "NOPE22", displayName: "A" }), "not-found");
  });
  test("użytkownik z domem nie może dołączyć do drugiego", async () => {
    const a = await setup();
    const b = await setup();
    const inv = await h.createInvite(db, b.admin, { householdId: b.hid });
    await expectCode(
      h.redeemInvite(db, a.admin, { code: inv.code, displayName: "A" }),
      "failed-precondition",
    );
  });
  test("domownik nie tworzy ani nie unieważnia zaproszeń", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid, multiUse: true });
    await h.redeemInvite(db, "m3", { code: inv.code, displayName: "A" });
    await expectCode(h.createInvite(db, "m3", { householdId: hid }), "permission-denied");
    await expectCode(
      h.revokeInvite(db, "m3", { householdId: hid, code: inv.code }),
      "permission-denied",
    );
  });
});

describe("role i usuwanie", () => {
  test("admin nadaje rolę admina, a potem może zdegradować siebie", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.redeemInvite(db, "m4", { code: inv.code, displayName: "A" });
    await h.setMemberRole(db, admin, { householdId: hid, targetUid: "m4", role: "admin" });
    await h.setMemberRole(db, admin, { householdId: hid, targetUid: admin, role: "member" });
    expect((await db.doc(`households/${hid}/members/${admin}`).get()).get("role")).toBe("member");
  });
  test("ostatniego admina nie da się zdegradować", async () => {
    const { hid, admin } = await setup();
    await expectCode(
      h.setMemberRole(db, admin, { householdId: hid, targetUid: admin, role: "member" }),
      "failed-precondition",
    );
  });
  test("ostatniego admina nie da się usunąć", async () => {
    const { hid, admin } = await setup();
    await expectCode(h.removeMember(db, admin, { householdId: hid, targetUid: admin }), "failed-precondition");
  });
  test("domownik nie zmienia ról ani nie usuwa", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.redeemInvite(db, "m5", { code: inv.code, displayName: "A" });
    await expectCode(
      h.setMemberRole(db, "m5", { householdId: hid, targetUid: "m5", role: "admin" }),
      "permission-denied",
    );
    await expectCode(h.removeMember(db, "m5", { householdId: hid, targetUid: admin }), "permission-denied");
  });
  test("usunięty domownik traci householdId i może dołączyć gdzie indziej", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.redeemInvite(db, "m6", { code: inv.code, displayName: "A" });
    await h.removeMember(db, admin, { householdId: hid, targetUid: "m6" });
    expect((await db.doc(`households/${hid}/members/m6`).get()).exists).toBe(false);
    expect((await db.doc("users/m6").get()).get("householdId")).toBeUndefined();
  });
});

describe("leaveHousehold", () => {
  test("jedyna osoba opuszczając dom usuwa go i może założyć nowy", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    const res = await h.leaveHousehold(db, admin, { householdId: hid });
    expect(res.deleted).toBe(true);
    expect((await db.doc(`households/${hid}`).get()).exists).toBe(false);
    expect((await db.doc(`households/${hid}/invites/${inv.code}`).get()).exists).toBe(false);
    expect((await db.doc(`users/${admin}`).get()).get("householdId")).toBeUndefined();
    await h.createHousehold(db, admin, { householdId: randomUUID(), name: "Nowy", displayName: "Ala" });
  });
  test("domownik wychodzi, a dom zostaje", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.redeemInvite(db, "l1", { code: inv.code, displayName: "A" });
    const res = await h.leaveHousehold(db, "l1", { householdId: hid });
    expect(res.deleted).toBe(false);
    expect((await db.doc(`households/${hid}`).get()).exists).toBe(true);
    expect((await db.doc(`households/${hid}/members/l1`).get()).exists).toBe(false);
    expect((await db.doc("users/l1").get()).get("householdId")).toBeUndefined();
  });
  test("jedyny Administrator nie wychodzi, gdy są inni domownicy", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.redeemInvite(db, "l2", { code: inv.code, displayName: "A" });
    await expectCode(h.leaveHousehold(db, admin, { householdId: hid }), "failed-precondition");
    expect((await db.doc(`households/${hid}/members/${admin}`).get()).exists).toBe(true);
  });
  test("Administrator wychodzi, gdy jest drugi Administrator", async () => {
    const { hid, admin } = await setup();
    const inv = await h.createInvite(db, admin, { householdId: hid });
    await h.redeemInvite(db, "l3", { code: inv.code, displayName: "A" });
    await h.setMemberRole(db, admin, { householdId: hid, targetUid: "l3", role: "admin" });
    const res = await h.leaveHousehold(db, admin, { householdId: hid });
    expect(res.deleted).toBe(false);
  });
  test("obca osoba nie może opuścić cudzego domu", async () => {
    const { hid } = await setup();
    await expectCode(h.leaveHousehold(db, "obcy", { householdId: hid }), "not-found");
  });
});

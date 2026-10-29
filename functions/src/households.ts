import { randomBytes } from "crypto";
import { Firestore, FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/v2/https";

export type Role = "admin" | "member";

const INVITE_TTL_MS = 24 * 60 * 60 * 1000;
// Bez znaków łatwych do pomylenia (0/O, 1/I/L).
const CODE_ALPHABET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";

function requireString(value: unknown, field: string, max = 80): string {
  if (typeof value !== "string" || value.trim().length === 0 || value.length > max) {
    throw new HttpsError("invalid-argument", `Nieprawidłowe pole: ${field}`);
  }
  return value.trim();
}

function requireUuid(value: unknown, field: string): string {
  const id = requireString(value, field, 64);
  if (!/^[0-9a-fA-F-]{32,36}$/.test(id)) {
    throw new HttpsError("invalid-argument", `Pole ${field} musi być UUID`);
  }
  return id.toLowerCase();
}

export function generateInviteCode(): string {
  const bytes = randomBytes(6);
  return Array.from(bytes, (b) => CODE_ALPHABET[b % CODE_ALPHABET.length]).join("");
}

async function requireAdmin(db: Firestore, hid: string, uid: string): Promise<void> {
  const snap = await db.doc(`households/${hid}/members/${uid}`).get();
  if (!snap.exists || snap.get("role") !== "admin") {
    throw new HttpsError("permission-denied", "Tylko administrator może to zrobić");
  }
}

export interface CreateHouseholdInput {
  householdId: unknown;
  name: unknown;
  displayName: unknown;
}

export async function createHousehold(db: Firestore, uid: string, input: CreateHouseholdInput) {
  const hid = requireUuid(input.householdId, "householdId");
  const name = requireString(input.name, "name");
  const displayName = requireString(input.displayName, "displayName");

  await db.runTransaction(async (tx) => {
    const userRef = db.doc(`users/${uid}`);
    const householdRef = db.doc(`households/${hid}`);
    const [user, household] = await Promise.all([tx.get(userRef), tx.get(householdRef)]);
    if (user.exists && user.get("householdId")) {
      throw new HttpsError("failed-precondition", "Użytkownik należy już do domu");
    }
    if (household.exists) {
      throw new HttpsError("already-exists", "Dom o tym identyfikatorze już istnieje");
    }
    tx.set(householdRef, {
      name,
      currency: "PLN",
      timezone: "Europe/Warsaw",
      weekStartsOn: 1,
      createdBy: uid,
      createdAt: FieldValue.serverTimestamp(),
    });
    tx.set(db.doc(`households/${hid}/members/${uid}`), {
      role: "admin",
      displayName,
      joinedAt: FieldValue.serverTimestamp(),
    });
    tx.set(userRef, { displayName, householdId: hid }, { merge: true });
  });
  return { householdId: hid };
}

export interface CreateInviteInput {
  householdId: unknown;
  multiUse?: unknown;
}

export async function createInvite(
  db: Firestore,
  uid: string,
  input: CreateInviteInput,
  now: Date = new Date(),
) {
  const hid = requireUuid(input.householdId, "householdId");
  await requireAdmin(db, hid, uid);

  for (let attempt = 0; attempt < 5; attempt++) {
    const code = generateInviteCode();
    const taken = await db.collectionGroup("invites").where("code", "==", code).limit(1).get();
    if (!taken.empty) continue;

    const qrToken = randomBytes(24).toString("hex");
    const expiresAt = Timestamp.fromMillis(now.getTime() + INVITE_TTL_MS);
    await db.doc(`households/${hid}/invites/${code}`).create({
      code,
      qrToken,
      expiresAt,
      multiUse: input.multiUse === true,
      createdBy: uid,
      usedBy: [],
      revoked: false,
    });
    return { code, qrToken, expiresAt: expiresAt.toMillis() };
  }
  throw new HttpsError("resource-exhausted", "Nie udało się wygenerować kodu, spróbuj ponownie");
}

export async function revokeInvite(
  db: Firestore,
  uid: string,
  input: { householdId: unknown; code: unknown },
) {
  const hid = requireUuid(input.householdId, "householdId");
  const code = requireString(input.code, "code", 12).toUpperCase();
  await requireAdmin(db, hid, uid);
  const ref = db.doc(`households/${hid}/invites/${code}`);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Nie ma takiego zaproszenia");
  await ref.update({ revoked: true });
  return {};
}

export async function redeemInvite(
  db: Firestore,
  uid: string,
  input: { code?: unknown; qrToken?: unknown; displayName: unknown },
  now: Date = new Date(),
) {
  const displayName = requireString(input.displayName, "displayName");
  let query;
  if (typeof input.qrToken === "string" && input.qrToken.length > 0) {
    query = db.collectionGroup("invites").where("qrToken", "==", input.qrToken);
  } else {
    const code = requireString(input.code, "code", 12).toUpperCase();
    query = db.collectionGroup("invites").where("code", "==", code);
  }
  const found = await query.limit(1).get();
  if (found.empty) throw new HttpsError("not-found", "Nieprawidłowy kod zaproszenia");
  const inviteRef = found.docs[0].ref;
  const hid = inviteRef.parent.parent!.id;

  await db.runTransaction(async (tx) => {
    const userRef = db.doc(`users/${uid}`);
    const memberRef = db.doc(`households/${hid}/members/${uid}`);
    const [invite, user] = await Promise.all([tx.get(inviteRef), tx.get(userRef)]);
    if (!invite.exists) throw new HttpsError("not-found", "Nieprawidłowy kod zaproszenia");
    if (invite.get("revoked") === true) {
      throw new HttpsError("failed-precondition", "Zaproszenie zostało unieważnione");
    }
    if ((invite.get("expiresAt") as Timestamp).toMillis() <= now.getTime()) {
      throw new HttpsError("failed-precondition", "Zaproszenie wygasło");
    }
    const usedBy: string[] = invite.get("usedBy") ?? [];
    if (invite.get("multiUse") !== true && usedBy.length > 0) {
      throw new HttpsError("failed-precondition", "Zaproszenie zostało już wykorzystane");
    }
    if (user.exists && user.get("householdId")) {
      throw new HttpsError("failed-precondition", "Użytkownik należy już do domu");
    }
    tx.set(memberRef, {
      role: "member",
      displayName,
      joinedAt: FieldValue.serverTimestamp(),
    });
    tx.update(inviteRef, { usedBy: FieldValue.arrayUnion(uid) });
    tx.set(userRef, { displayName, householdId: hid }, { merge: true });
  });
  return { householdId: hid };
}

export async function setMemberRole(
  db: Firestore,
  uid: string,
  input: { householdId: unknown; targetUid: unknown; role: unknown },
) {
  const hid = requireUuid(input.householdId, "householdId");
  const targetUid = requireString(input.targetUid, "targetUid", 128);
  if (input.role !== "admin" && input.role !== "member") {
    throw new HttpsError("invalid-argument", "Nieprawidłowa rola");
  }
  const role = input.role as Role;
  await requireAdmin(db, hid, uid);

  await db.runTransaction(async (tx) => {
    const targetRef = db.doc(`households/${hid}/members/${targetUid}`);
    const target = await tx.get(targetRef);
    if (!target.exists) throw new HttpsError("not-found", "Nie ma takiego domownika");
    if (target.get("role") === "admin" && role === "member") {
      const admins = await tx.get(
        db.collection(`households/${hid}/members`).where("role", "==", "admin"),
      );
      if (admins.size <= 1) {
        throw new HttpsError("failed-precondition", "Dom musi mieć co najmniej jednego administratora");
      }
    }
    tx.update(targetRef, { role });
  });
  return {};
}

export async function removeMember(
  db: Firestore,
  uid: string,
  input: { householdId: unknown; targetUid: unknown },
) {
  const hid = requireUuid(input.householdId, "householdId");
  const targetUid = requireString(input.targetUid, "targetUid", 128);
  await requireAdmin(db, hid, uid);

  await db.runTransaction(async (tx) => {
    const targetRef = db.doc(`households/${hid}/members/${targetUid}`);
    const target = await tx.get(targetRef);
    if (!target.exists) throw new HttpsError("not-found", "Nie ma takiego domownika");
    if (target.get("role") === "admin") {
      const admins = await tx.get(
        db.collection(`households/${hid}/members`).where("role", "==", "admin"),
      );
      if (admins.size <= 1) {
        throw new HttpsError("failed-precondition", "Nie można usunąć ostatniego administratora");
      }
    }
    tx.delete(targetRef);
    tx.set(db.doc(`users/${targetUid}`), { householdId: FieldValue.delete() }, { merge: true });
  });
  return {};
}

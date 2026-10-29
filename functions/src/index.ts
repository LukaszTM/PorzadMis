import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";
import * as h from "./households";

initializeApp();

const options = { region: "europe-west1" };

function authUid(request: CallableRequest): string {
  if (!request.auth) throw new HttpsError("unauthenticated", "Wymagane logowanie");
  return request.auth.uid;
}

export const createHousehold = onCall(options, (r) =>
  h.createHousehold(getFirestore(), authUid(r), r.data),
);
export const createInvite = onCall(options, (r) =>
  h.createInvite(getFirestore(), authUid(r), r.data),
);
export const revokeInvite = onCall(options, (r) =>
  h.revokeInvite(getFirestore(), authUid(r), r.data),
);
export const redeemInvite = onCall(options, (r) =>
  h.redeemInvite(getFirestore(), authUid(r), r.data),
);
export const setMemberRole = onCall(options, (r) =>
  h.setMemberRole(getFirestore(), authUid(r), r.data),
);
export const removeMember = onCall(options, (r) =>
  h.removeMember(getFirestore(), authUid(r), r.data),
);

import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";
import * as h from "./households";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { ChoreRule, regenerateAll, regenerateRule, todayInZone } from "./chores";

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
export const leaveHousehold = onCall(options, (r) =>
  h.leaveHousehold(getFirestore(), authUid(r), r.data),
);

// Obowiązki: wystąpienia generuje serwer (etap 4).
export const onChoreRuleWritten = onDocumentWritten(
  { ...options, document: "households/{hid}/choreRules/{ruleId}" },
  async (event) => {
    const { hid, ruleId } = event.params;
    const after = event.data?.after;
    const rule = after?.exists ? (after.data() as ChoreRule) : null;
    const house = await getFirestore().doc(`households/${hid}`).get();
    const tz = (house.get("timezone") as string | undefined) ?? "Europe/Warsaw";
    await regenerateRule(getFirestore(), hid, ruleId, rule, todayInZone(tz));
  },
);

export const dailyChoreRollover = onSchedule(
  { ...options, schedule: "5 0 * * *", timeZone: "Europe/Warsaw" },
  async () => {
    await regenerateAll(getFirestore());
  },
);

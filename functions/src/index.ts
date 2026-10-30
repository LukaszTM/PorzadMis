import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { CallableRequest, HttpsError, onCall } from "firebase-functions/v2/https";
import * as h from "./households";
import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import * as n from "./notifications";
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

// Powiadomienia push (etap 6). Przypomnienia o terminach planuje telefon lokalnie.
export const onChoreRuleAssigned = onDocumentWritten(
  { ...options, document: "households/{hid}/choreRules/{ruleId}" },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const before = event.data?.before;
    const assignee = after.get("assigneeId") as string | null;
    const previous = before?.exists ? (before.get("assigneeId") as string | null) : null;
    if (!assignee || assignee === previous) return;
    const db = getFirestore();
    const by = await n.displayName(db, event.params.hid, after.get("createdBy") as string);
    await n.sendToUsers(db, [assignee], "chores", n.messages.choreAssigned(after.get("title") as string, by));
  },
);

export const onMemberJoined = onDocumentCreated(
  { ...options, document: "households/{hid}/members/{uid}" },
  async (event) => {
    const db = getFirestore();
    const { hid, uid } = event.params;
    const others = (await n.memberUids(db, hid)).filter((u) => u !== uid);
    const name = (event.data?.get("displayName") as string | undefined) ?? "";
    await n.sendToUsers(db, others, "members", n.messages.memberJoined(name));
  },
);

export const onShoppingItemAdded = onDocumentCreated(
  { ...options, document: "households/{hid}/shoppingLists/{listId}/items/{itemId}" },
  async (event) => {
    const db = getFirestore();
    const { hid } = event.params;
    const addedBy = event.data?.get("addedBy") as string | undefined;
    const others = (await n.memberUids(db, hid)).filter((u) => u !== addedBy);
    const by = await n.displayName(db, hid, addedBy);
    await n.sendToUsers(db, others, "shopping", n.messages.shoppingAdded(event.data?.get("name") as string, by));
  },
);

export const onExpenseWritten = onDocumentWritten(
  { ...options, document: "households/{hid}/expenses/{id}" },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;
    const db = getFirestore();
    const { hid } = event.params;
    const month = after.get("month") as string;
    const planRef = db.doc(`households/${hid}/budgetPlans/${month}`);
    const plan = await planRef.get();
    if (!plan.exists || plan.get("alerted100") === true) return;
    const limits = (plan.get("limits") as Record<string, number> | undefined) ?? {};
    const planTotal = (plan.get("total") as number) || Object.values(limits).reduce((a, b) => a + b, 0);
    if (planTotal <= 0) return;
    const expenses = await db.collection(`households/${hid}/expenses`).where("month", "==", month).get();
    const total = expenses.docs.reduce((a, d) => a + ((d.get("amount") as number) || 0), 0);
    const added = (after.get("amount") as number) || 0;
    if (!n.crossedPlan(total - added, total, planTotal)) return;
    await planRef.update({ alerted100: true });
    const admins = await n.adminUids(db, hid);
    await n.sendToUsers(db, admins, "budget", n.messages.budgetExceeded(month, n.formatPln(total), n.formatPln(planTotal)));
  },
);

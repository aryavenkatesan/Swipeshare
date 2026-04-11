import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

export const reportUser = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
  }

  const reporterId = request.auth.uid;
  const { orderId, reason } = request.data;

  if (!orderId || !reason) {
    throw new functions.https.HttpsError("invalid-argument", "orderId and reason are required.");
  }

  // Fetch the order to identify the other participant
  const orderDoc = await admin.firestore().collection("orders").doc(orderId).get();
  if (!orderDoc.exists) {
    throw new functions.https.HttpsError("not-found", "Order not found.");
  }

  const order = orderDoc.data()!;
  const buyerId: string = order.buyer.id;
  const sellerId: string = order.seller.id;

  // Verify the caller is a participant
  if (reporterId !== buyerId && reporterId !== sellerId) {
    throw new functions.https.HttpsError("permission-denied", "You are not a participant in this order.");
  }

  const reportedId = reporterId === buyerId ? sellerId : buyerId;

  // Resolve emails via Admin SDK — no client read of users collection needed
  const [reporterRecord, reportedRecord] = await Promise.all([
    admin.auth().getUser(reporterId),
    admin.auth().getUser(reportedId),
  ]);

  await admin.firestore().collection("reports").add({
    reporterId,
    reporterEmail: reporterRecord.email ?? "",
    reportedId,
    reportedEmail: reportedRecord.email ?? "",
    reason,
    timestamp: FieldValue.serverTimestamp(),
  });

  return { success: true };
});

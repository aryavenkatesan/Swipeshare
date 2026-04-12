import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/https";
import * as functions from "firebase-functions/v2";
import { listingStatus, userStatus } from "../types";

const DELETED_NAME = "Deleted User";
const DELETED_EMAIL = "deleted@deleted.com";

export const deleteAccount = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Must be signed in.");
  }

  const uid = request.auth.uid;
  const db = admin.firestore();

  // 1. Anonymize listings — cancel active ones, scrub seller name from all
  const listingsSnapshot = await db
    .collection("listings")
    .where("sellerId", "==", uid)
    .get();

  if (!listingsSnapshot.empty) {
    const batch = db.batch();
    for (const doc of listingsSnapshot.docs) {
      const isActive = doc.data().status == listingStatus.active;
      batch.update(doc.ref, {
        sellerName: DELETED_NAME,
        ...(isActive && { status: listingStatus.cancelled }),
      });
    }
    await batch.commit();
  }

  // 2. Anonymize orders as seller and messages sent by the user in those orders
  const ordersAsSeller = await db
    .collection("orders")
    .where("seller.id", "==", uid)
    .get();

  for (const orderDoc of ordersAsSeller.docs) {
    const messagesSnapshot = await orderDoc.ref
      .collection("messages")
      .where("senderId", "==", uid)
      .get();

    if (!messagesSnapshot.empty) {
      const batch = db.batch();
      for (const msgDoc of messagesSnapshot.docs) {
        batch.update(msgDoc.ref, {
          senderName: DELETED_NAME,
          senderEmail: DELETED_EMAIL,
        });
      }
      await batch.commit();
    }

    await orderDoc.ref.update({ "seller.name": DELETED_NAME });
  }

  // 3. Anonymize orders as buyer and messages sent by the user in those orders
  const ordersAsBuyer = await db
    .collection("orders")
    .where("buyer.id", "==", uid)
    .get();

  for (const orderDoc of ordersAsBuyer.docs) {
    const messagesSnapshot = await orderDoc.ref
      .collection("messages")
      .where("senderId", "==", uid)
      .get();

    if (!messagesSnapshot.empty) {
      const batch = db.batch();
      for (const msgDoc of messagesSnapshot.docs) {
        batch.update(msgDoc.ref, {
          senderName: DELETED_NAME,
          senderEmail: DELETED_EMAIL,
        });
      }
      await batch.commit();
    }

    await orderDoc.ref.update({ "buyer.name": DELETED_NAME });
  }

  // 4. Scrub reporter email from reports filed by this user
  const reportsAsReporter = await db
    .collection("reports")
    .where("reporterId", "==", uid)
    .get();

  if (!reportsAsReporter.empty) {
    const batch = db.batch();
    for (const doc of reportsAsReporter.docs) {
      batch.update(doc.ref, { reporterEmail: DELETED_EMAIL });
    }
    await batch.commit();
  }

  // 5. Scrub reported email from reports filed against this user
  const reportsAsReported = await db
    .collection("reports")
    .where("reportedId", "==", uid)
    .get();

  if (!reportsAsReported.empty) {
    const batch = db.batch();
    for (const doc of reportsAsReported.docs) {
      batch.update(doc.ref, { reportedEmail: DELETED_EMAIL });
    }
    await batch.commit();
  }

  // 6. Scrub email from feedback submitted by this user
  const feedbackSnapshot = await db
    .collection("feedback")
    .where("userId", "==", uid)
    .get();

  if (!feedbackSnapshot.empty) {
    const batch = db.batch();
    for (const doc of feedbackSnapshot.docs) {
      batch.update(doc.ref, { userEmail: DELETED_EMAIL });
    }
    await batch.commit();
  }

  // 7. Archive the user document — zero out PII, mark as deleted
  await db.collection("users").doc(uid).update({
    status: userStatus.deleted,
    name: DELETED_NAME,
    email: DELETED_EMAIL,
    referral_email: "",
    verificationCode: null,
    payment_types: [],
    blocked_users: [],
  });

  // 8. Delete the Firebase Auth record — must be last
  await admin.auth().deleteUser(uid);

  console.log(`Account ${uid} successfully deleted and anonymized.`);
  return { success: true };
});

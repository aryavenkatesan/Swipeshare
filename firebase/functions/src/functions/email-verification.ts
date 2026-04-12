import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { createUser } from "../services/user-service";

export const createUserDocument = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
  }

  const uid = request.auth.uid;
  const email = request.auth.token.email;
  const { name, referralEmail } = request.data;

  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "User has no email.");
  }
  if (!name || typeof name !== "string" || name.trim() === "") {
    throw new functions.https.HttpsError("invalid-argument", "Name is required.");
  }

  try {
    await createUser(uid, email, name.trim(), referralEmail ?? "");
  } catch (e) {
    throw new functions.https.HttpsError("already-exists", "User document already exists.");
  }

  return { success: true };
});

export const sendVerificationCode = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
  }

  const uid = request.auth.uid;
  const email = request.auth.token.email;

  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "User has no email.");
  }

  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const expires = Timestamp.fromDate(
    new Date(Date.now() + 10 * 60 * 60 * 1000) // 10 hours
  );

  try {
    await admin.firestore().collection("users").doc(uid).update({
      verificationCode: code,
      verificationCodeExpires: expires,
    });

    await admin.firestore().collection("mail").add({
      to: [email],
      template: {
        name: "verification",
        data: { code },
      },
    });

    return { success: true };
  } catch (error) {
    console.error("Error sending verification code:", error);
    throw new functions.https.HttpsError("internal", "Failed to send verification code.");
  }
});

export const verifyEmailCode = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new functions.https.HttpsError("unauthenticated", "Must be signed in.");
  }

  const uid = request.auth.uid;
  const { code } = request.data;

  if (!code) {
    throw new functions.https.HttpsError("invalid-argument", "Code is required.");
  }

  const docRef = admin.firestore().collection("users").doc(uid);
  const doc = await docRef.get();

  if (!doc.exists || !doc.data()) {
    throw new functions.https.HttpsError("not-found", "User data not found.");
  }

  const data = doc.data()!;
  const storedCode: string | undefined = data["verificationCode"];
  const expires: Timestamp | undefined = data["verificationCodeExpires"];

  if (!storedCode || !expires) {
    throw new functions.https.HttpsError("failed-precondition", "No verification code found. Please resend.");
  }

  if (expires.toMillis() < Date.now()) {
    throw new functions.https.HttpsError("deadline-exceeded", "Verification code has expired. Please resend.");
  }

  if (storedCode !== code) {
    throw new functions.https.HttpsError("permission-denied", "Invalid verification code.");
  }

  await docRef.update({
    isEmailVerified: true,
    verificationCode: FieldValue.delete(),
    verificationCodeExpires: FieldValue.delete(),
  });

  return { success: true };
});

import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as crypto from "crypto";



export const requestPasswordReset = functions.https.onCall(async (request) => {
  const email = request.data.email;

  if (!email) {
    throw new functions.https.HttpsError('invalid-argument', 'Email required.');
  }

  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const expires = admin.firestore.Timestamp.fromDate(new Date(Date.now() + 12 * 60 * 60 * 1000));
  //expires after 12 hours, we could change this

  try {
    await admin.firestore().collection('password_resets').doc(email).set({
      code,
      expires,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await admin.firestore().collection('mail').add({
      to: [email],
      template: {
        name: 'verification',
        data: { code },
      },
    });

    return { success: true };
  } catch (error) {
    console.error("Mail error:", error);
    throw new functions.https.HttpsError('internal', 'Failed to send reset email.');
  }
});

export const verifyResetCode = onCall(async (request) => {
  const { email, code } = request.data;

  const docRef = admin.firestore().collection('password_resets').doc(email);
  const doc = await docRef.get();

  if (!doc.exists) throw new HttpsError('not-found', 'No reset request found.');

  const resetData = doc.data()!;

  // 1. Check expiration and code match
  if (resetData.expires.toMillis() < admin.firestore.Timestamp.now().toMillis()) {
    throw new HttpsError('deadline-exceeded', 'The code has expired.');
  }

  if (resetData.code !== code) {
    throw new HttpsError('permission-denied', 'Invalid code.');
  }

  // 2. Generate a secure, random token
  const verifiedToken = crypto.randomBytes(32).toString('hex');

  // 3. Mark as verified and store the token
  await docRef.update({
    isVerified: true,
    verifiedToken: verifiedToken,
    // Short 5-minute window to complete the password change
    tokenExpires: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 5 * 60000))
  });

  return { success: true, token: verifiedToken };
});

export const updateUserPassword = onCall(async (request) => {
  // Add this log to see what Flutter is actually sending
  console.log("Received Data:", JSON.stringify(request.data));

  const { email, newPassword, token } = request.data;

  if (!email || !newPassword || !token) {
    // This log helps you see which one is undefined
    console.error(`Missing Fields - Email: ${!!email}, Pwd: ${!!newPassword}, Token: ${!!token}`);
    throw new HttpsError("invalid-argument", "Missing required fields.");
  }

  try {
    const resetRef = admin.firestore().collection("password_resets").doc(email);
    const resetDoc = await resetRef.get();

    // 1. Security Check: Validate the token
    if (!resetDoc.exists) throw new HttpsError("permission-denied", "Unauthorized.");

    const resetData = resetDoc.data()!;
    if (!resetData.isVerified || resetData.verifiedToken !== token) {
      throw new HttpsError("permission-denied", "Invalid or missing verification token.");
    }

    if (resetData.tokenExpires.toMillis() < admin.firestore.Timestamp.now().toMillis()) {
      throw new HttpsError("deadline-exceeded", "Verification session expired.");
    }

    // 2. Proceed with UID lookup using your schema
    const userQuery = await admin.firestore()
      .collection("users")
      .where("email", "==", email)
      .limit(1)
      .get();

    if (userQuery.empty) throw new HttpsError("not-found", "User not found.");
    const uid = userQuery.docs[0].data().uid;

    // 3. Perform the update
    await admin.auth().updateUser(uid, { password: newPassword });

    // 4. Clean up the reset document immediately
    await resetRef.delete();

    return { success: true };
  } catch (error) {
    console.error("Update Error:", error);
    throw new HttpsError("internal", "Update failed.");
  }
});
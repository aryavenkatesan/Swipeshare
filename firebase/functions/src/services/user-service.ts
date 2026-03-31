import * as admin from "firebase-admin";
import { DocumentData, Firestore, Transaction, UpdateData, WriteResult } from "firebase-admin/firestore";
import { FirestoreWriter, Rating, User } from "../types";

export const getUser = async (
  userId: string,
  transaction?: Transaction,
): Promise<User | null> => {
  const userDoc = admin.firestore().collection("users").doc(userId);
  const userSnapshot = transaction
    ? await transaction.get(userDoc)
    : await userDoc.get();
  const userData = userSnapshot.data() as User | undefined;

  if (!userSnapshot.exists || !userData) {
    console.log(`User ${userId} does not exist.`);
    return null;
  }

  return userData as User;
};

export const getUserWithFcm = async (
  userId: string,
  transaction?: Transaction,
): Promise<(User & { fcmToken: string }) | null> => {
  const userData = await getUser(userId, transaction);
  if (!userData) {
    return null;
  }

  if (userData.fcmToken == null) {
    console.log(`User ${userId} does not have an FCM token.`);
    return null;
  }

  return userData as User & { fcmToken: string };
};

export const updateUserStars = async (
  db: Firestore,
  orderId: string,
  userIdToRate: string,
  rating: Rating,
  raterRole: "buyer" | "seller",
): Promise<void> => {
  try {
    const userData = await getUser(userIdToRate);

    if (!userData) {
      console.error(`User ${userIdToRate} not found for rating update.`);
      return;
    }

    const currentStars = userData.stars ?? 5;
    const transactionsCompleted = userData.transactions_completed ?? 0;

    const newStarRating = calculateNewStarRating(
      currentStars,
      transactionsCompleted,
      rating.stars,
    );

    await db.collection("users").doc(userIdToRate).update({
      stars: newStarRating,
    });

    console.log(
      `${raterRole} rated user ${userIdToRate} with ${rating.stars} stars. ` +
        `New rating: ${newStarRating} (order: ${orderId})`,
    );
  } catch (error) {
    console.error(`Error updating stars for user ${userIdToRate}:`, error);
    throw error;
  }
};

export const patchUser = (
  userId: string,
  patch: UpdateData<User>,
  writer?: FirestoreWriter,
): Promise<WriteResult> | void => {
  const userDoc = admin.firestore().collection("users").doc(userId);
  const data = patch as UpdateData<DocumentData>;
  if (writer) {
    writer.update(userDoc, data);
  } else {
    return userDoc.update(data);
  }
};

export const calculateNewStarRating = (
  currentStars: number,
  transactionsCompleted: number,
  newRating: number,
): number => {
  return (
    (transactionsCompleted * currentStars + newRating) /
    (transactionsCompleted + 1)
  );
};

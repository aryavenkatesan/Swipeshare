import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import { Listing, Order, User } from "../types";

/**
 * Retrieves a user document from Firestore with full logging, returning null if not found.
 */
export const getUser = async (
  userId: string,
  transaction?: FirebaseFirestore.Transaction,
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

/**
 * Retrieves a user document from Firestore with full logging,
 * returning null if not found or missing fcm token.
 */
export const getUserWithFcm = async (
  userId: string,
  transaction?: FirebaseFirestore.Transaction,
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

export const getListing = async (
  listingId: string,
  transaction?: FirebaseFirestore.Transaction,
): Promise<Listing | null> => {
  const listingDoc = admin.firestore().collection("listings").doc(listingId);
  const listingSnapshot = transaction
    ? await transaction.get(listingDoc)
    : await listingDoc.get();
  const listingData = listingSnapshot.data() as Listing | undefined;

  if (!listingSnapshot.exists || !listingData) {
    console.log(`Listing ${listingId} does not exist.`);
    return null;
  }

  return listingData;
};

/**
 * Retrieves an order document from Firestore with full logging, returning null if not found.
 */
export const getOrder = async (
  orderId: string,
  transaction?: FirebaseFirestore.Transaction,
): Promise<Order | null> => {
  const orderSnapshot = transaction
    ? await transaction.get(admin.firestore().collection("orders").doc(orderId))
    : await admin.firestore().collection("orders").doc(orderId).get();
  const orderData = orderSnapshot.data() as Order | undefined;

  if (!orderSnapshot.exists || !orderData) {
    console.log(`Order ${orderId} does not exist.`);
    return null;
  }

  return orderData;
};

/**
 * Generates the room name for an order chat.
 * Format: {sellerId}_{buyerId}_{transactionDate}
 * This matches the getRoomName() method in meal_order.dart
 */
export const getOrderRoomName = ({
  sellerId,
  buyerId,
  transactionDate,
}: {
  sellerId: string;
  buyerId: string;
  transactionDate: Timestamp;
}): string => {
  return `${sellerId}_${buyerId}_${transactionDate.toMillis()}`;
};

/**
 * Validates that an order exists and that the caller is a participant.
 * Throws appropriate HttpsErrors if validation fails.
 * Returns the order data if successful.
 */
export const validateOrderParticipant = async (
  orderId: string,
  callerUid: string
): Promise<Order> => {
  // Import functions here to avoid circular dependency
  const functions = await import("firebase-functions/v2");
  
  // Fetch the order
  const orderData = await getOrder(orderId);

  // Verify the order exists
  if (!orderData) {
    throw new functions.https.HttpsError(
      "not-found",
      `Order with ID ${orderId} does not exist.`
    );
  }

  // Verify the caller is either the buyer or seller in this order
  const isCallerParticipant =
    callerUid === orderData.buyerId || callerUid === orderData.sellerId;

  if (!isCallerParticipant) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "You are not a participant in this order."
    );
  }

  return orderData;
};

import * as admin from "firebase-admin";
import { Order, User } from "./types";

/**
 * Takes a time of day string like "TimeOfDay(14:30)" and converts it to a more
 * human-readable format like "2:30 PM".
 */
function timeOfDayStringToTime(timeOfDay: string) {
  const timeMatch = timeOfDay.match(/TimeOfDay\((\d{1,2}):(\d{2})\)/);
  if (!timeMatch) {
    return "";
  }
  let hours = parseInt(timeMatch[1], 10);
  const minutes = parseInt(timeMatch[2], 10);
  const period = hours >= 12 ? "PM" : "AM";
  hours = hours % 12;
  if (hours === 0) {
    hours = 12;
  }
  const minutesStr =
    minutes > 0 ? `:${minutes.toString().padStart(2, "0")}` : "";
  return `${hours}${minutesStr} ${period}`;
}

/**
 * Retrieves a user document from Firestore with full logging, returning null if not found.
 */
const getUser = async (
  userId: string
): Promise<(User & { fcmToken: string }) | null> => {
  const userDoc = await admin.firestore().collection("users").doc(userId).get();
  const userData = userDoc.data() as User | undefined;

  if (!userDoc.exists || !userData) {
    console.log(`User ${userId} does not exist.`);
    return null;
  }

  if (userData.fcmToken == null) {
    console.log(`User ${userId} does not have an FCM token.`);
    return null;
  }

  return userData as User & { fcmToken: string };
};

/**
 * Retrieves an order document from Firestore with full logging, returning null if not found.
 */
const getOrder = async (orderId: string): Promise<Order | null> => {
  const orderDoc = await admin
    .firestore()
    .collection("orders")
    .doc(orderId)
    .get();
  const orderData = orderDoc.data() as Order | undefined;

  if (!orderDoc.exists || !orderData) {
    console.log(`Order ${orderId} does not exist.`);
    return null;
  }

  return orderData;
};

/** Sets `sellerHasNotifs` or `buyerHasNotifs` to true for the given order and notification recipient */
const updateNotificationsStatus = async (
  orderId: string,
  recipientId: string
): Promise<void> => {
  const orderData = await getOrder(orderId);
  if (!orderData) {
    return;
  }

  const updateField =
    recipientId === orderData.sellerId ? "sellerHasNotifs" : "buyerHasNotifs";
  await admin
    .firestore()
    .collection("orders")
    .doc(orderId)
    .update({
      [updateField]: true,
    });
};

/** Prepares the payload for a notification message, including unread counts */
const payloadWithNotifs = async (
  userId: string,
  message: admin.messaging.Message
): Promise<admin.messaging.Message> => {
  const buyerOrders = admin
    .firestore()
    .collection("orders")
    .where("buyerId", "==", userId)
    .where("buyerHasNotifs", "==", true);

  const sellerOrders = admin
    .firestore()
    .collection("orders")
    .where("sellerId", "==", userId)
    .where("sellerHasNotifs", "==", true);

  const [userOrdersAsBuyer, userOrdersAsSeller] = await Promise.all([
    buyerOrders.get(),
    sellerOrders.get(),
  ]);

  const totalUnread = userOrdersAsBuyer.size + userOrdersAsSeller.size;

  return {
    apns: {
      payload: {
        aps: {
          badge: totalUnread,
        },
      },
    },
    android: {
      notification: {
        channelId: "default",
      },
    },
    ...message,
  };
};

export {
  getOrder,
  getUser,
  payloadWithNotifs,
  timeOfDayStringToTime,
  updateNotificationsStatus,
};

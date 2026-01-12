import * as admin from "firebase-admin";
import { getOrder } from "./firestore";
/** Sets `sellerHasNotifs` or `buyerHasNotifs` to true for the given order and notification recipient */
export const updateNotificationsStatus = async (
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
export const payloadWithNotifs = async (
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

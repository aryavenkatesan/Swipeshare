import * as admin from "firebase-admin";
import { getOrder, patchOrder } from "../services/order-service";
/** Sets `seller.hasNotifs` or `buyer.hasNotifs` to true for the given order and notification recipient */
export const updateNotificationsStatus = async (
  orderId: string,
  recipientId: string,
): Promise<void> => {
  const orderData = await getOrder(orderId);
  if (!orderData) {
    return;
  }

  if (orderData.status == "cancelled") {
    console.log(
      `Order ${orderId} is cancelled; not updating notification status.`,
    );
    return;
  }

  const updateField =
    recipientId === orderData.seller.id
      ? "seller.hasNotifs"
      : "buyer.hasNotifs";
  await patchOrder(orderId, { [updateField]: true });
};

/** Prepares the payload for a notification message, including unread counts */
export const payloadWithNotifs = async (
  userId: string,
  message: admin.messaging.Message,
): Promise<admin.messaging.Message> => {
  const buyerOrders = admin
    .firestore()
    .collection("orders")
    .where("status", "==", "active")
    .where("buyer.id", "==", userId)
    .where("buyer.hasNotifs", "==", true);

  const sellerOrders = admin
    .firestore()
    .collection("orders")
    .where("status", "==", "active")
    .where("seller.id", "==", userId)
    .where("seller.hasNotifs", "==", true);

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

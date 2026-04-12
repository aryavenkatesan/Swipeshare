import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { getOrder } from "../services/order-service";
import { getUserWithFcm } from "../services/user-service";
import { Message, messageTypes, Order, orderStatus } from "../types";
import {
  payloadWithNotifs,
  updateNotificationsStatus,
} from "../utils/notifications";
import { timeOfDayStringToTime } from "../utils/time";

export const notificationType = {
  newMessage: "new_message",
  newOrder: "new_order",
  timeProposalUpdate: "time_proposal_update",
  orderConfirmation: "order_confirmation",
  orderCancellation: "order_cancellation",
} as const;

export type NotificationType =
  (typeof notificationType)[keyof typeof notificationType];

export const sendMessageNotification = functions.firestore.onDocumentCreated(
  "orders/{orderId}/messages/{messageId}",
  async (event) => {
    const { orderId, messageId } = event.params;
    const message = event.data?.data() as Message | undefined;

    if (!message) {
      console.log("No message data found.");
      return;
    }

    try {
      const orderData = await getOrder(orderId);
      if (!orderData) {
        return;
      }

      if (!messageTypes.includes(message.messageType)) {
        console.log(
          `Unknown message type: ${message.messageType}. No notification sent.`,
        );
        return;
      }

      if (message.messageType === "system") {
        console.log("System message. No notification sent.");
        return;
      }

      const recipientId =
        orderData.buyer.id === message.senderId
          ? orderData.seller.id
          : orderData.buyer.id;

      const recipientData = await getUserWithFcm(recipientId);
      if (!recipientData) {
        return;
      }

      if (recipientData.notifSettings?.newMessages === false) {
        console.log(
          `User ${recipientId} has disabled new message notifications. No notification sent.`,
        );
        return;
      }

      const title = message.senderName;

      const body =
        message.messageType === "text"
          ? (message.content ?? "")
          : `Proposed a time: ${timeOfDayStringToTime(message.proposedTime ?? "")}`;

      await updateNotificationsStatus(orderId, recipientId);

      const payload = await payloadWithNotifs(recipientId, {
        notification: {
          title,
          body,
        },
        data: {
          orderId,
          messageId,
          senderId: message.senderId,
          senderName: message.senderName,
          type: notificationType.newMessage,
        },
        token: recipientData.fcmToken,
      });

      const response = await admin.messaging().send(payload);
      console.log(`Notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  },
);

export const sendNewOrderNotification = functions.firestore.onDocumentCreated(
  "orders/{orderId}",
  async (event) => {
    const { orderId } = event.params;
    const orderData = event.data?.data() as Order | undefined;

    if (orderData == null) {
      console.log("No order data found.");
      return;
    }

    try {
      const sellerData = await getUserWithFcm(orderData.seller.id);
      if (!sellerData) {
        return;
      }

      if (sellerData.notifSettings?.newOrders === false) {
        console.log(
          `User ${orderData.seller.id} has disabled new order notifications. No notification sent.`,
        );
        return;
      }

      const readableDate = new Date(
        orderData.transactionDate.toDate(),
      ).toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
      });

      await updateNotificationsStatus(orderId, orderData.seller.id);

      const payload = await payloadWithNotifs(orderData.seller.id, {
        notification: {
          title: "You have a new buyer!",
          body: `For ${readableDate} — tap to coordinate a time`,
        },
        data: {
          orderId,
          buyerId: orderData.buyer.id,
          buyerName: orderData.buyer.name,
          type: notificationType.newOrder,
        },
        token: sellerData.fcmToken,
      });

      const response = await admin.messaging().send(payload);
      console.log(`Notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  },
);

export const sendProposalUpdateNotification =
  functions.firestore.onDocumentUpdated(
    "orders/{orderId}/messages/{messageId}",
    async (event) => {
      const { orderId } = event.params;
      const beforeData = event.data?.before.data() as Message | undefined;
      const afterData = event.data?.after.data() as Message | undefined;

      if (!beforeData || !afterData) {
        console.log("Before or after data is missing.");
        return;
      }

      if (
        beforeData.messageType !== "timeProposal" ||
        afterData.messageType !== "timeProposal"
      ) {
        console.log("Message is not a time proposal.");
        return;
      }

      if (beforeData.status === afterData.status) {
        console.log("Message is not a time proposal or status did not change");
        return;
      }

      if (!afterData.status) {
        console.log("No status field in the updated message.");
        return;
      }

      try {
        const orderData = await getOrder(orderId);
        if (!orderData) {
          return;
        }

        const senderId = afterData.senderId;
        const senderData = await getUserWithFcm(afterData.senderId);
        if (!senderData) {
          return;
        }

        if (senderData.notifSettings?.newMessages === false) {
          console.log(
            `User ${senderId} has disabled new message notifications. No notification sent.`,
          );
          return;
        }

        const receiverName =
          senderId === orderData.buyer.id
            ? orderData.seller.name
            : orderData.seller.id === senderId
              ? orderData.buyer.name
              : "Someone";

        const proposalTime = timeOfDayStringToTime(
          afterData.proposedTime ?? "",
        );

        await updateNotificationsStatus(orderId, senderId);

        const payload = await payloadWithNotifs(senderId, {
          notification: {
            title: `${receiverName} ${afterData.status} your proposal`,
            body: `Meeting at ${proposalTime}`,
          },
          data: {
            orderId,
            type: notificationType.timeProposalUpdate,
          },
          token: senderData.fcmToken,
        });

        const response = await admin.messaging().send(payload);
        console.log(`Notification sent successfully: ${response}`);
      } catch (error) {
        console.error("Error sending notification:", error);
        throw error;
      }
    },
  );

/**
 * Sends a push notification to the other party when one user marks an order as complete.
 * Does not fire when both have confirmed (the completion trigger handles that case).
 */
export const sendMarkCompleteNotification =
  functions.firestore.onDocumentUpdated("orders/{orderId}", async (event) => {
    const { orderId } = event.params;
    const before = event.data?.before.data() as Order | undefined;
    const after = event.data?.after.data() as Order | undefined;

    if (!before || !after) {
      console.log(
        `Mark-complete notification skipped for order ${orderId}: before or after data is missing.`,
      );
      return;
    }

    // Only act on active orders
    if (after.status !== orderStatus.active) {
      console.log(
        `Mark-complete notification skipped for order ${orderId}: order status is ${after.status}.`,
      );
      return;
    }

    const sellerFlipped =
      !before.seller.markedComplete && after.seller.markedComplete;
    const buyerFlipped =
      !before.buyer.markedComplete && after.buyer.markedComplete;

    // Neither flipped — unrelated update
    if (!sellerFlipped && !buyerFlipped) {
      console.log(
        `Mark-complete notification skipped for order ${orderId}: no mark-complete flag changed.`,
      );
      return;
    }

      // Both are now confirmed — the order marked-complete trigger handles this
    if (after.seller.markedComplete && after.buyer.markedComplete) {
      console.log(
        `Mark-complete notification skipped for order ${orderId}: both parties have already confirmed completion.`,
      );
      return;
    }

    // Identify who confirmed and who receives the notification
    const confirmerName = sellerFlipped ? after.seller.name : after.buyer.name;
    const recipientId = sellerFlipped ? after.buyer.id : after.seller.id;

    try {
      const recipientData = await getUserWithFcm(recipientId);
      if (!recipientData) {
        console.log(
          `Mark-complete notification skipped for order ${orderId}: no recipient data found for user ${recipientId}.`,
        );
        return;
      }

      if (recipientData.notifSettings?.orderConfirmations === false) {
        console.log(
          `User ${recipientId} has disabled order confirmation notifications. No notification sent.`,
        );
        return;
      }

      await updateNotificationsStatus(orderId, recipientId);

      const payload = await payloadWithNotifs(recipientId, {
        notification: {
          title: `${confirmerName}`,
          body: "Marked the order complete. Tap to confirm",
        },
        data: {
          orderId,
          type: notificationType.orderConfirmation,
        },
        token: recipientData.fcmToken,
      });

      const response = await admin.messaging().send(payload);
      console.log(`Mark-complete notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending mark-complete notification:", error);
      throw error;
    }
  });

/**
 * Sends a push notification to the party who did NOT cancel when an order is cancelled.
 */
export const sendOrderCancelledNotification =
  functions.firestore.onDocumentUpdated("orders/{orderId}", async (event) => {
    const { orderId } = event.params;
    const before = event.data?.before.data() as Order | undefined;
    const after = event.data?.after.data() as Order | undefined;

    if (!before || !after) {
      return;
    }

    // Only fire when status transitions to cancelled
    if (before.status === orderStatus.cancelled || after.status !== orderStatus.cancelled) {
      return;
    }

    const cancelledBy = after.cancelledBy;
    if (!cancelledBy) {
      console.log(`Order cancellation notification skipped for ${orderId}: no cancelledBy field.`);
      return;
    }

    const cancellerName = cancelledBy === "seller" ? after.seller.name : after.buyer.name;
    const recipientId = cancelledBy === "seller" ? after.buyer.id : after.seller.id;

    try {
      const recipientData = await getUserWithFcm(recipientId);
      if (!recipientData) {
        return;
      }

      if (recipientData.notifSettings?.orderCancellations === false) {
        console.log(`User ${recipientId} has disabled order cancellation notifications. No notification sent.`);
        return;
      }

      const payload = await payloadWithNotifs(recipientId, {
        notification: {
          title: cancellerName,
          body: "Cancelled an order",
        },
        data: {
          orderId,
          type: notificationType.orderCancellation,
        },
        token: recipientData.fcmToken,
      });

      const response = await admin.messaging().send(payload);
      console.log(`Order cancelled notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending order cancelled notification:", error);
      throw error;
    }
  });

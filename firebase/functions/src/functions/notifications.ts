import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { getOrder } from "../services/order-service";
import { getUserWithFcm } from "../services/user-service";
import { Message, messageTypes, Order } from "../types";
import {
  payloadWithNotifs,
  updateNotificationsStatus,
} from "../utils/notifications";
import { timeOfDayStringToTime } from "../utils/time";

export const notificationType = {
  newMessage: "new_message",
  newOrder: "new_order",
  timeProposalUpdate: "time_proposal_update",
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
        orderData.buyerId === message.senderId
          ? orderData.sellerId
          : orderData.buyerId;

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
      const sellerData = await getUserWithFcm(orderData.sellerId);
      if (!sellerData) {
        return;
      }

      if (sellerData.notifSettings?.newOrders === false) {
        console.log(
          `User ${orderData.sellerId} has disabled new order notifications. No notification sent.`,
        );
        return;
      }

      const readableDate = new Date(
        orderData.transactionDate.toDate(),
      ).toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
      });

      await updateNotificationsStatus(orderId, orderData.sellerId);

      const payload = await payloadWithNotifs(orderData.sellerId, {
        notification: {
          title: "You have a new buyer!",
          body: `For ${readableDate} — tap to coordinate a time`,
        },
        data: {
          orderId,
          buyerId: orderData.buyerId,
          buyerName: orderData.buyerName,
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
          senderId === orderData.buyerId
            ? orderData.buyerName
            : orderData.sellerId === senderId
              ? orderData.sellerName
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

import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { Message, messageTypes, Order } from "../types";
import { getOrder, getUserWithFcm } from "../utils/firestore";
import {
  payloadWithNotifs,
  updateNotificationsStatus,
} from "../utils/notifications";
import { timeOfDayStringToTime } from "../utils/time";

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
          `Unknown message type: ${message.messageType}. No notification sent.`
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

      const title =
        message.messageType === "text"
          ? `${message.senderName} sent a message`
          : `${message.senderName} proposed a time`;

      const body =
        message.messageType === "text"
          ? message.content ?? ""
          : timeOfDayStringToTime(message.proposedTime ?? "");

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
          type: "new_message",
        },
        token: recipientData.fcmToken,
      });

      const response = await admin.messaging().send(payload);
      console.log(`Notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  }
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

      const readableDate = new Date(
        orderData.transactionDate
      ).toLocaleDateString("en-US", {
        month: "short",
        day: "numeric",
      });

      await updateNotificationsStatus(orderId, orderData.sellerId);

      const payload = await payloadWithNotifs(orderData.sellerId, {
        notification: {
          title: `Someone claimed your meal swipe for ${readableDate}`,
          body: "Tap to coordinate a meeting time",
        },
        data: {
          orderId,
          buyerId: orderData.buyerId,
          buyerName: orderData.buyerName,
          type: "new_order",
        },
        token: sellerData.fcmToken,
      });

      const response = await admin.messaging().send(payload);
      console.log(`Notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  }
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

        const receiverName =
          senderId === orderData.buyerId
            ? orderData.buyerName
            : orderData.sellerId === senderId
            ? orderData.sellerName
            : "Someone";

        const proposalTime = timeOfDayStringToTime(
          afterData.proposedTime ?? ""
        );

        await updateNotificationsStatus(orderId, senderId);

        const payload = await payloadWithNotifs(senderId, {
          notification: {
            title: `${receiverName} ${afterData.status} your time proposal for ${proposalTime}!`,
          },
          data: {
            orderId,
            type: "time_proposal_update",
          },
          token: senderData.fcmToken,
        });

        const response = await admin.messaging().send(payload);
        console.log(`Notification sent successfully: ${response}`);
      } catch (error) {
        console.error("Error sending notification:", error);
        throw error;
      }
    }
  );

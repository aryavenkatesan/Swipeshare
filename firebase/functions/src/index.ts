import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { Message, Order } from "./types";
import {
  getOrder,
  getUser,
  payloadWithNotifs,
  timeOfDayStringToTime,
  updateNotificationsStatus,
} from "./utils";

admin.initializeApp();

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

      const messageType =
        message.senderId === "time widget"
          ? "proposal"
          : message.senderId === "system"
          ? "system"
          : "text";

      if (messageType === "system") {
        console.log("System message. No notification sent.");
        return;
      }

      // For time proposal, receiverId is actually the senderId
      const senderId =
        messageType === "proposal" ? message.receiverId : message.senderId;

      const recipientId =
        orderData.buyerId === senderId ? orderData.sellerId : orderData.buyerId;

      const recipientData = await getUser(recipientId);
      if (!recipientData) {
        return;
      }

      const title =
        messageType === "text"
          ? `${message.senderName} sent a message`
          : `${message.senderName} proposed a time`;

      const body =
        messageType === "text"
          ? message.message || ""
          : timeOfDayStringToTime(message.message || "");

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
      const sellerData = await getUser(orderData.sellerId);
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

        // For time proposal, receiverId is actually the senderId
        const senderId = afterData.receiverId;
        const senderData = await getUser(senderId);
        if (!senderData) {
          return;
        }

        const receiverName =
          senderId === orderData.buyerId
            ? orderData.buyerName
            : orderData.sellerId === senderId
            ? orderData.sellerName
            : "Someone";

        const proposalTime = timeOfDayStringToTime(afterData.message || "");

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

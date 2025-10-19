import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

type Message = {
  senderId: string;
  senderEmail: string;
  messageType: "text" | "time_proposal";
  content?: string;
};

type Order = {
  buyerId: string;
  sellerId: string;
  // other fields aren't relevant
};

type User = {
  fcmToken?: string;
  // other fields aren't relevant
};

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
      const db = admin.firestore();

      const orderDoc = await db.collection("orders").doc(orderId).get();
      const orderData = orderDoc.data() as Order | undefined;

      if (!orderDoc.exists || !orderData) {
        console.log(`Order ${orderId} does not exist.`);
        return;
      }

      const recipientId =
        message.senderId === orderData.buyerId
          ? orderData.sellerId
          : orderData.buyerId;

      const recipientDoc = await db.collection("users").doc(recipientId).get();
      const recipientData = recipientDoc.data() as User | undefined;

      if (!recipientDoc.exists || !recipientData) {
        console.log(`User ${recipientId} does not exist.`);
        return;
      }

      if (!recipientData.fcmToken) {
        console.log(`User ${recipientId} does not have an FCM token.`);
        return;
      }

      const payload: admin.messaging.Message = {
        notification: {
          title: `New message from ${message.senderEmail}`,
          body:
            message.messageType === "text"
              ? message.content || "Sent a message"
              : "Sent a time proposal",
        },
        data: {
          orderId,
          messageId,
          senderId: message.senderId,
          type: "new_message",
        },
        token: recipientData.fcmToken,
      };

      const response = await admin.messaging().send(payload);
      console.log(`Notification sent successfully: ${response}`);
    } catch (error) {
      console.error("Error sending notification:", error);
      throw error;
    }
  }
);

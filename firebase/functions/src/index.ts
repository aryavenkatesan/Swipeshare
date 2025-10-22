import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();

type Message = {
  senderId: string;
  receiverId: string;
  senderName: string;
  message?: string;
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

function minutesToTimeString(minutes: number): string {
  const hours = Math.floor(minutes / 60);
  const mins = minutes % 60;
  const period = hours >= 12 ? "PM" : "AM";
  const displayHours = hours === 0 ? 12 : hours > 12 ? hours - 12 : hours;
  const displayMins = mins > 0 ? `:${mins.toString().padStart(2, "0")}` : "";
  return `${displayHours}${displayMins} ${period}`;
}

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

      const messageType =
        message.senderId === "time proposal"
          ? "proposal"
          : message.senderId === "system"
          ? "system"
          : "text";

      if (messageType === "system") {
        console.log("System message. No notification sent.");
        return;
      }

      const senderId =
        messageType === "proposal" ? message.receiverId : message.senderId;

      const recipientId =
        orderData.buyerId === senderId ? orderData.sellerId : orderData.buyerId;

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

      const title =
        messageType === "text"
          ? `${message.senderName} sent a message`
          : `${message.senderName} proposed a time`;

      const body =
        messageType === "text"
          ? message.message || ""
          : minutesToTimeString(parseInt(message.message || "0", 10));

      const payload: admin.messaging.Message = {
        notification: {
          title,
          body,
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

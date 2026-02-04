import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { validateOrderParticipant } from "../utils/firestore";
/**
 * Sends a welcome system message when a new order is created.
 * Provides transaction instructions to both buyer and seller.
 * 
 * @param orderId - The order ID for the new chat
 */
export const sendNewOrderSystemMessage = functions.https.onCall(
  async (request) => {
    const callerUid = request.auth?.uid;

    if (!callerUid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    const { orderId } = request.data;

    if (!orderId || typeof orderId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The function requires a valid 'orderId' parameter."
      );
    }

    try {
      await validateOrderParticipant(orderId, callerUid);

      const db = admin.firestore();
      const messagesRef = db
        .collection("orders")
        .doc(orderId)
        .collection("messages");
      const messageDoc = messagesRef.doc();

      const content = `Welcome to the chat room!

Feel free to discuss things like the time you'd want to meet up, identifiers like shirt color, or maybe the movie that came out last week :) 

Remember swipes are $7 and should be paid before the seller swipes you in.

Happy Swiping!`;

      const messageData = {
        messageType: "system" as const,
        senderId: "system",
        senderEmail: "system@swipeshare.app",
        senderName: "SwipeShare",
        content: content,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      };

      await messageDoc.set(messageData);

      console.log(
        `New order system message sent for order ${orderId} by user ${callerUid}`
      );

      return {
        success: true,
        messageId: messageDoc.id,
      };
    } catch (error) {
      console.error("Error sending new order system message:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        "Failed to send system message.",
        error
      );
    }
  }
);

/**
 * Sends a system message when a user deletes a chat.
 * Notifies the other party that the chat has been deleted.
 * 
 * @param orderId - The order ID of the deleted chat
 */
export const sendChatDeletedSystemMessage = functions.https.onCall(
  async (request) => {
    const callerUid = request.auth?.uid;

    if (!callerUid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    const { orderId } = request.data;

    if (!orderId || typeof orderId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The function requires a valid 'orderId' parameter."
      );
    }

    try {
      const orderData = await validateOrderParticipant(orderId, callerUid);

      const callerName =
        callerUid === orderData.buyerId
          ? (orderData.buyerName || "A user")
          : (orderData.sellerName || "A user");

      const db = admin.firestore();
      const messagesRef = db
        .collection("orders")
        .doc(orderId)
        .collection("messages");
      const messageDoc = messagesRef.doc();

      const content = `${callerName} has deleted the chat and left.\nPlease click the menu options above to delete the chat.`;

      const messageData = {
        messageType: "system" as const,
        senderId: "system",
        senderEmail: "system@swipeshare.app",
        senderName: "SwipeShare",
        content: content,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      };

      await messageDoc.set(messageData);

      console.log(
        `Chat deleted system message sent for order ${orderId} by user ${callerUid} (${callerName})`
      );

      return {
        success: true,
        messageId: messageDoc.id,
      };
    } catch (error) {
      console.error("Error sending chat deleted system message:", error);

      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      throw new functions.https.HttpsError(
        "internal",
        "Failed to send system message.",
        error
      );
    }
  }
);

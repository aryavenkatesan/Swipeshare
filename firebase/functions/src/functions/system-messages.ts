import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { getOrder } from "../utils/firestore";
/**
 * Cloud Function to send a "new order" welcome system message.
 * This is for when a new order is created to provide instructions to both parties.
 */

export const sendNewOrderSystemMessage = functions.https.onCall(
  async (request) => {
    // Extract the authenticated user ID from the request context
    const callerUid = request.auth?.uid;

    // Verify that the request is authenticated
    if (!callerUid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    // Extract the orderId parameter from the request data
    const { orderId } = request.data;

    // Validate that the order ID is provided
    if (!orderId || typeof orderId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The function requires a valid 'orderId' parameter."
      );
    }

    try {
      // Fetch the order using the utility function
      const orderData = await getOrder(orderId);

      // Verify the order exists
      if (!orderData) {
        throw new functions.https.HttpsError(
          "not-found",
          `Order with ID ${orderId} does not exist.`
        );
      }

      // Verify the caller is either the buyer or seller in this order
      const isCallerParticipant =
        callerUid === orderData.buyerId || callerUid === orderData.sellerId;

      if (!isCallerParticipant) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You are not a participant in this order."
        );
      }

      // Get a reference to the Firestore database
      const db = admin.firestore();

      // Get a reference to the messages subcollection for this order
      const messagesRef = db
        .collection("orders")
        .doc(orderId)
        .collection("messages");

      // Create a new message document reference
      const messageDoc = messagesRef.doc();

      // The welcome message content
      const content = `Welcome to the chat room!

Feel free to discuss things like the time you'd want to meet up, identifiers like shirt color, or maybe the movie that came out last week :) 

Remember swipes are $7 and should be paid before the seller swipes you in.

Happy Swiping!`;

      // Create the system message object
      const messageData = {
        messageType: "system",
        content: content,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Write the system message to Firestore
      await messageDoc.set(messageData);

      // Log success message for debugging
      console.log(
        `New order system message sent for order ${orderId} by user ${callerUid}`
      );

      // Return success response with the message ID
      return {
        success: true,
        messageId: messageDoc.id,
      };
    } catch (error) {
      // Log the error for debugging purposes
      console.error("Error sending new order system message:", error);

      // If it's already an HttpsError, rethrow it
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Otherwise, wrap it in a generic internal error
      throw new functions.https.HttpsError(
        "internal",
        "Failed to send system message.",
        error
      );
    }
  }
);

/**
 * Cloud Function to send a "chat deleted" system message.
 * This is called when a user deletes a chat to notify the other party.
 */
export const sendChatDeletedSystemMessage = functions.https.onCall(
  async (request) => {
    // Extract the authenticated user ID from the request context
    const callerUid = request.auth?.uid;

    // Verify that the request is authenticated
    if (!callerUid) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "The function must be called while authenticated."
      );
    }

    // Extract the orderId parameter from the request data
    const { orderId } = request.data;

    // Validate that the order ID is provided
    if (!orderId || typeof orderId !== "string") {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "The function requires a valid 'orderId' parameter."
      );
    }

    try {
      // Fetch the order using the utility function
      const orderData = await getOrder(orderId);

      // Verify the order exists
      if (!orderData) {
        throw new functions.https.HttpsError(
          "not-found",
          `Order with ID ${orderId} does not exist.`
        );
      }

      // Verify the caller is either the buyer or seller in this order
      const isCallerParticipant =
        callerUid === orderData.buyerId || callerUid === orderData.sellerId;

      if (!isCallerParticipant) {
        throw new functions.https.HttpsError(
          "permission-denied",
          "You are not a participant in this order."
        );
      }

      // Determine the caller's name based on their role in the order
      const callerName =
        callerUid === orderData.buyerId
          ? orderData.buyerName
          : orderData.sellerName;

      // Get a reference to the Firestore database
      const db = admin.firestore();

      // Get a reference to the messages subcollection for this order
      const messagesRef = db
        .collection("orders")
        .doc(orderId)
        .collection("messages");

      // Create a new message document reference
      const messageDoc = messagesRef.doc();

      // Create the chat deleted message content
      const content = `${callerName} has deleted the chat and left.\nPlease click the menu options above to delete the chat.`;

      // Create the system message object
      const messageData = {
        messageType: "system",
        content: content,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      };

      await messageDoc.set(messageData);

      // Log success message for debugging
      console.log(
        `Chat deleted system message sent for order ${orderId} by user ${callerUid} (${callerName})`
      );

      // Return success response with the message ID
      return {
        success: true,
        messageId: messageDoc.id,
      };
    } catch (error) {
      // Log the error for debugging purposes
      console.error("Error sending chat deleted system message:", error);

      // If it's already an HttpsError, rethrow it
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }

      // Otherwise, wrap it in a generic internal error
      throw new functions.https.HttpsError(
        "internal",
        "Failed to send system message.",
        error
      );
    }
  }
);

import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { getOrder, getUser } from "../utils/firestore";

/**
 * Cloud Function to update a user's star rating after a transaction is rated.
 * This function takes only an orderId and determines who is being rated based on
 * the authenticated caller. If caller is the buyer, they rate the seller, and vice versa.
 */
export const updateStarRating = functions.https.onCall(async (request) => {  
  // Extract the authenticated user ID from the request context
  const callerUid = request.auth?.uid;

  // Verify that the request is authenticated
  if (!callerUid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  // Extract parameters from the request data
  // orderId: the order that this rating is associated with
  // incomingStar: the rating value (1-5)
  const { orderId, incomingStar } = request.data;

  // Validate that the order ID is provided
  if (!orderId || typeof orderId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function requires a valid 'orderId' parameter."
    );
  }

  // Validate that the incoming star rating is a number between 1 and 5
  if (
    typeof incomingStar !== "number" ||
    incomingStar < 1 ||
    incomingStar > 5
  ) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The 'incomingStar' parameter must be a number between 1 and 5."
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

    // Determine who is being rated based on who the caller is
    // If caller is the buyer, they're rating the seller
    // If caller is the seller, they're rating the buyer
    let userIdToRate: string;

    if (callerUid === orderData.buyerId) {
      // Caller is the buyer, so they're rating the seller
      userIdToRate = orderData.sellerId;
    } else if (callerUid === orderData.sellerId) {
      // Caller is the seller, so they're rating the buyer
      userIdToRate = orderData.buyerId;
    } else {
      // Caller is neither the buyer nor seller - unauthorized
      throw new functions.https.HttpsError(
        "permission-denied",
        "You are not a participant in this order."
      );
    }

    // Fetch the user being rated using the utility function
    const userData = await getUser(userIdToRate);

    // Verify the user exists
    if (!userData) {
      throw new functions.https.HttpsError(
        "not-found",
        `User with ID ${userIdToRate} does not exist.`
      );
    }

    // Get the current star rating (defaults to 5 if not set)
    const currentStars = userData.stars ?? 5;

    // Get the number of completed transactions (defaults to 0 if not set)
    const transactionsCompleted =
      (userData as any).transactions_completed ?? 0;

    // Calculate the new weighted average star rating
    // Formula: (total points from all previous ratings + new rating) / (total number of ratings)
    const calculatedStarRating =
      (transactionsCompleted * currentStars + incomingStar) /
      (transactionsCompleted + 1);

    // Get a reference to the Firestore database
    const db = admin.firestore();

    // Update the user document with the new star rating
    await db.collection("users").doc(userIdToRate).update({
      stars: calculatedStarRating,
    });

    // Log success message for debugging and monitoring
    console.log(
      `User ${callerUid} rated user ${userIdToRate} with ${incomingStar} stars. ` +
        `New rating: ${calculatedStarRating} (order: ${orderId})`
    );

    // Return the new rating to the caller
    return {
      success: true,
      newRating: calculatedStarRating,
      ratedUserId: userIdToRate,
    };
  } catch (error) {
    // Log the error for debugging purposes
    console.error("Error updating star rating:", error);

    // If it's already an HttpsError, rethrow it
    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    // Otherwise, wrap it in a generic internal error
    throw new functions.https.HttpsError(
      "internal",
      "Failed to update star rating.",
      error
    );
  }
});
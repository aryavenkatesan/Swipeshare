import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { getUser, validateOrderParticipant } from "../utils/firestore";

/**
 * Updates a user's star rating after being rated in a transaction.
 * Caller (buyer or seller) rates the other party in the order.
 * Prevents duplicate ratings and maintains weighted average.
 * 
 * @param orderId - The order ID associated with this rating
 * @param incomingStar - Rating value (1-5)
 */
export const updateStarRating = functions.https.onCall(async (request) => {  
  const callerUid = request.auth?.uid;

  if (!callerUid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const { orderId, incomingStar } = request.data;

  if (!orderId || typeof orderId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The function requires a valid 'orderId' parameter."
    );
  }

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
    const db = admin.firestore();

    const orderData = await validateOrderParticipant(orderId, callerUid);

    // Prevent duplicate ratings
    if (callerUid === orderData.buyerId && orderData.buyerHasRated) {
      throw new functions.https.HttpsError(
        "already-exists",
        "You have already rated this order."
      );
    }
    
    if (callerUid === orderData.sellerId && orderData.sellerHasRated) {
      throw new functions.https.HttpsError(
        "already-exists",
        "You have already rated this order."
      );
    }

    const userIdToRate: string =
      callerUid === orderData.buyerId ? orderData.sellerId : orderData.buyerId;

    const userData = await getUser(userIdToRate);

    if (!userData) {
      throw new functions.https.HttpsError(
        "not-found",
        `User with ID ${userIdToRate} does not exist.`
      );
    }

    const currentStars = userData.stars ?? 5;
    const transactionsCompleted = (userData as any).transactions_completed ?? 0;

    // Weighted average: (previous_total + new_rating) / (total_count + 1)
    const calculatedStarRating =
      (transactionsCompleted * currentStars + incomingStar) /
      (transactionsCompleted + 1);

    await db.collection("users").doc(userIdToRate).update({
      stars: calculatedStarRating,
      transactions_completed: admin.firestore.FieldValue.increment(1),
    });

    const ratingField = callerUid === orderData.buyerId ? "buyerHasRated" : "sellerHasRated";
    await db.collection("orders").doc(orderId).update({
      [ratingField]: true,
    });

    console.log(
      `User ${callerUid} rated user ${userIdToRate} with ${incomingStar} stars. ` +
        `New rating: ${calculatedStarRating} (order: ${orderId})`
    );

    return {
      success: true,
      newRating: calculatedStarRating,
      ratedUserId: userIdToRate,
    };
  } catch (error) {
    console.error("Error updating star rating:", error);

    if (error instanceof functions.https.HttpsError) {
      throw error;
    }

    throw new functions.https.HttpsError(
      "internal",
      "Failed to update star rating.",
      error
    );
  }
});
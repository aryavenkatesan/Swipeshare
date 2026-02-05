import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { Order, Rating, orderStatus } from "../types";
import { updateUserStars } from "../utils/firestore";

/**
 * Updates a user's star rating when an order is updated with a new rating.
 * Triggers when ratingByBuyer or ratingBySeller is added to an order.
 */
export const updateStarRatingOnOrderUpdate =
  functions.firestore.onDocumentUpdated("orders/{orderId}", async (event) => {
    const { orderId } = event.params;
    const beforeData = event.data?.before.data() as Order | undefined;
    const afterData = event.data?.after.data() as Order | undefined;

    if (!beforeData || !afterData) {
      console.log("Before or after data is missing.");
      return;
    }

    // Only process ratings for completed orders
    if (afterData.status !== orderStatus.completed) {
      console.log(
        `Order ${orderId} has status '${afterData.status}'; skipping rating update.`,
      );
      return;
    }

    const isValidRating = (rating: Rating): boolean => {
      return (
        typeof rating.stars === "number" &&
        Number.isInteger(rating.stars) &&
        rating.stars >= 1 &&
        rating.stars <= 5
      );
    };

    const db = admin.firestore();
    const updates: Promise<void>[] = [];

    // Check if ratingByBuyer was added (buyer rated the seller)
    if (!beforeData.ratingByBuyer && afterData.ratingByBuyer) {
      if (!isValidRating(afterData.ratingByBuyer)) {
        console.error(
          `Invalid buyer rating for order ${orderId}: ${afterData.ratingByBuyer.stars}`,
        );
      } else {
        updates.push(
          updateUserStars(
            db,
            orderId,
            afterData.sellerId,
            afterData.ratingByBuyer,
            "buyer",
          ),
        );
      }
    }

    // Check if ratingBySeller was added (seller rated the buyer)
    if (!beforeData.ratingBySeller && afterData.ratingBySeller) {
      if (!isValidRating(afterData.ratingBySeller)) {
        console.error(
          `Invalid seller rating for order ${orderId}: ${afterData.ratingBySeller.stars}`,
        );
      } else {
        updates.push(
          updateUserStars(
            db,
            orderId,
            afterData.buyerId,
            afterData.ratingBySeller,
            "seller",
          ),
        );
      }
    }

    if (updates.length === 0) {
      return;
    }

    await Promise.all(updates);
  });

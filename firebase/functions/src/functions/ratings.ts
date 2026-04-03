import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { updateUserStars } from "../services/user-service";
import { Order, Rating, orderStatus } from "../types";

/**
 * Updates a user's star rating when an order is updated with a new rating.
 * Triggers when buyer.rating or seller.rating is added to an order.
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

    // Check if buyer.rating was added (buyer rated the seller)
    if (!beforeData.buyer.rating && afterData.buyer.rating) {
      if (!isValidRating(afterData.buyer.rating)) {
        console.error(
          `Invalid buyer rating for order ${orderId}: ${afterData.buyer.rating.stars}`,
        );
      } else {
        updates.push(
          updateUserStars(
            db,
            orderId,
            afterData.seller.id,
            afterData.buyer.rating,
            "buyer",
          ),
        );
      }
    }

    // Check if seller.rating was added (seller rated the buyer)
    if (!beforeData.seller.rating && afterData.seller.rating) {
      if (!isValidRating(afterData.seller.rating)) {
        console.error(
          `Invalid seller rating for order ${orderId}: ${afterData.seller.rating.stars}`,
        );
      } else {
        updates.push(
          updateUserStars(
            db,
            orderId,
            afterData.buyer.id,
            afterData.seller.rating,
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

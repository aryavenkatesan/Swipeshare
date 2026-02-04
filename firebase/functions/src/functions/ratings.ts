import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { Order } from "../types";
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

    const db = admin.firestore();
    const updates: Promise<void>[] = [];

    // Check if ratingByBuyer was added (buyer rated the seller)
    if (!beforeData.ratingByBuyer && afterData.ratingByBuyer) {
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

    // Check if ratingBySeller was added (seller rated the buyer)
    if (!beforeData.ratingBySeller && afterData.ratingBySeller) {
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

    if (updates.length === 0) {
      return;
    }

    await Promise.all(updates);
  });

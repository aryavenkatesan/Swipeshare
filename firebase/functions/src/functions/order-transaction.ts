import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import * as functions from "firebase-functions/v2";
import {
  claimListingForOrder,
  createOrderSystemMessage,
  getOrder,
  patchOrder,
} from "../services/order-service";
import { getUser, patchUser } from "../services/user-service";
import { Order, orderStatus } from "../types";
import { WALK_IN_PRICE } from "../utils/constants";

export const createOrderFromListing = functions.https.onCall(
  async (request) => {
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated to create an order",
      );
    }

    const { listingId } = request.data;
    const buyerId = request.auth.uid;

    if (!listingId) {
      throw new HttpsError("invalid-argument", "listingId is required");
    }

    const buyer = await getUser(buyerId);
    if (!buyer?.isEmailVerified) {
      throw new HttpsError(
        "failed-precondition",
        "Email must be verified to create an order",
      );
    }

    console.log(`Creating order for listing ${listingId} by buyer ${buyerId}`);

    const { order } = await claimListingForOrder(listingId, buyerId);
    return order;
  },
);

/**
 * Firestore trigger that handles marked-complete updates on active orders.
 * It writes server-authored system messages for each new confirmation and
 * completes the order once both parties have confirmed.
 */
export const handleOrderMarkedCompleteUpdate =
  functions.firestore.onDocumentUpdated("orders/{orderId}", async (event) => {
    const before = event.data?.before.data() as Order | undefined;
    const after = event.data?.after.data() as Order | undefined;

    if (!before || !after) return;
    if (after.status !== orderStatus.active) return;

    const sellerFlipped =
      !before.seller.markedComplete && after.seller.markedComplete;
    const buyerFlipped =
      !before.buyer.markedComplete && after.buyer.markedComplete;

    if (!sellerFlipped && !buyerFlipped) return;

    const orderId = event.params.orderId;
    const writes: Promise<unknown>[] = [];

    if (sellerFlipped) {
      writes.push(
        createOrderSystemMessage(
          orderId,
          `${after.seller.name} marked this order as complete.`,
        ),
      );
    }

    if (buyerFlipped) {
      writes.push(
        createOrderSystemMessage(
          orderId,
          `${after.buyer.name} marked this order as complete.`,
        ),
      );
    }

    await Promise.all(writes);

    if (writes.length > 0) {
      console.log(
        `Wrote ${writes.length} mark-complete system message(s) for order ${orderId}.`,
      );
    }

    // If there is still a party left to confirm, we're done here
    if (!after.seller.markedComplete || !after.buyer.markedComplete) {
      console.log(
        `Order ${orderId} is not yet fully confirmed: seller markedComplete=${after.seller.markedComplete}, buyer markedComplete=${after.buyer.markedComplete}. Waiting for other party to confirm.`,
      );
      return;
    }

    const price = after.price ?? 0;

    console.log(
      `Both parties confirmed completion for order ${orderId}. Completing order.`,
    );

    const batch = admin.firestore().batch();

    patchOrder(orderId, { status: orderStatus.completed }, batch);

    patchUser(
      after.buyer.id,
      {
        transactions_completed: FieldValue.increment(1),
        moneySaved: FieldValue.increment(WALK_IN_PRICE - price),
      },
      batch,
    );

    patchUser(
      after.seller.id,
      {
        transactions_completed: FieldValue.increment(1),
        moneyEarned: FieldValue.increment(price),
      },
      batch,
    );

    batch.set(
      admin.firestore().collection("stats").doc("platform"),
      { completedOrders: FieldValue.increment(1) },
      { merge: true },
    );

    await batch.commit();

    console.log(`Order ${orderId} completed via mutual confirmation.`);
  });

export const cancelOrder = functions.https.onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "User must be authenticated to cancel an order",
    );
  }

  const { orderId } = request.data;
  const callerUid = request.auth.uid;

  if (!orderId) {
    throw new HttpsError("invalid-argument", "orderId is required");
  }

  const orderData = await getOrder(orderId);

  if (!orderData) {
    throw new HttpsError("not-found", `Order ${orderId} not found`);
  }

  if (callerUid !== orderData.buyer.id && callerUid !== orderData.seller.id) {
    throw new HttpsError(
      "permission-denied",
      "You are not a participant in this order",
    );
  }

  if (orderData.status !== orderStatus.active) {
    throw new HttpsError(
      "failed-precondition",
      "Only active orders can be cancelled.",
    );
  }

  const cancelledBy = callerUid === orderData.buyer.id ? "buyer" : "seller";

  await admin.firestore().collection("orders").doc(orderId).update({
    status: orderStatus.cancelled,
    cancelledBy,
    cancellationAcknowledged: false,
  });

  console.log(`Order ${orderId} cancelled by ${cancelledBy} (${callerUid})`);

  return { success: true };
});

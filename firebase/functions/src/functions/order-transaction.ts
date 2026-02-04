import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import * as functions from "firebase-functions/v2";
import { Listing, listingStatus, Order, orderStatus } from "../types";
import { getListing, getOrderRoomName, getUser } from "../utils/firestore";
import { dateToTimeOfDayString } from "../utils/time";

/**
 * Creates an order between two users identified by their email addresses.
 * Transaction time is set to now. This is an admin/debug function.
 *
 * Set env var before running shell: ADMIN_SECRET=your-secret npm run shell
 * Call from shell: createOrderFromEmails({data: {sellerEmail: "...", buyerEmail: "...", secret: "your-secret"}})
 */
export const createOrderFromEmails = functions.https.onCall(async (request) => {
  const { sellerEmail, buyerEmail, diningHall, price, secret } =
    request.data ?? request;

  if (secret !== process.env.ADMIN_SECRET) {
    throw new HttpsError("permission-denied", "Admin secret required");
  }

  if (!sellerEmail || !buyerEmail) {
    throw new HttpsError(
      "invalid-argument",
      "sellerEmail and buyerEmail are required",
    );
  }

  // Look up users by email using Firebase Auth
  let sellerAuth, buyerAuth;
  try {
    sellerAuth = await admin.auth().getUserByEmail(sellerEmail);
  } catch {
    throw new HttpsError(
      "not-found",
      `Seller with email ${sellerEmail} not found`,
    );
  }

  try {
    buyerAuth = await admin.auth().getUserByEmail(buyerEmail);
  } catch {
    throw new HttpsError(
      "not-found",
      `Buyer with email ${buyerEmail} not found`,
    );
  }

  const sellerId = sellerAuth.uid;
  const buyerId = buyerAuth.uid;

  // Get user data from Firestore
  const seller = await getUser(sellerId);
  if (!seller) {
    throw new HttpsError(
      "not-found",
      `Seller user data for ${sellerEmail} not found`,
    );
  }

  const buyer = await getUser(buyerId);
  if (!buyer) {
    throw new HttpsError(
      "not-found",
      `Buyer user data for ${buyerEmail} not found`,
    );
  }

  const now = new Date();
  const transactionDate = Timestamp.fromDate(now);
  const displayTime = dateToTimeOfDayString(now);

  const newOrder: Order = {
    sellerId,
    sellerName: seller.name,
    sellerStars: seller.stars,
    buyerId,
    buyerName: buyer.name,
    buyerStars: buyer.stars,
    diningHall: diningHall ?? "Test Dining Hall",
    displayTime,
    sellerHasNotifs: true,
    buyerHasNotifs: true,
    transactionDate,
    status: orderStatus.active,
    price: price ?? 0,
  };

  const orderId = getOrderRoomName(newOrder);
  const orderDoc = admin.firestore().collection("orders").doc(orderId);
  const orderSnapshot = await orderDoc.get();

  if (orderSnapshot.exists) {
    throw new HttpsError(
      "already-exists",
      `Order with id ${orderId} already exists`,
    );
  }

  await orderDoc.set(newOrder);

  console.log(
    `Created order ${orderId} between seller ${sellerEmail} and buyer ${buyerEmail}`,
  );

  return { orderId, ...newOrder };
});

export const createOrderFromListing = functions.https.onCall(
  async (request) => {
    // Verify user is authenticated
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "User must be authenticated to create an order",
      );
    }

    const { listingId } = request.data;
    const buyerId = request.auth.uid;

    // Validate input parameters
    if (!listingId) {
      throw new HttpsError("invalid-argument", "listingId is required");
    }

    console.log(`Creating order for listing ${listingId} by buyer ${buyerId}`);

    return await admin.firestore().runTransaction(async (transaction) => {
      const buyer = await getUser(buyerId, transaction);
      if (!buyer) {
        throw new HttpsError(
          "not-found",
          `Buyer user data for id ${buyerId} not found`,
        );
      }

      if (!buyer.isEmailVerified) {
        throw new HttpsError(
          "failed-precondition",
          "Email must be verified to create an order",
        );
      }

      const listing = await getListing(listingId, transaction);
      if (!listing) {
        throw new HttpsError(
          "not-found",
          `Listing data for id ${listingId} not found`,
        );
      }

      const seller = await getUser(listing.sellerId, transaction);
      if (!seller) {
        throw new HttpsError(
          "not-found",
          `Seller user data for id ${listing.sellerId} not found`,
        );
      }

      const newOrder: Order = {
        sellerId: listing.sellerId,
        sellerName: listing.sellerName,
        sellerStars: seller.stars,
        buyerId: buyerId,
        buyerName: buyer.name,
        buyerStars: buyer.stars,
        diningHall: listing.diningHall,
        // displayTime: undefined,
        sellerHasNotifs: true,
        buyerHasNotifs: true,
        transactionDate: listing.transactionDate,
        status: orderStatus.active,
        price: listing.price ?? 0,
      };

      const orderId = getOrderRoomName(newOrder);
      const orderDoc = admin.firestore().collection("orders").doc(orderId);
      const orderSnapshot = await transaction.get(orderDoc);
      if (orderSnapshot.exists) {
        throw new HttpsError(
          "already-exists",
          `Order with id ${orderId} already exists`,
        );
      }

      transaction.set(orderDoc, newOrder);
      const listingDoc = admin
        .firestore()
        .collection("listings")
        .doc(listingId);

      const listingUpdate: Partial<Listing> = {
        status: listingStatus.claimed,
      };
      transaction.update(listingDoc, listingUpdate);

      return newOrder;
    });
  },
);

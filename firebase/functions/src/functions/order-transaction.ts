import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/https";
import * as functions from "firebase-functions/v2";
import { Listing, listingStatus, Order, orderStatus } from "../types";
import { getListing, getOrderRoomName, getUser } from "../utils/firestore";

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
        sellerVisibility: true,
        sellerStars: seller.stars,
        buyerId: buyerId,
        buyerName: buyer.name,
        buyerVisibility: true,
        buyerStars: buyer.stars,
        diningHall: listing.diningHall,
        // displayTime: undefined,
        sellerHasNotifs: true,
        buyerHasNotifs: true,
        transactionDate: listing.transactionDate,
        isChatDeleted: false,
        status: orderStatus.active,
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

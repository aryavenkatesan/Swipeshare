import { HttpsError } from "firebase-functions/https";
import * as functions from "firebase-functions/v2";
import { claimListingForOrder } from "../services/order-service";
import { getUser } from "../services/user-service";

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

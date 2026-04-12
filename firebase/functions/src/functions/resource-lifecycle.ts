import * as admin from "firebase-admin";
import { Timestamp } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v2";
import { patchListing } from "../services/listing-service";
import { completeExpiredOrders } from "../services/order-service";
import { Listing, listingStatus } from "../types";

/**
 * Debug callable to manually trigger order completion.
 * Set env var before running shell: ADMIN_SECRET=your-secret npm run shell
 * triggerCompleteOldOrders({data: {secret: "your-secret"}})
 */
export const triggerCompleteOldOrders = functions.https.onCall(
  async (request) => {
    const { secret } = request.data ?? {};
    if (secret !== process.env.ADMIN_SECRET) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Admin secret required",
      );
    }
    return await completeExpiredOrders();
  },
);

/**
 * Scheduled function that runs daily at 12:00 AM EST.
 * Finds all active listings with a transactionDate before the current time
 * and updates their status to expired.
 */
export const expireOldListings = functions.scheduler.onSchedule(
  { schedule: "0 0 * * *", timeZone: "America/New_York" }, // 12:00 AM EST
  async () => {
    const now = Timestamp.now();

    console.log(
      `Running listing expiration job at ${now.toDate().toISOString()}`,
    );

    try {
      const listingsRef = admin.firestore().collection("listings");
      const expiredListingsQuery = listingsRef
        .where("status", "==", listingStatus.active)
        .where("transactionDate", "<", now);

      const snapshot = await expiredListingsQuery.get();

      if (snapshot.empty) {
        console.log("No expired listings found.");
        return;
      }

      console.log(`Found ${snapshot.size} listings to expire.`);

      const batch = admin.firestore().batch();

      snapshot.docs.forEach((doc) => {
        const listing = doc.data() as Listing;
        console.log(
          `Expiring listing ${doc.id} (seller: ${listing.sellerId}, date: ${listing.transactionDate.toDate().toISOString()})`,
        );
        patchListing(doc.id, { status: listingStatus.expired }, batch);
      });

      await batch.commit();

      console.log(`Successfully expired ${snapshot.size} listings.`);
    } catch (error) {
      console.error("Error expiring listings:", error);
      throw error;
    }
  },
);

/**
 * Scheduled function that runs daily at 12:00 AM EST.
 * Finds all active orders with a transactionDate before the current time
 * and updates their status to completed.
 */
export const completeOldOrders = functions.scheduler.onSchedule(
  { schedule: "0 0 * * *", timeZone: "America/New_York" }, // 12:00 AM EST
  async () => {
    try {
      await completeExpiredOrders();
    } catch (error) {
      console.error("Error completing orders:", error);
      throw error;
    }
  },
);

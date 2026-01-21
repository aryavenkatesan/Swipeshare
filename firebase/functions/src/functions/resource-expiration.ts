import * as admin from "firebase-admin";
import * as functions from "firebase-functions/v2";
import { Listing, listingStatus } from "../types";

/**
 * Scheduled function that runs daily at 12:00 AM EST.
 * Finds all active listings with a transactionDate before the current time
 * and updates their status to expired.
 */
export const expireOldListings = functions.scheduler.onSchedule(
  { schedule: "0 0 * * *", timeZone: "America/New_York" }, // 12:00 AM EST
  async () => {
    const now = admin.firestore.Timestamp.now();

    console.log(`Running listing expiration job at ${now.toDate().toISOString()}`);

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
          `Expiring listing ${doc.id} (seller: ${listing.sellerId}, date: ${listing.transactionDate.toDate().toISOString()})`
        );
        batch.update(doc.ref, { status: listingStatus.expired });
      });

      await batch.commit();

      console.log(`Successfully expired ${snapshot.size} listings.`);
    } catch (error) {
      console.error("Error expiring listings:", error);
      throw error;
    }
  }
);

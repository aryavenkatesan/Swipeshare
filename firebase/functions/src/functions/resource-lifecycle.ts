import * as admin from "firebase-admin";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import * as functions from "firebase-functions/v2";
import { Listing, listingStatus, Order, orderStatus } from "../types";

/** Core logic for completing old orders - shared between scheduled and callable */
async function completeOldOrdersLogic() {
  const now = Timestamp.now();

  console.log(`Running order completion job at ${now.toDate().toISOString()}`);

  const ordersRef = admin.firestore().collection("orders");
  const oldOrdersQuery = ordersRef
    .where("status", "==", orderStatus.active)
    .where("transactionDate", "<", now);

  const snapshot = await oldOrdersQuery.get();

  if (snapshot.empty) {
    console.log("No orders to complete.");
    return { completed: 0, usersUpdated: 0 };
  }

  console.log(`Found ${snapshot.size} orders to complete.`);

  const batch = admin.firestore().batch();
  const usersRef = admin.firestore().collection("users");

  const userIncrements = new Map<string, number>();

  snapshot.docs.forEach((doc) => {
    const order = doc.data() as Order;
    console.log(
      `Completing order ${doc.id} (seller: ${order.sellerId}, buyer: ${order.buyerId}, date: ${order.transactionDate.toDate().toISOString()})`,
    );
    batch.update(doc.ref, { status: orderStatus.completed });

    userIncrements.set(
      order.buyerId,
      (userIncrements.get(order.buyerId) || 0) + 1,
    );
    userIncrements.set(
      order.sellerId,
      (userIncrements.get(order.sellerId) || 0) + 1,
    );
  });

  userIncrements.forEach((incrementCount, userId) => {
    const userRef = usersRef.doc(userId);
    batch.update(userRef, {
      transactions_completed: FieldValue.increment(incrementCount),
    });
  });

  await batch.commit();

  console.log(`Successfully completed ${snapshot.size} orders.`);
  console.log(`Updated transaction counts for ${userIncrements.size} users.`);

  return { completed: snapshot.size, usersUpdated: userIncrements.size };
}

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
    return await completeOldOrdersLogic();
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
    const now = admin.firestore.Timestamp.now();

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
        batch.update(doc.ref, { status: listingStatus.expired });
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
      await completeOldOrdersLogic();
    } catch (error) {
      console.error("Error completing orders:", error);
      throw error;
    }
  },
);

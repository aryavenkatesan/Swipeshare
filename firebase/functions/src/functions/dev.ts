import * as admin from "firebase-admin";
import { HttpsError } from "firebase-functions/https";
import * as functions from "firebase-functions/v2";
import { createListing } from "../services/listing-service";
import {
  claimListingForOrder,
  completeExpiredOrders,
} from "../services/order-service";
import { getUser } from "../services/user-service";
import { Listing, Order } from "../types"; // Order used in return type inference

export const devSeed = functions.https.onCall(async (request) => {
  if (!process.env.FUNCTIONS_EMULATOR) {
    throw new HttpsError("failed-precondition", "This function is dev-only.");
  }

  const { action, ...data } = request.data;

  console.log(
    `[devSeed] action=${action} data=${JSON.stringify(data, null, 2)}`,
  );

  switch (action) {
    case "createListing":
      return await _createListing(data as any);
    case "createOrder":
      return await _createOrder(data as any);
    case "clearData":
      return await _clearData();
    case "completeOldOrders":
      return await completeExpiredOrders();
    default:
      throw new HttpsError("invalid-argument", `Unknown action: ${action}`);
  }
});

const _clearData = async () => {
  const db = admin.firestore();
  // Excludes 'users' — seed user profiles must survive between test runs.
  const topLevelCollections = ["listings", "orders", "password_resets", "mail"];

  for (const collectionName of topLevelCollections) {
    // Retry up to 3 times: the emulator's BulkWriter occasionally cancels
    // gRPC streams mid-delete, but a retry on the same collection succeeds.
    let lastError: unknown;
    for (let attempt = 0; attempt < 3; attempt++) {
      try {
        await db.recursiveDelete(db.collection(collectionName));
        lastError = undefined;
        break;
      } catch (e) {
        if (attempt !== 2) {
          console.warn(
            `[devSeed] Warning: Failed to clear collection ${collectionName} (attempt ${attempt + 1}/3). Retrying...`,
          );
        }
        lastError = e;
      }
    }
    if (lastError) throw lastError;
  }

  console.log(
    `[devSeed] Cleared collections: ${topLevelCollections.join(", ")}`,
  );
  return { cleared: topLevelCollections };
};

const _createListing = async ({
  sellerEmail,
  overrides,
  nowMinutes,
}: {
  sellerEmail: string;
  overrides?: Partial<Listing>;
  nowMinutes?: number;
}) => {
  const sellerAuth = await admin.auth().getUserByEmail(sellerEmail);
  const seller = await getUser(sellerAuth.uid);
  if (!seller) {
    throw new HttpsError("not-found", `Seller ${sellerEmail} not found`);
  }
  const listingId = await createListing(
    { ...seller, id: sellerAuth.uid },
    overrides,
    nowMinutes,
  );
  console.log(
    `[devSeed] Created listing ${listingId} for seller ${sellerEmail}`,
  );
  return { listingId };
};

const _createOrder = async ({
  sellerEmail,
  buyerEmail,
  listingOverrides,
  nowMinutes,
}: {
  sellerEmail: string;
  buyerEmail: string;
  listingOverrides?: Partial<Listing>;
  nowMinutes?: number;
}): Promise<{ orderId: string; order: Order }> => {
  const [sellerAuth, buyerAuth] = await Promise.all([
    admin.auth().getUserByEmail(sellerEmail),
    admin.auth().getUserByEmail(buyerEmail),
  ]);
  const seller = await getUser(sellerAuth.uid);
  if (!seller) {
    throw new HttpsError("not-found", `Seller ${sellerEmail} not found`);
  }

  // Create a listing for the seller, then claim it as the buyer — mirroring the real flow.
  const listingId = await createListing(
    { ...seller, id: sellerAuth.uid },
    listingOverrides,
    nowMinutes,
  );
  const result = await claimListingForOrder(listingId, buyerAuth.uid);

  console.log(
    `[devSeed] Created order ${result.orderId} via listing ${listingId} (seller: ${sellerEmail}, buyer: ${buyerEmail})`,
  );
  return result;
};

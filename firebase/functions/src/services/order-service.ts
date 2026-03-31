import * as admin from "firebase-admin";
import {
  DocumentData,
  DocumentReference,
  FieldValue,
  Timestamp,
  Transaction,
  UpdateData,
  WriteResult,
} from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import {
  FirestoreWriter,
  listingStatus,
  Order,
  orderStatus,
  SystemMessage,
  User,
} from "../types";
import {
  newOrderSystemMessageContent,
  WALK_IN_PRICE,
} from "../utils/constants";
import { getListing } from "./listing-service";
import { getUser, patchUser } from "./user-service";

export const getOrder = async (
  orderId: string,
  transaction?: Transaction,
): Promise<Order | null> => {
  const orderSnapshot = transaction
    ? await transaction.get(admin.firestore().collection("orders").doc(orderId))
    : await admin.firestore().collection("orders").doc(orderId).get();
  const orderData = orderSnapshot.data() as Order | undefined;

  if (!orderSnapshot.exists || !orderData) {
    console.log(`Order ${orderId} does not exist.`);
    return null;
  }

  return orderData;
};

/**
 * Generates the room name for an order chat.
 * Format: {sellerId}_{buyerId}_{transactionDate}
 * This matches the getRoomName() method in meal_order.dart
 */
export const getOrderRoomName = ({
  sellerId,
  buyerId,
  transactionDate,
}: {
  sellerId: string;
  buyerId: string;
  transactionDate: Timestamp;
}): string => {
  return `${sellerId}_${buyerId}_${transactionDate.toMillis()}`;
};

export const patchOrder = (
  orderId: string,
  patch: UpdateData<Order>,
  writer?: FirestoreWriter,
): Promise<WriteResult> | void => {
  const orderDoc = admin.firestore().collection("orders").doc(orderId);
  const data = patch as UpdateData<DocumentData>;
  if (writer) {
    writer.update(orderDoc, data);
  } else {
    return orderDoc.update(data);
  }
};

/**
 * Checks for duplicates, then writes the order within a transaction.
 * Returns the order DocumentReference on success, or null if the order already exists.
 */
export const writeOrder = async (
  order: Order,
  transaction: Transaction,
): Promise<DocumentReference | null> => {
  const orderDoc = admin
    .firestore()
    .collection("orders")
    .doc(getOrderRoomName(order));
  const snapshot = await transaction.get(orderDoc);
  if (snapshot.exists) {
    return null;
  }
  transaction.set(orderDoc, order);
  return orderDoc;
};

export const buildOrder = (
  seller: User & { id: string },
  buyer: User & { id: string },
  overrides?: Partial<Order>,
): Order => ({
  sellerId: seller.id,
  sellerName: seller.name,
  sellerStars: seller.stars ?? 5,
  buyerId: buyer.id,
  buyerName: buyer.name,
  buyerStars: buyer.stars ?? 5,
  diningHall: "Lenoir",
  sellerHasNotifs: true,
  buyerHasNotifs: true,
  transactionDate: Timestamp.now(),
  status: orderStatus.active,
  price: 5.0,
  cancellationAcknowledged: false,
  ...overrides,
});

/**
 * Claims a listing and creates an order from it, including the system message.
 * This is the shared logic used by both the real createOrderFromListing callable
 * and the dev seed function.
 */
export const claimListingForOrder = async (
  listingId: string,
  buyerId: string,
): Promise<{ orderId: string; order: Order }> => {
  return await admin.firestore().runTransaction(async (transaction) => {
    const buyer = await getUser(buyerId, transaction);
    if (!buyer) {
      throw new HttpsError(
        "not-found",
        `Buyer user data for id ${buyerId} not found`,
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

    const newOrder = buildOrder(
      { ...seller, id: listing.sellerId },
      { ...buyer, id: buyerId },
      {
        diningHall: listing.diningHall,
        transactionDate: listing.transactionDate,
        price: listing.price ?? 0,
      },
    );

    const orderDoc = await writeOrder(newOrder, transaction);
    if (!orderDoc) {
      throw new HttpsError(
        "already-exists",
        `Order between seller ${listing.sellerId} and buyer ${buyerId} already exists`,
      );
    }

    transaction.update(
      admin.firestore().collection("listings").doc(listingId),
      { status: listingStatus.claimed },
    );

    const messageDoc = orderDoc.collection("messages").doc();
    const messageData: SystemMessage = {
      messageType: "system",
      senderId: "system",
      senderEmail: "system@swipeshare.app",
      senderName: "SwipeShare",
      content: newOrderSystemMessageContent(newOrder.price),
    };
    transaction.set(messageDoc, {
      ...messageData,
      timestamp: FieldValue.serverTimestamp(),
    });

    return { orderId: orderDoc.id, order: newOrder };
  });
};

export const completeExpiredOrders = async (): Promise<{
  completed: number;
  usersUpdated: number;
}> => {
  const now = Timestamp.now();

  console.log(`Running order completion job at ${now.toDate().toISOString()}`);

  const ordersRef = admin.firestore().collection("orders");
  const snapshot = await ordersRef
    .where("status", "==", orderStatus.active)
    .where("transactionDate", "<", now)
    .get();

  if (snapshot.empty) {
    console.log("No orders to complete.");
    return { completed: 0, usersUpdated: 0 };
  }

  console.log(`Found ${snapshot.size} orders to complete.`);

  const batch = admin.firestore().batch();

  type UserUpdates = {
    transactions: number;
    moneySaved: number;
    moneyEarned: number;
  };
  const userUpdates = new Map<string, UserUpdates>();

  const getOrCreate = (userId: string): UserUpdates => {
    if (!userUpdates.has(userId)) {
      userUpdates.set(userId, {
        transactions: 0,
        moneySaved: 0,
        moneyEarned: 0,
      });
    }
    return userUpdates.get(userId)!;
  };

  snapshot.docs.forEach((doc) => {
    const order = doc.data() as Order;
    const price = order.price ?? 0;
    console.log(
      `Completing order ${doc.id} (seller: ${order.sellerId}, buyer: ${order.buyerId}, price: $${price}, date: ${order.transactionDate.toDate().toISOString()})`,
    );
    patchOrder(doc.id, { status: orderStatus.completed }, batch);

    const buyerUpdates = getOrCreate(order.buyerId);
    buyerUpdates.transactions += 1;
    buyerUpdates.moneySaved += WALK_IN_PRICE - price;

    const sellerUpdates = getOrCreate(order.sellerId);
    sellerUpdates.transactions += 1;
    sellerUpdates.moneyEarned += price;
  });

  userUpdates.forEach((updates, userId) => {
    patchUser(
      userId,
      {
        transactions_completed: FieldValue.increment(updates.transactions),
        moneySaved: FieldValue.increment(updates.moneySaved),
        moneyEarned: FieldValue.increment(updates.moneyEarned),
      },
      batch,
    );
  });

  await batch.commit();

  console.log(`Successfully completed ${snapshot.size} orders.`);
  console.log(`Updated transaction counts for ${userUpdates.size} users.`);

  return { completed: snapshot.size, usersUpdated: userUpdates.size };
};

export const createOrder = async (
  seller: User & { id: string },
  buyer: User & { id: string },
  overrides?: Partial<Order>,
): Promise<{ orderId: string; order: Order }> => {
  const order = buildOrder(seller, buyer, overrides);
  const orderId = getOrderRoomName(order);
  await admin.firestore().collection("orders").doc(orderId).set(order);
  return { orderId, order };
};

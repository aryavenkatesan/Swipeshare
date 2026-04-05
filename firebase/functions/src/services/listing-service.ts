import * as admin from "firebase-admin";
import { DocumentData, Timestamp, Transaction, UpdateData, WriteResult } from "firebase-admin/firestore";
import { FirestoreWriter, Listing, listingStatus, User } from "../types";

export const getListing = async (
  listingId: string,
  transaction?: Transaction,
): Promise<Listing | null> => {
  const listingDoc = admin.firestore().collection("listings").doc(listingId);
  const listingSnapshot = transaction
    ? await transaction.get(listingDoc)
    : await listingDoc.get();
  const listingData = listingSnapshot.data() as Listing | undefined;

  if (!listingSnapshot.exists || !listingData) {
    console.log(`Listing ${listingId} does not exist.`);
    return null;
  }

  return listingData;
};

export const buildListing = (
  seller: User & { id: string },
  overrides?: Partial<Listing>,
  nowMinutes?: number,
): Listing => {
  const now = new Date();
  const base = nowMinutes ?? now.getHours() * 60 + now.getMinutes();
  const timeStart = base + 60; // 1 hour from now
  const timeEnd = Math.min(base + 180, 1439); // 3 hours from now, capped at 23:59

  return {
    sellerId: seller.id,
    sellerName: seller.name,
    sellerRating: seller.stars ?? 5,
    diningHall: "Lenoir",
    timeStart,
    timeEnd,
    transactionDate: Timestamp.fromDate(now),
    paymentTypes: ["Venmo"],
    price: 5.0,
    status: listingStatus.active,
    ...overrides,
  };
};

export const patchListing = (
  listingId: string,
  patch: UpdateData<Listing>,
  writer?: FirestoreWriter,
): Promise<WriteResult> | void => {
  const listingDoc = admin.firestore().collection("listings").doc(listingId);
  const data = patch as UpdateData<DocumentData>;
  if (writer) {
    writer.update(listingDoc, data);
  } else {
    return listingDoc.update(data);
  }
};

export const createListing = async (
  seller: User & { id: string },
  overrides?: Partial<Listing>,
  nowMinutes?: number,
): Promise<string> => {
  const listing = buildListing(seller, overrides, nowMinutes);
  const ref = await admin.firestore().collection("listings").add(listing);
  return ref.id;
};

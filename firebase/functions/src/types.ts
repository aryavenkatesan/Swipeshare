import type { DocumentData, DocumentReference, Timestamp, UpdateData } from "firebase-admin/firestore";

/**
 * Structural interface satisfied by both WriteBatch and Transaction.
 * Avoids union-type overload resolution issues when passing either to service patch functions.
 */
export interface FirestoreWriter {
  update(
    documentRef: DocumentReference<DocumentData>,
    data: UpdateData<DocumentData>,
  ): unknown;
}

export const messageTypes = ["text", "system", "timeProposal"] as const;
export type MessageType = (typeof messageTypes)[number];

// TimeOfDay string type matching Flutter's TimeFormatter.productionToString format
// Format: "TimeOfDay(HH:MM)" where HH and MM are zero-padded
export type TimeOfDayString = `TimeOfDay(${string}:${string})`;

// Base message fields shared by all message types
type BaseMessage = {
  messageType: MessageType;
  senderId: string;
  senderEmail: string;
  senderName: string;
  timestamp?: Timestamp; // optional: set by server on creation
};

export type TextMessage = BaseMessage & {
  messageType: "text";
  content: string;
};

export type SystemMessage = BaseMessage & {
  messageType: "system";
  content: string;
};

export type TimeProposal = BaseMessage & {
  messageType: "timeProposal";
  proposedTime: TimeOfDayString;
  status: "pending" | "accepted" | "declined";
};

export type Message = TextMessage | SystemMessage | TimeProposal;

export const listingStatus = {
  active: "active",
  claimed: "claimed",
  cancelled: "cancelled",
  expired: "expired",
} as const;

export type ListingStatus = (typeof listingStatus)[keyof typeof listingStatus];

export type Listing = {
  sellerId: string;
  sellerName: string;
  diningHall: string;
  timeStart: number; // minutes since midnight (TimeOfDay converted via toMinutes)
  timeEnd: number; // minutes since midnight (TimeOfDay converted via toMinutes)
  transactionDate: Timestamp;
  sellerRating: number;
  paymentTypes: string[];
  price?: number;
  status: ListingStatus;
};

export const orderStatus = {
  active: "active",
  completed: "completed",
  cancelled: "cancelled",
} as const;

export type OrderStatus = (typeof orderStatus)[keyof typeof orderStatus];

export type OrderRole = "buyer" | "seller";

export type OrderParticipant = {
  id: string;
  name: string;
  stars: number;
  hasNotifs: boolean;
  markedComplete: boolean;
  rating?: Rating;
};

export type Order = {
  seller: OrderParticipant;
  buyer: OrderParticipant;
  diningHall: string;
  displayTime?: TimeOfDayString;
  transactionDate: Timestamp;
  status: OrderStatus;
  price: number;
  cancelledBy?: OrderRole;
  cancellationAcknowledged: boolean;
};

export const userStatus = {
  active: "active",
  deleted: "deleted",
  banned: "banned",
} as const;

export type UserStatus = (typeof userStatus)[keyof typeof userStatus];

export type User = {
  email: string;
  name: string;
  stars: number;
  fcmToken?: string;
  isEmailVerified: boolean;
  verificationCode?: string;
  verificationCodeExpires?: Timestamp;
  status: UserStatus;
  payment_types: string[];
  transactions_completed: number;
  referral_email: string;
  blocked_users: string[];
  moneySaved: number;
  moneyEarned: number;
  notifSettings: NotifSettings;
  hasSeenAppFeedback: boolean;
};

export type NotifSettings = {
  newOrders: boolean;
  newMessages: boolean;
  orderConfirmations?: boolean;
  orderCancellations?: boolean;
};

export type Rating = {
  stars: number;
  extraInfo?: string;
  timestamp: Timestamp;
};

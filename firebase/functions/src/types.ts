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
  status: "pending" | "accepted" | "rejected";
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
  transactionDate: FirebaseFirestore.Timestamp;
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

export type Order = {
  sellerId: string;
  sellerName: string;
  sellerStars: number;
  buyerId: string;
  buyerName: string;
  buyerStars: number;
  diningHall: string;
  displayTime?: TimeOfDayString;
  sellerHasNotifs: boolean;
  buyerHasNotifs: boolean;
  transactionDate: FirebaseFirestore.Timestamp;
  ratingByBuyer?: Rating;
  ratingBySeller?: Rating;
  status: OrderStatus;
  price: number;
};

export type User = {
  name: string;
  stars: number;
  fcmToken?: string;
  isEmailVerified: boolean;
  transactions_completed: number;
  moneySaved: number;
  moneyEarned: number;
  // other fields aren't relevant
};

export type Rating = {
  stars: number;
  extraInfo?: string;
  timestamp: FirebaseFirestore.Timestamp;
};

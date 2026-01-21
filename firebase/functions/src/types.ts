export const messageTypes = ["text", "system", "timeProposal"] as const;
export type MessageType = (typeof messageTypes)[number];

// TimeOfDay string type matching Flutter's TimeFormatter.productionToString format
// Format: "TimeOfDay(HH:MM)" where HH and MM are zero-padded
type Digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9";
export type TimeOfDayString = `TimeOfDay(${Digit}${Digit}:${Digit}${Digit})`;

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
  proposedTime: string; // TimeOfDay formatted as string
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

export type Order = {
  sellerId: string;
  sellerName: string;
  sellerVisibility: boolean;
  sellerStars: number;
  buyerId: string;
  buyerName: string;
  buyerVisibility: boolean;
  buyerStars: number;
  diningHall: string;
  displayTime?: TimeOfDayString;
  sellerHasNotifs: boolean;
  buyerHasNotifs: boolean;
  transactionDate: string; // ISO 8601 string
  isChatDeleted: boolean;
};

export type User = {
  name: string;
  stars: number;
  fcmToken?: string;
  isEmailVerified: boolean;
  // other fields aren't relevant
};

export type Message = {
  senderId: string;
  receiverId: string;
  senderName: string;
  message?: string;
  status?: "accepted" | "declined";
  // other fields aren't relevant
};

export type Order = {
  buyerId: string;
  buyerName: string;
  sellerId: string;
  sellerName: string;
  transactionDate: string;
  sellerHasNotifs: boolean;
  buyerHasNotifs: boolean;
  // other fields aren't relevant
};

export type User = {
  fcmToken?: string;
  // other fields aren't relevant
};
export const messageTypes = ['text', 'system', 'timeProposal'] as const;
export type MessageType = (typeof messageTypes)[number];

// Base message fields shared by all message types
type BaseMessage = {
  messageType: MessageType;
  senderId: string;
  senderEmail: string;
  senderName: string;
};

export type TextMessage = BaseMessage & {
  messageType: 'text';
  content: string;
};

export type SystemMessage = BaseMessage & {
  messageType: 'system';
  content: string;
};

export type TimeProposal = BaseMessage & {
  messageType: 'timeProposal';
  proposedTime: string; // TimeOfDay formatted as string
  status: 'pending' | 'accepted' | 'rejected';
};

export type Message = TextMessage | SystemMessage | TimeProposal;

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
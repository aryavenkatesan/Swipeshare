import * as admin from "firebase-admin";

admin.initializeApp();

export * from "./functions/notifications";
export * from "./functions/remote-call";
export * from "./functions/ratings";
export * from "./functions/system-messages";
export * from "./functions/forgot-password";

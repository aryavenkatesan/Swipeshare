import * as admin from "firebase-admin";

admin.initializeApp();

export * from "./functions/notifications";
export * from "./functions/remote-call";

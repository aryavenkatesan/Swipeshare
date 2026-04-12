import * as admin from "firebase-admin";

admin.initializeApp();

export * from "./functions/delete-account";
export * from "./functions/email-verification";
export * from "./functions/forgot-password";
export * from "./functions/notifications";
export * from "./functions/order-transaction";
export * from "./functions/ratings";
export * from "./functions/reports";
export * from "./functions/resource-lifecycle";
if (process.env.FUNCTIONS_EMULATOR) {
  module.exports = { ...module.exports, ...require("./functions/dev") };
}

// Connect to local emulators before importing firebase-admin
process.env["FIRESTORE_EMULATOR_HOST"] = "localhost:8080";
process.env["FIREBASE_AUTH_EMULATOR_HOST"] = "localhost:9099";

import * as admin from "firebase-admin";

admin.initializeApp({ projectId: "swipeshare-c24d1" });

const auth = admin.auth();
const db = admin.firestore();

// ---------------------------------------------------------------------------
// Seed data
// ---------------------------------------------------------------------------

interface SeedUser {
  uid: string;
  email: string;
  name: string;
  payment_types: string[];
}

function userDefaults(user: SeedUser) {
  return {
    email: user.email,
    name: user.name,
    payment_types: user.payment_types,
    stars: 5,
    transactions_completed: 0,
    referral_email: "",
    blocked_users: [],
    isEmailVerified: true,
    moneySaved: 0,
    moneyEarned: 0,
    notifSettings: { newOrders: true, newMessages: true },
    hasSeenAppFeedback: false,
    status: "active",
  };
}

const users: SeedUser[] = [
  {
    uid: "cbXS5WxIqjWcbxdnnlOLHTNSTS92",
    email: "naasanov+a@unc.edu",
    name: "n",
    payment_types: ["Cash", "Venmo", "Zelle", "PayPal", "CashApp"],
  },
  {
    uid: "5NYXMDkIm1VroafedKVarXhqf1n1",
    email: "naasanov@unc.edu",
    name: "Nick",
    payment_types: ["Cash", "Venmo", "Zelle", "PayPal", "CashApp"],
  },
  {
    uid: "hvWDeXIpRdVMjNZyvEdBW7YKUxH2",
    email: "vmshah2@unc.edu",
    name: "Vidur",
    payment_types: ["Cash", "Venmo"],
  },
  {
    uid: "j0FKMOHvulaOgUS5BTDEOdbBZ612",
    email: "aryav@unc.edu",
    name: "Arya",
    payment_types: ["Cash", "Zelle", "Venmo", "Apple Pay", "PayPal", "CashApp"],
  },
  {
    uid: "testuser1000000000000000000001",
    email: "testuser1@unc.edu",
    name: "Test User 1",
    payment_types: ["Cash", "Venmo"],
  },
  {
    uid: "testuser1000000000000000000002",
    email: "testuser2@unc.edu",
    name: "Test User 2",
    payment_types: ["Cash", "Zelle"],
  },
  {
    uid: "testuser1000000000000000000003",
    email: "testuser3@unc.edu",
    name: "Test User 3",
    payment_types: ["Cash"],
  },
];

// ---------------------------------------------------------------------------
// Seeding logic
// ---------------------------------------------------------------------------

async function seedUsers() {
  console.log("Seeding users...");

  for (const user of users) {
    // Create Auth user
    try {
      await auth.createUser({ uid: user.uid, email: user.email, password: "password" });
      console.log(`  ✓ Auth: ${user.email}`);
    } catch (err: any) {
      if (err.code === "auth/uid-already-exists" || err.code === "auth/email-already-exists") {
        console.log(`  ~ Auth already exists, skipping: ${user.email}`);
      } else {
        throw err;
      }
    }

    // Create Firestore document
    await db.collection("users").doc(user.uid).set(userDefaults(user), { merge: true });
    console.log(`  ✓ Firestore: ${user.email}`);
  }

  console.log(`\nDone. Seeded ${users.length} users.`);
}

seedUsers().catch((err) => {
  console.error(err);
  process.exit(1);
});

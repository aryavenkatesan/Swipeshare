// Entry point that runs all integration test flows.
// Run with: flutter test integration_test/app_test.dart
//
// You can also run a single flow directly:
//   flutter test integration_test/flows/create_listing_test.dart

import 'flows/create_listing_test.dart' as create_listing;
import 'flows/order_lifecycle_test.dart' as order_lifecycle;
import 'flows/user_signup_test.dart' as user_signup;
import 'flows/report_user_test.dart' as report_user;
import 'flows/delete_account_test.dart' as delete_account;

void main() {
  create_listing.main();
  order_lifecycle.main();
  user_signup.main();
  report_user.main();
  delete_account.main();
}

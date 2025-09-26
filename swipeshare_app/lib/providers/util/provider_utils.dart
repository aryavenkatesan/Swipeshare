import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipeshare_app/providers/listing_provider.dart';
import 'package:swipeshare_app/providers/order_provider.dart';
import 'package:swipeshare_app/providers/user_provider.dart';

void initializeAuthBasedProviders(BuildContext context) {
  context.read<UserProvider>().ensureInitialized();
  context.read<OrderProvider>().ensureInitialized();
  context.read<ListingProvider>().ensureInitialized();
}

void resetAuthBasedProviders(BuildContext context) {
  context.read<UserProvider>().ensureReset();
  context.read<OrderProvider>().ensureReset();
  context.read<ListingProvider>().ensureReset();
}

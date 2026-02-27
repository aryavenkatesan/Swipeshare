import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/listing_form/listing_form.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/pages/sell/confirm_listing_page.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class CreateSwipeListingPage extends StatefulWidget {
  const CreateSwipeListingPage({super.key});

  @override
  State<CreateSwipeListingPage> createState() => _CreateSwipeListingPageState();
}

class _CreateSwipeListingPageState extends State<CreateSwipeListingPage> {
  List<String>? _initialPaymentTypes;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserPaymentTypes();
  }

  Future<void> _loadUserPaymentTypes() async {
    try {
      final user = await UserService.instance.getCurrentUser();
      if (mounted) {
        setState(() {
          _initialPaymentTypes = user.paymentTypes;
          _loadingUser = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _initialPaymentTypes = [];
          _loadingUser = false;
        });
      }
    }
  }

  void _onSubmit(BuildContext context, ListingFormData data) {
    safeVibrate(HapticsType.medium);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmListingPage(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const PageAppBar(title: 'Sell Swipes'),
      body: ListingForm(
        initialPaymentTypes: _initialPaymentTypes,
        submitLabel: 'Next',
        onSubmit: (data) => _onSubmit(context, data),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_form/listing_form.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/listing_service.dart';

class EditListingPage extends StatefulWidget {
  final Listing listing;

  const EditListingPage({super.key, required this.listing});

  @override
  State<EditListingPage> createState() => _EditListingPageState();
}

class _EditListingPageState extends State<EditListingPage> {
  bool _isLoading = false;

  Future<void> _save(ListingFormData data) async {
    setState(() => _isLoading = true);
    try {
      await ListingService.instance.updateListing(
        widget.listing.id,
        diningHall: data.diningHall,
        timeStart: data.timeStart,
        timeEnd: data.timeEnd,
        transactionDate: data.transactionDate,
        paymentTypes: data.paymentTypes,
        price: data.price,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update listing. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageAppBar(title: 'Edit Listing'),
      body: ListingForm(
        initialListing: widget.listing,
        onSubmit: _save,
        submitLabel: 'Save',
        isLoading: _isLoading,
      ),
    );
  }
}

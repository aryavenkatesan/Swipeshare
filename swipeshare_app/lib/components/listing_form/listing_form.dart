import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/listing_form/date_selector_field.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/components/listing_form/dining_hall_selector.dart';
import 'package:swipeshare_app/components/listing_form/payment_options_field.dart';
import 'package:swipeshare_app/components/listing_form/price_stepper_field.dart';
import 'package:swipeshare_app/components/listing_form/time_range_selector.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/user_service.dart';

/// Holds the validated values collected by [ListingForm].
class ListingFormData {
  final String diningHall;
  final DateTime transactionDate;
  final TimeOfDay timeStart;
  final TimeOfDay timeEnd;
  final double price;
  final List<String> paymentTypes;

  const ListingFormData({
    required this.diningHall,
    required this.transactionDate,
    required this.timeStart,
    required this.timeEnd,
    required this.price,
    required this.paymentTypes,
  });
}

/// A reusable listing form for both creating and editing swipe listings.
///
/// Pre-fills fields from [initialListing] when provided (edit mode).
/// Calls [onSubmit] with the collected [ListingFormData] when the user
/// taps the submit button — only enabled once all required fields are filled.
class ListingForm extends StatefulWidget {
  /// Pre-fills all fields when editing an existing listing.
  final Listing? initialListing;

  /// Seeds the payment types when creating a new listing (e.g. from user profile).
  /// Ignored when [initialListing] is provided.
  final List<String>? initialPaymentTypes;

  /// Called when the user successfully submits the form.
  final void Function(ListingFormData data) onSubmit;

  /// Label shown on the submit button (e.g. "Save" or "Post Listing").
  final String submitLabel;

  /// Whether the submit button is showing a loading indicator.
  final bool isLoading;

  const ListingForm({
    super.key,
    this.initialListing,
    this.initialPaymentTypes,
    required this.onSubmit,
    this.submitLabel = 'Save',
    this.isLoading = false,
  });

  @override
  State<ListingForm> createState() => _ListingFormState();
}

const _diningHallHours = {
  'Lenoir': (min: TimeOfDay(hour: 7, minute: 0), max: TimeOfDay(hour: 20, minute: 30)),
  'Chase':  (min: TimeOfDay(hour: 7, minute: 0), max: TimeOfDay(hour: 23, minute: 59)),
};

class _ListingFormState extends State<ListingForm> {
  String? _diningHall;
  DateTime? _transactionDate;
  TimeOfDay? _timeStart;
  TimeOfDay? _timeEnd;
  int _price = 5;
  List<String> _paymentTypes = [];

  static int _tod2min(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _clampToHall(TimeOfDay t) {
    final hours = _diningHallHours[_diningHall];
    if (hours == null) return t;
    final mins = _tod2min(t)
        .clamp(_tod2min(hours.min), _tod2min(hours.max));
    return TimeOfDay(hour: mins ~/ 60, minute: mins % 60);
  }

  void _onDiningHallChanged(String hall) {
    setState(() {
      _diningHall = hall;
      if (_timeStart != null) _timeStart = _clampToHall(_timeStart!);
      if (_timeEnd != null) _timeEnd = _clampToHall(_timeEnd!);
    });
  }

  bool get _isValidTimeRange {
    if (_timeStart == null || _timeEnd == null) return true;
    final s = _timeStart!.hour * 60 + _timeStart!.minute;
    final e = _timeEnd!.hour * 60 + _timeEnd!.minute;
    return e > s;
  }

  bool get _isTimeRangeInPast {
    if (_transactionDate == null || _timeEnd == null) return false;
    final now = DateTime.now();
    final endDateTime = DateTime(
      _transactionDate!.year,
      _transactionDate!.month,
      _transactionDate!.day,
      _timeEnd!.hour,
      _timeEnd!.minute,
    );
    return endDateTime.isBefore(now);
  }

  bool get _isComplete =>
      _diningHall != null &&
      _transactionDate != null &&
      _timeStart != null &&
      _timeEnd != null &&
      _paymentTypes.isNotEmpty &&
      _isValidTimeRange &&
      !_isTimeRangeInPast;

  String? get _missingFieldsHint {
    final missing = <String>[];
    if (_diningHall == null) missing.add('a dining hall');
    if (_timeStart == null) missing.add('a start time');
    if (_timeEnd == null) missing.add('an end time');
    if (!_isValidTimeRange) missing.add('a valid time range');
    if (_isTimeRangeInPast) missing.add('a future time range');
    if (_paymentTypes.isEmpty) missing.add('payment methods');
    if (missing.isEmpty) return null;
    return 'Please select ${missing.join(', ')}';
  }

  @override
  void initState() {
    super.initState();
    final l = widget.initialListing;
    if (l != null) {
      // Edit mode: pre-fill everything from the existing listing.
      _diningHall = l.diningHall;
      _transactionDate = l.transactionDate;
      _timeStart = l.timeStart;
      _timeEnd = l.timeEnd;
      _price = l.price?.round() ?? 5;
      _paymentTypes = List.from(l.paymentTypes);
    } else {
      // Create mode: default date to today; seed payment types from profile if provided.
      _transactionDate = DateTime.now();
      _loadDefaultPaymentTypes();
    }
  }

  Future<void> _loadDefaultPaymentTypes() async {
    final user = await UserService.instance.getCurrentUser();
    if (!mounted) return;
    setState(() => _paymentTypes = List.from(user.paymentTypes));
  }

  Future<void> _submit() async {
    if (!_isComplete) return;
    await safeVibrate(HapticsType.success);
    widget.onSubmit(
      ListingFormData(
        diningHall: _diningHall!,
        transactionDate: _transactionDate!,
        timeStart: _timeStart!,
        timeEnd: _timeEnd!,
        price: _price.toDouble(),
        paymentTypes: List.from(_paymentTypes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          Text(
            'Set up your swipe listing with location, time, and payment preferences.',
            style: textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 24),

          // Dining hall toggle
          DiningHallSelector(
            selected: _diningHall,
            onChanged: _onDiningHallChanged,
          ),
          const SizedBox(height: 16),

          // Date picker
          DateSelectorField(
            selectedDate: _transactionDate,
            onChanged: (date) => setState(() => _transactionDate = date),
          ),
          const SizedBox(height: 16),

          // Start / end time pickers
          TimeRangeSelector(
            timeStart: _timeStart,
            timeEnd: _timeEnd,
            minTime: _diningHallHours[_diningHall]?.min,
            maxTime: _diningHallHours[_diningHall]?.max,
            onStartChanged: (t) => setState(() => _timeStart = t),
            onEndChanged: (t) => setState(() => _timeEnd = t),
            onNow: () {
              final now = DateTime.now();
              final end = now.add(const Duration(minutes: 30));
              setState(() {
                _timeStart = TimeOfDay(hour: now.hour, minute: now.minute);
                _timeEnd = TimeOfDay(hour: end.hour, minute: end.minute);
              });
            },
          ),
          const SizedBox(height: 16),

          // Price stepper
          PriceStepperField(
            price: _price,
            onChanged: (p) => setState(() => _price = p),
          ),
          const SizedBox(height: 16),

          // Payment options
          PaymentOptionsField(
            selected: _paymentTypes,
            onChanged: (opts) => setState(() => _paymentTypes = opts),
          ),
          const SizedBox(height: 32),

          // Missing fields hint
          if (_missingFieldsHint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _missingFieldsHint!,
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 14),
              ),
            ),

          // Submit button
          ElevatedButton(
            onPressed: (_isComplete && !widget.isLoading) ? _submit : null,
            child: widget.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}

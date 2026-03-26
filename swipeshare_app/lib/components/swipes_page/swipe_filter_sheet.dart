import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/listing_form/time_range_selector.dart';
import 'package:swipeshare_app/components/swipes_page/date_range_picker_chip.dart';
import 'package:swipeshare_app/components/swipes_page/filter_chip.dart';
import 'package:swipeshare_app/models/user.dart';

/// Holds all filter values for the swipes listing page.
class SwipeFilterData {
  final Set<String> locations;
  final Set<String> dates;
  final DateTimeRange? otherRange;
  final TimeOfDay? startAt;
  final TimeOfDay? endAt;
  final Set<String> paymentTypes;
  final double? maxPrice;

  SwipeFilterData({
    required this.locations,
    required this.dates,
    this.otherRange,
    this.startAt,
    this.endAt,
    required this.paymentTypes,
    this.maxPrice,
  });

  /// Default: all locations, today, all payment methods (= no payment filter).
  static SwipeFilterData get defaults => SwipeFilterData(
        locations: {'Lenoir', 'Chase'},
        dates: {'Today'},
        paymentTypes: Set.from(PaymentOption.allPaymentTypeNames),
      );

  SwipeFilterData copyWith({
    Set<String>? locations,
    Set<String>? dates,
    Object? otherRange = _keep,
    Object? startAt = _keep,
    Object? endAt = _keep,
    Set<String>? paymentTypes,
    Object? maxPrice = _keep,
  }) =>
      SwipeFilterData(
        locations: locations ?? Set.from(this.locations),
        dates: dates ?? Set.from(this.dates),
        otherRange:
            otherRange == _keep ? this.otherRange : otherRange as DateTimeRange?,
        startAt: startAt == _keep ? this.startAt : startAt as TimeOfDay?,
        endAt: endAt == _keep ? this.endAt : endAt as TimeOfDay?,
        paymentTypes: paymentTypes ?? Set.from(this.paymentTypes),
        maxPrice: maxPrice == _keep ? this.maxPrice : maxPrice as double?,
      );
}

const Object _keep = Object();

/// Shows the filter bottom sheet.
/// Returns updated [SwipeFilterData] on Save, or null on dismiss.
Future<SwipeFilterData?> showSwipeFilterSheet(
  BuildContext context,
  SwipeFilterData current,
) {
  return showModalBottomSheet<SwipeFilterData>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _SwipeFilterSheetContent(initial: current),
  );
}

class _SwipeFilterSheetContent extends StatefulWidget {
  final SwipeFilterData initial;
  const _SwipeFilterSheetContent({required this.initial});

  @override
  State<_SwipeFilterSheetContent> createState() =>
      _SwipeFilterSheetContentState();
}

class _SwipeFilterSheetContentState extends State<_SwipeFilterSheetContent> {
  late Set<String> _locations;
  late Set<String> _dates;
  late DateTimeRange? _otherRange;
  late TimeOfDay? _startAt;
  late TimeOfDay? _endAt;
  late Set<String> _paymentTypes;
  late double? _maxPrice;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _locations = Set.from(widget.initial.locations);
    _dates = Set.from(widget.initial.dates);
    _otherRange = widget.initial.otherRange;
    _startAt = widget.initial.startAt;
    _endAt = widget.initial.endAt;
    _paymentTypes = Set.from(widget.initial.paymentTypes);
    _maxPrice = widget.initial.maxPrice;
    _priceController = TextEditingController(
      text: _maxPrice != null
          ? (_maxPrice! == _maxPrice!.roundToDouble()
              ? _maxPrice!.toInt().toString()
              : _maxPrice!.toStringAsFixed(2))
          : '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _toggle(Set<String> set, String value) {
    setState(() {
      if (set.contains(value)) {
        set.remove(value);
      } else {
        set.add(value);
      }
    });
  }

  void _reset() {
    final d = SwipeFilterData.defaults;
    setState(() {
      _locations = Set.from(d.locations);
      _dates = Set.from(d.dates);
      _otherRange = null;
      _startAt = null;
      _endAt = null;
      _paymentTypes = Set.from(d.paymentTypes);
      _maxPrice = null;
      _priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 11, 15, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header: Reset | Filters | X ──
              Row(
                children: [
                  TextButton(
                    onPressed: _reset,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Reset',
                      style: textTheme.bodyLarge
                          ?.copyWith(color: SwipeshareColors.primary),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Filters',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Location ──
              Text(
                'Location',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SwipesFilterChip(
                    label: 'Lenoir',
                    selected: _locations.contains('Lenoir'),
                    onTap: () => _toggle(_locations, 'Lenoir'),
                  ),
                  const SizedBox(width: 8),
                  SwipesFilterChip(
                    label: 'Chase',
                    selected: _locations.contains('Chase'),
                    onTap: () => _toggle(_locations, 'Chase'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Date ──
              Text(
                'Date',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SwipesFilterChip(
                    label: 'Today',
                    selected: _dates.contains('Today'),
                    onTap: () => _toggle(_dates, 'Today'),
                  ),
                  const SizedBox(width: 8),
                  SwipesFilterChip(
                    label: 'Tomorrow',
                    selected: _dates.contains('Tomorrow'),
                    onTap: () => _toggle(_dates, 'Tomorrow'),
                  ),
                  const SizedBox(width: 8),
                  DateRangePickerChip(
                    value: _otherRange,
                    onChanged: (r) => setState(() => _otherRange = r),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Time ──
              Text(
                'Time',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TimeRangeSelector(
                timeStart: _startAt,
                timeEnd: _endAt,
                onStartChanged: (t) => setState(() => _startAt = t),
                onEndChanged: (t) => setState(() => _endAt = t),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  final now = TimeOfDay.now();
                  final nextHour = TimeOfDay(
                    hour: (now.hour + 1) % 24,
                    minute: now.minute,
                  );
                  setState(() {
                    _startAt = now;
                    _endAt = nextHour;
                  });
                },
                child: Text(
                  'Choose current time',
                  style: textTheme.bodyLarge
                      ?.copyWith(color: SwipeshareColors.primary),
                ),
              ),
              const SizedBox(height: 16),

              // ── Payment Options ──
              Text(
                'Payment Options',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final opt in PaymentOption.allPaymentOptions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SwipesFilterChip(
                          label: opt.name,
                          selected: _paymentTypes.contains(opt.name),
                          onTap: () => _toggle(_paymentTypes, opt.name),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Max Price ──
              Text(
                'Max Price',
                style: textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    prefixText: '\$ ',
                    hintText: 'Any',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _maxPrice =
                          val.isEmpty ? null : double.tryParse(val);
                    });
                  },
                ),
              ),
              const SizedBox(height: 32),

              // ── Save ──
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(
                  SwipeFilterData(
                    locations: Set.from(_locations),
                    dates: Set.from(_dates),
                    otherRange: _otherRange,
                    startAt: _startAt,
                    endAt: _endAt,
                    paymentTypes: Set.from(_paymentTypes),
                    maxPrice: _maxPrice,
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

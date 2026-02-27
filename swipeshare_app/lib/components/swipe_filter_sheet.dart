import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/listing_form/time_range_selector.dart';
import 'package:swipeshare_app/models/user.dart';

/// Holds all filter values for the swipes listing page.
class SwipeFilterData {
  final Set<String> locations;
  final Set<String> dates;
  final DateTimeRange? otherRange;
  final TimeOfDay? startAt;
  final TimeOfDay? endAt;
  final Set<String> paymentTypes;

  SwipeFilterData({
    required this.locations,
    required this.dates,
    this.otherRange,
    this.startAt,
    this.endAt,
    required this.paymentTypes,
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
  }) =>
      SwipeFilterData(
        locations: locations ?? Set.from(this.locations),
        dates: dates ?? Set.from(this.dates),
        otherRange:
            otherRange == _keep ? this.otherRange : otherRange as DateTimeRange?,
        startAt: startAt == _keep ? this.startAt : startAt as TimeOfDay?,
        endAt: endAt == _keep ? this.endAt : endAt as TimeOfDay?,
        paymentTypes: paymentTypes ?? Set.from(this.paymentTypes),
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

  @override
  void initState() {
    super.initState();
    _locations = Set.from(widget.initial.locations);
    _dates = Set.from(widget.initial.dates);
    _otherRange = widget.initial.otherRange;
    _startAt = widget.initial.startAt;
    _endAt = widget.initial.endAt;
    _paymentTypes = Set.from(widget.initial.paymentTypes);
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
    });
  }

  Future<void> _tapOtherRange() async {
    // Toggle off if already set
    if (_otherRange != null) {
      setState(() => _otherRange = null);
      return;
    }
    await _pickOtherRange();
  }

  Future<void> _pickOtherRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = today.add(const Duration(days: 30));

    final result = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: lastDate,
      initialDateRange: _otherRange,
    );

    if (result != null) setState(() => _otherRange = result);
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
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _FilterChip(
                    label: 'Lenoir',
                    selected: _locations.contains('Lenoir'),
                    onTap: () => _toggle(_locations, 'Lenoir'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
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
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _FilterChip(
                    label: 'Today',
                    selected: _dates.contains('Today'),
                    onTap: () => _toggle(_dates, 'Today'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Tomorrow',
                    selected: _dates.contains('Tomorrow'),
                    onTap: () => _toggle(_dates, 'Tomorrow'),
                  ),
                  const SizedBox(width: 8),
                  // "Other" — chip when range selected, plain text link when not
                  if (_otherRange != null)
                    _FilterChip(
                      label:
                          '${_otherRange!.start.month}/${_otherRange!.start.day}–'
                          '${_otherRange!.end.month}/${_otherRange!.end.day}',
                      selected: true,
                      onTap: _tapOtherRange,
                    )
                  else
                    GestureDetector(
                      onTap: _tapOtherRange,
                      child: Text(
                        'Other',
                        style: textTheme.bodyLarge
                            ?.copyWith(color: SwipeshareColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Time (deactivated until user picks; null = no filter) ──
              Text(
                'Time',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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

              // ── Payment Options (horizontal scroll) ──
              Text(
                'Payment Options',
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final opt in PaymentOption.allPaymentOptions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: opt.name,
                          selected: _paymentTypes.contains(opt.name),
                          onTap: () => _toggle(_paymentTypes, opt.name),
                        ),
                      ),
                  ],
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

/// A toggleable pill chip. Both selected and unselected always show a black border
/// (matches Figma 621:1270 spec). Selected = blue bg, unselected = white bg.
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE2ECF9) : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w300,
              ),
        ),
      ),
    );
  }
}

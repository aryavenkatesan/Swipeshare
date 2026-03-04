import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/swipes_page/pill.dart';
import 'package:swipeshare_app/components/swipes_page/swipe_filter_sheet.dart';
import 'package:swipeshare_app/models/user.dart';

/// Interactive pill row for the swipes page.
/// The four default pills (Lenoir, Chase, Today, Tomorrow) are always shown.
/// Extra pills (time range, payment) appear when set via the filter sheet.
/// Selected pills are always sorted before unselected ones.
class FilterPillRow extends StatelessWidget {
  final SwipeFilterData filterData;
  final ValueChanged<String> onToggleLocation;
  final ValueChanged<String> onToggleDate;
  final VoidCallback onOpenSheet;
  final VoidCallback onClearTime;
  final VoidCallback onClearPayment;

  const FilterPillRow({
    super.key,
    required this.filterData,
    required this.onToggleLocation,
    required this.onToggleDate,
    required this.onOpenSheet,
    required this.onClearTime,
    required this.onClearPayment,
  });

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min =
        t.minute == 0 ? '' : ':${t.minute.toString().padLeft(2, '0')}';
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour$min $period';
  }

  String get _timePillLabel {
    final start = filterData.startAt;
    final end = filterData.endAt;
    if (start != null && end != null) {
      return '${_formatTime(start)}–${_formatTime(end)}';
    } else if (start != null) {
      return 'After ${_formatTime(start)}';
    } else {
      return 'Before ${_formatTime(end!)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTimePill =
        filterData.startAt != null || filterData.endAt != null;
    final allPayNames = Set.from(PaymentOption.allPaymentTypeNames);
    final hasPaymentPill = filterData.paymentTypes.isNotEmpty &&
        !filterData.paymentTypes.containsAll(allPayNames);

    // Build selected and unselected pill lists separately so selected always
    // appear first, preserving relative order within each group.
    final selectedPills = <Widget>[];
    final unselectedPills = <Widget>[];

    void addPill(String label, bool selected, VoidCallback onTap) {
      final pill = Pill(label: label, selected: selected, onTap: onTap);
      (selected ? selectedPills : unselectedPills).add(pill);
    }

    addPill(
      ' Lenoir ',
      filterData.locations.contains('Lenoir'),
      () => onToggleLocation('Lenoir'),
    );
    addPill(
      ' Chase ',
      filterData.locations.contains('Chase'),
      () => onToggleLocation('Chase'),
    );
    addPill(
      ' Today ',
      filterData.dates.contains('Today'),
      () => onToggleDate('Today'),
    );
    addPill(
      ' Tomorrow ',
      filterData.dates.contains('Tomorrow'),
      () => onToggleDate('Tomorrow'),
    );

    // Extra pills are always selected when visible — append to selected list.
    if (filterData.otherRange != null) {
      final r = filterData.otherRange!;
      selectedPills.add(Pill(
        label: ' ${r.start.month}/${r.start.day}–${r.end.month}/${r.end.day} ',
        selected: true,
        onTap: onOpenSheet,
      ));
    }
    if (hasTimePill) {
      selectedPills.add(Pill(
        label: ' $_timePillLabel ',
        selected: true,
        onTap: onClearTime,
      ));
    }
    if (hasPaymentPill) {
      selectedPills.add(Pill(
        label: ' Payment ',
        selected: true,
        onTap: onClearPayment,
      ));
    }

    final allPills = [...selectedPills, ...unselectedPills];

    // Build row with SizedBox spacers between pills.
    final rowChildren = <Widget>[
      GestureDetector(
        onTap: onOpenSheet,
        child: Icon(Icons.tune, color: SwipeshareColors.primary, size: 32),
      ),
    ];
    for (final pill in allPills) {
      rowChildren.add(const SizedBox(width: 8));
      rowChildren.add(pill);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: rowChildren),
    );
  }
}

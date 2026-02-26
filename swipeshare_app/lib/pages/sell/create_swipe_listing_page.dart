import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/page_app_bar.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/pages/sell/confirm_listing_page.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/time_formatter.dart';

class CreateSwipeListingPage extends StatefulWidget {
  const CreateSwipeListingPage({super.key});

  @override
  State<CreateSwipeListingPage> createState() => _CreateSwipeListingPageState();
}

class _CreateSwipeListingPageState extends State<CreateSwipeListingPage> {
  static const List<String> _locations = ['Chase', 'Lenoir'];
  static const double _price = 7.0;

  String? _selectedLocation;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final List<String> _paymentOptions = [];
  bool _paymentExpanded = false;

  bool get _canPost =>
      _selectedLocation != null &&
      _startTime != null &&
      _endTime != null &&
      _paymentOptions.isNotEmpty &&
      !_isEndBeforeStart();

  bool _isEndBeforeStart() {
    if (_startTime == null || _endTime == null) return false;
    return (_endTime!.hour * 60 + _endTime!.minute) <=
        (_startTime!.hour * 60 + _startTime!.minute);
  }

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  String _formatTime(TimeOfDay time) =>
      TimeFormatter.formatTimeOfDay(TimeFormatter.productionToString(time));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const PageAppBar(title: 'Sell Swipes'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set up your swipe listing with location, time, and payment preferences',
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),

                  Text('Location', style: textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  _buildLocationSelector(textTheme),
                  const SizedBox(height: 16),

                  Text('Date', style: textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  _buildDateRow(textTheme),
                  const SizedBox(height: 16),

                  Text('Time', style: textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  _buildTimeRow(textTheme),
                  const SizedBox(height: 16),

                  Text('Price', style: textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  _buildPriceRow(textTheme),
                  const SizedBox(height: 16),

                  _buildPaymentOptions(textTheme),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton(
              onPressed: _canPost ? _navigateToConfirm : null,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSelector(TextTheme textTheme) {
    return Row(
      children: _locations.asMap().entries.map((entry) {
        final isLast = entry.key == _locations.length - 1;
        final loc = entry.value;
        final isSelected = _selectedLocation == loc;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLocation = loc),
              child: Container(
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? SwipeshareColors.primary
                      : SwipeshareColors.surface,
                  border: Border.all(
                    color: isSelected
                        ? SwipeshareColors.primary
                        : SwipeshareColors.outline,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isSelected
                        ? SwipeshareColors.onPrimary
                        : SwipeshareColors.onBackground,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRow(TextTheme textTheme) {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: SwipeshareColors.surface,
          border: Border.all(color: SwipeshareColors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: SwipeshareColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(_formattedDate, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(TextTheme textTheme) {
    final labelStyle = textTheme.bodyLarge?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    );

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickStartTime,
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: SwipeshareColors.surface,
                border: Border.all(color: SwipeshareColors.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start at', style: labelStyle),
                  Text(
                    _startTime != null ? _formatTime(_startTime!) : '--:--',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _pickEndTime,
            child: Container(
              height: 65,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: SwipeshareColors.surface,
                border: Border.all(color: SwipeshareColors.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('End at', style: labelStyle),
                  Text(
                    _endTime != null ? _formatTime(_endTime!) : '--:--',
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(TextTheme textTheme) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: SwipeshareColors.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_money,
            color: SwipeshareColors.outlineVariant,
            size: 20,
          ),
          Text(
            '${_price.toInt()}',
            style: textTheme.bodyLarge?.copyWith(
              color: SwipeshareColors.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions(TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        color: SwipeshareColors.surface,
        border: Border.all(color: SwipeshareColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _paymentExpanded = !_paymentExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Options', style: textTheme.bodyLarge),
                        Text(
                          _paymentOptions.isEmpty
                              ? 'Tap to select payment methods'
                              : '${_paymentOptions.length} method${_paymentOptions.length > 1 ? 's' : ''} selected',
                          style: textTheme.bodyLarge?.copyWith(
                            fontSize: 13,
                            height: 1.4,
                            color: _paymentOptions.isEmpty
                                ? SwipeshareColors.outlineVariant
                                : SwipeshareColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _paymentExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _paymentExpanded
                ? Column(
                    children: [
                      const Divider(
                        height: 1,
                        color: SwipeshareColors.outlineVariant,
                      ),
                      ...PaymentOption.allPaymentOptions.map((option) {
                        final isSelected =
                            _paymentOptions.contains(option.name);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (isSelected) {
                              _paymentOptions.remove(option.name);
                            } else {
                              _paymentOptions.add(option.name);
                            }
                          }),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  option.icon,
                                  color: SwipeshareColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option.name,
                                    style: textTheme.bodyLarge,
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: isSelected
                                      ? SwipeshareColors.primary
                                      : SwipeshareColors.outlineVariant,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _navigateToConfirm() async {
    await safeVibrate(HapticsType.medium);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmListingPage(
          location: _selectedLocation!,
          date: _selectedDate,
          startTime: _startTime!,
          endTime: _endTime!,
          price: _price,
          paymentOptions: List<String>.from(_paymentOptions),
        ),
      ),
    );
  }
}

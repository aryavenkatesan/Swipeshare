import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/listing_form/listing_form.dart';
import 'package:swipeshare_app/models/listing.dart';
import 'package:swipeshare_app/services/dev_service.dart';

class DevPage extends StatefulWidget {
  const DevPage({super.key});

  @override
  State<DevPage> createState() => _DevPageState();
}

class _DevPageState extends State<DevPage> {
  ColorScheme get _colors => Theme.of(context).colorScheme;
  TextTheme get _textTheme => Theme.of(context).textTheme;

  late SeedEmail _currentUser;
  late SeedEmail _listingSeller;
  bool _listingLoading = false;
  ListingFormData? _listingOverrides;

  late SeedEmail _orderSeller;
  SeedEmail _orderBuyer = SeedEmail.testUser1;
  bool _orderLoading = false;
  ListingFormData? _orderOverrides;

  @override
  void initState() {
    super.initState();
    final email = FirebaseAuth.instance.currentUser?.email;
    _currentUser =
        SeedEmail.values.where((e) => e.value == email).firstOrNull ??
        SeedEmail.nick;
    _listingSeller = _currentUser;
    _orderSeller = _currentUser;
    _orderBuyer = SeedEmail.values.firstWhere(
      (email) => email != _orderSeller,
      orElse: () => SeedEmail.nick,
    );
  }

  bool _clearLoading = false;
  bool _completeOrdersLoading = false;

  Map<String, dynamic> _toOverridesMap(ListingFormData data) {
    return {
      'diningHall': data.diningHall,
      'timeStart': data.timeStart.hour * 60 + data.timeStart.minute,
      'timeEnd': data.timeEnd.hour * 60 + data.timeEnd.minute,
      'price': data.price,
      'paymentTypes': data.paymentTypes,
    };
  }

  Listing _defaultDevListing() {
    final now = DateTime.now();
    final base = now.hour * 60 + now.minute;
    return Listing(
      id: '',
      sellerId: '',
      sellerName: '',
      diningHall: 'Lenoir',
      timeStart: Listing.minutesToTOD(base + 60),
      timeEnd: Listing.minutesToTOD((base + 180).clamp(0, 1439)),
      transactionDate: now,
      sellerRating: 5,
      paymentTypes: const ['Venmo'],
      price: 5.0,
      status: ListingStatus.active,
    );
  }

  Listing _listingFromFormData(ListingFormData data) {
    return Listing(
      id: '',
      sellerId: '',
      sellerName: '',
      diningHall: data.diningHall,
      timeStart: data.timeStart,
      timeEnd: data.timeEnd,
      transactionDate: data.transactionDate,
      sellerRating: 5,
      paymentTypes: data.paymentTypes,
      price: data.price,
      status: ListingStatus.active,
    );
  }

  Future<void> _showOverrideSheet(
    ListingFormData? currentOverrides,
    ValueChanged<ListingFormData> onSaved,
  ) async {
    final initial = currentOverrides != null
        ? _listingFromFormData(currentOverrides)
        : _defaultDevListing();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ListingForm(
        initialListing: initial,
        onSubmit: (data) {
          onSaved(data);
          Navigator.pop(context);
        },
        submitLabel: 'Apply overrides',
      ),
    );
  }

  Future<void> _createListing() async {
    setState(() => _listingLoading = true);
    try {
      await DevService.instance.createListing(
        sellerEmail: _listingSeller,
        overrides: _listingOverrides != null
            ? _toOverridesMap(_listingOverrides!)
            : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _listingLoading = false);
    }
  }

  Future<void> _completeOldOrders() async {
    setState(() => _completeOrdersLoading = true);
    try {
      final result = await DevService.instance.completeOldOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Completed ${result['completed']} orders, updated ${result['usersUpdated']} users',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _completeOrdersLoading = false);
    }
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'This will delete all listings, orders, and messages. User accounts are preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear', style: TextStyle(color: _colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _clearLoading = true);
    try {
      await DevService.instance.clearData();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data cleared')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _clearLoading = false);
    }
  }

  Future<void> _createOrder() async {
    if (_orderSeller == _orderBuyer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Seller and buyer must be different users'),
          backgroundColor: _colors.error,
        ),
      );
      return;
    }

    setState(() => _orderLoading = true);
    try {
      await DevService.instance.createOrder(
        sellerEmail: _orderSeller,
        buyerEmail: _orderBuyer,
        overrides: _orderOverrides != null
            ? _toOverridesMap(_orderOverrides!)
            : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: _colors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _orderLoading = false);
    }
  }

  Widget _emailDropdown({
    required String label,
    required SeedEmail value,
    required ValueChanged<SeedEmail?> onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        labelStyle: _textTheme.bodySmall,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SeedEmail>(
          value: value,
          isDense: true,
          isExpanded: true,
          style: _textTheme.bodySmall,
          items: SeedEmail.values
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.displayName, style: _textTheme.bodySmall),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: colors.surface,
        ),
      ),
    );
  }

  Widget _loadingButton({
    required bool isLoading,
    required VoidCallback onPressed,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _colors.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }

  Widget _overrideSection({
    required ListingFormData? overrides,
    required VoidCallback onCustomize,
    required VoidCallback onClear,
  }) {
    if (overrides == null) {
      return TextButton.icon(
        onPressed: onCustomize,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: _textTheme.bodySmall,
        ),
        icon: const Icon(Icons.tune, size: 12),
        label: const Text('Customize listing values'),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Text(
            '${overrides.diningHall}  ·  \$${overrides.price.toStringAsFixed(0)}'
            '  ·  ${overrides.timeStart.format(context)}-${overrides.timeEnd.format(context)}',
            style: _textTheme.bodySmall,
          ),
        ),
        TextButton(onPressed: onCustomize, child: const Text('Edit')),
        IconButton(
          onPressed: onClear,
          icon: const Icon(Icons.close, size: 18),
          tooltip: 'Clear overrides',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Listing', style: _textTheme.titleMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _emailDropdown(
                  label: 'Seller',
                  value: _listingSeller,
                  onChanged: (v) => setState(() => _listingSeller = v!),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _listingSeller = _listingSeller == _currentUser
                      ? SeedEmail.testUser1
                      : _currentUser;
                }),
                icon: const Icon(Icons.swap_horiz, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: 'Swap to test user',
              ),
            ],
          ),
          _overrideSection(
            overrides: _listingOverrides,
            onCustomize: () => _showOverrideSheet(
              _listingOverrides,
              (data) => setState(() => _listingOverrides = data),
            ),
            onClear: () => setState(() => _listingOverrides = null),
          ),
          const SizedBox(height: 4),
          _loadingButton(
            isLoading: _listingLoading,
            onPressed: _createListing,
            label: 'Create Listing',
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text('Create Order', style: _textTheme.titleMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _emailDropdown(
                  label: 'Seller',
                  value: _orderSeller,
                  onChanged: (v) => setState(() => _orderSeller = v!),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  final tmp = _orderSeller;
                  _orderSeller = _orderBuyer;
                  _orderBuyer = tmp;
                }),
                icon: const Icon(Icons.swap_horiz, size: 18),
                visualDensity: VisualDensity.compact,
                tooltip: 'Swap seller and buyer',
              ),
              Expanded(
                child: _emailDropdown(
                  label: 'Buyer',
                  value: _orderBuyer,
                  onChanged: (v) => setState(() => _orderBuyer = v!),
                ),
              ),
            ],
          ),
          _overrideSection(
            overrides: _orderOverrides,
            onCustomize: () => _showOverrideSheet(
              _orderOverrides,
              (data) => setState(() => _orderOverrides = data),
            ),
            onClear: () => setState(() => _orderOverrides = null),
          ),
          const SizedBox(height: 4),
          _loadingButton(
            isLoading: _orderLoading,
            onPressed: _createOrder,
            label: 'Create Order',
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text('Actions', style: _textTheme.titleMedium),
          const SizedBox(height: 6),
          _loadingButton(
            isLoading: _completeOrdersLoading,
            onPressed: _completeOldOrders,
            label: 'Complete Old Orders',
          ),
          const SizedBox(height: 6),
          _loadingButton(
            isLoading: _clearLoading,
            onPressed: _clearData,
            label: 'Clear All Data',
          ),
        ],
      ),
    );
  }
}

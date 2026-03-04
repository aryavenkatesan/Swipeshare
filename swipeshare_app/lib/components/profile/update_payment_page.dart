import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/models/user.dart';
import 'package:swipeshare_app/services/user_service.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:swipeshare_app/utils/snackbar_messages.dart';

class UpdatePaymentPage extends StatefulWidget {
  const UpdatePaymentPage({super.key});

  @override
  State<UpdatePaymentPage> createState() => _UpdatePaymentPageState();
}

class _UpdatePaymentPageState extends State<UpdatePaymentPage> {
  final _userService = UserService.instance;
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  bool _isLoading = true;
  bool _isSaving = false;
  List<String> _selectedOptions = [];

  @override
  void initState() {
    super.initState();
    _loadPaymentOptions();
  }

  Future<void> _loadPaymentOptions() async {
    final user = await _userService.getCurrentUser();
    if (mounted) {
      setState(() {
        _selectedOptions = List<String>.from(user.paymentTypes);
        _isLoading = false;
      });
    }
  }

  void _toggleOption(String option) async {
    await safeVibrate(HapticsType.selection);
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        _selectedOptions.add(option);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await _userService.updatePaymentTypes(_uid, _selectedOptions);
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SnackbarMessages.paymentMethodsUpdated)),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text("Payment Options", style: textTheme.displayLarge),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else ...[
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: PaymentOption.allPaymentOptions.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: Color(0xFFE0E0E0),
                ),
                itemBuilder: (context, index) {
                  final option = PaymentOption.allPaymentOptions[index];
                  final isSelected = _selectedOptions.contains(option.name);
                  return _PaymentOptionTile(
                    option: option,
                    isSelected: isSelected,
                    primaryColor: colorScheme.primary,
                    onTap: () => _toggleOption(option.name),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    disabledBackgroundColor: colorScheme.primary.withValues(
                      alpha: 0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    textStyle: textTheme.labelLarge,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Text("Save"),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final PaymentOption option;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.option,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      splashColor: primaryColor.withValues(alpha: 0.08),
      highlightColor: primaryColor.withValues(alpha: 0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 22,
              color: isSelected ? primaryColor : Colors.grey.shade500,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                option.name,
                style: textTheme.bodyLarge!.copyWith(
                  color: Colors.black,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                key: ValueKey(isSelected),
                size: 22,
                color: isSelected ? primaryColor : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

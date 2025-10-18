import 'package:flutter/material.dart';
import 'package:swipeshare_app/components/colors.dart';
import 'package:swipeshare_app/components/text_styles.dart';
import 'package:swipeshare_app/components/buy_and_sell_screens/shared_constants.dart';

class PaymentOptionsComponent extends StatefulWidget {
  final List<String> selectedPaymentOptions;
  final Function(List<String>) onPaymentOptionsChanged;
  final bool fromHomeScreen;
  final VoidCallback? onUpdatePreferredMethods; // Optional callback

  const PaymentOptionsComponent({
    super.key,
    required this.selectedPaymentOptions,
    required this.onPaymentOptionsChanged,
    required this.fromHomeScreen,
    this.onUpdatePreferredMethods, // Optional parameter
  });

  @override
  State<PaymentOptionsComponent> createState() =>
      _PaymentOptionsComponentState();
}

class _PaymentOptionsComponentState extends State<PaymentOptionsComponent> {
  bool isExpanded = false;

  final List<PaymentOption> paymentOptions = [
    PaymentOption('Cash', Icons.attach_money),
    PaymentOption('Venmo', Icons.payment),
    PaymentOption('Zelle', Icons.account_balance),
    PaymentOption('Apple Pay', Icons.apple),
    PaymentOption('PayPal', Icons.paypal),
    PaymentOption('CashApp', Icons.money),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.whiteTransparent,
        borderRadius: BorderRadius.circular(BuySwipesConstants.borderRadius),
        border: Border.all(color: AppColors.borderGrey, width: 2),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              padding: BuySwipesConstants.containerPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Options',
                          style: AppTextStyles.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.selectedPaymentOptions.isEmpty
                              ? 'Tap to select payment methods'
                              : '${widget.selectedPaymentOptions.length} method${widget.selectedPaymentOptions.length > 1 ? 's' : ''} selected',
                          style: AppTextStyles.validationText.copyWith(
                            color: widget.selectedPaymentOptions.isEmpty
                                ? AppColors.subText
                                : AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: [
                      const Divider(height: 1, color: AppColors.borderGrey),
                      ...paymentOptions.map(
                        (option) => _buildPaymentOption(option),
                      ),
                      // Conditional button for home screen
                      if (widget.fromHomeScreen) _buildUpdateButton(),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(PaymentOption option) {
    final isSelected = widget.selectedPaymentOptions.contains(option.name);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: GestureDetector(
        onTap: () => _togglePaymentOption(option.name),
        child: Container(
          padding: BuySwipesConstants.containerPadding,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentBlue.withOpacity(0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(option.icon, color: AppColors.accentBlue, size: 20),
              const SizedBox(width: BuySwipesConstants.mediumSpacing),
              Expanded(child: Text(option.name, style: AppTextStyles.bodyText)),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  key: ValueKey(isSelected),
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.borderGrey,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton(
        onPressed: widget.onUpdatePreferredMethods,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Update Preferred Payment Methods',
          style: AppTextStyles.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _togglePaymentOption(String option) {
    final currentOptions = List<String>.from(widget.selectedPaymentOptions);
    if (currentOptions.contains(option)) {
      currentOptions.remove(option);
    } else {
      currentOptions.add(option);
    }
    widget.onPaymentOptionsChanged(currentOptions);
  }
}

class PaymentOption {
  final String name;
  final IconData icon;

  PaymentOption(this.name, this.icon);
}

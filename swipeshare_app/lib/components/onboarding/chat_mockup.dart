import 'package:flutter/material.dart';

class OnboardingChatMockup extends StatefulWidget {
  const OnboardingChatMockup({super.key});

  @override
  State<OnboardingChatMockup> createState() => _OnboardingChatMockupState();
}

class _OnboardingChatMockupState extends State<OnboardingChatMockup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _bubble1;
  late Animation<double> _bubble2;
  late Animation<double> _bubble3;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _bubble1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _bubble2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
      ),
    );
    _bubble3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Column(
          children: [
            _buildBubble(
              animation: _bubble1,
              text: 'Hey! Want to meet at Lenoir at 1?',
              isSent: true,
              color: colorScheme.primary,
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildBubble(
              animation: _bubble2,
              text: 'Sounds good! I\'ll be by the entrance',
              isSent: false,
              color: const Color(0xFFE8E8EA),
              textTheme: textTheme,
            ),
            const SizedBox(height: 12),
            _buildBubble(
              animation: _bubble3,
              text: 'Perfect, see you there!',
              isSent: true,
              color: colorScheme.primary,
              textTheme: textTheme,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBubble({
    required Animation<double> animation,
    required String text,
    required bool isSent,
    required Color color,
    required TextTheme textTheme,
  }) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(animation),
        child: Align(
          alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isSent ? 18 : 4),
                bottomRight: Radius.circular(isSent ? 4 : 18),
              ),
            ),
            child: Text(
              text,
              style: (textTheme.bodyLarge ?? const TextStyle()).copyWith(
                color: isSent ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

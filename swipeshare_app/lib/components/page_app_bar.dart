import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/utils/haptics.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const PageAppBar({super.key, required this.title});

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + 1); // +1 for divider

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: colors.surface,
      leading: BackButton(
        onPressed: () async {
          await safeVibrate(HapticsType.selection);
          if (context.mounted) Navigator.of(context).pop();
        },
      ),
      title: Text(title, style: textTheme.displayLarge),
      centerTitle: true,
      scrolledUnderElevation: 5,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1),
      ),
    );
  }
}

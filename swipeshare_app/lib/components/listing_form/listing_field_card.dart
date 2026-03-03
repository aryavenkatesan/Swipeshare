import 'package:flutter/material.dart';

/// A shared card container used by each listing form field.
///
/// Renders a bordered, rounded box that can optionally be tappable.
class ListingFieldCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;

  const ListingFieldCard({
    super.key,
    required this.child,
    this.onTap,
    this.height = 75,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 9, top: 4, bottom: 4),
            child: child,
          ),
        ),
      ),
    );
  }
}

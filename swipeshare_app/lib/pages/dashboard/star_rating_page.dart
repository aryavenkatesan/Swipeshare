import 'package:flutter/material.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:swipeshare_app/utils/haptics.dart';
import 'package:url_launcher/url_launcher.dart';

const _rickAscii = '''
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣶⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⠿⠟⠛⠻⣿⠆⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣆⣀⣀⠀⣿⠂⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠻⣿⣿⣿⠅⠛⠋⠈⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢼⣿⣿⣿⣃⠠⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣟⡿⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣛⣛⣫⡄⠀⢸⣦⣀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⡆⠸⣿⣿⣿⡷⠂⠨⣿⣿⣿⣿⣶⣦⣤⣀
⠀⠀⠀⠀⣤⣾⣿⣿⣿⣿⡇⢀⣿⡿⠋⠁⢀⡶⠪⣉⢸⣿⣿⣿⣿⣿⣇
⠀⠀⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⡏⢸⣿⣷⣿⣿⣷⣦⡙⣿⣿⣿⣿⣿⡏
⠀⠀⠀⠈⣿⣿⣿⣿⣿⣿⣿⣿⣇⢸⣿⣿⣿⣿⣿⣷⣦⣿⣿⣿⣿⣿⡇
⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄
⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⠀⠀⠀⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿
⠀⠀⠀⢹⣿⣵⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⡁''';

class StarRatingPage extends StatefulWidget {
  final double rating;
  final int transactionsCompleted;

  const StarRatingPage({
    super.key,
    required this.rating,
    required this.transactionsCompleted,
  });

  @override
  State<StarRatingPage> createState() => _StarRatingPageState();
}

class _StarRatingPageState extends State<StarRatingPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _entranceController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceOpacity;

  bool _revealed = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _entranceScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );

    _entranceOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    await safeVibrate(HapticsType.heavy);
    setState(() => _revealed = true);
    final url = Uri.parse('https://www.youtube.com/watch?v=xvFZjo5PgG0');
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _revealed
                ? _RickReveal(
                    key: const ValueKey('rick'),
                    colors: colors,
                    transactionsCompleted: widget.transactionsCompleted,
                  )
                : _RatingDisplay(
                    key: const ValueKey('rating'),
                    rating: widget.rating,
                    colors: colors,
                    scaleAnimation: _scaleAnimation,
                    entranceScale: _entranceScale,
                    entranceOpacity: _entranceOpacity,
                    entranceController: _entranceController,
                  ),
          ),
        ),
      ),
    );
  }
}

class _RatingDisplay extends StatelessWidget {
  final double rating;
  final ColorScheme colors;
  final Animation<double> scaleAnimation;
  final Animation<double> entranceScale;
  final Animation<double> entranceOpacity;
  final AnimationController entranceController;

  const _RatingDisplay({
    super.key,
    required this.rating,
    required this.colors,
    required this.scaleAnimation,
    required this.entranceScale,
    required this.entranceOpacity,
    required this.entranceController,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: AnimatedBuilder(
          animation: Listenable.merge([scaleAnimation, entranceController]),
          builder: (context, child) {
            return Opacity(
              opacity: entranceOpacity.value,
              child: Transform.scale(
                scale: entranceScale.value * scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 160,
                  fontWeight: FontWeight.w900,
                  color: colors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Tap to learn more about your rating",
                style: TextStyle(
                  fontSize: 16,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RickReveal extends StatelessWidget {
  final ColorScheme colors;
  final int transactionsCompleted;

  const _RickReveal({
    super.key,
    required this.colors,
    required this.transactionsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _rickAscii,
            style: TextStyle(
              fontSize: 24,
              height: 0.85,
              letterSpacing: -2,
              fontFamily: 'monospace',
              color: colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "get rick rolled lol",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "nah but this is just your rating over the "
              "course of your $transactionsCompleted "
              "order${transactionsCompleted == 1 ? '' : 's'}, "
              "what else did you expect?",
              style: TextStyle(
                fontSize: 13,
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

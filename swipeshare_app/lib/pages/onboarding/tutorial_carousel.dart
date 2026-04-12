import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/browse_swipes_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/communication_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/dashboard_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/final_step_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/sell_listing_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/stars_feedback_slide.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/welcome_slide.dart';

class TutorialCarousel extends StatefulWidget {
  const TutorialCarousel({super.key});

  @override
  State<TutorialCarousel> createState() => _TutorialCarouselState();
}

class _TutorialCarouselState extends State<TutorialCarousel> {
  final PageController _controller = PageController();
  static const int _lastPageIndex = 6;

  int _currentPage = 0;
  bool _isPageTransitioning = false;

  bool get onLastPage => _currentPage == _lastPageIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int index) async {
    if (!_controller.hasClients) return;
    if (_isPageTransitioning) return;
    if (index < 0 || index > _lastPageIndex) return;

    _isPageTransitioning = true;
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
    if (mounted) {
      _isPageTransitioning = false;
    }
  }

  void _onBackPressed() {
    _goToPage(_currentPage - 1);
  }

  void _onNextPressed() {
    _goToPage(_currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    final double vw = MediaQuery.of(context).size.width;
    final double dotSize = (vw / 22).clamp(10.0, 20.0);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFFFEF8FF),
        title: Text("A Quick Refresher!"),
      ),
      backgroundColor: Color(0xFFFEF8FF),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                if (!mounted) return;
                setState(() {
                  _currentPage = index;
                });
                _isPageTransitioning = false;
              },
              children: [
                const OnboardingWelcomeSlide(tutorial: true),
                const OnboardingBrowseSwipesSlide(),
                const OnboardingSellListingSlide(),
                const OnboardingDashboardSlide(),
                const OnboardingCommunicationSlide(),
                const OnboardingStarsFeedbackSlide(),
                const OnboardingFinalStepSlide(tutorial: true),
              ],
            ),
          ),
          SizedBox(height: 30),
          Container(
            height: 50,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _onBackPressed,
                    child: const Text("back"),
                  ),

                  SmoothPageIndicator(
                    controller: _controller,
                    count: 7,
                    effect: WormEffect(
                      dotHeight: dotSize,
                      dotWidth: dotSize,
                      activeDotColor: Colors.black,
                      dotColor: Colors.grey,
                    ),
                  ),

                  !onLastPage
                      ? GestureDetector(
                          onTap: _onNextPressed,
                          child: const Text("next"),
                        )
                      : GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text("home"),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

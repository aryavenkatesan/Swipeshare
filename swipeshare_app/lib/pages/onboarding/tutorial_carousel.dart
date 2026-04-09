import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_1.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_2.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_3.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_4.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_5.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_7.dart';

class TutorialCarousel extends StatefulWidget {
  const TutorialCarousel({super.key});

  @override
  State<TutorialCarousel> createState() => _TutorialCarouselState();
}

class _TutorialCarouselState extends State<TutorialCarousel> {
  final PageController _controller = PageController();
  static const int _lastPageIndex = 5;

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
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.69,
            //genuinly does not work on iphone se at 0.7 or 0.68
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
                const Page1(tutorial: true),
                const Page2(),
                const Page3(),
                const Page4(),
                const Page5(),
                const Page7(tutorial: true),
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
                    count: 6,
                    effect: WormEffect(
                      dotHeight: 20,
                      dotWidth: 20,
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

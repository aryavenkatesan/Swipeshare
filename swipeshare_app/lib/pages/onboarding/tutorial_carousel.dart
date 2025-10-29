import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_1.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_2.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_3.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_4.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_5.dart';
import 'package:swipeshare_app/pages/onboarding/onboarding_pages.dart/page_6.dart';

class TutorialCarousel extends StatefulWidget {
  const TutorialCarousel({super.key});

  @override
  State<TutorialCarousel> createState() => _TutorialCarouselState();
}

class _TutorialCarouselState extends State<TutorialCarousel> {
  final PageController _controller = PageController();

  bool onLastPage = false;

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
                setState(() {
                  // The last page is at index 5 (since there are 6 pages, 0-5)
                  onLastPage = (index == 5);
                });
              },
              children: [
                Page1(tutorial: true),
                Page2(),
                Page3(),
                Page4(),
                Page5(),
                Page6(tutorial: true),
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
                    onTap: () {
                      _controller.previousPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      );
                    },
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
                          onTap: () {
                            _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            );
                          },
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

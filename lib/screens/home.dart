import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = [
      'lib/misc/example_images/image1.png',
      'lib/misc/example_images/image2.png',
      'lib/misc/example_images/image3.png',
    ];

    final List<Widget> cards = imagePaths.map((path) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                path,
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: CardSwiper(
              cardsCount: cards.length,
              allowedSwipeDirection:
                  AllowedSwipeDirection.only(left: true, right: true, up: true),
              numberOfCardsDisplayed: 3,
              onTapDisabled: () => _onTap(),
              onSwipe: _onSwipe,
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) =>
                      cards[index],
            ),
          ),
          Center(
            child: ControlOverlay(),
          )
        ],
      )),
    );
  }
}

class ControlOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = screenWidth * 0.22;

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: screenHeight * 0.5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                print('No button pressed');
              },
              child: Image.asset(
                'lib/assets/No_Icon.png',
                width: iconSize,
                height: iconSize,
              ),
            ),
            SizedBox(
                width: screenWidth -
                    (iconSize * 3)), // Adds spacing between buttons
            GestureDetector(
              onTap: () {
                print('Yes button pressed');
              },
              child: Image.asset(
                'lib/assets/Yes_Icon.png',
                width: iconSize,
                height: iconSize,
              ),
            ),
          ],
        )
      ],
    ));
  }
}

// Local functions
bool _onSwipe(
  int previousIndex,
  int? currentIndex,
  CardSwiperDirection direction,
) {
  if (direction == CardSwiperDirection.left) {
    print('swiped left'); // TODO: add functionality
    HapticFeedback.lightImpact();
  } else if (direction == CardSwiperDirection.right) {
    print('swiped right'); // TODO: add functionality
    HapticFeedback.lightImpact();
  } else if (direction == CardSwiperDirection.top) {
    print('swiped up');
    HapticFeedback.heavyImpact();
  }
  return true;
}

bool _onTap() {
  print('Card tapped');
  return true;
}

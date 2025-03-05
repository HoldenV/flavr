import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final CardSwiperController _controller =
      CardSwiperController(); // Controller used to force a swipe

  @override
  Widget build(BuildContext context) {
    final List<String> imagePaths = [
      'lib/assets/dish_images/bacalao-a-la-vizcaina.jpg',
      'lib/assets/dish_images/bbq-ribs.jpg',
      'lib/assets/dish_images/beef-and-broccoli.jpg',
      'lib/assets/dish_images/bibimbap.jpg',
      'lib/assets/dish_images/birria.jpg',
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
              controller: _controller,
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
            child: ControlOverlay(controller: _controller),
          )
        ],
      )),
    );
  }
}

class ControlOverlay extends StatelessWidget {
  final CardSwiperController controller;

  ControlOverlay({required this.controller});

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
                controller.swipe(CardSwiperDirection.left);
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
                controller.swipe(CardSwiperDirection.right);
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
    print('swiped left');
    HapticFeedback.lightImpact();
  } else if (direction == CardSwiperDirection.right) {
    print('swiped right');
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';

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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange, Colors.black],
          stops: [0.01, 0.25],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'FLAVR',
                style: GoogleFonts.oi(fontSize: 36),
              ),
            ],
          ),
        ),
        body: SafeArea(
            child: Stack(
          children: [
            Center(
              child: CardSwiper(
                controller: _controller,
                cardsCount: cards.length,
                allowedSwipeDirection: AllowedSwipeDirection.only(
                    left: true, right: true, up: true),
                numberOfCardsDisplayed: 2,
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
      ),
    );
  }
}

class ControlOverlay extends StatelessWidget {
  final CardSwiperController controller;

  ControlOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.15;

    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
                    (iconSize * 2.5)), // Adds spacing between buttons
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

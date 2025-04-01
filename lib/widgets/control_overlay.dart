import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class ControlOverlay extends StatelessWidget {
  final CardSwiperController controller;

  ControlOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.18;

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
              SizedBox(width: screenWidth - (iconSize * 2.5)),
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
          ),
        ],
      ),
    );
  }
}

/*
Authors: Holden Vail
Description: This is where we define the widgets of the home screen
*/

// Dependency Imports
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> imagePaths = [
      'lib/misc/example_images/image1.png',
      'lib/misc/example_images/image2.png',
      'lib/misc/example_images/image3.png',
    ];

    List<Widget> cards = imagePaths.map((path) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Center(
          child: SizedBox(
            width: 400,
            height: 600,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(path, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: CardSwiper(
            cardsCount: cards.length,
            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) =>
                    cards[index],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flavr/widgets/recommendation_popup.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _initializeFoods();
  }

  Future<void> _initializeFoods() async {
    // Use listen: false since we are calling this outside of build
    final appState = Provider.of<AppState>(context, listen: false);
    for (int i = 0; i < 3; i++) {
      String newPath = await generateFoodPath();
      appState.addCard(newPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context); // Get the instance
    List<Widget> cards = appState.imagePaths.map((path) {
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
          colors: appState.swipeCount < 7
              ? [Colors.orange, Colors.black]
              : [Colors.purple, Colors.orange],
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                iconSize: 30.0,
                icon: Icon(Icons.person_add),
                onPressed: () {
                  // Add onPressed code
                  print('Person add icon pressed');
                },
              ),
            ),
          ],
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
                // child: ControlOverlay(controller: _controller),
                child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: appState.swipeCount >= 7
                  ? RecommendationPopup()
                  : Container(key: ValueKey('empty')),
            ))
          ],
        )),
      ),
    );
  }

// Local functions
  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final appState = Provider.of<AppState>(context, listen: false);

    appState.incrementSwipeCount();

    if (direction == CardSwiperDirection.left) {
      print('swiped left');
      HapticFeedback.lightImpact();
      appState.negativeSwipe(pathToName(appState.imagePaths[previousIndex]));
    } else if (direction == CardSwiperDirection.right) {
      print('swiped right');
      HapticFeedback.lightImpact();
      appState.positiveSwipe(pathToName(appState.imagePaths[previousIndex]));
    } else if (direction == CardSwiperDirection.top) {
      print('swiped up');
      HapticFeedback.heavyImpact();
    }

    print(appState.positiveSwipes);
    print(appState.negativeSwipes);

    String newPath = await generateFoodPath();
    appState.addCard(newPath);

    return true;
  }
}

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

bool _onTap() {
  print('Card tapped');
  return true;
}

nameToPath(String foodName) {
  String path = foodName.toLowerCase().replaceAll(' ', '-');
  path = 'lib/assets/dish_images/$path.jpg';
  return path;
}

pathToName(String path) {
  String foodName = path
      .substring(23, path.length - 4)
      .replaceAll('lib/assets/dish_images/', '');
  return foodName;
}

Future<String> numToFood(int number) async {
  try {
    String content = await rootBundle.loadString('lib/data/foods.csv');
    List<String> lines = content.split('\n');
    return lines[number].trim();
  } catch (e) {
    print('Error reading file: $e');
    return ''; // Return an empty string or handle as appropriate
  }
}

generateFoodPath() async {
  var random = Random();
  String foodName = await numToFood(random.nextInt(131));
  return nameToPath(foodName);
}

Future<String> loadCsv() async {
  return await rootBundle.loadString('lib/data/foods.csv');
}
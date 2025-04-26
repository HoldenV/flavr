// ignore_for_file: deprecated_member_use

import 'package:flavr/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flavr/widgets/recommendation_popup.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';
import 'package:flavr/services/google_maps.dart';
import 'package:flavr/services/path_service.dart';



class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CardSwiperController _controller = CardSwiperController();

  Future<void> _initializeFoods() async {
    final appState = Provider.of<AppState>(context, listen: false);
    for (int i = 0; i < 3; i++) {
      String newPath = await generateFoodPath(appState.badRecommendation);
      appState.addCard(newPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeFoods(), // Wait for this Future to complete
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for the Future to complete
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          // Handle any errors that occurred during initialization
          return Scaffold(
            body: Center(
              child: Text('Error loading data: ${snapshot.error}'),
            ),
          );
        }

        // Once the Future is complete, render the actual screen content
        return _buildHomeScreenContent(context);
      },
    );
  }

  Widget _buildHomeScreenContent(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    List<Widget> cards = appState.imagePaths.map((path) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16.0),
                        child: Image.asset(
                          path,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: [
                              0.0,
                              0.1,
                              0.2
                            ], // Back to transparent at 20% up the image
                            colors: [
                              Colors.black
                                  .withOpacity(0.7), // Adjust opacity as needed
                              Colors.black.withOpacity(0.5),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 16,
                        child: SizedBox(
                          width: screenWidth * 0.8,
                          child: Text(
                            pathToNameCaps(path),
                            maxLines: 2, // wrap to a second line if needed
                            overflow: TextOverflow
                                .ellipsis, // add "…" if it still can’t fit
                            softWrap: true,
                            style: TextStyle(
                              fontFamily: 'Arial Rounded MT Bold',
                              fontSize: screenWidth * 0.08,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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
                icon: Icon(Icons.history_edu),
                onPressed: () {
                  // Add onPressed code
                  print('Recommendation history icon pressed');
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

    if (appState.swipeCount >= 7) {
      Map<String, dynamic> recs = await appState.getRecommendations();
      List<double> longLat = await getLongLat();
      List<dynamic> results = [];
      for (int i = 0; i < recs.length; i++) {
        // Get results from Google Maps API
        results = (await textSearchPlaces(
          query: recs.entries.elementAt(i).key,
          latitude: longLat[1],
          longitude: longLat[0],
          apiKey: await getApiKey(),
          radius: 1000,
        ));

        // Set the recommendation in appState
        appState.setRecommendation(recs.entries.elementAt(i).key);

        // Go until we have at least 3 results
        if (results.length >= 3) {
          break;
        } else {
          print('Not enough results for ${recs.entries.elementAt(i).key}, trying again...');
        }
      }

      // Assume we got some results
        // should probably add in a check for this
      print('Results of TextSearch: $results');
      appState.updateRestaurants(results);
    }

    String newPath = await generateFoodPath(appState.badRecommendation);
    appState.addCard(newPath);

    return true;
  }
}

bool _onTap() {
  print('Card tapped');
  return true;
}

// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';
import 'package:flavr/services/path_service.dart';
import 'package:flavr/services/google_maps.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationPopup extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _RecommendationPopupState createState() => _RecommendationPopupState();
}

class _RecommendationPopupState extends State<RecommendationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _backgroundAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the controller with the overall duration.
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Background slides in from the bottom over the first 40% of the animation.
    _backgroundAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Card scales in from 0 to full size, starting a bit later.
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    // Show spinner while recommendation or restaurants are loading or during unload
    if ((appState.currentRecommendation.isEmpty || appState.currentRestaurants.length < 3) && appState.swipeCount >= 7) {
      return Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              appState.resetSwipeCount();
              appState.resetSession();
            },
            child: SlideTransition(
              position: _backgroundAnimation,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.purple],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'We Suggest...',
                  style: GoogleFonts.titanOne(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.08,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                // Wrap the RecommendationCardDisplay in a ScaleTransition.
                ScaleTransition(
                  scale: _cardAnimation,
                  child: RecommendationCardDisplay(
                    imagePath: nameToPath(appState.currentRecommendation),
                    dishName: appState.currentRecommendation[0].toUpperCase() +
                        appState.currentRecommendation.substring(1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationCardDisplay extends StatelessWidget {
  final String imagePath;
  final String dishName;

  RecommendationCardDisplay({required this.imagePath, required this.dishName});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Stack(children: [
              Image.asset(
                imagePath,
                width: screenWidth * 0.9,
                height: screenHeight * 0.65,
                fit: BoxFit.cover,
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [
                        0.0,
                        0.5,
                        1
                      ], // Fades out by half the image's height
                      colors: [
                        Colors.black
                            .withOpacity(0.7), // Adjust opacity as needed
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Inside your RecommendationCardDisplay widget's Positioned widget:
              Positioned(
                bottom: 16, // adjust as needed
                left: 16, // adjust as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8, // keeps text within card bounds
                      child: Text(
                        dishName,
                        maxLines: 2,               // wrap to a second line if needed
                        overflow: TextOverflow.ellipsis, // add "…" if it still can’t fit
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: 'Arial Rounded MT Bold',
                          fontSize: screenWidth * 0.1,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    // Wrap the restaurantƒ cards in a container with a defined height
                    SizedBox(
                      width: screenWidth * 0.8,
                      height: screenHeight * 0.20,
                      child: FutureBuilder<String>(
                        future: getApiKey(), // Get the API key asynchronously.
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          }
                          // Once the API key is available, build your row of RestaurantCards.
                          final apiKey = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                RestaurantCard(
                                  image: getPlacePhoto(
                                      appState.currentRestaurants[0]['photos']
                                          [0]['photo_reference'],
                                      apiKey),
                                  restaurant_name:
                                      appState.currentRestaurants[0]['name'],
                                  url: 
                                      appState.currentRestaurants[0]
                                        ['googleMapsUri'],
                                  rating:
                                      appState.currentRestaurants[0]['rating'],
                                ),
                                SizedBox(width: 5),
                                RestaurantCard(
                                  image: getPlacePhoto(
                                      appState.currentRestaurants[1]['photos']
                                          [0]['photo_reference'],
                                      apiKey),
                                  restaurant_name:
                                      appState.currentRestaurants[1]['name'],
                                  url: 
                                      appState.currentRestaurants[1]['googleMapsUri'],
                                  rating:
                                      appState.currentRestaurants[1]['rating'],
                                ),
                                SizedBox(width: 5),
                                RestaurantCard(
                                  image: getPlacePhoto(
                                      appState.currentRestaurants[2]['photos']
                                          [0]['photo_reference'],
                                      apiKey),
                                  restaurant_name:
                                      appState.currentRestaurants[2]['name'],
                                  url: 
                                      appState.currentRestaurants[2]
                                        ['googleMapsUri'],
                                  rating:
                                      appState.currentRestaurants[2]['rating'],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              )
            ]),
          );
        },
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Image image;
  final String restaurant_name;
  final String url;
  final num rating;

  RestaurantCard({required this.image, required this.restaurant_name, required this.url, required this.rating});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: GestureDetector(
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: Stack(children: [
                SizedBox(
                  width: screenWidth * 0.65,
                  height: screenHeight * 0.65,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: image,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [
                          0.0,
                          0.3,
                          0.6
                        ], // Fades out by half the image's height
                        colors: [
                          Colors.black
                              .withOpacity(0.7), // Adjust opacity as needed
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8, // adjust as needed
                  left: 16, // adjust as needed
                  child: SizedBox(
                    width:
                        screenWidth * 0.6, // Constrain width to prevent overflow
                    child: Text(
                      '${rating.toStringAsFixed(1)}/5.0\n$restaurant_name', // (⭐, ★,  ☆,  ⚝) ?
                      maxLines: 2, // Allows up to 2 lines
                      overflow: TextOverflow
                          .ellipsis, // Fade or cut off if still too long
                      softWrap: true,
                      style: TextStyle(
                        fontFamily: 'Arial Rounded MT Bold',
                        fontSize: screenWidth * 0.05,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 8, // adjust as needed
                //   right: 16, // adjust as needed
                //   child: SizedBox(
                //     width:
                //         screenWidth * 0.6, // Constrain width to prevent overflow
                //     child: Text(
                //       '${rating.toStringAsFixed(1)}⭐', // Display rating with one decimal
                //       maxLines: 2, // Allows up to 2 lines
                //       overflow: TextOverflow
                //           .ellipsis, // Fade or cut off if still too long
                //       softWrap: true,
                //       style: TextStyle(
                //         fontFamily: 'Arial Rounded MT Bold',
                //         fontSize: screenWidth * 0.05,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
              ]),
            )
          );
        },
      ),
    );
  }
}

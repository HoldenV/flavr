// ignore_for_file: non_constant_identifier_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';

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
                    imagePath: 'lib/assets/dish_images/hot-pot.jpg',
                    dishName: 'Hot Pot',
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
                    Text(
                      dishName,
                      style: TextStyle(
                        fontFamily: 'Arial Rounded MT Bold',
                        fontSize: screenWidth * 0.1,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    // Wrap the restaurant cards in a container with a defined height
                    SizedBox(
                      width: screenWidth *
                          0.8, // Constrain the width to the card's width
                      height: screenHeight * 0.20, // adjust as needed
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            RestaurantCard(
                              image_path: 'lib/assets/res1.jpg',
                              restaurant_name: 'KPOT',
                            ),
                            SizedBox(width: 5), // spacing between cards
                            RestaurantCard(
                              image_path: 'lib/assets/res2.jpg',
                              restaurant_name: 'Three Bowl',
                            ),
                            SizedBox(width: 5),
                            RestaurantCard(
                              image_path: 'lib/assets/res3.jpg',
                              restaurant_name: 'Lotus Hot Pot',
                            ),
                          ],
                        ),
                      ),
                    ),
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
  final String image_path;
  final String restaurant_name;

  RestaurantCard({required this.image_path, required this.restaurant_name});

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
            child: Stack(children: [
              Image.asset(
                image_path,
                width: screenWidth * 0.6,
                height: screenHeight * 0.2,
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
                        0.2,
                        0.5
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
                child: Text(
                  restaurant_name,
                  style: TextStyle(
                    fontFamily: 'Arial Rounded MT Bold',
                    fontSize: screenWidth * 0.05,
                    color: Colors.white,
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

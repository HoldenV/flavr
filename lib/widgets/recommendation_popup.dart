import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';

class RecommendationPopup extends StatefulWidget {
  @override
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
                    image_path: 'lib/assets/dish_images/bbq-ribs.jpg',
                    dish_name: "BBQ Ribs",
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
  final String image_path;
  final String dish_name;

  RecommendationCardDisplay(
      {required this.image_path, required this.dish_name});

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
                width: screenWidth * 0.8,
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
                      dish_name,
                      style: TextStyle(
                        fontFamily: 'Arial Rounded MT Bold',
                        fontSize: screenWidth * 0.1,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    // Wrap the restaurant cards in a container with a defined height
                    Container(
                      width: screenWidth *
                          0.8, // Constrain the width to the card's width
                      height: screenHeight * 0.25, // adjust as needed
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            RestaurantCard(
                              image_path: 'lib/assets/dish_images/kofta.jpg',
                              restaurant_name: "Restaurant 1",
                            ),
                            SizedBox(width: 5), // spacing between cards
                            RestaurantCard(
                              image_path: 'lib/assets/dish_images/pad-thai.jpg',
                              restaurant_name: "Restaurant 2",
                            ),
                            SizedBox(width: 5),
                            RestaurantCard(
                              image_path:
                                  'lib/assets/dish_images/pasta-salad.jpg',
                              restaurant_name: "Restaurant 3",
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
                bottom: 16, // adjust as needed
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

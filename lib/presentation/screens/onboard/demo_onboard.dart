// import 'dart:math';
// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:provider/provider.dart';
// import 'package:wisdeals/core/colors.dart';
// import 'package:wisdeals/presentation/provider/onboard_provider.dart';
// import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

// class OnboardScreen extends StatefulWidget {
//   const OnboardScreen({Key? key}) : super(key: key);

//   @override
//   _OnboardScreenState createState() => _OnboardScreenState();
// }

// class _OnboardScreenState extends State<OnboardScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;
//   Offset cardOffset = Offset.zero;
//   double rotation = 0.0;

//   int topCardIndex = 0;

//   List<String> cards = ["Card 1", "Card 2", "Card 3"];
//   bool _showSwipeHint = true;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     // Hide hint after 4 seconds
//     Future.delayed(const Duration(seconds: 4), () {
//       if (mounted) {
//         setState(() {
//           _showSwipeHint = false;
//         });
//       }
//     });
//   }

//   List<Map<String, dynamic>> cardsContent = [
//     {
//       "text1": "Track",
//       "text2": "Your",
//       "text0": "Professional",
//       "text3": "Journey",
//       "image": "assets/images/dashboardImage1.png",
//       "text4": "Easily record travel routes",
//       "text5": "visits, and client meetings",
//       "text6": "in real-time.",
//     },
//     {
//       "text1": "Manage",
//       "text2": "Clients",
//       "text": "",
//       "text3": "And Orders",
//       "image": "assets/images/dashboardimage2.png",
//       "text4": "Easily add clients,",
//       "text5": "follow up on leads, and",
//       "text6": "organize all orders.",
//     },
//     {
//       "text1": "Track",
//       "text2": "Analyse",
//       "text": "",
//       "text3": "Grow",
//       "image": "assets/images/dashboardimage3.png",
//       "text4": "Track expenses",
//       "text5": "performance, and sales",
//       "text6": "trends to grow faster.",
//     },
//   ];

//   // ------------------ SWIPE LOGIC ------------------

//   void onPanUpdate(DragUpdateDetails details) {
//     setState(() {
//       cardOffset += details.delta;
//       rotation = cardOffset.dx / 500;
//     });
//   }

//   void onPanEnd(DragEndDetails details) {
//     const threshold = 120;

//     if (cardOffset.dx > threshold) {
//       swipeRight();
//     } else if (cardOffset.dx < -threshold) {
//       swipeLeft();
//     } else {
//       resetCard();
//     }
//   }

//   void swipeLeft() {
//     animateCard(const Offset(-600, 0), () {
//       if (topCardIndex < cardsContent.length - 1) {
//         topCardIndex++;
//       }
//     });
//   }

//   void swipeRight() {
//     animateCard(const Offset(600, 0), () {
//       if (topCardIndex > 0) {
//         topCardIndex--;
//       }
//     });
//   }

//   void animateCard(Offset targetOffset, VoidCallback onComplete) {
//     _slideAnimation = Tween(begin: cardOffset, end: targetOffset).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeOut),
//     )..addListener(() {
//       setState(() {
//         cardOffset = _slideAnimation.value;
//         rotation = cardOffset.dx / 500;
//       });
//     });

//     _controller.forward(from: 0).whenComplete(() {
//       onComplete();
//       resetCard();
//     });
//   }
//   // void swipeCard(DragEndDetails details) {
//   //   print('cardsssssssssss :${cardsContent.length}');
//   //   const swipeThreshold = 150;

//   //   if (cardOffset.dx.abs() > swipeThreshold) {
//   //     setState(() {
//   //       if (cardOffset.dx < 0) {
//   //         // Swiped right → move forward
//   //         if (topCardIndex < cardsContent.length - 1) {
//   //           topCardIndex += 1;
//   //         }
//   //         print("Swiped Right → Next Card");
//   //       } else {
//   //         // Swiped left → move backward
//   //         if (topCardIndex > 0) {
//   //           topCardIndex -= 1;
//   //         }
//   //         print("Swiped Left → Previous Card");
//   //       }
//   //       cardOffset = Offset.zero;
//   //       rotation = 0.0;
//   //     });
//   //   } else {
//   //     resetCard();
//   //   }
//   // }

//   void resetCard() {
//     setState(() {
//       cardOffset = Offset.zero;
//       rotation = 0.0;
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black,
//         child: ReusableScafoldAndGlowbackground(
//           child: Consumer<OnboardProvider>(
//             builder: (context, onboardProvider, _) {
//               return Stack(
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 300,
//                         height: 440,
//                         child: Stack(
//                           clipBehavior: Clip.none,
//                           children: List.generate(3, (index) {
//                             int displayIndex =
//                                 (topCardIndex +
//                                     index -
//                                     2 +
//                                     cardsContent.length) %
//                                 cardsContent.length;
//                             double angle = [-0.4, -0.2, 0.0][index];

//                             bool isTopCard = index == 2;
//                             double scale = isTopCard ? 1 : 0.9 + (index * 0.05);
//                             double opacity =
//                                 isTopCard ? 1 : 0.6 + (index * 0.2);
//                             return Positioned(
//                               top: index * 12,
//                               left: index * 6,
//                               child:
//                                   isTopCard
//                                       ? GestureDetector(
//                                         onPanUpdate: onPanUpdate,
//                                         onPanEnd: onPanEnd,
//                                         child: Transform.translate(
//                                           offset: cardOffset,
//                                           child: Transform.rotate(
//                                             angle: rotation + angle,
//                                             child: Opacity(
//                                               opacity: opacity,
//                                               child: Transform.scale(
//                                                 scale: scale,
//                                                 child: buildCard(displayIndex),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                       : Transform.rotate(
//                                         angle: angle,
//                                         child: Opacity(
//                                           opacity: opacity,
//                                           child: Transform.scale(
//                                             scale: scale,
//                                             child: buildCard(displayIndex),
//                                           ),
//                                         ),
//                                       ),
//                             );
//                           }),
//                         ),
//                       ),
//                       const SizedBox(height: 80),
//                       // Dot indicator

//                       // DOTS
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: List.generate(
//                           cardsContent.length,
//                           (index) => AnimatedContainer(
//                             duration: const Duration(milliseconds: 300),
//                             margin: const EdgeInsets.symmetric(horizontal: 5),
//                             width: topCardIndex == index ? 18 : 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color:
//                                   topCardIndex == index
//                                       ? Colors.blue
//                                       : Colors.white,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 50),

//                       // Next button
//                       if (topCardIndex == cardsContent.length - 1)
//                         ElevatedButton(
//                           onPressed: () async {
//                             print("Next button pressed!");
//                             // Navigate to next screen
//                             Navigator.pushReplacementNamed(
//                               context,
//                               '/loginScreen',
//                             );
//                             await onboardProvider.completeOnboarding();
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: kbuttonColor1,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 50,
//                               vertical: 15,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                           child: Icon(Icons.arrow_forward_ios),
//                         ),
//                     ],
//                   ),
//                   _showSwipeHint
//                       ? AnimatedOpacity(
//                         opacity: _showSwipeHint ? 1 : 0,
//                         duration: const Duration(seconds: 1),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.5),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Center(
//                                 child: Lottie.asset(
//                                   'assets/json/swipeleft.json',
//                                   width: 150,
//                                   height: 150,
//                                   repeat: true,
//                                   animate: true,
//                                 ),
//                               ),
//                               const SizedBox(height: 5),
//                               const Text(
//                                 'Swipe left to continue',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       )
//                       : SizedBox.shrink(),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//   // ------------------ CARD UI ------------------

//   Widget buildCard(int index) {
//     final data = cardsContent[index];
//     return Padding(
//       padding: const EdgeInsets.only(left: 20, right: 20),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(30),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
//           child: Container(
//             width: 260,
//             height: 400,
//             decoration: BoxDecoration(
//               color: Colors.amber,
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   const Color(0xFFFFFFFF).withOpacity(0.02),
//                   const Color(0xFF999999).withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(30),
//               border: Border.all(
//                 color: Colors.grey.withOpacity(0.3),
//                 width: 1.5,
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     children: [
//                       RichText(
//                         textAlign: TextAlign.center,
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: "${cardsContent[index]['text1']}",
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: kTextColorPrimary,
//                               ),
//                             ),
//                             WidgetSpan(
//                               child: SizedBox(width: 8), // space between words
//                             ),
//                             TextSpan(
//                               text: "${cardsContent[index]['text2']}",
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: kTextColorSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       RichText(
//                         textAlign: TextAlign.center,
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: "${cardsContent[index]['text0'] ?? ''}",
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: kTextColorSecondary,
//                               ),
//                             ),
//                             WidgetSpan(
//                               child: SizedBox(width: 8), // space between words
//                             ),
//                             TextSpan(
//                               text: "${cardsContent[index]['text3']}",
//                               style: const TextStyle(
//                                 fontSize: 28,
//                                 fontWeight: FontWeight.bold,
//                                 color: kTextColorPrimary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   Image.asset(data['image'], height: 140),

//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RichText(
//                         textAlign: TextAlign.start,
//                         text: TextSpan(
//                           children: [
//                             TextSpan(
//                               text: "${cardsContent[index]['text4']}",
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: kTextColorSecondary,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Text(
//                         "${cardsContent[index]['text5']}",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: kTextColorPrimary,
//                         ),
//                       ),
//                       Text(
//                         "${cardsContent[index]['text6']}",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: kTextColorPrimary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

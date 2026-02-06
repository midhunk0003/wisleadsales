// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
// import 'package:provider/provider.dart';
// import 'package:wisdeals/app_update_version.dart/app_update_version_provider.dart';
// import 'package:wisdeals/core/colors.dart';
// import 'package:wisdeals/presentation/provider/home_provider.dart';
// import 'package:wisdeals/widgets/custom_appbar_widget.dart';
// import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _initialData();
//     mb.MapboxOptions.setAccessToken(
//       "pk.eyJ1IjoibWlkbWFwIiwiYSI6ImNtZ3QydzQxbjAxbHkybHF5NHd0c3dsanQifQ.ZaciO7IvkSPR5VW3WLPiGQ",
//     );
//   }

//   void _initialData() async {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final appUpdateProvider = Provider.of<AppUpdateVersionProvider>(
//         context,
//         listen: false,
//       );
//       final provider = Provider.of<HomeProvider>(context, listen: false);
//       appUpdateProvider.checkForUpdate(context);
//       provider.getHomePro();
//     });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ReusableScafoldAndGlowbackground(
//       child: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool _isTablet = constraints.maxWidth > 600;
//           return Padding(
//             padding: EdgeInsets.symmetric(
//               vertical: _isTablet ? 50 : 25,
//               horizontal: _isTablet ? 50 : 25,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 children: [
//                   SizedBox(height: 30),
//                   CustomAppBarWidget(title: "Home Screen"),

//                   Consumer<HomeProvider>(
//                     builder: (context, homeProvider, _) {
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 40),
//                           RichText(
//                             text: TextSpan(
//                               children: [
//                                 TextSpan(
//                                   text: "Ready",
//                                   style: TextStyle(
//                                     fontFamily: "MontrealSerial",
//                                     color: Color(0xFF82AE09),
//                                     fontSize: 40,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 WidgetSpan(child: SizedBox(width: 10)),
//                                 TextSpan(
//                                   text: "for todays",
//                                   style: TextStyle(
//                                     fontFamily: "MontrealSerial",
//                                     color: Colors.white,
//                                     fontSize: 40,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Text(
//                             'challenge',
//                             style: TextStyle(
//                               fontFamily: "MontrealSerial",
//                               color: Colors.white,
//                               fontSize: 40,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           SizedBox(height: 30),
//                           if (homeProvider.isTracking)
//                             Container(
//                               padding: EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     Icons.location_on,
//                                     color: Colors.green,
//                                     size: 16,
//                                   ),
//                                   SizedBox(width: 4),
//                                   Text(
//                                     'Live Tracking Active',
//                                     style: TextStyle(
//                                       color: Colors.green,
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           SizedBox(height: 10),
//                           Text(
//                             '${homeProvider.sessionDistance.toStringAsFixed(2)} KM',
//                             style: TextStyle(
//                               fontFamily: "MontrealSerial",
//                               color: Colors.white,
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 10),
//                           // Additional stats container
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: khome3rdSectionColor,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(18),
//                                     child: Column(
//                                       children: [
//                                         Text(
//                                           'Today Distance',
//                                           style: TextStyle(
//                                             fontFamily: "MontrealSerial",
//                                             color: Colors.white,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         SizedBox(height: 8),
//                                         Text(
//                                           '${homeProvider.homeData?.km == null ? homeProvider.currentDisplayDistance.toStringAsFixed(2) : homeProvider.homeData?.km} KM',
//                                           style: TextStyle(
//                                             fontFamily: "MontrealSerial",
//                                             color: Colors.white,
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: khome3rdSectionColor,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(18),
//                                     child: Column(
//                                       children: [
//                                         Text(
//                                           'Pending Follow-Ups',
//                                           style: TextStyle(
//                                             fontFamily: "MontrealSerial",
//                                             color: Colors.white,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                         SizedBox(height: 8),
//                                         Text(
//                                           '100',
//                                           style: TextStyle(
//                                             fontFamily: "MontrealSerial",
//                                             color: Colors.white,
//                                             fontSize: 24,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),

//                           Stack(
//                             children: [
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.only(
//                                   topLeft: Radius.circular(30),
//                                   topRight: Radius.circular(30),
//                                 ),
//                                 child: SizedBox(
//                                   width: double.infinity,
//                                   height: 400,
//                                   child: mb.MapWidget(
//                                     key: const ValueKey("mapWidget"),
//                                     cameraOptions: mb.CameraOptions(
//                                       center:
//                                           (homeProvider.latitude != null &&
//                                                   homeProvider.longitude !=
//                                                       null)
//                                               ? mb.Point(
//                                                 coordinates: mb.Position(
//                                                   homeProvider.longitude!,
//                                                   homeProvider.latitude!,
//                                                 ),
//                                               )
//                                               : mb.Point(
//                                                 coordinates: mb.Position(
//                                                   76.2711, // Longitude
//                                                   10.8505, // Latitude
//                                                 ),
//                                               ),
//                                       zoom:
//                                           (homeProvider.latitude != null)
//                                               ? 16.0
//                                               : 10.0,
//                                       pitch: 0.0,
//                                       bearing: 0.0,
//                                     ),
//                                     onMapCreated: homeProvider.onMapCreated,
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 40,
//                                 left: 100,
//                                 right: 100,
//                                 child: GestureDetector(
//                                   onTap:
//                                       homeProvider.isLoadingAuth
//                                           ? null
//                                           : () async {
//                                             homeProvider.authenticateAndClock(
//                                               context,
//                                             );
//                                           },
//                                   child: Container(
//                                     width: 130,
//                                     height: 130,
//                                     decoration: const BoxDecoration(
//                                       color: Colors.transparent,
//                                     ),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(8.0),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color:
//                                               homeProvider.homeData?.status ==
//                                                       true
//                                                   ? Colors.green.withOpacity(
//                                                     0.30,
//                                                   )
//                                                   : Colors.red.withOpacity(
//                                                     0.30,
//                                                   ),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Center(
//                                           child:
//                                               homeProvider.isLoadingAuth
//                                                   ? const CircularProgressIndicator(
//                                                     color: Colors.white,
//                                                   )
//                                                   : Column(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .center,
//                                                     children: [
//                                                       Image.asset(
//                                                         'assets/images/fingerprient.png',
//                                                         width: 40,
//                                                         height: 40,
//                                                       ),
//                                                       const SizedBox(height: 4),
//                                                       Text(
//                                                         homeProvider
//                                                                     .homeData
//                                                                     ?.status ==
//                                                                 true
//                                                             ? "Clock Out"
//                                                             : "Clock In",
//                                                         style: const TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 12,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 100),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/presentation/provider/drawer_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';

class ReusableScafoldAndGlowbackground extends StatelessWidget {
  final Widget? child;

  const ReusableScafoldAndGlowbackground({Key? key, this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<DrawerProvider>(context, listen: false).drawerListData();
      Provider.of<DrawerProvider>(context, listen: false).getUserDetail();
    });
    return Scaffold(
      drawer: CustomDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine screen size
          final bool _isSmallScreen = constraints.maxWidth < 600;
          final bool _isLargeTablet = constraints.maxWidth > 900;
          return Container(
            height: double.infinity,
            color: Colors.black,
            child: Stack(
              children: [
                // Green glow (top)
                Positioned(
                  child: Container(
                    width:
                        _isSmallScreen ? 570 : (_isLargeTablet ? 1200 : 1000),
                    height: _isSmallScreen ? 300 : (_isLargeTablet ? 700 : 600),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFCEF566).withOpacity(0.18),
                          Colors.transparent,
                        ],
                        center: Alignment(0, -0.4),
                        radius: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCEF566).withOpacity(0.1),
                          blurRadius: _isSmallScreen ? 50 : 80,
                          spreadRadius: _isSmallScreen ? 50 : 80,
                        ),
                      ],
                    ),
                  ),
                ),

                // Blue glow
                Positioned(
                  bottom: _isSmallScreen ? 200 : 200,
                  left: _isSmallScreen ? -100 : -200,
                  child: Container(
                    width: _isSmallScreen ? 300 : 500,
                    height: _isSmallScreen ? 300 : 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF4A66E3).withOpacity(0.1),
                          Colors.transparent,
                        ],
                        center: Alignment(0, 0),
                        radius: 0.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A66E3).withOpacity(0.1),
                          blurRadius: _isSmallScreen ? 70 : 100,
                          spreadRadius: _isSmallScreen ? 40 : 60,
                        ),
                      ],
                    ),
                  ),
                ),

                // Green glow (bottom)
                Positioned(
                  bottom: _isSmallScreen ? -80 : -150,
                  right: _isSmallScreen ? -100 : -200,
                  child: Container(
                    width: _isSmallScreen ? 300 : 500,
                    height: _isSmallScreen ? 300 : 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFCEF566).withOpacity(0.0),
                          Colors.transparent,
                        ],
                        center: Alignment(0, -0.1),
                        radius: 0.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCEF566).withOpacity(0.1),
                          blurRadius: _isSmallScreen ? 70 : 100,
                          spreadRadius: _isSmallScreen ? 40 : 60,
                        ),
                      ],
                    ),
                  ),
                ),

                // Optional child overlay
                if (child != null) child!,
              ],
            ),
          );
        },
      ),
    );
  }
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialData();
  }

  // void initialData() async {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final provider = Provider.of<ProfileProvider>(context, listen: false);
  //     provider.getProfilImgFromShared();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DrawerProvider, ProfileProvider>(
      builder: (context, drawerProvider, profileProvider, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final bool _isTablet = constraints.maxWidth > 600;
            return Drawer(
              backgroundColor: Colors.transparent, // Transparent base
              child: Stack(
                children: [
                  // Blurred background
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(
                              0xFF82AE09,
                            ).withOpacity(0.7), // Light green start
                            const Color(
                              0xFF82AE09,
                            ).withOpacity(0.10), // Slightly darker end
                          ],
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/profilescreen');
                        },
                        child: Container(
                          height: 80,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            // mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                // radius: 40,
                                backgroundColor: Colors.grey.shade200,
                                child: ClipOval(
                                  child:
                                      (profileProvider
                                                      .profileDatas
                                                      ?.profileImage ==
                                                  null &&
                                              profileProvider.selectedFile ==
                                                  null)
                                          ? Image.asset(
                                            'assets/images/emptypro.jpg',
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                          )
                                          : (profileProvider.selectedFile !=
                                              null)
                                          ? Image.file(
                                            profileProvider.selectedFile!,
                                          )
                                          : Image.network(
                                            '${ApiEndPoint.photoBaseUrl}${profileProvider.profileDatas?.profileImage}',
                                            fit: BoxFit.cover,
                                            width: 80,
                                            height: 80,
                                            loadingBuilder: (
                                              context,
                                              child,
                                              progress,
                                            ) {
                                              if (progress == null)
                                                return child;
                                              return Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (_, __, ___) => Image.asset(
                                                  'assets/images/emptypro.jpg',
                                                  fit: BoxFit.cover,
                                                  width: 80,
                                                  height: 80,
                                                ),
                                          ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${drawerProvider.userName ?? 'N/A'}',
                                    style: TextStyle(
                                      fontFamily: "MontrealSerial",
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    '${drawerProvider.userEmail ?? 'N/A'}',
                                    style: TextStyle(
                                      fontFamily: "MontrealSerial",
                                      color: Colors.white38,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Container(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount:
                                        drawerProvider.listOfdata == null
                                            ? 0
                                            : drawerProvider.listOfdata!.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        leading: Container(
                                          width: _isTablet ? 30 : 18,
                                          height: _isTablet ? 30 : 18,
                                          child: Image.asset(
                                            drawerProvider
                                                    .listOfdata![index]['iconImage'] ??
                                                'assets/images/empty.png',
                                          ),
                                        ),
                                        title: Text(
                                          '${drawerProvider.listOfdata![index]['title'] ?? 'No Title'}',
                                          style: TextStyle(
                                            overflow: TextOverflow.ellipsis,
                                            fontFamily: "MontrealSerial",
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onTap: () {
                                          final routeName =
                                              drawerProvider
                                                  .listOfdata![index]['route'];
                                          final title =
                                              drawerProvider
                                                  .listOfdata![index]['title'];
                                          Navigator.pop(context);
                                          if (drawerProvider
                                                  .listOfdata![index]['title'] ==
                                              'My Clients') {
                                            print('go to client ');
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              routeName,
                                              (route) => false,
                                              arguments: {'initialIndex': 2},
                                            );
                                          } else if (title ==
                                              'Reports & Analysis') {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              routeName,
                                              (route) => false,
                                              arguments: {'initialIndex': 1},
                                            );
                                          } else if (title == 'Settings') {
                                            Navigator.pushNamedAndRemoveUntil(
                                              context,
                                              routeName,
                                              (route) => false,
                                              arguments: {'initialIndex': 3},
                                            );
                                          } else {
                                            Navigator.pushNamed(
                                              context,
                                              '${routeName}',
                                            );
                                          }
                                        },
                                        trailing: Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.white24,
                                          size: 18,
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider();
                                    },
                                  ),
                                  SizedBox(height: _isTablet ? 90 : 60),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: _isTablet ? 90 : 60),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/presentation/screens/home/home_screen.dart';
import 'package:wisdeals/presentation/screens/ordersandclientlist/orders_screen.dart';
import 'package:wisdeals/presentation/screens/report/report_screen.dart';
import 'package:wisdeals/presentation/screens/setting/settings_screen.dart';

class BottomNavbarWidget extends StatefulWidget {
  final int? initialIndex;
  const BottomNavbarWidget({Key? key, required this.initialIndex})
    : super(key: key);

  @override
  _BottomNavbarWidgetState createState() => _BottomNavbarWidgetState();
}

class _BottomNavbarWidgetState extends State<BottomNavbarWidget> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ReportScreen(),
    OrdersScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // The main page content
          _pages[_currentIndex],

          // Floating Bottom Navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 35, // distance from bottom
            child: ClipRRect(
              // borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  width: double.infinity,
                  height: 90,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(82, 19, 18, 18).withOpacity(0.5),
                        const Color.fromARGB(117, 43, 40, 40).withOpacity(0.24),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(4, (index) {
                      final icons = [
                        "assets/images/navbaricon/iconhomegreen.png",
                        "assets/images/navbaricon/iconreport.png",
                        "assets/images/navbaricon/iconorder.png",
                        "assets/images/navbaricon/iconsettings.png",
                      ];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        child: _navIcon(icons[index], index),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navIcon(String assetPath, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white24 : Colors.transparent, // bg color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(
        assetPath,
        height: 24,
        width: 24,
        color: isSelected ? kButtonColor2 : Colors.grey, // change icon color
      ),
    );
  }
}

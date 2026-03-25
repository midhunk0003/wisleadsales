import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmallScreen = constraints.maxWidth < 400;

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical:
                  isTablet
                      ? 50
                      : isSmallScreen
                      ? 10
                      : 25,
              horizontal:
                  isTablet
                      ? 50
                      : isSmallScreen
                      ? 10
                      : 25,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                CustomAppBarWidget(
                  title: "Settings",
                  drawerIconImage: true,
                  notificationIconImage: false,
                ),
                SizedBox(height: 50),
                Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    fontFamily: "MontrealSerial",
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Help & Support',
                  style: TextStyle(
                    fontFamily: "MontrealSerial",
                    color: Colors.white,
                    fontSize: isTablet ? 28 : 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logout Icon
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.redAccent,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 15),

                                // Title
                                const Text(
                                  "Log Out",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Description
                                const Text(
                                  "Are you sure you want to log out?",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Buttons
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Cancel Button
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black87,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Logout Button
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, _) {
                                        return Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 3,
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                            ),
                                            onPressed: () {
                                              // Add your logout logic here
                                              authProvider.logOut(context);
                                            },
                                            child: const Text(
                                              "Log Out",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontFamily: "MontrealSerial",
                          color: Colors.white,
                          fontSize: isTablet ? 28 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "App Version 1.0.0",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                          letterSpacing: .3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

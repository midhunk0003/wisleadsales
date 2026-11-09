import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animaton;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();
    _animaton = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigatToLoginOrHome();
      }
    });
  }

  // bool _isNavigated = false;

  // void _safeNavigate() {
  //   if (_isNavigated) return;
  //   _isNavigated = true;
  //   _navigatToLoginOrHome();
  // }

  // Future<void> checkUpdate() async {
  //   try {
  //     final updateAppProvider = Provider.of<AppUpdateVersionProvider>(
  //       context,
  //       listen: false,
  //     );

  //     // ⏱️ Add timeout (VERY IMPORTANT)
  //     await updateAppProvider
  //         .checkForUpdate(context)
  //         .timeout(const Duration(seconds: 5));

  //     if (!mounted) return;
  //     _safeNavigate();
  //     // If update available → dialog shown → DO NOTHING
  //   } catch (e) {
  //     // ✅ fallback → NEVER block user
  //     if (mounted) {
  //       _navigatToLoginOrHome();
  //     }
  //   }
  // }

  Future<void> _navigatToLoginOrHome() async {
    final pref = await SharedPreferences.getInstance();
    final String? token = pref.getString('token');
    final bool? isOnboarded = await pref.getBool('isOnboarded') ?? false;

    print('aaaaaaaaaaaaaa splash screen  : $token');
    print('aaaaaaaaaaaaaa splash isonbord  : $isOnboarded');

    if (token == null || token.isEmpty) {
      if (isOnboarded == false) {
        Navigator.pushReplacementNamed(context, '/onboardscreen');
      } else {
        Navigator.pushReplacementNamed(context, '/loginScreen');
      }
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/bottomnavbarwidget',
        arguments: {'initialIndex': 0},
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // dispose the animation controller here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReusableScafoldAndGlowbackground(
        child: Consumer<AppUpdateVersionProvider>(
          builder: (context, appUpdateProvider, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool _isTablet = constraints.maxWidth > 600;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: FadeTransition(
                        opacity: _animaton,
                        child: Text(
                          'Wteams',
                          style: TextStyle(
                            color: kTextColorPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: _isTablet ? 48 : 24,
                          ),
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _animaton,
                      child: Column(
                        children: [
                          Text(
                            'Better team. Better growth',
                            style: TextStyle(
                              color: Color(0x80FFFFFF),
                              fontWeight: FontWeight.w400,
                              fontSize: _isTablet ? 24 : 12,
                            ),
                          ),
                          Divider(
                            color: Color(0x80FFFFFF),
                            thickness: 0.3,
                            indent: 120,
                            endIndent: 120,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),
                    appUpdateProvider.isLoading
                        ?
                        // Smooth Loading Indicator
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.5,
                            color: khome3rdSectionColor,
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

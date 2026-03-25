import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_provider.dart';
import 'package:wisdeals/core/colors.dart';
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
  bool _shouldNavigate = true; // control navigation
  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();
    _animaton = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      checkUpdate();
      // _navigatToLoginOrHome();
    });
  }

  Future<void> checkUpdate() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final updateAppProvider = Provider.of<AppUpdateVersionProvider>(
        context,
        listen: false,
      );
      await updateAppProvider.fetchUpdateResponce();
      // await updateAppProvider.checkForUpdate(context);
      if (updateAppProvider.failure != null) {
        // 👉 If internet/server error
        print(
          'updateAppProvider failure splash screen : ${updateAppProvider.failure}',
        );
        showErrorDialog(
          context,
          updateAppProvider.failure!.message ?? "Something went wrong!",
        );
      } else {
        bool updateAvailable = await updateAppProvider.checkForUpdate(context);
        print('updateAvailable splash screen : ${!updateAvailable}');
        if (!updateAvailable) {
          // only navigate if update is NOT available
          Future.delayed(const Duration(seconds: 3), () {
            if (_shouldNavigate) {
              _navigatToLoginOrHome();
            }
          });
        } else {
          // prevent navigation if update dialog is showing
          _shouldNavigate = false;
        }
      }
    });
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            title: const Text("Error"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Provider.of<AppUpdateVersionProvider>(
                    context,
                    listen: false,
                  ).clearFailure();
                  Provider.of<AppUpdateVersionProvider>(
                    context,
                    listen: false,
                  ).fetchUpdateResponce();
                  // Try again
                  Provider.of<AppUpdateVersionProvider>(
                    context,
                    listen: false,
                  ).checkForUpdate(context);
                },
                child: const Text("Retry"),
              ),
            ],
          ),
    );
  }

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
                      child: Text(
                        'Better team. Better growth',
                        style: TextStyle(
                          color: Color(0x80FFFFFF),
                          fontWeight: FontWeight.w400,
                          fontSize: _isTablet ? 24 : 12,
                        ),
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

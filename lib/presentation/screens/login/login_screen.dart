import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReusableScafoldAndGlowbackground(
        child: Consumer<AuthProvider>(
          builder: (context, loginProvider, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final failure = loginProvider.failure;
              if (failure != null) {
                if (failure is ClientFailure ||
                    failure is ServerFailure ||
                    loginProvider.failure is ClientFailure ||
                    loginProvider.failure is ServerFailure) {
                  failureDilogeWidget(
                    context,
                    'assets/images/failicon.png',
                    "Login Failed",
                    '${failure.message}',
                    provider: loginProvider,
                  );
                }
              }
            });

            if (loginProvider.failure is NetworkFailure) {
              return NetWorkRetry(
                failureMessage:
                    loginProvider.failure?.message ?? "No internet connection",
                userNameController: _emailController,
                passwordController: _passwordController,
                onRetry: () async {
                  await loginProvider.loginProvider(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                  );
                },
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final bool _isTablet = constraints.maxWidth > 600;
                final bool isMediumScreen =
                    constraints.maxWidth >= 600 && constraints.maxWidth < 900;
                final bool isLargeScreen = constraints.maxWidth >= 900;
                return Stack(
                  children: [
                    Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: _getHorizontalPadding(
                              constraints.maxWidth,
                            ),
                            vertical: _getVerticalPadding(
                              constraints.maxHeight,
                            ),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: _getTopSpacing(constraints.maxHeight),
                              ),
                              Container(
                                decoration: BoxDecoration(),
                                child: Column(
                                  children: [
                                    Text(
                                      'WISLEAD',
                                      style: TextStyle(
                                        color: kTextColorPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: _isTablet ? 48 : 24,
                                      ),
                                    ),
                                    SizedBox(height: _isTablet ? 8 : 10),
                                    Text(
                                      'Better team. Better growth',
                                      style: TextStyle(
                                        color: Color(0x80FFFFFF),
                                        fontWeight: FontWeight.w400,
                                        fontSize: _isTablet ? 24 : 12,
                                      ),
                                    ),
                                    SizedBox(
                                      height: _getSpacingAfterLogo(
                                        constraints.maxHeight,
                                      ),
                                    ),
                                    TextFormField(
                                      controller: _emailController,
                                      style: TextStyle(
                                        color: kTextColorPrimary,
                                        fontSize: _isTablet ? 20 : 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter email",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: _isTablet ? 24 : 12,
                                          vertical: _isTablet ? 24 : 12,
                                        ),
                                      ),
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter Email";
                                        } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value)) {
                                          return "Please enter a valid email";
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                    SizedBox(height: _isTablet ? 24 : 12),
                                    TextFormField(
                                      obscureText:
                                          loginProvider.isVisible
                                              ? true
                                              : false,
                                      controller: _passwordController,
                                      style: TextStyle(
                                        color: kTextColorPrimary,
                                        fontSize: _isTablet ? 20 : 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        suffixIcon: IconButton(
                                          onPressed: () {
                                            loginProvider.isVisibleOrNot();
                                          },
                                          icon: Icon(
                                            loginProvider.isVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility_outlined,
                                          ),
                                        ),

                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: _isTablet ? 24 : 12,
                                          vertical: _isTablet ? 24 : 12,
                                        ),
                                      ),
                                      validator: (value) {
                                        print(
                                          'textaaaa : ${_passwordController.text}',
                                        );
                                        if (value == null || value.isEmpty) {
                                          return "Please Enter Password";
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                    SizedBox(height: _isTablet ? 16 : 8),
                                    // GestureDetector(
                                    //   onTap: () {},
                                    //   child: Align(
                                    //     alignment: Alignment.topRight,
                                    //     child: Text(
                                    //       'Recovery Password',
                                    //       style: TextStyle(
                                    //         color: kTextColorPrimary,
                                    //         fontWeight: FontWeight.bold,
                                    //         fontSize: _isTablet ? 24 : 12,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: _getBottomSpacing(
                                  constraints.maxHeight,
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    print('go..');
                                    print('${_emailController.text}');
                                    print('${_passwordController.text}');
                                    await loginProvider.loginProvider(
                                      _emailController.text.toString(),
                                      _passwordController.text.toString(),
                                    );
                                    if (loginProvider.failure == null) {
                                      Navigator.pushNamed(
                                        context,
                                        '/bottomnavbarwidget',
                                        arguments: {'initialIndex': 0},
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: _isTablet ? 400 : 300,
                                  height: _isTablet ? 60 : 60,
                                  decoration: BoxDecoration(
                                    color: kButtonColor2,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: _isTablet ? 20 : 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    loginProvider.isLoading
                        ? Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: kButtonColor2,
                            ),
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

// Responsive padding methods and between heights
double _getHorizontalPadding(double screenWidth) {
  if (screenWidth < 400) return 24;
  if (screenWidth < 600) return 32;
  if (screenWidth < 900) return 42;
  return screenWidth * 0.2; // For very large screens, use percentage
}

double _getVerticalPadding(double screenHeight) {
  if (screenHeight < 600) return 20;
  if (screenHeight < 800) return 30;
  return 40;
}

double _getTopSpacing(double screenHeight) {
  if (screenHeight < 600) return 50;
  if (screenHeight < 800) return 80;
  return 100;
}

double _getSpacingAfterLogo(double screenHeight) {
  if (screenHeight < 600) return 40;
  if (screenHeight < 800) return 60;
  return 90;
}

double _getBottomSpacing(double screenHeight) {
  if (screenHeight < 600) return 150;
  if (screenHeight < 800) return 200;
  return 300;
}

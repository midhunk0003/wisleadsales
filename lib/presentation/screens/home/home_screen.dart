import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wisdeals/app_update_version.dart/app_update_version_provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/presentation/provider/home_provider.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initialData();
  }

  void _initialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// Providers
      final appUpdateProvider = Provider.of<AppUpdateVersionProvider>(
        context,
        listen: false,
      );
      final provider = Provider.of<HomeProvider>(context, listen: false);
      final leadprovider = Provider.of<LeadProvider>(context, listen: false);
      final profileProviders = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );

      //  Clear old profile images
      profileProviders.clearSelectedImages();
      //Load Home Data
      // provider.getHomePro();
      // // Then load lead data
      // leadprovider.getLeadPro('', '', isRefresh: true);
      // //Load Profile Data
      // profileProviders.getProfileData(); // wait for data to load
      // // Load Profile Image from Shared
      // profileProviders.getProfilImgFromShared(); // wait for data to load
      // appUpdateProvider.fetchUpdateResponce();

      await Future.wait([
        provider.getHomePro(),
        leadprovider.getLeadPro('', '', isRefresh: true),
        profileProviders.getProfileData(),
        profileProviders.getProfilImgFromShared(),
        appUpdateProvider.fetchUpdateResponce(),
      ]);

      appUpdateProvider.checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<HomeProvider, LeadProvider, ProfileProvider, AuthProvider>(
      builder: (
        context,
        homeProvider,
        leadProvider,
        profileProvider,
        authProvider,
        _,
      ) {
        final failures = <Failure?>[
          homeProvider.failure,
          leadProvider.failure,
          profileProvider.failure,
          authProvider.failure,
        ];

        /// 🌐 Network failure (highest priority)
        final networkFailure = failures.firstWhere(
          (f) => f is NetworkFailure,
          orElse: () => null,
        );

        if (networkFailure != null) {
          return NetWorkRetry(
            failureMessage: networkFailure.message ?? "No internet connection",
            onRetry: () async {
              await Future.wait([
                homeProvider.getHomePro(),
                leadProvider.getLeadPro('', '', isRefresh: true),
                profileProvider.getProfileData(),
              ]);
            },
          );
        }

        /// ❌ Dialog failures (Client / Server / Unknown)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dialogFailure = failures.firstWhere(
            (f) => f is ClientFailure || f is ServerFailure,
            orElse: () => null,
          );

          if (dialogFailure != null) {
            failureDilogeWidget(
              context,
              'assets/images/failicon.png',
              "Failed",
              dialogFailure.message,
              provider: _getFailureProvider(
                dialogFailure,
                homeProvider,
                leadProvider,
                profileProvider,
                authProvider,
              ),
            );
          }
        });
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   final failure = leadProvider.failure;
        //   if (failure != null) {
        //     if (failure is ClientFailure ||
        //         failure is ServerFailure ||
        //         leadProvider.failure is ClientFailure ||
        //         leadProvider.failure is ServerFailure) {
        //       failureDilogeWidget(
        //         context,
        //         'assets/images/failicon.png',
        //         "Failed",
        //         '${failure.message}',
        //         provider: leadProvider,
        //       );
        //     }
        //   }
        // });
        // if (leadProvider.failure is NetworkFailure) {
        //   return NetWorkRetry(
        //     failureMessage:
        //         leadProvider.failure?.message ?? "No internet connection",
        //     onRetry: () async {
        //       await leadProvider.getLeadPro('', isRefresh: true);
        //     },
        //   );
        // }
        return Stack(
          children: [
            ReusableScafoldAndGlowbackground(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  /// 📱 Breakpoints
                  final isMobile = constraints.maxWidth < 600;
                  final _isTablet =
                      constraints.maxWidth >= 600 &&
                      constraints.maxWidth < 1100;
                  final isLargeTablet = constraints.maxWidth >= 1100;

                  /// 📏 Dynamic Sizes
                  final horizontalPadding =
                      isMobile
                          ? 20.0
                          : _isTablet
                          ? 40.0
                          : 80.0;

                  final titleFont =
                      isMobile
                          ? 32.0
                          : _isTablet
                          ? 36.0
                          : 42.0;

                  final cardHeight =
                      isMobile
                          ? 90.0
                          : _isTablet
                          ? 110.0
                          : 130.0;

                  final mapHeight =
                      isMobile
                          ? 500.0
                          : _isTablet
                          ? 800.0
                          : 500.0;

                  final clockSize =
                      isMobile
                          ? 130.0
                          : _isTablet
                          ? 160.0
                          : 150.0;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: _isTablet ? 50 : 25,
                      horizontal: _isTablet ? 50 : 25,
                    ),
                    child: RefreshIndicator(
                      onRefresh: () {
                        return Future.wait([
                          homeProvider.getHomePro(),
                          leadProvider.getLeadPro('', '', isRefresh: true),
                          profileProvider.getProfileData(),
                        ]);
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 30),
                            CustomAppBarWidget(title: "Wteams"),
                            SizedBox(height: 40),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Ready",
                                    style: TextStyle(
                                      fontFamily: "MontrealSerial",
                                      color: Color(0xFF82AE09),
                                      fontSize: titleFont,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  WidgetSpan(child: SizedBox(width: 10)),
                                  TextSpan(
                                    text: "For Todays",
                                    style: TextStyle(
                                      fontFamily: "MontrealSerial",
                                      color: Colors.white,
                                      fontSize: titleFont,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Challenge',
                              style: TextStyle(
                                fontFamily: "MontrealSerial",
                                color: Colors.white,
                                fontSize: titleFont,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 30),

                            // if (homeProvider.isTracking)
                            //   Container(
                            //     padding: EdgeInsets.all(8),
                            //     decoration: BoxDecoration(
                            //       color: Colors.green.withOpacity(0.3),
                            //       borderRadius: BorderRadius.circular(8),
                            //     ),
                            //     child: Row(
                            //       mainAxisSize: MainAxisSize.min,
                            //       children: [
                            //         Icon(
                            //           Icons.location_on,
                            //           color: Colors.green,
                            //           size: 16,
                            //         ),
                            //         SizedBox(width: 4),
                            //         Text(
                            //           'Live Tracking Active',
                            //           style: TextStyle(
                            //             color: Colors.green,
                            //             fontSize: 12,
                            //             fontWeight: FontWeight.bold,
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // Additional status container
                            (homeProvider.isLoading ||
                                    profileProvider.isLoading ||
                                    homeProvider.homeData == null)
                                ? HomeShimmer()
                                : Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: khome3rdSectionColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(18),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Today Distance',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "MontrealSerial",
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),

                                                  Text(
                                                    homeProvider.homeData !=
                                                            null
                                                        ? (double.tryParse(
                                                                  homeProvider
                                                                          .homeData!
                                                                          .km
                                                                          ?.toString() ??
                                                                      '',
                                                                ) ??
                                                                ((homeProvider
                                                                            .totalDistancePrefData ??
                                                                        0) /
                                                                    1000))
                                                            .toStringAsFixed(2)
                                                        : '0.00',
                                                    style: const TextStyle(
                                                      fontFamily:
                                                          "MontrealSerial",
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: khome3rdSectionColor,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(18),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Pending Leads',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "MontrealSerial",
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    '${leadProvider.pendingLeads ?? '0'}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "MontrealSerial",
                                                      color: Colors.white,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),

                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(30),
                                            topRight: Radius.circular(30),
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            height: mapHeight,
                                            child: GoogleMap(
                                              onMapCreated:
                                                  homeProvider.setMapController,
                                              initialCameraPosition: CameraPosition(
                                                target:
                                                    (homeProvider
                                                            .currentPositionPrefData ??
                                                        homeProvider
                                                            .currentPosition ??
                                                        const LatLng(
                                                          37.43296,
                                                          -122.08832,
                                                        )), // Provide a default
                                                zoom: 19,
                                              ),
                                              myLocationEnabled: true,
                                              myLocationButtonEnabled: true,
                                              markers: homeProvider.markers,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: isMobile ? 30 : 40,
                                          left: 100,
                                          right: 100,
                                          child: GestureDetector(
                                            onTap:
                                                homeProvider.isLoadingAuth
                                                    ? null
                                                    : () async {
                                                      homeProvider
                                                          .authenticateAndClock(
                                                            context,
                                                          );
                                                    },
                                            child: Container(
                                              width: clockSize,
                                              height: clockSize,
                                              decoration: const BoxDecoration(
                                                color: Colors.transparent,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        homeProvider
                                                                    .homeData
                                                                    ?.status ==
                                                                true
                                                            ? Colors.green
                                                                .withOpacity(
                                                                  0.30,
                                                                )
                                                            : Colors.red
                                                                .withOpacity(
                                                                  0.30,
                                                                ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child:
                                                        homeProvider
                                                                .isLoadingAuth
                                                            ? const CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            )
                                                            : Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Image.asset(
                                                                  'assets/images/fingerprient.png',
                                                                  width: 40,
                                                                  height: 40,
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  homeProvider
                                                                              .homeData
                                                                              ?.status ==
                                                                          true
                                                                      ? "Clock Out"
                                                                      : "Clock In",
                                                                  style: const TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            (profileProvider.profileDatas == null)
                ? SizedBox.shrink()
                : (profileProvider.profileDatas!.isActive.toString()) == '0'
                ? AnimatedOpacity(
                  opacity: 1,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.6),
                    child: Center(
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 320,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 🔒 Title
                              const Text(
                                'Account Blocked',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 10),

                              /// 📄 Details
                              const Text(
                                'Your account has been temporarily blocked by the admin.\n\n'
                                'Please contact support or your administrator for further clarification.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// 🚪 Logout Button
                              SizedBox(
                                width: double.infinity,
                                height: 45,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () async {
                                    /// clear session / token
                                    await authProvider.logOut(context);

                                    /// navigate to login
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class AccountBlockedDialog extends StatelessWidget {
  const AccountBlockedDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: const [
          Icon(Icons.block, color: Colors.red),
          SizedBox(width: 8),
          Text('Account Blocked'),
        ],
      ),
      content: const Text(
        'Your account has been blocked. Please contact support for more details.',
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            // TODO: clear auth data
            // authProvider.logout();

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

ChangeNotifier _getFailureProvider(
  Failure failure,
  HomeProvider home,
  LeadProvider lead,
  ProfileProvider profile,
  AuthProvider auth,
) {
  if (home.failure == failure) return home;
  if (lead.failure == failure) return lead;
  if (profile.failure == failure) return profile;
  return auth;
}

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: _card()),
              const SizedBox(width: 12),
              Expanded(child: _card()),
            ],
          ),
          const SizedBox(height: 20),
          _map(),
        ],
      ),
    );
  }

  Widget _card() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _map() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 400,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
        ),
        Container(
          width: 110,
          height: 110,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

void clearAllFailures({
  required HomeProvider homeProvider,
  required LeadProvider leadProvider,
  required ProfileProvider profileProvider,
  required AuthProvider authProvider,
}) {
  homeProvider.clearFailure();
  leadProvider.clearFailure();
  profileProvider.clearFailure();
  authProvider.clearFailure();
}

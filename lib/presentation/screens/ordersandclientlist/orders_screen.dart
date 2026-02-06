import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/order_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/list_shimmer_effect.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/search_and_filter_field_widget.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController scrollcontrollers = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollcontrollers.addListener(_scrollListener);
    _initialData();
  }

  void _initialData() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final leadProvider = Provider.of<LeadProvider>(context, listen: false);
      final profileProviders = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      orderProvider.getleadStatusPro();
      orderProvider.getleadPriorityPro();
      await orderProvider.getClientsPro(isRefresh: true, '', '');
      // for filter section
      await leadProvider.getCustomerProfilePro();
      orderProvider.getClientStatus();
      //load profile data
      profileProviders.clearSelectedImages();
      profileProviders.getProfileData(); // wait for data to load
      profileProviders.getProfilImgFromShared(); // wait for data to load
    });
  }

  void _scrollListener() {
    if (scrollcontrollers.position.pixels >=
        scrollcontrollers.position.maxScrollExtent - 100) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      if (!orderProvider.isLoadingMore && orderProvider.hasMore) {
        // print('listening  and index name${leadProvider.getFilterLeadIndex}');
        orderProvider.getClientsPro(isRefresh: false, '', '');
      }
    } else {
      print('no listening ');
    }
  }

  @override
  void dispose() {
    scrollcontrollers.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmallScreen = constraints.maxWidth < 400;
          final double screenWidth = constraints.maxWidth;
          final double padding = screenWidth * 0.04; // dynamic padding
          double scale(double base) {
            if (isTablet) return base * 1.6;
            if (isSmallScreen) return base * 0.85;
            return base;
          }

          return Consumer4<
            OrderProvider,
            LeadProvider,
            ProfileProvider,
            AuthProvider
          >(
            builder: (
              context,
              orderProvider,
              leadProvider,
              profileProvider,
              authProvider,
              _,
            ) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final failure = orderProvider.failure;
                if (failure != null) {
                  if (failure is ClientFailure ||
                      failure is ServerFailure ||
                      orderProvider.failure is ClientFailure ||
                      orderProvider.failure is ServerFailure) {
                    failureDilogeWidget(
                      context,
                      'assets/images/failicon.png',
                      "Failed",
                      '${failure.message}',
                      provider: orderProvider,
                    );
                  }
                }
              });

              if (orderProvider.failure is NetworkFailure) {
                return NetWorkRetry(
                  failureMessage:
                      orderProvider.failure?.message ??
                      "No internet connection",
                  onRetry: () async {
                    await orderProvider.getClientsPro(isRefresh: false, '', '');
                  },
                );
              }
              return Stack(
                children: [
                  // list data and search part
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: padding,
                      horizontal: padding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: scale(30)),
                        CustomAppBarWidget(title: "Clients"),
                        SizedBox(height: scale(40)),
                        // filter portion button
                        SearchAndFilterFieldWidget(
                          isTablet: isTablet,
                          title: "Search Client",
                          textEditingController: _searchController,
                          onChange: () {
                            print(
                              'onchange search variable ${_searchController.text}',
                            );
                            orderProvider.searchLeadList(
                              _searchController.text,
                            );
                          },
                          onTap: () {
                            print('filter');
                            orderProvider.hideandShowFilter();
                          },
                          showFilter: true,
                        ),
                        SizedBox(height: scale(30)),
                        Text(
                          'Client : ${orderProvider.totalClient ?? '0'}',
                          style: TextStyle(
                            fontFamily: "MontrealSerial",
                            color: Colors.white,
                            fontSize: scale(22),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // list
                        (orderProvider.isLoading ||
                                orderProvider.searchedclientList == null ||
                                leadProvider.isLoading ||
                                leadProvider.getCustomerProfileList == null ||
                                profileProvider.isLoading ||
                                profileProvider.profileDatas == null)
                            ? Expanded(
                              child: const LeadCardShimmer(isTablet: false),
                            )
                            : (orderProvider.searchedclientList == null ||
                                orderProvider.searchedclientList!.isEmpty)
                            ? Container(
                              width: double.infinity,
                              height: 500,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Lottie.asset(
                                    'assets/json/noevents.json',
                                    width: scale(150),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No Client Found',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: scale(16),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Expanded(
                              child: Container(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    _initialData();
                                  },
                                  child: ListView.separated(
                                    controller: scrollcontrollers,
                                    shrinkWrap: false,
                                    itemCount:
                                        orderProvider
                                            .searchedclientList!
                                            .length +
                                        (orderProvider.isLoadingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      // 🔥 SHOW LOAD MORE INDICATOR AT BOTTOM
                                      if (index ==
                                          orderProvider
                                              .searchedclientList!
                                              .length) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: kButtonColor2,
                                            ),
                                          ),
                                        );
                                      }

                                      final client =
                                          orderProvider
                                              .searchedclientList![index];
                                      final meetings = client.meetings ?? [];

                                      print("Meetings: $meetings");
                                      var pastMeeting;
                                      var nextMeeting;
                                      // ------------------------------------------
                                      // 1️⃣ DATE PARSER (supports yyyy-MM-dd & dd-MM-yyyy)
                                      // ------------------------------------------
                                      DateTime? _parseCustomDate(dynamic date) {
                                        if (date == null) return null;

                                        if (date is DateTime) return date;

                                        if (date is String) {
                                          // yyyy-MM-dd
                                          final iso = RegExp(
                                            r'^\d{4}-\d{1,2}-\d{1,2}$',
                                          );
                                          if (iso.hasMatch(date)) {
                                            try {
                                              return DateTime.parse(date);
                                            } catch (_) {}
                                          }

                                          // dd-MM-yyyy
                                          final dmy = RegExp(
                                            r'^\d{1,2}-\d{1,2}-\d{4}$',
                                          );
                                          if (dmy.hasMatch(date)) {
                                            final parts = date.split("-");
                                            return DateTime(
                                              int.parse(parts[2]),
                                              int.parse(parts[1]),
                                              int.parse(parts[0]),
                                            );
                                          }
                                        }

                                        return null;
                                      }

                                      // ------------------------------------------
                                      // 2️⃣ Convert parsed meeting dates (remove time)
                                      // ------------------------------------------
                                      List<Map<String, dynamic>> parsed =
                                          meetings
                                              .map((m) {
                                                final d = _parseCustomDate(
                                                  m.date,
                                                );
                                                if (d == null) return null;

                                                return {
                                                  "meeting": m,
                                                  "date": DateTime(
                                                    d.year,
                                                    d.month,
                                                    d.day,
                                                  ), // strip time
                                                };
                                              })
                                              .where((e) => e != null)
                                              .cast<Map<String, dynamic>>()
                                              .toList();

                                      // If no valid dates → no past or next
                                      if (parsed.isEmpty) {
                                        pastMeeting = null;
                                        nextMeeting = null;
                                      } else {
                                        // ------------------------------------------
                                        // 3️⃣ Sort meetings by date ascending
                                        // ------------------------------------------
                                        parsed.sort(
                                          (a, b) => (a["date"] as DateTime)
                                              .compareTo(b["date"]),
                                        );

                                        print("Sorted Meetings: $parsed");

                                        if (parsed.length == 1) {
                                          // ------------------------------------------
                                          // 4️⃣ Only one meeting → next = that meeting, past = null
                                          // ------------------------------------------
                                          pastMeeting = null;
                                          nextMeeting = parsed[0]["meeting"];
                                        } else {
                                          // ------------------------------------------
                                          // 5️⃣ Multiple meetings:
                                          // past = second last
                                          // next = last
                                          // ------------------------------------------
                                          pastMeeting =
                                              parsed.length >= 2
                                                  ? parsed[parsed.length -
                                                      2]["meeting"]
                                                  : null;
                                          nextMeeting = parsed.last["meeting"];
                                        }
                                      }

                                      // ------------------------------------------
                                      // 6️⃣ Format date for UI
                                      // ------------------------------------------
                                      String _formatDate(dynamic date) {
                                        final parsed = _parseCustomDate(date);
                                        if (parsed == null) return "";
                                        return DateFormat(
                                          "dd-MM-yyyy",
                                        ).format(parsed);
                                      }

                                      return InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/ordersingleviewscreen',
                                            arguments: {"client": client},
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.white.withOpacity(0.20),
                                                Colors.white.withOpacity(0.05),
                                              ],
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(scale(15)),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // --- Header: Client Info ---
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              client.companyName ??
                                                                  'N/A',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "MontrealSerial",
                                                                color:
                                                                    Colors
                                                                        .white,
                                                                fontSize: scale(
                                                                  20,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            // const SizedBox(
                                                            //   width: 5,
                                                            // ),
                                                            // client.isImportant ==
                                                            //         true
                                                            //     ? Icon(
                                                            //       Icons
                                                            //           .star_border_outlined,
                                                            //       color:
                                                            //           Colors
                                                            //               .amber,
                                                            //     )
                                                            //     : Icon(
                                                            //       Icons.star,
                                                            //       color:
                                                            //           Colors
                                                            //               .amber,
                                                            //     ),
                                                          ],
                                                        ),
                                                        Text(
                                                          client.clientName ??
                                                              'N/A',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "MontrealSerial",
                                                            color: Colors.white,
                                                            fontSize: scale(14),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        print(
                                                          '${client.isImportant}',
                                                        );
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/ordersingleviewscreen',
                                                          arguments: {
                                                            "client": client,
                                                          },
                                                        );
                                                      },
                                                      child: Column(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/clientlistarrow.png',
                                                            width: scale(40),
                                                            height: scale(40),
                                                          ),
                                                          SizedBox(
                                                            height: scale(5),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Text(
                                                  'Status : ${client.status ?? 'N/A'}',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "MontrealSerial",
                                                    color: kButtonColor2,
                                                    fontSize:
                                                        isTablet ? 18 : 12,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                // --- Old Visit + Next Meeting ---
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _buildMeetingColumn(
                                                      title: 'Past Meeting',
                                                      date: _formatDate(
                                                        pastMeeting?.date,
                                                      ),
                                                      time:
                                                          '${pastMeeting?.timeFrom ?? '--'} to ${pastMeeting?.timeTo ?? '--'}',
                                                      scale: scale,
                                                    ),
                                                    SizedBox(width: 10),
                                                    _buildMeetingColumn(
                                                      title: 'Next Meeting',
                                                      date: _formatDate(
                                                        nextMeeting?.date,
                                                      ),
                                                      time:
                                                          '${nextMeeting?.timeFrom ?? '--'} to ${nextMeeting?.timeTo ?? '--'}',
                                                      scale: scale,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (context, index) =>
                                            SizedBox(height: 15),
                                  ),
                                ),
                              ),
                            ),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),

                  /// filter section hide and show portion
                  orderProvider.hideAndShowStatus
                      ? Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color.fromARGB(
                                255,
                                155,
                                153,
                                153,
                              ).withOpacity(0.20), // bright top-left
                              const Color.fromARGB(
                                255,
                                128,
                                127,
                                127,
                              ).withOpacity(0.5), // softer bottom-right
                            ],
                          ),
                        ),
                      )
                      : SizedBox.shrink(),
                  // Animated container
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    top: orderProvider.hideAndShowStatus ? 200 : -1000,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            isTablet
                                ? 50
                                : isSmallScreen
                                ? 10
                                : 10,
                        horizontal:
                            isTablet
                                ? 50
                                : isSmallScreen
                                ? 10
                                : 15,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFEDFCC5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Filter Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Filter',
                                  style: TextStyle(
                                    fontFamily: "MontrealSerial",
                                    color: Colors.black,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    orderProvider.hideandShowFilter();
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ],
                            ),

                            const Divider(),
                            const SizedBox(height: 15),

                            // Sort by Status
                            Text(
                              'Sort by Status',
                              style: TextStyle(
                                fontFamily: "MontrealSerial",
                                color: Colors.black,
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 4,
                                  ),
                              itemCount:
                                  (orderProvider.clientStatus ?? []).length,
                              itemBuilder: (context, index) {
                                final statusList =
                                    orderProvider.clientStatus ?? [];
                                final statusName = statusList[index] ?? '';

                                return Row(
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue:
                                          orderProvider.selectedStatusvalue,
                                      onChanged: (value) {
                                        if (value != null) {
                                          orderProvider.selectedStatusPro(
                                            value,
                                            statusName,
                                          );
                                        }
                                      },
                                    ),
                                    Flexible(
                                      child: Text(
                                        statusName,
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.black,
                                          fontSize: isTablet ? 20 : 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 15),

                            // Sort by Priority
                            Text(
                              'Sort by Priority',
                              style: TextStyle(
                                fontFamily: "MontrealSerial",
                                color: Colors.black,
                                fontSize: isTablet ? 20 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 4,
                                  ),
                              itemCount:
                                  (leadProvider.getCustomerProfileList ?? [])
                                      .length,
                              itemBuilder: (context, index) {
                                final list =
                                    leadProvider.getCustomerProfileList ?? [];

                                final name = list[index].name ?? 'N/A';
                                final id = list[index].id?.toString() ?? '';

                                return Row(
                                  children: [
                                    Radio<int>(
                                      value: index,
                                      groupValue:
                                          orderProvider.selectedPriorityvalue,
                                      onChanged: (value) {
                                        if (value != null) {
                                          orderProvider.selectedPriorityPro(
                                            value,
                                            name,
                                            id,
                                          );
                                        }
                                      },
                                    ),
                                    Flexible(
                                      child: Text(
                                        name,
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.black,
                                          fontSize: isTablet ? 20 : 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            // Apply Filter Button
                            InkWell(
                              onTap: () {
                                orderProvider.hideandShowFilter();

                                orderProvider.getClientsPro(
                                  isRefresh: true,
                                  orderProvider.selectedStatusName ?? '',
                                  orderProvider.selectedCustomerProfileId
                                          ?.toString() ??
                                      '',
                                );
                              },
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFF82AE09),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: isTablet ? 14 : 7,
                                      horizontal: isTablet ? 30 : 27,
                                    ),
                                    child: Text(
                                      'Apply Filter',
                                      style: TextStyle(
                                        fontFamily: "MontrealSerial",
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 12,
                                        fontWeight: FontWeight.w400,
                                      ),
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

                  (profileProvider.profileDatas == null)
                      ? SizedBox.shrink()
                      : (profileProvider.profileDatas!.isActive.toString()) ==
                          '0'
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
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
        },
      ),
    );
  }
}

Widget _buildMeetingColumn({
  required String title,
  required String date,
  required String time,
  required double Function(double) scale,
}) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: scale(14),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: scale(5)),
        Row(
          children: [
            Image.asset(
              'assets/images/clock.png',
              width: scale(18),
              height: scale(18),
            ),
            SizedBox(width: scale(5)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.white, fontSize: scale(13)),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.white70, fontSize: scale(12)),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

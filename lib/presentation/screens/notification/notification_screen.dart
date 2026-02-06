import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/notification_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialData();
  }

  void initialData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<NotificationProvider>(context, listen: false).filterDatas();
      Provider.of<NotificationProvider>(
        context,
        listen: false,
      ).getNotification();
    });
  }

  String formatDateTime(String date) {
    final DateTime parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy • hh:mm a').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmallScreen = constraints.maxWidth < 400;

          return Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final failure = notificationProvider.failure;
                if (failure != null) {
                  if (failure is ClientFailure ||
                      failure is ServerFailure ||
                      notificationProvider.failure is ClientFailure ||
                      notificationProvider.failure is ServerFailure) {
                    failureDilogeWidget(
                      context,
                      'assets/images/failicon.png',
                      "Failed",
                      '${failure.message}',
                      provider: notificationProvider,
                    );
                  }
                }
              });
              if (notificationProvider.failure is NetworkFailure) {
                return NetWorkRetry(
                  failureMessage:
                      notificationProvider.failure?.message ??
                      "No internet connection",
                  onRetry: () async {
                    await notificationProvider.getNotification();
                  },
                );
              }
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
                  children: [
                    SizedBox(height: 30),
                    CustomAppBarWidget(
                      title: "Notification",
                      drawerIconImage: false,
                      notificationIconImage: false,
                    ),
                    SizedBox(height: 30),
                    // filter section
                    Container(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount:
                            (notificationProvider.filterData == null ||
                                    notificationProvider.filterData.isEmpty)
                                ? 0
                                : notificationProvider.filterData.length,
                        itemBuilder: (context, index) {
                          final data = notificationProvider.filterData[index];
                          return InkWell(
                            onTap: () {
                              notificationProvider.selectFilter(data);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(50, 87, 2, 0.925),
                                ),
                                color:
                                    notificationProvider.selectedFilter ==
                                            notificationProvider
                                                .filterData![index]
                                        ? Color.fromRGBO(50, 87, 2, 0.925)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(
                                  '${data}',
                                  style: TextStyle(
                                    fontFamily: "MontrealSerial",
                                    color: Colors.white,
                                    fontSize: isTablet ? 28 : 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return SizedBox(width: 10);
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                    notificationProvider.notificationListReal.isEmpty
                        ? Expanded(
                          child: Container(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Lottie.asset(
                                    'assets/json/noevents.json',
                                    width: 150,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No Notification Found',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        : Expanded(
                          child: Container(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                initialData();
                              },
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    // today container
                                    (notificationProvider.filteredToday.isEmpty)
                                        ? Container()
                                        : Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Today",
                                                style: TextStyle(
                                                  fontFamily: "MontrealSerial",
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 28 : 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              notificationProvider.isLoading
                                                  ? notificationShimmerList(
                                                    isTablet: isTablet,
                                                  )
                                                  : ListView.separated(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        notificationProvider
                                                            .filteredToday
                                                            .length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final title =
                                                          notificationProvider
                                                              .filteredToday[index]
                                                              .title;
                                                      print('title : ${title}');
                                                      final imageIcon =
                                                          _getNotificationImage(
                                                            title!,
                                                          );
                                                      final bool isread =
                                                          notificationProvider
                                                              .filteredToday[index]
                                                              .isRead ==
                                                          false;
                                                      print(
                                                        'image icon : ${imageIcon}',
                                                      );
                                                      return InkWell(
                                                        onTap: () async {
                                                          print(
                                                            'today notification',
                                                          );
                                                          await notificationProvider
                                                              .readNotificationPro(
                                                                notificationProvider
                                                                    .filteredToday[index]
                                                                    .id
                                                                    .toString(),
                                                              );
                                                          if (notificationProvider
                                                                  .success !=
                                                              null) {
                                                            notificationProvider
                                                                .getNotification();
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            showSuccessDialog(
                                                              context,
                                                              "assets/images/successicons.png",
                                                              "Success",
                                                              "${notificationProvider.success!.message}",
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                    0.25,
                                                                  ),
                                                            ),
                                                            gradient:
                                                                isread
                                                                    ? LinearGradient(
                                                                      begin:
                                                                          Alignment
                                                                              .topLeft,
                                                                      end:
                                                                          Alignment
                                                                              .bottomRight,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                          124,
                                                                          128,
                                                                          119,
                                                                          0.922,
                                                                        ).withOpacity(
                                                                          0.3,
                                                                        ), // bright top-left
                                                                        Color.fromRGBO(
                                                                          124,
                                                                          128,
                                                                          119,
                                                                          0.922,
                                                                        ).withOpacity(
                                                                          0.3,
                                                                        ), // softer bottom-right
                                                                      ],
                                                                    )
                                                                    : LinearGradient(
                                                                      begin:
                                                                          Alignment
                                                                              .topLeft,
                                                                      end:
                                                                          Alignment
                                                                              .bottomRight,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                          50,
                                                                          87,
                                                                          2,
                                                                          0.925,
                                                                        ).withOpacity(
                                                                          0.10,
                                                                        ), // bright top-left
                                                                        Color.fromRGBO(
                                                                          50,
                                                                          87,
                                                                          2,
                                                                          0.925,
                                                                        ).withOpacity(
                                                                          0.10,
                                                                        ), // softer bottom-right
                                                                      ],
                                                                    ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  15,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child: Row(
                                                                        children: [
                                                                          Image.asset(
                                                                            '${imageIcon}',
                                                                            width:
                                                                                24,
                                                                            height:
                                                                                24,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            '${notificationProvider.filteredToday[index].title ?? 'N/A'}',
                                                                            style: TextStyle(
                                                                              fontFamily:
                                                                                  "MontrealSerial",
                                                                              color:
                                                                                  Colors.white,
                                                                              fontSize:
                                                                                  isTablet
                                                                                      ? 28
                                                                                      : 18,
                                                                              fontWeight:
                                                                                  FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),

                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  '${notificationProvider.filteredToday[index].message ?? 'N/A'}',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .white60,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 28
                                                                            : 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  isread
                                                                      ? 'Unread'
                                                                      : 'Read',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'MontrealSerial',
                                                                    color:
                                                                        isread
                                                                            ? Colors.greenAccent
                                                                            : Colors.orangeAccent,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 28
                                                                            : 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  formatDateTime(
                                                                    notificationProvider
                                                                            .filteredToday[index]
                                                                            .createdAt
                                                                            .toString() ??
                                                                        '',
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 20
                                                                            : 10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return SizedBox(
                                                        height: 10,
                                                      );
                                                    },
                                                  ),
                                            ],
                                          ),
                                        ),

                                    SizedBox(height: 10),

                                    // yesterday container
                                    (notificationProvider
                                            .filteredYesterday
                                            .isEmpty)
                                        ? Container()
                                        : Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Yesterday & Earlier",
                                                style: TextStyle(
                                                  fontFamily: "MontrealSerial",
                                                  color: Colors.white,
                                                  fontSize: isTablet ? 28 : 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              notificationProvider.isLoading
                                                  ? notificationShimmerList(
                                                    isTablet: isTablet,
                                                  )
                                                  : ListView.separated(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemCount:
                                                        notificationProvider
                                                            .filteredYesterday
                                                            .length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      final title =
                                                          notificationProvider
                                                              .filteredYesterday[index]
                                                              .title;
                                                      print('title : ${title}');
                                                      final imageIcon =
                                                          _getNotificationImage(
                                                            title!,
                                                          );
                                                      final bool isread =
                                                          notificationProvider
                                                              .filteredYesterday[index]
                                                              .isRead ==
                                                          false;
                                                      print(
                                                        'image icon : ${imageIcon}',
                                                      );
                                                      return InkWell(
                                                        onTap: () async {
                                                          print(
                                                            'yesterday notification',
                                                          );
                                                          await notificationProvider
                                                              .readNotificationPro(
                                                                notificationProvider
                                                                    .filteredYesterday[index]
                                                                    .id
                                                                    .toString(),
                                                              );
                                                          if (notificationProvider
                                                                  .success !=
                                                              null) {
                                                            notificationProvider
                                                                .getNotification();
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            showSuccessDialog(
                                                              context,
                                                              "assets/images/successicons.png",
                                                              "Success",
                                                              "${notificationProvider.success!.message}",
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            border: Border.all(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                    0.25,
                                                                  ),
                                                            ),
                                                            gradient:
                                                                isread
                                                                    ? LinearGradient(
                                                                      begin:
                                                                          Alignment
                                                                              .topLeft,
                                                                      end:
                                                                          Alignment
                                                                              .bottomRight,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                          124,
                                                                          128,
                                                                          119,
                                                                          0.922,
                                                                        ).withOpacity(
                                                                          0.3,
                                                                        ), // bright top-left
                                                                        Color.fromRGBO(
                                                                          124,
                                                                          128,
                                                                          119,
                                                                          0.922,
                                                                        ).withOpacity(
                                                                          0.3,
                                                                        ), // softer bottom-right
                                                                      ],
                                                                    )
                                                                    : LinearGradient(
                                                                      begin:
                                                                          Alignment
                                                                              .topLeft,
                                                                      end:
                                                                          Alignment
                                                                              .bottomRight,
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                          50,
                                                                          87,
                                                                          2,
                                                                          0.925,
                                                                        ).withOpacity(
                                                                          0.10,
                                                                        ), // bright top-left
                                                                        Color.fromRGBO(
                                                                          50,
                                                                          87,
                                                                          2,
                                                                          0.925,
                                                                        ).withOpacity(
                                                                          0.10,
                                                                        ), // softer bottom-right
                                                                      ],
                                                                    ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  15,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      child: Row(
                                                                        children: [
                                                                          Image.asset(
                                                                            '${imageIcon}',
                                                                            width:
                                                                                24,
                                                                            height:
                                                                                24,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                10,
                                                                          ),
                                                                          Text(
                                                                            '${notificationProvider.filteredYesterday[index].title ?? 'N/A'}',
                                                                            style: TextStyle(
                                                                              fontFamily:
                                                                                  "MontrealSerial",
                                                                              color:
                                                                                  Colors.white,
                                                                              fontSize:
                                                                                  isTablet
                                                                                      ? 28
                                                                                      : 18,
                                                                              fontWeight:
                                                                                  FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  '${notificationProvider.filteredYesterday[index].message ?? 'N/A'}',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .white60,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 28
                                                                            : 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w200,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  isread
                                                                      ? 'Unread'
                                                                      : 'Read',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        'MontrealSerial',
                                                                    color:
                                                                        isread
                                                                            ? Colors.greenAccent
                                                                            : Colors.orangeAccent,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 28
                                                                            : 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  formatDateTime(
                                                                    notificationProvider
                                                                            .filteredYesterday[index]
                                                                            .createdAt
                                                                            .toString() ??
                                                                        '',
                                                                  ),
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 20
                                                                            : 10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return SizedBox(
                                                        height: 10,
                                                      );
                                                    },
                                                  ),
                                            ],
                                          ),
                                        ),
                                    SizedBox(height: 50),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getNotificationImage(String title) {
    if (title.contains('Attendance')) {
      return "assets/images/attendance.png";
    } else if (title.contains('Leave') || title.contains('absent')) {
      return 'assets/images/leave.png';
    } else if (title.contains('Order') || title.contains('client')) {
      return 'assets/images/order.png';
    } else if (title.contains('teacher')) {
      return 'assets/images/attendance.png';
    }
    return 'assets/images/attendance.png';
  }
}

Widget notificationShimmerItem({required bool isTablet}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade800,
    highlightColor: Colors.grey.shade700,
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade800,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 16,
                width: isTablet ? 250 : 160,
                color: Colors.grey,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 14, width: double.infinity, color: Colors.grey),
          const SizedBox(height: 6),
          Container(
            height: 14,
            width: isTablet ? 180 : 120,
            color: Colors.grey,
          ),
        ],
      ),
    ),
  );
}

Widget notificationShimmerList({required bool isTablet}) {
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 5,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, __) => notificationShimmerItem(isTablet: isTablet),
  );
}

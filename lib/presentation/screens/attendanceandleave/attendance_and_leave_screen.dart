import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/drawer_provider.dart';
import 'package:wisdeals/presentation/provider/leave_and_attendance_provider.dart';
import 'package:wisdeals/presentation/screens/attendanceandleave/applay_leave_widget.dart';
import 'package:wisdeals/presentation/screens/attendanceandleave/widgets/color_and_text_change_status.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/delete_custome_diloge.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/list_shimmer_effect.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class AttendanceAndLeaveScreen extends StatefulWidget {
  const AttendanceAndLeaveScreen({Key? key}) : super(key: key);

  @override
  _AttendanceAndLeaveScreenState createState() =>
      _AttendanceAndLeaveScreenState();
}

class _AttendanceAndLeaveScreenState extends State<AttendanceAndLeaveScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final ScrollController dateScrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialData();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = DateTime.now(); // or your DateTime variable
      final formattedDate = DateFormat('dd-MM-yyyy').format(date);
      print('date and time ${formattedDate}');
      final attendanceProvider = Provider.of<LeaveAndAttendanceProvider>(
        context,
        listen: false,
      );
      Provider.of<DrawerProvider>(context, listen: false).getUserDetail();
      // attendanceProvider.getLeaveType();
      attendanceProvider.getLeaveTypePro();
      // inition when current date selected
      attendanceProvider.selectDate(date);
      attendanceProvider.getLeaveAndAttendancePro(formattedDate);
      // 🔥 Delay ensures ListView is ready
      Future.delayed(Duration(milliseconds: 200), () {
        attendanceProvider.scrollToSelectedDate();
      });
    });
  }

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
            child: Consumer2<LeaveAndAttendanceProvider, DrawerProvider>(
              builder: (context, attendanceProvider, draweProvider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final failure = attendanceProvider.failure;
                  if (failure != null) {
                    if (failure is ClientFailure ||
                        failure is ServerFailure ||
                        attendanceProvider.failure is ClientFailure ||
                        attendanceProvider.failure is ServerFailure) {
                      failureDilogeWidget(
                        context,
                        'assets/images/failicon.png',
                        "Failed",
                        '${failure.message}',
                        provider: attendanceProvider,
                      );
                    }
                  }
                });

                if (attendanceProvider.failure is NetworkFailure) {
                  return NetWorkRetry(
                    failureMessage:
                        attendanceProvider.failure?.message ??
                        "No internet connection",

                    onRetry: () async {
                      _initialData();
                    },
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    _initialData();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        CustomAppBarWidget(
                          title: "Attendance and Leave",
                          drawerIconImage: false,
                          notificationIconImage: false,
                        ),
                        SizedBox(height: 50),
                        firstSection(
                          isTablet: isTablet,
                          provider: attendanceProvider,
                          drawerProvider: draweProvider,
                        ),
                        SizedBox(height: 10),
                        ApplayLeaveWidget(
                          isExpanded:
                              attendanceProvider.hideAndShowContainerIndex,
                          isEdit: false,
                          leaveprovider: attendanceProvider,
                          dateFromController: dateController,
                          dateToController: timeFromController,
                          noteController: noteController,
                          attachMent:
                              attendanceProvider.selectedFile.toString(),
                        ),
                        SizedBox(height: 30),
                        GestureDetector(
                          onTap: () async {
                            final provider =
                                Provider.of<LeaveAndAttendanceProvider>(
                                  context,
                                  listen: false,
                                );

                            final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: provider.selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Colors.amber, // header color
                                      onPrimary:
                                          Colors.black, // header text color
                                      onSurface:
                                          Colors.black, // body text color
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (pickedDate != null) {
                              provider.selectDate(pickedDate);
                              print(provider.selectedDate);
                              final formattedDateWhenSelected = DateFormat(
                                'dd-MM-yyyy',
                              ).format(provider.selectedDate);
                              await provider.getLeaveAndAttendancePro(
                                formattedDateWhenSelected,
                              );
                              provider.scrollToSelectedDate();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: kButtonColor2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Select Date',
                                style: TextStyle(
                                  fontFamily: "MontrealSerial",
                                  color: Colors.black,
                                  fontSize: isTablet ? 28 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          '${attendanceProvider.currentMonthYear}',
                          style: TextStyle(
                            fontFamily: "MontrealSerial",
                            color: Colors.white54,
                            fontSize: isTablet ? 28 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Container(
                          height: isTablet ? 120 : 60,
                          child: ListView.separated(
                            controller: attendanceProvider.dateScrollController,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: attendanceProvider.monthDays.length,
                            itemBuilder: (context, index) {
                              final date = attendanceProvider.monthDays[index];
                              final isSelected =
                                  date.day ==
                                      attendanceProvider.selectedDate.day &&
                                  date.month ==
                                      attendanceProvider.selectedDate.month &&
                                  date.year ==
                                      attendanceProvider.selectedDate.year;
                              return Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.white : kButtonColor2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding:
                                      isTablet
                                          ? EdgeInsets.all(20)
                                          : EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text(
                                        DateFormat('dd').format(date),
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.black,
                                          fontSize: isTablet ? 28 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('E').format(date),
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.black54,
                                          fontSize: isTablet ? 28 : 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) {
                              return SizedBox(width: 10);
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        (attendanceProvider.isLoading ||
                                attendanceProvider.leaveData == null)
                            ? const LeadCardShimmer(isTablet: false)
                            : (attendanceProvider.leaveData == null)
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
                                    width: 150,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'No Leave Found',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClockInAndClockOutWidget(
                                        isTablet: isTablet,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        title1: "Today Attendance",
                                        clock: true,
                                        title2:
                                            "${attendanceProvider.leaveData!.data!.clockIn ?? '---- ---'}",
                                        title3: "On time",
                                        title4: "Clock-In",
                                      ),
                                      SizedBox(width: 15),
                                      ClockInAndClockOutWidget(
                                        isTablet: isTablet,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        title1:
                                            "Total Hours : ${attendanceProvider.leaveData!.data!.totalHours ?? '0.00'}",
                                        clock: true,
                                        title2:
                                            "${attendanceProvider.leaveData!.data!.clockOut ?? '---- ---'}",
                                        title3: "Go home",
                                        title4: "Clock-Out",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClockInAndClockOutWidget(
                                        isTablet: isTablet,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        title1: "Leave Status",
                                        clock: false,
                                        title2: "Leave\nBalance",
                                        title3:
                                            "${attendanceProvider.leaveData!.data!.leaveBalance ?? ''}",
                                        title4: "",
                                      ),
                                      SizedBox(width: 15),
                                      ClockInAndClockOutWidget(
                                        isTablet: isTablet,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        title1: "",
                                        clock: false,
                                        title2: "Leave\nApproved",
                                        title3:
                                            "${attendanceProvider.leaveData!.data!.leaveApproved ?? ''}",
                                        title4: "",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ClockInAndClockOutWidget(
                                        isTablet: isTablet,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        title1: "",
                                        clock: false,
                                        title2: "Leave\nPending",
                                        title3:
                                            "${attendanceProvider.leaveData!.data!.leavePending ?? ''}",
                                        title4: "",
                                      ),
                                      SizedBox(width: 15),
                                      ClockInAndClockOutWidget(
                                        isTablet: isTablet,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        title1: "",
                                        clock: false,
                                        title2: "Leave\nCancelled",
                                        title3:
                                            "${attendanceProvider.leaveData!.data!.leaveCancelled ?? ''}",
                                        title4: "",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  Text(
                                    'Leave Applied',
                                    style: TextStyle(
                                      fontFamily: "MontrealSerial",
                                      color: Colors.white,
                                      fontSize: isTablet ? 28 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  // const SizedBox(height: 5),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        attendanceProvider
                                            .leaveData!
                                            .data!
                                            .leaveHistory!
                                            .length,
                                    itemBuilder: (context, index) {
                                      final leaveData =
                                          attendanceProvider
                                              .leaveData!
                                              .data!
                                              .leaveHistory![index];

                                      final fromD = leaveData.fromDate;
                                      final toD = leaveData.toDate;

                                      // ------------------------------------------------------------
                                      // 1️⃣ SAFE DATE PARSER FUNCTION (supports dd-MM-yyyy)
                                      // ------------------------------------------------------------
                                      DateTime? parseCustomDate(String? date) {
                                        if (date == null || date.isEmpty)
                                          return null;

                                        try {
                                          return DateFormat(
                                            'dd-MM-yyyy',
                                          ).parse(date);
                                        } catch (e) {
                                          try {
                                            return DateFormat(
                                              'yyyy-MM-dd',
                                            ).parse(date);
                                          } catch (e) {
                                            return null;
                                          }
                                        }
                                      }

                                      final fromDate = parseCustomDate(fromD);
                                      final toDate = parseCustomDate(toD);

                                      // ------------------------------------------------------------
                                      // 2️⃣ CALCULATE TOTAL DAYS (inclusive count)
                                      // ------------------------------------------------------------
                                      int? totalDays;
                                      if (fromDate != null && toDate != null) {
                                        totalDays =
                                            toDate.difference(fromDate).inDays +
                                            1;
                                      }

                                      print("start date : $fromD");
                                      print("end date : $toD");

                                      // ------------------------------------------------------------
                                      // 3️⃣ FORMAT DATE RANGE FOR DISPLAY
                                      // ------------------------------------------------------------
                                      String formattedRange = 'N/A';

                                      if (fromDate != null && toDate != null) {
                                        formattedRange =
                                            '${DateFormat('MMM d, yyyy').format(fromDate)} - ${DateFormat('MMM d, yyyy').format(toDate)}';
                                      } else if (fromDate != null) {
                                        formattedRange = DateFormat(
                                          'MMM d, yyyy',
                                        ).format(fromDate);
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(
                                              0xFF82AE09,
                                            ).withOpacity(0.15),
                                          ),
                                          color: const Color(
                                            0xFF82AE09,
                                          ).withOpacity(0.15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(14.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Date',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        formattedRange,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white60,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: getStatusColor(
                                                        leaveData.status!,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
                                                          ),
                                                      child: Text(
                                                        leaveData.status ?? '',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Leave Type : ${leaveData.leaveType}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          "MontrealSerial",
                                                      color: Colors.white,
                                                      fontSize:
                                                          isTablet ? 28 : 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  (leaveData.status ==
                                                              'Pending' ||
                                                          leaveData.status ==
                                                              'pending')
                                                      ? Row(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              attendanceProvider
                                                                  .hideAndShowContainer(
                                                                    true,
                                                                    index,
                                                                  );
                                                            },
                                                            icon: Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              showDeleteConfirmationDialog(
                                                                context,
                                                                onDelete: () async {
                                                                  await attendanceProvider
                                                                      .deleteLeavePro(
                                                                        leaveData
                                                                            .id
                                                                            .toString(),
                                                                      );
                                                                  if (attendanceProvider
                                                                          .success !=
                                                                      null) {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                    showSuccessDialog(
                                                                      context,
                                                                      "assets/images/successicons.png",
                                                                      "Success",
                                                                      attendanceProvider
                                                                          .success!
                                                                          .message
                                                                          .toString(),
                                                                    );
                                                                    // final date =
                                                                    //     DateTime.now(); // or your DateTime variable
                                                                    // final formattedDate =
                                                                    //     DateFormat(
                                                                    //       'yyyy-MM-dd',
                                                                    //     ).format(
                                                                    //       date,
                                                                    //     );
                                                                    _initialData();
                                                                  }
                                                                },
                                                                textMain:
                                                                    "Delete Leave",
                                                                provider:
                                                                    attendanceProvider,
                                                              );
                                                            },
                                                            icon: Icon(
                                                              Icons.delete,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                              ApplayLeaveWidget(
                                                leaveData: leaveData,
                                                isExpanded:
                                                    attendanceProvider
                                                        .hideAndShowContainerIndexEditindex ==
                                                    index,
                                                isEdit: true,
                                                leaveprovider:
                                                    attendanceProvider,
                                                dateFromController:
                                                    dateController,
                                                dateToController:
                                                    timeFromController,
                                                noteController: noteController,
                                                attachMent:
                                                    attendanceProvider
                                                        .selectedFile
                                                        .toString(),
                                              ),
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
                                                      const Text(
                                                        'Apply Days',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '${totalDays ?? 'N/A'} Days',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white60,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        'Leave Balance',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Text(
                                                        '${attendanceProvider.leaveData!.data!.leaveBalance ?? 'N/A'} Days',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white60,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  leaveData.status == 'Approved'
                                                      ? Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Text(
                                                            'Approved by',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "MontrealSerial",
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            leaveData.status ==
                                                                    'Approved'
                                                                ? 'Admin'
                                                                : '--------',
                                                            style: const TextStyle(
                                                              fontFamily:
                                                                  "MontrealSerial",
                                                              color:
                                                                  Colors
                                                                      .white60,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                      : SizedBox(),
                                                ],
                                              ),
                                              (leaveData.adminComment == null ||
                                                      leaveData
                                                          .adminComment!
                                                          .isEmpty)
                                                  ? SizedBox.shrink()
                                                  : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Divider(),
                                                      Text(
                                                        'Leave Rejected Reason',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${leaveData.adminComment ?? ''}',
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white60,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(height: 10);
                                    },
                                  ),
                                  const SizedBox(height: 90),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ClockInAndClockOutWidget extends StatelessWidget {
  final CrossAxisAlignment crossAxisAlignment;
  final String? title1;
  final bool? clock;
  final String? title2;
  final String? title3;
  final String? title4;
  final Size? size;
  final Color? color;
  const ClockInAndClockOutWidget({
    super.key,
    required this.isTablet,
    required this.crossAxisAlignment,
    required this.title1,
    required this.clock,
    required this.title2,
    required this.title3,
    required this.title4,
    this.size,
    this.color,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text(
              '${title1}',
              style: TextStyle(
                fontFamily: "MontrealSerial",
                color: Colors.white,
                fontSize: isTablet ? 28 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF82AE09).withOpacity(0.10)),
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF82AE09).withOpacity(0.15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          if (clock == true) ...[
                            Image.asset(
                              'assets/images/clock.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '${title4 ?? 'N/A'}',
                              style: TextStyle(
                                fontFamily: "MontrealSerial",
                                color: Colors.white,
                                fontSize: isTablet ? 28 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ] else ...[
                            // Keep same spacing to maintain layout width
                            SizedBox(width: 24 + 10 + (isTablet ? 80 : 50)),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    Text(
                      '${title2}',
                      style: TextStyle(
                        fontFamily: "MontrealSerial",
                        color: Colors.white,
                        fontSize: isTablet ? 40 : 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${title3}',
                      style: TextStyle(
                        fontFamily: "MontrealSerial",
                        color: clock == true ? Colors.white54 : kButtonColor2,
                        fontSize:
                            clock == true
                                ? isTablet
                                    ? 22
                                    : 14
                                : isTablet
                                ? 40
                                : 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class firstSection extends StatelessWidget {
  final LeaveAndAttendanceProvider provider;
  final DrawerProvider drawerProvider;
  const firstSection({
    super.key,
    required this.isTablet,
    required this.provider,
    required this.drawerProvider,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: Row(
            children: [
              // CircleAvatar(),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${drawerProvider.userName ?? 'N/A'}',
                    style: TextStyle(
                      fontFamily: "MontrealSerial",
                      color: Colors.white,
                      fontSize: isTablet ? 28 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${drawerProvider.role}',
                    style: TextStyle(
                      fontFamily: "MontrealSerial",
                      color: Colors.white60,
                      fontSize: isTablet ? 28 : 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            provider.hideAndShowContainer(false, 0);
          },
          child: Container(
            decoration: BoxDecoration(
              color: kButtonColor2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Apply Leave',
                style: TextStyle(
                  fontFamily: "MontrealSerial",
                  color: Colors.black,
                  fontSize: isTablet ? 28 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

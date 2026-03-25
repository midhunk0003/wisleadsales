import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/auth_provider.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/presentation/provider/report_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _initialData();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).getReportPro('expenses', 'today', '', '');
      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).selectedRangePro('today');
      Provider.of<ReportProvider>(
        context,
        listen: false,
      ).selectedTypePro('expenses');
      Provider.of<ReportProvider>(context, listen: false).getRange();
      Provider.of<ReportProvider>(context, listen: false).getType();
      final profileProviders = Provider.of<ProfileProvider>(
        context,
        listen: false,
      );
      profileProviders.clearSelectedImages();
      //load profile data
      profileProviders.getProfileData(); // wait for data to load
      profileProviders.getProfilImgFromShared(); // wait for data to load
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
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

          return Consumer3<ReportProvider, ProfileProvider, AuthProvider>(
            builder: (
              context,
              reportProvider,
              profileProvider,
              authProvider,
              _,
            ) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final failure = reportProvider.failure;
                if (failure != null) {
                  if (failure is ClientFailure ||
                      failure is ServerFailure ||
                      reportProvider.failure is ClientFailure ||
                      reportProvider.failure is ServerFailure) {
                    failureDilogeWidget(
                      context,
                      'assets/images/failicon.png',
                      "Failed",
                      '${failure.message}',
                      provider: reportProvider,
                    );
                  }
                }
              });

              if (reportProvider.failure is NetworkFailure) {
                return NetWorkRetry(
                  failureMessage:
                      reportProvider.failure?.message ??
                      "No internet connection",
                  onRetry: () async {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Provider.of<ReportProvider>(
                        context,
                        listen: false,
                      ).getReportPro('expenses', 'today', '', '');
                    });
                  },
                );
              }
              return Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: padding,
                        horizontal: padding,
                      ),
                      child: Stack(
                        children: [
                          // report section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                              CustomAppBarWidget(
                                title: "Report",
                                drawerIconImage: true,
                              ),
                              SizedBox(height: 30),

                              // Date Range Selector
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Date Range Selector",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: isTablet ? 20 : 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 40,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: reportProvider.range.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            reportProvider.selectedRangePro(
                                              reportProvider
                                                  .range[index]['range']
                                                  .toString(),
                                            );
                                            print(
                                              '${reportProvider.range[index]['range'].toString()}',
                                            );
                                            print(
                                              '${startDateController.text}',
                                            );
                                            print('${endDateController.text}');
                                            print(
                                              '${reportProvider.range[index]['range'].toString()}',
                                            );
                                            if (startDateController
                                                    .text
                                                    .isNotEmpty ||
                                                startDateController.text !=
                                                    null) {
                                              reportProvider.getReportPro(
                                                '${reportProvider.selectedType}',
                                                '${reportProvider.range[index]['range']}',
                                                '${startDateController.text.toString()}',
                                                '${endDateController.text.toString()}',
                                              );
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  reportProvider
                                                              .selectedRange ==
                                                          reportProvider
                                                              .range[index]['range']
                                                      ? kButtonColor2
                                                      : Colors.white12,

                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${reportProvider.range[index]['title']}',
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      reportProvider
                                                                  .selectedRange ==
                                                              reportProvider
                                                                  .range[index]['range']
                                                          ? Colors.black
                                                          : Colors.white54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(width: 5);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  reportProvider.selectedRange == 'custom'
                                      ? Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1E1E),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            /// Start Date
                                            Expanded(
                                              child: TextFormField(
                                                controller: startDateController,
                                                readOnly: true,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                onTap: () async {
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();

                                                  final DateTime?
                                                  picked = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );

                                                  if (picked != null) {
                                                    startDateController.text =
                                                        "${picked.day.toString().padLeft(2, '0')}-"
                                                        "${picked.month.toString().padLeft(2, '0')}-"
                                                        "${picked.year}";
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "Start Date",
                                                  hintText: "DD-MM-YYYY",
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white60,
                                                  ),
                                                  hintStyle: const TextStyle(
                                                    color: Colors.white38,
                                                  ),
                                                  filled: true,
                                                  fillColor: const Color(
                                                    0xFF2A2A2D,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 10,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            /// Divider
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                "—",
                                                style: TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: isTablet ? 22 : 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),

                                            ///  End Date
                                            Expanded(
                                              child: TextFormField(
                                                controller: endDateController,
                                                readOnly: true,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                onTap: () async {
                                                  FocusScope.of(
                                                    context,
                                                  ).unfocus();

                                                  final DateTime?
                                                  picked = await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(2000),
                                                    lastDate: DateTime(2100),
                                                  );

                                                  if (picked != null) {
                                                    endDateController.text =
                                                        "${picked.day.toString().padLeft(2, '0')}-"
                                                        "${picked.month.toString().padLeft(2, '0')}-"
                                                        "${picked.year}";
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  labelText: "End Date",
                                                  hintText: "DD-MM-YYYY",
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white60,
                                                  ),
                                                  hintStyle: const TextStyle(
                                                    color: Colors.white38,
                                                  ),
                                                  filled: true,
                                                  fillColor: const Color(
                                                    0xFF2A2A2D,
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 10,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            /// Show Button
                                            Expanded(
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                onTap: () {
                                                  reportProvider.getReportPro(
                                                    '${reportProvider.selectedType}',
                                                    '${reportProvider.selectedRange}',
                                                    startDateController.text,
                                                    endDateController.text,
                                                  );

                                                  startDateController.clear();
                                                  endDateController.clear();
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: kButtonColor2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Show",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: Colors.black,
                                                            fontSize:
                                                                isTablet
                                                                    ? 16
                                                                    : 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                      : SizedBox.shrink(),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Report Type",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: isTablet ? 20 : 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 40,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: reportProvider.type.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            reportProvider.selectedTypePro(
                                              reportProvider.type[index]['type']
                                                  .toString(),
                                            );
                                            print(
                                              '${reportProvider.type[index]['type'].toString()}',
                                            );
                                            reportProvider.getReportPro(
                                              '${reportProvider.selectedType ?? ''}',
                                              '${reportProvider.selectedRange ?? ''}',
                                              '',
                                              '',
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  reportProvider.selectedType ==
                                                          reportProvider
                                                              .type[index]['type']
                                                      ? kButtonColor2
                                                      : Colors.white12,

                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${reportProvider.type[index]['title']}',
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      reportProvider
                                                                  .selectedType ==
                                                              reportProvider
                                                                  .type[index]['type']
                                                          ? Colors.black
                                                          : Colors.white54,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      separatorBuilder: (context, index) {
                                        return SizedBox(width: 5);
                                      },
                                    ),
                                  ),

                                  // const SizedBox(height: 24),

                                  // // Selected Range Text
                                  // Text(
                                  //   '${reportProvider.selectedRange}',
                                  //   style: const TextStyle(
                                  //     color: Colors.greenAccent,
                                  //     fontSize: 16,
                                  //     fontWeight: FontWeight.w600,
                                  //     letterSpacing: 0.5,
                                  //   ),
                                  // ),
                                  const SizedBox(height: 10),

                                  // Date Range Card
                                  (reportProvider.isLoading ||
                                          reportProvider.reportModel == null)
                                      ? Shimmer.fromColors(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 18,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                kButtonColor2.withOpacity(0.15),
                                                kButtonColor2.withOpacity(0.05),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                            border: Border.all(
                                              color: kButtonColor2.withOpacity(
                                                0.35,
                                              ),
                                              width: 1.2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: kButtonColor2
                                                    .withOpacity(0.08),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                        baseColor: Colors.grey.shade800,
                                        highlightColor: Colors.grey.shade700,
                                      )
                                      : Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 18,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              kButtonColor2.withOpacity(0.15),
                                              kButtonColor2.withOpacity(0.05),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: kButtonColor2.withOpacity(
                                              0.35,
                                            ),
                                            width: 1.2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kButtonColor2.withOpacity(
                                                0.08,
                                              ),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            // Calendar Icon
                                            Icon(
                                              Icons.calendar_month_rounded,
                                              color: kButtonColor2,
                                              size: 22,
                                            ),
                                            const SizedBox(width: 12),

                                            // Date Text
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Selected Date",
                                                  style: TextStyle(
                                                    color: kButtonColor2
                                                        .withOpacity(0.8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  '${reportProvider.reportModel!.range!.start != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(reportProvider.reportModel!.range!.start!)) : 'N/A'}  -  '
                                                  '${reportProvider.reportModel!.range!.end != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(reportProvider.reportModel!.range!.end!)) : 'N/A'}',
                                                  style: const TextStyle(
                                                    color: kButtonColor2,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                  const SizedBox(height: 24),
                                  // Monthly Sales Report Card
                                  (reportProvider.isLoading ||
                                          reportProvider.reportModel == null)
                                      ? salesReportShimmer(isTablet)
                                      : Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1A1F1A),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: kButtonColor2.withOpacity(
                                              0.2,
                                            ),
                                          ),
                                        ),
                                        child: ReportColumCard(
                                          isTablet: isTablet,
                                          reportProvider: reportProvider,
                                          reportType:
                                              reportProvider.selectedType,
                                        ),
                                      ),

                                  const SizedBox(height: 24),

                                  /*********************Status Section percentage card start************************** */
                                  if (reportProvider.selectedType ==
                                      'attendance')
                                    (reportProvider.isLoading ||
                                            reportProvider.reportModel == null)
                                        ? Row(
                                          children: [
                                            Expanded(child: statCardShimmer()),
                                            SizedBox(width: 5),
                                            Expanded(child: statCardShimmer()),
                                          ],
                                        )
                                        : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        (double.tryParse(
                                                              reportProvider
                                                                      .reportModel
                                                                      ?.report
                                                                      ?.presentPercentage ??
                                                                  "0",
                                                            ) ??
                                                            0) /
                                                        100,
                                                    title: "Present",
                                                    subtitle: "",
                                                    valueColor: kButtonColor2,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        (double.tryParse(
                                                              reportProvider
                                                                      .reportModel
                                                                      ?.report
                                                                      ?.absentPercentage ??
                                                                  "0",
                                                            ) ??
                                                            0) /
                                                        100,
                                                    title: "Absent",
                                                    subtitle: "",
                                                    valueColor:
                                                        Colors.blueAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        (double.tryParse(
                                                              reportProvider
                                                                      .reportModel
                                                                      ?.report
                                                                      ?.latePercentage ??
                                                                  "0",
                                                            ) ??
                                                            0) /
                                                        100,
                                                    title: "Late",
                                                    subtitle: "",
                                                    valueColor: Colors.red,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        (double.tryParse(
                                                              reportProvider
                                                                      .reportModel
                                                                      ?.report
                                                                      ?.earlyLogoutPercentage ??
                                                                  "0",
                                                            ) ??
                                                            0) /
                                                        100,
                                                    title: "Early Logout",
                                                    subtitle: "",
                                                    valueColor: Colors.yellow,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                  if (reportProvider.selectedType == 'expenses')
                                    (reportProvider.isLoading ||
                                            reportProvider.reportModel == null)
                                        ? Row(
                                          children: [
                                            Expanded(child: statCardShimmer()),
                                            SizedBox(width: 5),
                                            Expanded(child: statCardShimmer()),
                                          ],
                                        )
                                        : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        ((double.tryParse(
                                                                  reportProvider
                                                                          .reportModel
                                                                          ?.report
                                                                          ?.pendingPercentageAmount ??
                                                                      "0",
                                                                ) ??
                                                                0) /
                                                            100),
                                                    title: "Pending Amount",
                                                    subtitle: "",
                                                    valueColor: kButtonColor2,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        (double.tryParse(
                                                              reportProvider
                                                                      .reportModel
                                                                      ?.report
                                                                      ?.approvedPercentageAmount ??
                                                                  "0",
                                                            ) ??
                                                            0) /
                                                        100,
                                                    title: "Approved",
                                                    subtitle: "",
                                                    valueColor:
                                                        Colors.blueAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: _StatCard(
                                                    percent:
                                                        (double.tryParse(
                                                              reportProvider
                                                                      .reportModel
                                                                      ?.report
                                                                      ?.rejectedPercentageAmount ??
                                                                  "0",
                                                            ) ??
                                                            0) /
                                                        100,
                                                    title: "Rejected Amount",
                                                    subtitle: "",
                                                    valueColor: Colors.orange,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                  if (reportProvider.selectedType == 'clients')
                                    (reportProvider.isLoading ||
                                            reportProvider.reportModel == null)
                                        ? Row(
                                          children: [
                                            Expanded(child: statCardShimmer()),
                                            SizedBox(width: 5),
                                            Expanded(child: statCardShimmer()),
                                          ],
                                        )
                                        : Row(
                                          children: [
                                            Expanded(
                                              child: _StatCard(
                                                percent:
                                                    (double.tryParse(
                                                          reportProvider
                                                                  .reportModel
                                                                  ?.report
                                                                  ?.activeClientsPercentage ??
                                                              "0",
                                                        ) ??
                                                        0) /
                                                    100,
                                                title: "Active Clients",
                                                subtitle: "",
                                                valueColor: kButtonColor2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _StatCard(
                                                percent:
                                                    (double.tryParse(
                                                          reportProvider
                                                                  .reportModel
                                                                  ?.report
                                                                  ?.inactiveClientsPercentage ??
                                                              "0",
                                                        ) ??
                                                        0) /
                                                    100,
                                                title: "Inactive Clients",
                                                subtitle: "",
                                                valueColor: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),

                                  if (reportProvider.selectedType == 'leads')
                                    (reportProvider.isLoading ||
                                            reportProvider.reportModel == null)
                                        ? Row(
                                          children: [
                                            Expanded(child: statCardShimmer()),
                                            SizedBox(width: 5),
                                            Expanded(child: statCardShimmer()),
                                          ],
                                        )
                                        : Row(
                                          children: [
                                            Expanded(
                                              child: _StatCard(
                                                percent:
                                                    (double.tryParse(
                                                          reportProvider
                                                                  .reportModel
                                                                  ?.report
                                                                  ?.convertedPercentage ??
                                                              "0",
                                                        ) ??
                                                        0) /
                                                    100,
                                                title: "Converted Leads",
                                                subtitle: "",
                                                valueColor: kButtonColor2,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _StatCard(
                                                percent:
                                                    (double.tryParse(
                                                          reportProvider
                                                                  .reportModel
                                                                  ?.report
                                                                  ?.pendingPercentage ??
                                                              "0",
                                                        ) ??
                                                        0) /
                                                    100,
                                                title: "Pending",
                                                subtitle: "",
                                                valueColor: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),

                                  /*********************Status Section percentage card End************************** */
                                  const SizedBox(height: 10),
                                  /*********************charts section start************************** */
                                  // Chart Section
                                  Row(
                                    children: [
                                      // Expanded(
                                      //   child:
                                      //       (reportProvider.isLoading ||
                                      //               reportProvider.reportModel == null)
                                      //           ? statCardShimmer()
                                      //           : _BarChartWidget(),
                                      // ),
                                      // const SizedBox(width: 12),
                                      Expanded(
                                        child:
                                            (reportProvider.isLoading ||
                                                    reportProvider
                                                            .reportModel ==
                                                        null)
                                                ? statCardShimmer()
                                                : _PieChartWidget(
                                                  type:
                                                      reportProvider
                                                          .selectedType,
                                                  reportProvider:
                                                      reportProvider,
                                                ),
                                      ),
                                      // const SizedBox(width: 12),
                                    ],
                                  ),
                                  /*********************charts section end************************** */
                                  SizedBox(height: 200),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // active block and unblock widget
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

  Shimmer salesReportShimmer(bool isTablet) {
    return Shimmer.fromColors(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isTablet ? 26 : 18,
            width: 180,
            color: Colors.white38,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerLine(),
                    shimmerLine(),
                    shimmerLine(),
                    shimmerLine(),
                    shimmerLine(),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            height: 40,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
    );
  }
}

class ReportColumCard extends StatelessWidget {
  final ReportProvider reportProvider;
  final String? reportType;
  const ReportColumCard({
    super.key,
    required this.isTablet,
    required this.reportProvider,
    required this.reportType,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    print('asdhsgshdgah : ${reportType}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${reportProvider.reportModel!.report!.title ?? 'N/A'}",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: isTablet ? 22 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        if (reportType == 'attendance')
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportItem(
                      title: "Total Days",
                      value:
                          "${reportProvider.reportModel!.report!.totalDays ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Present Days",
                      value:
                          "${reportProvider.reportModel!.report!.presentDays ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Absent Days",
                      value:
                          "${reportProvider.reportModel!.report!.absentDays ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Late Days",
                      value:
                          "${reportProvider.reportModel!.report!.lateDays ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Early Logout Days",
                      value:
                          "${reportProvider.reportModel!.report!.earlyLogoutDays ?? 'N/A'}",
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),
              // CircularPercentIndicator(
              //   radius: 45,
              //   lineWidth: 10,
              //   percent: 0.75,
              //   progressColor: Colors.greenAccent,
              //   backgroundColor: Colors.white10,
              //   center: Text(
              //     "75%",
              //     style: GoogleFonts.poppins(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        if (reportType == 'expenses')
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportItem(
                      title: "Total Expenses",
                      value:
                          "₹ ${reportProvider.reportModel!.report!.totalExpenses ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Expense",
                      value:
                          "${reportProvider.reportModel!.report!.expenseCount ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Pending Total Amount",
                      value:
                          "₹ ${reportProvider.reportModel!.report!.pendingAmount ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Pending",
                      value:
                          "${reportProvider.reportModel!.report!.pendingCount ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Approved Total Amount",
                      value:
                          "₹ ${reportProvider.reportModel!.report!.approvedAmount ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Approved",
                      value:
                          "${reportProvider.reportModel!.report!.approvedCount ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Rejected Total Amount",
                      value:
                          "₹ ${reportProvider.reportModel!.report!.rejectedAmount ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Rejected",
                      value:
                          "${reportProvider.reportModel!.report!.rejectedCount ?? 'N/A'}",
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // CircularPercentIndicator(
              //   radius: 45,
              //   lineWidth: 10,
              //   percent: 0.75,
              //   progressColor: Colors.greenAccent,
              //   backgroundColor: Colors.white10,
              //   center: Text(
              //     "75%",
              //     style: GoogleFonts.poppins(
              //       color: Colors.white,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),

        if (reportType == 'clients')
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportItem(
                      title: "Total Clients",
                      value:
                          "${reportProvider.reportModel!.report!.totalClients ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Active Clients",
                      value:
                          "${reportProvider.reportModel!.report!.activeClients ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Inactive Clients",
                      value:
                          "${reportProvider.reportModel!.report!.inactiveClients ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Pending Clients",
                      value:
                          "${reportProvider.reportModel!.report!.pendingClients ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "New Clients",
                      value:
                          "${reportProvider.reportModel!.report!.newClients ?? 'N/A'}",
                    ),
                  ],
                ),
              ),
            ],
          ),
        if (reportType == 'leads')
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ReportItem(
                      title: "Total Leads",
                      value:
                          "${reportProvider.reportModel!.report!.totalLeads ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Converted Leads",
                      value:
                          "${reportProvider.reportModel!.report!.convertedLeads ?? 'N/A'}",
                    ),
                    _ReportItem(
                      title: "Pending Leads",
                      value:
                          "${reportProvider.reportModel!.report!.pendingLeads ?? 'N/A'}",
                    ),
                  ],
                ),
              ),
            ],
          ),

        // const SizedBox(height: 12),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: kButtonColor2,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //   ),
        //   onPressed: () {},
        //   child: const Text("Download", style: TextStyle(color: Colors.black)),
        // ),
      ],
    );
  }
}

class _ReportItem extends StatelessWidget {
  final String title;
  final String value;

  const _ReportItem({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final double percent;
  final String title;
  final String? subtitle;
  final Color valueColor;
  const _StatCard({
    required this.percent,
    required this.title,
    this.subtitle,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kButtonColor2.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularPercentIndicator(
            radius: 40,
            lineWidth: 8,
            percent: percent,
            progressColor: valueColor,
            backgroundColor: Colors.white10,
            center: Text(
              "${(percent * 100).toStringAsFixed(0)}%",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

Widget statCardShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade800,
    highlightColor: Colors.grey.shade700,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kButtonColor2.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 16, width: 80, color: Colors.white24),
          const SizedBox(height: 8),
          Container(height: 14, width: 60, color: Colors.white24),
        ],
      ),
    ),
  );
}

class _BarChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: List.generate(
            6,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (index + 2) * 3.0,
                  width: 14,
                  borderRadius: BorderRadius.circular(6),
                  color: kButtonColor2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final String? type;
  final ReportProvider reportProvider;

  const _PieChartWidget({
    super.key,
    required this.type,
    required this.reportProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (type == 'attendance')
            Expanded(
              child:
                  _isAllZero([
                        reportProvider.reportModel!.report!.presentPercentage,
                        reportProvider.reportModel!.report!.absentPercentage,
                        reportProvider.reportModel!.report!.latePercentage,
                        reportProvider
                            .reportModel!
                            .report!
                            .earlyLogoutPercentage,
                      ])
                      ? const Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                      : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: kButtonColor2,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .presentPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.presentPercentage ?? "0").toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.blueAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .absentPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.absentPercentage ?? "0").toStringAsFixed(0)}%',
                            ),
                            PieChartSectionData(
                              color: Colors.orangeAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .latePercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.latePercentage ?? "0").toStringAsFixed(0)}%',
                            ),

                            PieChartSectionData(
                              color: Colors.orangeAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .earlyLogoutPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.earlyLogoutPercentage ?? "0").toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ),
            ),
          if (type == 'expenses')
            Expanded(
              child:
                  _isAllZero([
                        reportProvider
                            .reportModel!
                            .report!
                            .pendingPercentageAmount,
                        reportProvider
                            .reportModel!
                            .report!
                            .approvedPercentageAmount,
                        reportProvider
                            .reportModel!
                            .report!
                            .rejectedPercentageAmount,
                      ])
                      ? const Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                      : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: kButtonColor2,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .pendingPercentageAmount ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.pendingPercentageAmount ?? "0").toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.blueAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .approvedPercentageAmount ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.approvedPercentageAmount ?? "0").toStringAsFixed(0)}%',
                            ),
                            PieChartSectionData(
                              color: Colors.orangeAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .rejectedPercentageAmount ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.rejectedPercentageAmount ?? "0").toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ),
            ),
          if (type == 'clients')
            Expanded(
              child:
                  _isAllZero([
                        reportProvider
                            .reportModel!
                            .report!
                            .activeClientsPercentage,
                        reportProvider
                            .reportModel!
                            .report!
                            .inactiveClientsPercentage,
                        reportProvider
                            .reportModel!
                            .report!
                            .pendingClientsPercentage,
                        reportProvider
                            .reportModel!
                            .report!
                            .newClientsPercentage,
                      ])
                      ? const Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                      : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            PieChartSectionData(
                              color: kButtonColor2,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .activeClientsPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.activeClientsPercentage ?? "0").toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.blueAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .inactiveClientsPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.inactiveClientsPercentage ?? "0").toStringAsFixed(0)}%',
                            ),
                          ],
                        ),
                      ),
            ),
          if (type == 'leads')
            Expanded(
              child:
                  _isAllZero([
                        reportProvider.reportModel!.report!.convertedPercentage,
                        reportProvider
                            .reportModel!
                            .report!
                            .pendingClientsPercentage,
                      ])
                      ? const Center(
                        child: Text(
                          "No Data Found",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                      : PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                          sections: [
                            /// 🔵 Converted %
                            PieChartSectionData(
                              color: kButtonColor2,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .convertedPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.convertedPercentage ?? "0").toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            /// 🟢 Pending %
                            PieChartSectionData(
                              color: Colors.blueAccent,
                              value: double.parse(
                                reportProvider
                                        .reportModel!
                                        .report!
                                        .pendingPercentage ??
                                    "0",
                              ),
                              title:
                                  '${double.parse(reportProvider.reportModel!.report!.pendingPercentage ?? "0").toStringAsFixed(0)}%',
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
        ],
      ),
    );
  }
}

Widget shimmerLine() {
  return Container(
    height: 16,
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white38,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}

bool _isAllZero(List<String?> values) {
  return values.every((v) => (double.tryParse(v ?? "0") ?? 0) == 0);
}

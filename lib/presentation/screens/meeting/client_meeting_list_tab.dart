import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/meeting_provider.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/list_shimmer_effect.dart';
import 'package:wisdeals/widgets/network_widget.dart';

class ClientMeetingListTab extends StatefulWidget {
  const ClientMeetingListTab({Key? key}) : super(key: key);

  @override
  _ClientMeetingListTabState createState() => _ClientMeetingListTabState();
}

class _ClientMeetingListTabState extends State<ClientMeetingListTab> {
  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingProvider>(
        context,
        listen: false,
      ).getClientsInmeetingPro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
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

        return Consumer<MeetingProvider>(
          builder: (context, meetingProvider, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final failure = meetingProvider.failure;
              if (failure != null) {
                if (failure is ClientFailure ||
                    failure is ServerFailure ||
                    meetingProvider.failure is ClientFailure ||
                    meetingProvider.failure is ServerFailure) {
                  failureDilogeWidget(
                    context,
                    'assets/images/failicon.png',
                    "Failed",
                    '${failure.message}',
                    provider: meetingProvider,
                  );
                }
              }
            });

            if (meetingProvider.failure is NetworkFailure) {
              return NetWorkRetry(
                failureMessage:
                    meetingProvider.failure?.message ??
                    "No internet connection",

                onRetry: () async {
                  _initialData();
                },
              );
            }
            return (meetingProvider.isLoading ||
                    meetingProvider.clientListSearched == null)
                ? const LeadCardShimmer(isTablet: false)
                : (meetingProvider.clientListSearched == null ||
                    meetingProvider.clientListSearched!.isEmpty)
                ? SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    height: 500,
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset('assets/json/noevents.json', width: 150),
                        const SizedBox(height: 10),
                        const Text(
                          'No Client Meeting',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
                : Container(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _initialData();
                    },
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount:
                                meetingProvider.clientListSearched!.length,
                            itemBuilder: (context, index) {
                              final client =
                                  meetingProvider.clientListSearched![index];
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
                                        final d = _parseCustomDate(m.date);
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
                                  (a, b) => (a["date"] as DateTime).compareTo(
                                    b["date"],
                                  ),
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
                                          ? parsed[parsed.length - 2]["meeting"]
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
                                return DateFormat("dd-MM-yyyy").format(parsed);
                              }

                              return InkWell(
                                onTap: () {
                                  print('${client.isImportant}');
                                  Navigator.pushNamed(
                                    context,
                                    '/ordersingleviewscreen',
                                    arguments: {"client": client},
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
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
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      client.companyName ??
                                                          'N/A',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "MontrealSerial",
                                                        color: Colors.white,
                                                        fontSize: scale(20),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    // const SizedBox(width: 5),
                                                    // client.isImportant == 1
                                                    //     ? Icon(
                                                    //       Icons
                                                    //           .star_border_outlined,
                                                    //       color: Colors.amber,
                                                    //     )
                                                    //     : Icon(
                                                    //       Icons.star,
                                                    //       color: Colors.amber,
                                                    //     ),
                                                  ],
                                                ),
                                                Text(
                                                  client.clientName ?? '',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        "MontrealSerial",
                                                    color: Colors.white,
                                                    fontSize: scale(14),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Image.asset(
                                                  'assets/images/clientlistarrow.png',
                                                  width: scale(40),
                                                  height: scale(40),
                                                ),
                                                // SizedBox(height: scale(5)),
                                                // Text(
                                                //   'Add meeting',
                                                //   style: TextStyle(
                                                //     fontFamily:
                                                //         "MontrealSerial",
                                                //     color: Colors.white,
                                                //     fontSize:
                                                //         isTablet ? 18 : 12,
                                                //     fontWeight: FontWeight.w700,
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Status : ${client.status ?? 'N/A'}',
                                          style: TextStyle(
                                            fontFamily: "MontrealSerial",
                                            color: kButtonColor2,
                                            fontSize: isTablet ? 18 : 12,
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

                                            // // --- Next Meeting ---
                                            // Column(
                                            //   crossAxisAlignment:
                                            //       CrossAxisAlignment
                                            //           .start,
                                            //   children: [
                                            //     Text(
                                            //       'Next meeting',
                                            //       style: TextStyle(
                                            //         fontFamily:
                                            //             "MontrealSerial",
                                            //         color:
                                            //             Colors
                                            //                 .white,
                                            //         fontSize:
                                            //             isTablet
                                            //                 ? 20
                                            //                 : 14,
                                            //         fontWeight:
                                            //             FontWeight
                                            //                 .w500,
                                            //       ),
                                            //     ),
                                            //     SizedBox(
                                            //       height:
                                            //           isTablet
                                            //               ? 10
                                            //               : 5,
                                            //     ),
                                            //     Row(
                                            //       crossAxisAlignment:
                                            //           CrossAxisAlignment
                                            //               .start,
                                            //       children: [
                                            //         Image.asset(
                                            //           'assets/images/clock.png',
                                            //           width:
                                            //               isTablet
                                            //                   ? 25
                                            //                   : 17,
                                            //           height:
                                            //               isTablet
                                            //                   ? 25
                                            //                   : 17,
                                            //         ),
                                            //         SizedBox(
                                            //           width:
                                            //               isTablet
                                            //                   ? 10
                                            //                   : 5,
                                            //         ),
                                            //         Column(
                                            //           crossAxisAlignment:
                                            //               CrossAxisAlignment
                                            //                   .start,
                                            //           children: [
                                            //             Text(
                                            //               formatDate(
                                            //                 nextMeeting
                                            //                     ?.date,
                                            //               ),
                                            //               style: TextStyle(
                                            //                 fontFamily:
                                            //                     "MontrealSerial",
                                            //                 color:
                                            //                     Colors.white,
                                            //                 fontSize:
                                            //                     isTablet
                                            //                         ? 18
                                            //                         : 14,
                                            //                 fontWeight:
                                            //                     FontWeight.w500,
                                            //               ),
                                            //             ),
                                            //             Text(
                                            //               nextMeeting !=
                                            //                       null
                                            //                   ? '${nextMeeting.timeFrom ?? '--'} To ${nextMeeting.timeTo ?? '--'}'
                                            //                   : '---- ------ ----- -----',
                                            //               style: TextStyle(
                                            //                 fontFamily:
                                            //                     "MontrealSerial",
                                            //                 color:
                                            //                     Colors.white,
                                            //                 fontSize:
                                            //                     isTablet
                                            //                         ? 18
                                            //                         : 14,
                                            //                 fontWeight:
                                            //                     FontWeight.w500,
                                            //               ),
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ],
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder:
                                (context, index) => SizedBox(height: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
          },
        );
      },
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

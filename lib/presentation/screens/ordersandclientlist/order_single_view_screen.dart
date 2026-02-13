import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';
import 'package:wisdeals/presentation/provider/order_provider.dart';
import 'package:wisdeals/presentation/screens/lead_screen/widget/validation_date_and_time.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/delete_custome_diloge.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class OrderSingleViewScreen extends StatefulWidget {
  final Clients clientSingle;
  const OrderSingleViewScreen({Key? key, required this.clientSingle})
    : super(key: key);

  @override
  _OrderSingleViewScreenState createState() => _OrderSingleViewScreenState();
}

class _OrderSingleViewScreenState extends State<OrderSingleViewScreen> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final TextEditingController callLOgNoteController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    final updatedClient = (provider.clientList ?? []).firstWhere(
      (e) => e.id == widget.clientSingle.id,
      orElse: () => widget.clientSingle,
    );

    final meetings = updatedClient.meetings ?? [];
    final callLogs = updatedClient.callLogs ?? [];

    print("Single View Meetings: $meetings");

    // VARIABLES
    var pastMeeting;
    var nextMeeting;

    // ------------------------------------------------------------
    // 1️⃣ DATE PARSER (supports yyyy-MM-dd & dd-MM-yyyy)
    // ------------------------------------------------------------
    DateTime? _parseCustomDate(dynamic date) {
      if (date == null) return null;

      if (date is DateTime) return date;

      if (date is String) {
        // yyyy-MM-dd
        final iso = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$');
        if (iso.hasMatch(date)) {
          try {
            return DateTime.parse(date);
          } catch (_) {}
        }

        // dd-MM-yyyy
        final dmy = RegExp(r'^\d{1,2}-\d{1,2}-\d{4}$');
        if (dmy.hasMatch(date)) {
          final p = date.split('-');
          return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
        }
      }

      return null;
    }

    // ------------------------------------------------------------
    // 2️⃣ Convert parsed meeting dates (strip time)
    // ------------------------------------------------------------
    List<Map<String, dynamic>> parsed =
        meetings
            .map((m) {
              final d = _parseCustomDate(m.date);
              if (d == null) return null;

              return {"meeting": m, "date": DateTime(d.year, d.month, d.day)};
            })
            .where((e) => e != null)
            .cast<Map<String, dynamic>>()
            .toList();

    if (parsed.isEmpty) {
      pastMeeting = null;
      nextMeeting = null;
    } else {
      // ------------------------------------------------------------
      // 3️⃣ Sort ascending (oldest → newest)
      // ------------------------------------------------------------
      parsed.sort(
        (a, b) => (a["date"] as DateTime).compareTo(b["date"] as DateTime),
      );

      print("Sorted Single View Meetings: $parsed");

      if (parsed.length == 1) {
        pastMeeting = null;
        nextMeeting = parsed.first["meeting"];
      } else {
        pastMeeting = parsed[parsed.length - 2]["meeting"];
        nextMeeting = parsed.last["meeting"];
      }
    }

    // ------------------------------------------------------------
    // 4️⃣ Format Date
    // ------------------------------------------------------------
    String formatDate(dynamic date) {
      final parsed = _parseCustomDate(date);
      if (parsed == null) return '---- ------ ----- -----';
      return DateFormat('dd-MM-yyyy').format(parsed);
    }

    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 700;
          final bool isSmallScreen = constraints.maxWidth < 400;

          double scale(double base) {
            if (isTablet) return base * 1.4;
            if (isSmallScreen) return base * 0.85;
            return base;
          }

          return Consumer<OrderProvider>(
            builder: (context, orderProvider, _) {
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
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
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
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 50),
                                      // image
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/emptypro.jpg',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      Text(
                                        '${widget.clientSingle.companyName ?? 'N/A'}',
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${widget.clientSingle.customerProfile ?? ''}',
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 30),

                                      // contact
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // orderProvider.isLoading
                                            //     ? Container(
                                            //       // width: 80,
                                            //       // height: 65,
                                            //       decoration: BoxDecoration(
                                            //         border: Border.all(
                                            //           color: Colors.grey,
                                            //         ),
                                            //         borderRadius:
                                            //             BorderRadius.circular(
                                            //               10,
                                            //             ),
                                            //       ),
                                            //       child: Padding(
                                            //         padding:
                                            //             const EdgeInsets.symmetric(
                                            //               vertical: 10,
                                            //               horizontal: 20,
                                            //             ),
                                            //         child:
                                            //             CircularProgressIndicator(
                                            //               color: kButtonColor2,
                                            //             ),
                                            //       ),
                                            //     )
                                            //     : ContactSocialWidget(
                                            //       image:
                                            //           updatedClient.isImportant!
                                            //               ? 'assets/images/staropen.png'
                                            //               : "assets/images/star.png",
                                            //       text: "Mark Important",
                                            //       onTap: () async {
                                            //         // Call Provider
                                            //         await orderProvider
                                            //             .isImportant(
                                            //               widget.clientSingle.id
                                            //                   .toString(),
                                            //               updatedClient
                                            //                       .isImportant!
                                            //                   ? '0'
                                            //                   : '1',
                                            //             );

                                            //         if (orderProvider.success !=
                                            //             null) {
                                            //           orderProvider
                                            //               .getClientsPro(
                                            //                 isRefresh: true,
                                            //                 '',
                                            //                 '',
                                            //               );

                                            //           ScaffoldMessenger.of(
                                            //             context,
                                            //           ).showSnackBar(
                                            //             SnackBar(
                                            //               content: Text(
                                            //                 '${orderProvider.success!.message}',
                                            //                 style: TextStyle(
                                            //                   color:
                                            //                       Colors.white,
                                            //                   fontSize: 14,
                                            //                 ),
                                            //               ),
                                            //               backgroundColor:
                                            //                   Colors.green,
                                            //               behavior:
                                            //                   SnackBarBehavior
                                            //                       .floating,
                                            //               margin: const EdgeInsets.only(
                                            //                 bottom:
                                            //                     80, // pushes above nav bar
                                            //                 left: 20,
                                            //                 right: 20,
                                            //               ),
                                            //               elevation: 10,
                                            //               shape: RoundedRectangleBorder(
                                            //                 borderRadius:
                                            //                     BorderRadius.circular(
                                            //                       14,
                                            //                     ),
                                            //               ),
                                            //               duration:
                                            //                   const Duration(
                                            //                     seconds: 2,
                                            //                   ),
                                            //             ),
                                            //           );

                                            //           // // Navigator.pop(context);
                                            //           // showSuccessDialog(
                                            //           //   context,
                                            //           //   "assets/images/successicons.png",
                                            //           //   "Success",
                                            //           //   "${orderProvider.success!.message}",
                                            //           // );
                                            //         }
                                            //       },
                                            //     ),
                                            const SizedBox(width: 10),
                                            ContactSocialWidget(
                                              image:
                                                  "assets/images/callnew.png",
                                              text: "Phone",
                                              onTap: () {
                                                print('make call');
                                                orderProvider.callLogFlagPro();
                                                orderProvider.setClientIdPro(
                                                  widget.clientSingle.id
                                                      .toString(),
                                                );
                                                orderProvider.makePhoneCall(
                                                  '+91${widget.clientSingle.contactNumber ?? ''}',
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            ContactSocialWidget(
                                              image:
                                                  "assets/images/calllognew.png",
                                              text: "Call Log",
                                              onTap: () {
                                                print(
                                                  '${widget.clientSingle.callLogs}',
                                                );
                                                orderProvider
                                                    .showCallLogListHideAndShow();
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            ContactSocialWidget(
                                              image:
                                                  "assets/images/whatsappnew.png",
                                              text: "WhatsApp",
                                              onTap: () {
                                                orderProvider.openWhatsApp(
                                                  '+91${widget.clientSingle.contactNumber}',
                                                  message:
                                                      'Hello! I’d like to know more.',
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            ContactSocialWidget(
                                              image:
                                                  "assets/images/lead/trash.png",
                                              // image: "assets/images/star.png",
                                              text: "Delete",
                                              onTap: () {
                                                showDeleteConfirmationDialog(
                                                  context,
                                                  onDelete: () async {
                                                    await orderProvider
                                                        .deleteClientPro(
                                                          widget.clientSingle.id
                                                              .toString(),
                                                        );
                                                    if (orderProvider.success !=
                                                        null) {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      showSuccessDialog(
                                                        context,
                                                        "assets/images/successicons.png",
                                                        "Success",
                                                        orderProvider
                                                            .success!
                                                            .message
                                                            .toString(),
                                                      );
                                                      orderProvider
                                                          .getClientsPro(
                                                            '',
                                                            isRefresh: false,
                                                            '',
                                                            '',
                                                          );
                                                    }
                                                  },
                                                  textMain: "Delete Client",
                                                  provider: orderProvider,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              CustomAppBarWidget(
                                title: "",
                                drawerIconImage: false,
                                notificationIconImage: false,
                                editButton: true,
                                onTap: () {
                                  print('Edit Screen');
                                  Navigator.pushNamed(
                                    context,
                                    '/orderupdatescreen',
                                    arguments: {'client': widget.clientSingle},
                                  );
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          //*******************hide and show call logs with animation ************************** */
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 450),
                            switchInCurve: Curves.easeOutExpo,
                            switchOutCurve: Curves.easeInExpo,
                            transitionBuilder: (child, animation) {
                              final fade = Tween<double>(
                                begin: 0.0,
                                end: 1.0,
                              ).animate(animation);

                              final slide = Tween<Offset>(
                                begin: const Offset(0, 0.08),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                ),
                              );

                              final scale = Tween<double>(
                                begin: 0.97,
                                end: 1.0,
                              ).animate(
                                CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutBack,
                                ),
                              );

                              return FadeTransition(
                                opacity: fade,
                                child: SlideTransition(
                                  position: slide,
                                  child: ScaleTransition(
                                    scale: scale,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child:
                                orderProvider.showHideCallLogs
                                    ? callLogs.isNotEmpty
                                        ? Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: callLogs!.length,
                                            itemBuilder: (context, indexCall) {
                                              final call = callLogs[indexCall];

                                              // Parse the string to DateTime
                                              // ✅ Parse the string to DateTime
                                              DateTime dateTime =
                                                  DateTime.parse(
                                                    call.createdAt.toString(),
                                                  );
                                              // ✅ Convert to local time (optional but recommended)
                                              DateTime localTime =
                                                  dateTime.toLocal();
                                              // ✅ Format date and time separately
                                              String formattedDate = DateFormat(
                                                'dd-MM-yyyy',
                                              ).format(localTime);
                                              String formattedTime = DateFormat(
                                                'hh:mm a',
                                              ).format(localTime);
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                      horizontal: 10,
                                                    ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Left timeline + index
                                                    Column(
                                                      children: [
                                                        // The numbered circle
                                                        CircleAvatar(
                                                          radius: 10,
                                                          backgroundColor:
                                                              Colors.blueAccent,
                                                          child: Text(
                                                            '${indexCall + 1}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                          ),
                                                        ),
                                                        // The vertical line
                                                        Container(
                                                          width: 2,
                                                          height: 50,
                                                          color:
                                                              indexCall ==
                                                                      callLogs.length -
                                                                          1
                                                                  ? Colors
                                                                      .transparent
                                                                  : Colors.grey,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(width: 12),
                                                    // Right side content
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              Colors
                                                                  .grey
                                                                  .shade100,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  Colors
                                                                      .grey
                                                                      .shade300,
                                                              blurRadius: 3,
                                                              offset:
                                                                  const Offset(
                                                                    1,
                                                                    1,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              call.notes ??
                                                                  'No notes',
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              'Duration: ${formattedTime ?? 'N/A'}',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              'Date: ${formattedDate ?? 'N/A'}',
                                                              style:
                                                                  const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color:
                                                                        Colors
                                                                            .grey,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                        : Container(
                                          width: double.infinity,

                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: kButtonColor2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
                                              child: Text(
                                                'No Call Logs',
                                                style: TextStyle(
                                                  color: kButtonColor2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    : SizedBox.shrink(),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Status : ${widget.clientSingle.status ?? 'N/A'}',
                            style: TextStyle(
                              fontFamily: "MontrealSerial",
                              color: kButtonColor2,
                              fontSize: isTablet ? 18 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          // second position
                          Text(
                            'Follow Up Status : Converted',
                            style: TextStyle(
                              fontFamily: "MontrealSerial",
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Divider(),
                          const SizedBox(height: 20),

                          // meetings colume
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    // color: Colors.amber,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Meetings',
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      orderProvider.hideandShowMeetings();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: kButtonColor2,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Add Meeting'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              AddMeetingWidget(
                                provider: orderProvider,
                                dateController: dateController,
                                timeFromController: timeFromController,
                                timeToController: timeToController,
                                noteController: noteController,
                                clientId: widget.clientSingle.id.toString(),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _buildMeetingColumn(
                                    title: 'Meeting',
                                    date: formatDate(pastMeeting?.date),
                                    time:
                                        '${pastMeeting?.timeFrom ?? '--'} to ${pastMeeting?.timeTo ?? '--'}',
                                    scale: scale,
                                  ),
                                  _buildMeetingColumn(
                                    title: 'Next Meeting',
                                    date: formatDate(nextMeeting?.date),
                                    time:
                                        '${nextMeeting?.timeFrom ?? '--'} to ${nextMeeting?.timeTo ?? '--'}',
                                    scale: scale,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              orderProvider.showMeetingsPro();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'All Meetings',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    orderProvider.showMeetings
                                        ? Icon(
                                          Icons.arrow_drop_up,
                                          color: Colors.white,
                                        )
                                        : Icon(
                                          Icons.arrow_drop_down,
                                          color: Colors.white,
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // show all meetings
                          // AnimatedSize(
                          //   duration: const Duration(milliseconds: 400),
                          //   curve: Curves.easeInOut,
                          //   child:
                          //       orderProvider.showMeetings
                          //           ? Container(
                          //             width: double.infinity,

                          //             decoration: BoxDecoration(
                          //               color: Colors.transparent,
                          //               borderRadius: BorderRadius.circular(15),
                          //               boxShadow: const [
                          //                 BoxShadow(
                          //                   blurRadius: 6,
                          //                   spreadRadius: 1,
                          //                   offset: Offset(0, 3),
                          //                 ),
                          //               ],
                          //               border: Border.all(
                          //                 color: kButtonColor2,
                          //               ),
                          //             ),
                          //             child: Padding(
                          //               padding: const EdgeInsets.all(10.0),
                          //               child: ListView.separated(
                          //                 padding: EdgeInsets.all(0),
                          //                 shrinkWrap: true,
                          //                 physics:
                          //                     const NeverScrollableScrollPhysics(),
                          //                 itemCount: meetings.length,
                          //                 itemBuilder: (context, indexMeet) {
                          //                   return MeetingCard(
                          //                     meeting: meetings[indexMeet],
                          //                     scale:
                          //                         MediaQuery.of(
                          //                           context,
                          //                         ).textScaleFactor,
                          //                   );
                          //                 },
                          //                 separatorBuilder:
                          //                     (context, _) => const Divider(),
                          //               ),
                          //             ),
                          //           )
                          //           : SizedBox.shrink(),
                          // ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child:
                                orderProvider.showMeetings
                                    ? meetings.isNotEmpty
                                        ? Container(
                                          width: double.infinity,

                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: kButtonColor2,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: ListView.separated(
                                              padding: EdgeInsets.all(0),
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: meetings.length,
                                              itemBuilder: (
                                                context,
                                                indexMeet,
                                              ) {
                                                return MeetingCard(
                                                  meeting: meetings[indexMeet],
                                                  scale:
                                                      MediaQuery.of(
                                                        context,
                                                      ).textScaleFactor,
                                                  orderClientProvider:
                                                      orderProvider,
                                                );
                                              },
                                              separatorBuilder:
                                                  (context, _) =>
                                                      const Divider(),
                                            ),
                                          ),
                                        )
                                        : Container(
                                          width: double.infinity,

                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                            border: Border.all(
                                              color: kButtonColor2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
                                              child: Text(
                                                'No Client Meeting',
                                                style: TextStyle(
                                                  color: kButtonColor2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    : SizedBox.shrink(),
                          ),
                          const SizedBox(height: 5),
                          const Divider(),
                          const SizedBox(height: 20),

                          /*************email************* */
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/mail.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(fontSize: 18, text: "Email"),
                                  const SizedBox(height: 10),
                                  CustomText(fontSize: 12, text: ""),
                                  CustomText(
                                    fontSize: 18,
                                    text:
                                        "${'${widget.clientSingle.email ?? 'N/A'}'}",
                                  ),
                                  // const SizedBox(height: 10),
                                  // CustomText(fontSize: 12, text: "personal"),
                                  // CustomText(
                                  //   fontSize: 14,
                                  //   text: "Company mail@gmail.com",
                                  // ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(),
                          const SizedBox(height: 10),
                          /*************Phone************* */
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/phone.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    fontSize: 18,
                                    text: "Phone Number",
                                  ),
                                  const SizedBox(height: 10),
                                  CustomText(fontSize: 12, text: ""),
                                  CustomText(
                                    fontSize: 18,
                                    text:
                                        "${'${widget.clientSingle.contactNumber ?? 'N/A'}'}",
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Divider(),
                          const SizedBox(height: 10),
                          /*************Address************* */
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/location.png',
                                width: 24,
                                height: 24,
                              ),
                              SizedBox(width: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(fontSize: 18, text: "Address"),
                                  const SizedBox(height: 10),
                                  CustomText(fontSize: 12, text: ""),
                                  CustomText(
                                    fontSize: 18,
                                    text:
                                        "${'${widget.clientSingle.address ?? 'N/A'}'}",
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                    orderProvider.callLogFlag
                        ? AnimatedOpacity(
                          opacity: 1.0,
                          duration: Duration(seconds: 1),
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 300,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Call Log',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 10),
                                        Text('Enter Call Log Details...'),
                                        SizedBox(height: 10),
                                        TextFormField(
                                          controller: callLOgNoteController,
                                          decoration: InputDecoration(
                                            hintText: "ex : Not Attend...",
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () async {
                                            print(
                                              'Reason: ${orderProvider.clientIdForCallLog}',
                                            );
                                            if (callLOgNoteController
                                                .text
                                                .isNotEmpty) {
                                              await orderProvider
                                                  .clientAddcallLogsPro(
                                                    orderProvider
                                                        .clientIdForCallLog,
                                                    '',
                                                    callLOgNoteController.text
                                                        .toString(),
                                                  );
                                              if (orderProvider.success !=
                                                  null) {
                                                orderProvider.callLogFlagPro();
                                                // Update only this client's data without closing screen
                                                setState(() {});
                                                showSuccessDialog(
                                                  context,
                                                  "assets/images/successicons.png",
                                                  "Success",
                                                  "${orderProvider.success!.message}",
                                                );
                                                orderProvider.getClientsPro(
                                                  '',
                                                  isRefresh: true,
                                                  '',
                                                  '',
                                                );
                                              }
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    'Please enter a call reason before submitting.',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  behavior:
                                                      SnackBarBehavior
                                                          .floating, // ✅ Floating snackbar
                                                  margin: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            '${orderProvider.isLoading ? 'Loading.....' : 'Submit'}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AddMeetingWidget extends StatefulWidget {
  final OrderProvider provider;
  final TextEditingController dateController;
  final TextEditingController timeFromController;
  final TextEditingController timeToController;
  final TextEditingController noteController;
  final String? clientId;
  const AddMeetingWidget({
    super.key,
    required this.provider,
    required this.dateController,
    required this.timeFromController,
    required this.timeToController,
    required this.noteController,
    required this.clientId,
  });

  @override
  State<AddMeetingWidget> createState() => _AddMeetingWidgetState();
}

class _AddMeetingWidgetState extends State<AddMeetingWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print('hiiiiiii : ${widget.provider.selectedMeetingDate ?? ''}');
    widget.dateController.text = widget.provider.selectedMeetingDate ?? '';
    widget.timeFromController.text = widget.provider.selectedTimeFrom ?? '';
    widget.timeToController.text = widget.provider.selectedTimeTo ?? '';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      height:
          widget.provider.hideAndShowMeeting
              ? 450
              : 0, // smoothly expands/collapses
      decoration: BoxDecoration(
        color: const Color(0xFFEDFCC5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child:
              widget.provider.hideAndShowMeeting
                  ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            widget.provider.hideandShowMeetings();
                          },
                          child: Icon(Icons.close),
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select date'),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: widget.dateController,
                                onTap: () {
                                  widget.provider.setSelectedDate(context);
                                },
                                readOnly: true, // locks typing
                                decoration: InputDecoration(
                                  hintText: "Select Date",
                                  suffixIcon: Icon(Icons.calendar_month),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Select Date";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Time from'),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: widget.timeFromController,
                                      onTap: () {
                                        widget.provider.setSelectedTimeFrom(
                                          context,
                                        );
                                      },
                                      readOnly: true,
                                      decoration: InputDecoration(
                                        hintText: "Time From",
                                        suffixIcon: Icon(Icons.access_time),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Select Time From";
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Time To'),
                                    SizedBox(height: 10),
                                    TextFormField(
                                      controller: widget.timeToController,
                                      onTap: () {
                                        widget.provider.setSelectedTimeTo(
                                          context,
                                        );
                                      },
                                      decoration: InputDecoration(
                                        hintText: "Time To",
                                        suffixIcon: Icon(Icons.access_time),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please Select Time To";
                                        } else {
                                          return null;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Note'),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: widget.noteController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "write a note",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please Enter Note";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap:
                              widget.provider.isLoadingAddMeeting
                                  ? null
                                  : () async {
                                    print('${widget.clientId.toString()}');
                                    print(
                                      '${widget.dateController.text.toString()}',
                                    );
                                    print(
                                      '${widget.timeFromController.text.toString()}',
                                    );
                                    print(
                                      '${widget.timeToController.text.toString()}',
                                    );
                                    print(
                                      '${widget.noteController.text.toString()}',
                                    );

                                    if (_formKey.currentState!.validate()) {
                                      final date =
                                          widget.dateController.text.trim();
                                      final timeFrom =
                                          widget.timeFromController.text.trim();
                                      final timeTo =
                                          widget.timeToController.text.trim();

                                      // validation time 'End time cannot be before start time!', start
                                      final isValid = validateDateTime(
                                        context,
                                        date,
                                        timeFrom,
                                        timeTo,
                                      );
                                      if (!isValid) return;
                                      // validation time 'End time cannot be before start time!', end
                                      await widget.provider
                                          .orderAndCLientAddMeetingPro(
                                            widget.clientId.toString(),
                                            widget.dateController.text
                                                .toString(),
                                            widget.timeFromController.text
                                                .toString(),
                                            widget.timeToController.text
                                                .toString(),
                                            widget.noteController.text
                                                .toString(),
                                          );

                                      if (widget.provider.success != null) {
                                        widget.provider.getClientsPro(
                                          '',
                                          isRefresh: true,
                                          '',
                                          '',
                                        );
                                        Navigator.pop(context);
                                        widget.provider.hideandShowMeetings();
                                        showSuccessDialog(
                                          context,
                                          "assets/images/successicons.png",
                                          "Success",
                                          "${widget.provider.success!.message}",
                                        );
                                        // widget.leadId,
                                        widget.provider.clearMeetingData();
                                        widget.noteController.text = '';
                                      }
                                    }
                                  },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  widget.provider.isLoadingAddMeeting
                                      ? Colors.black
                                      : kButtonColor2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.provider.isLoadingAddMeeting
                                    ? 'Adding meeting...'
                                    : 'Add Meeting',
                                style: TextStyle(
                                  color:
                                      widget.provider.isLoadingAddMeeting
                                          ? Colors.white
                                          : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  : null,
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final double fontSize;
  final String? text;
  const CustomText({super.key, required this.fontSize, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${text}',
      style: TextStyle(
        fontFamily: "MontrealSerial",
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class ContactSocialWidget extends StatelessWidget {
  final String? image;
  final VoidCallback onTap;
  final String? text;
  const ContactSocialWidget({
    super.key,
    required this.image,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // width: 80,
        // height: 65,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('${image}', width: 24, height: 24),
              SizedBox(height: 3),
              Text(
                '${text}',
                style: TextStyle(
                  fontFamily: "MontrealSerial",
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
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

class MeetingCard extends StatefulWidget {
  final Meeting meeting;
  final double scale;
  final OrderProvider orderClientProvider;
  const MeetingCard({
    Key? key,
    required this.meeting,
    required this.scale,
    required this.orderClientProvider,
  }) : super(key: key);

  @override
  State<MeetingCard> createState() => _MeetingCardState();
}

class _MeetingCardState extends State<MeetingCard> {
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "--";

    try {
      final parsed = DateTime.parse(date);
      return DateFormat('dd-MM-yyyy').format(parsed);
    } catch (e) {
      return "--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kButtonColor2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.meeting.title ?? 'Meeting',
            style: TextStyle(
              fontSize: 16 * widget.scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14 * widget.scale,
                    color: kButtonColor2,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formatDate(widget.meeting.date),
                    style: TextStyle(
                      fontSize: 14 * widget.scale,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),

              InkWell(
                onTap: () {
                  print('edit');

                  print('meeting id ${widget.meeting.id.toString()}');
                  showDeleteConfirmationDialog(
                    context,
                    onDelete: () async {
                      await widget.orderClientProvider.deleteClientMeetingPro(
                        widget.meeting.id.toString(),
                      );
                      if (widget.orderClientProvider.success != null) {
                        Navigator.pop(context);
                        showSuccessDialog(
                          context,
                          "assets/images/successicons.png",
                          "Success",
                          widget.orderClientProvider.success!.message
                              .toString(),
                        );
                        widget.orderClientProvider.getClientsPro(
                          '',
                          '',
                          '',
                          isRefresh: true,
                        );
                      }
                    },
                    textMain: "Delete Meeting",
                    provider: widget.orderClientProvider,
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14 * widget.scale,
                color: kButtonColor2,
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.meeting.timeFrom ?? '--'} to ${widget.meeting.timeTo ?? '--'}',
                style: TextStyle(
                  fontSize: 14 * widget.scale,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

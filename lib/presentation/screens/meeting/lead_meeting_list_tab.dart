import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/meeting_provider.dart';
import 'package:wisdeals/presentation/screens/lead_screen/lead_list_screen.dart';
import 'package:wisdeals/presentation/screens/lead_screen/widget/add_to_client_popup.dart';
import 'package:wisdeals/widgets/delete_custome_diloge.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/list_shimmer_effect.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class LeadMeetingListTab extends StatefulWidget {
  const LeadMeetingListTab({Key? key}) : super(key: key);

  @override
  _LeadMeetingListTabState createState() => _LeadMeetingListTabState();
}

class _LeadMeetingListTabState extends State<LeadMeetingListTab> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // call log controller
  final TextEditingController callLogNoteController = TextEditingController();

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MeetingProvider>(
        context,
        listen: false,
      ).getLeadMeetingPro('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isTablet = constraints.maxWidth > 600;
        final bool isSmallScreen = constraints.maxWidth < 400;
        return Consumer2<MeetingProvider, LeadProvider>(
          builder: (context, meetingProvider, leadProvider, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final failure = leadProvider.failure;
              if (failure != null) {
                if (failure is ClientFailure ||
                    failure is ServerFailure ||
                    leadProvider.failure is ClientFailure ||
                    leadProvider.failure is ServerFailure) {
                  failureDilogeWidget(
                    context,
                    'assets/images/failicon.png',
                    "Failed",
                    '${failure.message}',
                    provider: leadProvider,
                  );
                }
              }
            });

            if (leadProvider.failure is NetworkFailure) {
              return NetWorkRetry(
                failureMessage:
                    leadProvider.failure?.message ?? "No internet connection",

                onRetry: () async {
                  _initialData();
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
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              _initialData();
                            },
                            child: RefreshIndicator(
                              onRefresh: () async {},
                              child: SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    // lead list widget
                                    SizedBox(height: 10),
                                    (meetingProvider.isLoading ||
                                            meetingProvider
                                                    .leadDataListSearched ==
                                                null)
                                        ? const LeadCardShimmer(isTablet: false)
                                        : (meetingProvider
                                                    .leadDataListSearched ==
                                                null ||
                                            meetingProvider
                                                .leadDataListSearched!
                                                .isEmpty)
                                        ? Container(
                                          width: double.infinity,
                                          height: 500,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Lottie.asset(
                                                'assets/json/noevents.json',
                                                width: 150,
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'No Lead Meeting',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        : ListView.separated(
                                          padding: EdgeInsets.all(0),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              meetingProvider
                                                  .leadDataListSearched!
                                                  .length,
                                          itemBuilder: (context, index) {
                                            final isExpanded =
                                                leadProvider
                                                    .hideAndShowAddMeetingIndex ==
                                                index;
                                            final leadId =
                                                meetingProvider
                                                    .leadDataListSearched![index]
                                                    .id
                                                    .toString();
                                            final meetings =
                                                meetingProvider
                                                    .leadDataListSearched![index]
                                                    .meetings;
                                            final callLogs =
                                                meetingProvider
                                                    .leadDataListSearched![index]
                                                    .callLogs;
                                            final latestMeeting =
                                                meetings!.isNotEmpty
                                                    ? meetings.reduce(
                                                      (a, b) =>
                                                          DateTime.parse(
                                                                a.date,
                                                              ).isAfter(
                                                                DateTime.parse(
                                                                  b.date,
                                                                ),
                                                              )
                                                              ? a
                                                              : b,
                                                    )
                                                    : null;
                                            // Format only the date (e.g. "2025-10-29")
                                            final formattedDate =
                                                latestMeeting != null
                                                    ? DateFormat(
                                                      'dd-MM-yyyy',
                                                    ).format(
                                                      DateTime.parse(
                                                        latestMeeting.date,
                                                      ),
                                                    )
                                                    : '---';
                                            return Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.white.withOpacity(
                                                      0.20,
                                                    ), // bright top-left
                                                    Colors.white.withOpacity(
                                                      0.05,
                                                    ), // softer bottom-right
                                                  ],
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  15,
                                                ),
                                                child: Column(
                                                  children: [
                                                    // main first container
                                                    Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        // color: Colors.amber,
                                                      ),

                                                      // 2 row container
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                  // color: Colors.deepOrange,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,

                                                              children: [
                                                                Text(
                                                                  '${meetingProvider.leadDataListSearched![index].companyName ?? ''}',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 32
                                                                            : 18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '${meetingProvider.leadDataListSearched![index].clientName ?? ''}',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color: const Color(
                                                                      0xFFD1F66F,
                                                                    ),
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 18
                                                                            : 12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                isTablet
                                                                    ? 20
                                                                    : 10,
                                                          ),
                                                          Container(
                                                            decoration:
                                                                BoxDecoration(
                                                                  // color: Colors.blue,
                                                                ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  '${meetingProvider.leadDataListSearched![index].customerProfile ?? ''}',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .yellow,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 18
                                                                            : 12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height:
                                                                      isTablet
                                                                          ? 10
                                                                          : 8,
                                                                ),
                                                                Text(
                                                                  '${meetingProvider.leadDataListSearched![index].leadStatus ?? ''}',
                                                                  style: TextStyle(
                                                                    fontFamily:
                                                                        "MontrealSerial",
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                    fontSize:
                                                                        isTablet
                                                                            ? 18
                                                                            : 12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        // color: Colors.green,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          // new meeting
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Next Meeting',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      "MontrealSerial",
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      isTablet
                                                                          ? 18
                                                                          : 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height:
                                                                    isTablet
                                                                        ? 10
                                                                        : 5,
                                                              ),
                                                              // time
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/images/clock.png',
                                                                    width:
                                                                        isTablet
                                                                            ? 25
                                                                            : 17,
                                                                    height:
                                                                        isTablet
                                                                            ? 25
                                                                            : 17,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                        isTablet
                                                                            ? 10
                                                                            : 5,
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        '${formattedDate ?? "-------"}',
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              "MontrealSerial",
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              isTablet
                                                                                  ? 18
                                                                                  : 14,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        '${latestMeeting != null ? latestMeeting.timeFrom : '---'} TO ${latestMeeting != null ? latestMeeting.timeTo : '---'}',
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              "MontrealSerial",
                                                                          color:
                                                                              Colors.white,
                                                                          fontSize:
                                                                              isTablet
                                                                                  ? 18
                                                                                  : 14,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),

                                                          // add meeting
                                                          InkWell(
                                                            onTap: () {
                                                              leadProvider
                                                                  .hideAndShowAddLeadMeeting(
                                                                    index,
                                                                  );
                                                            },
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                                color:
                                                                    kButtonColor2,
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      8.0,
                                                                    ),
                                                                child: Center(
                                                                  child: Text(
                                                                    'Add Meeting',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    // hide and show add meeting
                                                    AddMeetingShaduleWidget(
                                                      isExpanded: isExpanded,
                                                      index: index,
                                                      leadId:
                                                          meetingProvider
                                                              .leadDataListSearched![index]
                                                              .id
                                                              .toString(),
                                                      provider: leadProvider,
                                                      dateController:
                                                          dateController,
                                                      timeFromController:
                                                          timeFromController,
                                                      timeToController:
                                                          timeToController,
                                                      noteController:
                                                          noteController,
                                                    ),
                                                    SizedBox(height: 10),
                                                    // contact
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/lead/addtoclient.png",
                                                            text:
                                                                "Add To Client",
                                                            onTap: () {
                                                              final lead =
                                                                  meetingProvider
                                                                      .leadDataListSearched![index];

                                                              print(
                                                                'client name: ${lead.clientName ?? ''}',
                                                              );
                                                              print(
                                                                'company name: ${lead.companyName ?? ''}',
                                                              );
                                                              print(
                                                                'phone number: ${lead.contactNumber ?? ''}',
                                                              );
                                                              print(
                                                                'email: ${lead.email ?? ''}',
                                                              );
                                                              print(
                                                                'address: ${lead.clientAddress ?? ''}',
                                                              );
                                                              print(
                                                                'lead: ${lead.leadSource ?? ''}',
                                                              );
                                                              print(
                                                                'add note: ${lead.addNote ?? ''}',
                                                              );
                                                              print(
                                                                'lead status: ${lead.leadStatus ?? ''}',
                                                              );
                                                              print(
                                                                'customer profile: ${lead.customerProfile ?? ''}',
                                                              );
                                                              addToClientPopup(
                                                                context,
                                                                AddToCLient: () async {
                                                                  await leadProvider.leadConvertToClientPro(
                                                                    lead.id
                                                                        .toString(),
                                                                    lead.clientName
                                                                        .toString(),
                                                                    lead.companyName
                                                                        .toString(),
                                                                    lead.contactNumber
                                                                        .toString(),
                                                                    lead.email
                                                                        .toString(),
                                                                    lead.clientAddress
                                                                        .toString(),
                                                                    lead.leadSource
                                                                        .toString(),
                                                                    lead.addNote
                                                                        .toString(),
                                                                    lead.leadStatus
                                                                        .toString(),
                                                                    lead.customerProfile
                                                                        .toString(),
                                                                  );

                                                                  if (leadProvider
                                                                          .success !=
                                                                      null) {
                                                                    // Close popup first
                                                                    Navigator.pop(
                                                                      context,
                                                                    );

                                                                    // Then show success dialog
                                                                    showSuccessDialog(
                                                                      context,
                                                                      "assets/images/successicons.png",
                                                                      "Success",
                                                                      leadProvider
                                                                          .success!
                                                                          .message
                                                                          .toString(),
                                                                    );

                                                                    // Refresh list
                                                                    meetingProvider
                                                                        .getLeadMeetingPro(
                                                                          '',
                                                                        );
                                                                  }
                                                                },
                                                                textMain:
                                                                    "Convert To Client",
                                                                provider:
                                                                    leadProvider,
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),

                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/lead/allmeetings.png",
                                                            text:
                                                                "All Meetings",
                                                            onTap: () {
                                                              print(
                                                                'All Meetings',
                                                              );
                                                              leadProvider
                                                                  .allMeetingsShowHideIndex(
                                                                    index,
                                                                  );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/callnew.png",
                                                            text: "Phone",
                                                            onTap: () {
                                                              print(
                                                                'make call',
                                                              );
                                                              leadProvider
                                                                  .callLogFlagPro();
                                                              leadProvider.setLeadIdForCallLog(
                                                                leadProvider
                                                                    .searchdLeadList![index]
                                                                    .id
                                                                    .toString(),
                                                              );
                                                              leadProvider
                                                                  .makePhoneCall(
                                                                    '+91${leadProvider.searchdLeadList![index].contactNumber ?? ''}',
                                                                  );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/calllognew.png",
                                                            text: "Call Log",
                                                            onTap: () {
                                                              print('Call Log');
                                                              leadProvider
                                                                  .callShowHideIndex(
                                                                    index,
                                                                  );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),

                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/whatsappnew.png",
                                                            text: "WhatsApp",
                                                            onTap: () {
                                                              leadProvider.openWhatsApp(
                                                                '+91${leadProvider.searchdLeadList![index].contactNumber}',
                                                                message:
                                                                    'Hello! I’d like to know more.',
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/edit.png",
                                                            text: "Edit",
                                                            onTap: () {
                                                              Navigator.pushNamed(
                                                                context,
                                                                '/leadupdatescreen',
                                                                arguments:
                                                                    leadProvider
                                                                        .searchdLeadList![index],
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          ContactSocialWidget(
                                                            image:
                                                                "assets/images/lead/trash.png",
                                                            text: "Delete",

                                                            onTap: () async {
                                                              showDeleteConfirmationDialog(
                                                                context,
                                                                onDelete: () async {
                                                                  await leadProvider.deleteLeadPro(
                                                                    leadProvider
                                                                        .searchdLeadList![index]
                                                                        .id
                                                                        .toString(),
                                                                  );
                                                                  if (leadProvider
                                                                          .success !=
                                                                      null) {
                                                                    Navigator.pop(
                                                                      context,
                                                                    );
                                                                    showSuccessDialog(
                                                                      context,
                                                                      "assets/images/successicons.png",
                                                                      "Success",
                                                                      leadProvider
                                                                          .success!
                                                                          .message
                                                                          .toString(),
                                                                    );
                                                                    leadProvider
                                                                        .getLeadPro(
                                                                          '',
                                                                        );
                                                                  }
                                                                },
                                                                textMain:
                                                                    "Delete Lead",
                                                                provider:
                                                                    leadProvider,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    leadProvider.callLogShowHideIndex ==
                                                            index
                                                        ? AnimatedSwitcher(
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    400,
                                                              ),
                                                          switchInCurve:
                                                              Curves
                                                                  .easeOutCubic,
                                                          switchOutCurve:
                                                              Curves
                                                                  .easeInCubic,
                                                          transitionBuilder: (
                                                            child,
                                                            animation,
                                                          ) {
                                                            final offsetAnimation =
                                                                Tween<Offset>(
                                                                  begin:
                                                                      const Offset(
                                                                        0,
                                                                        0.1,
                                                                      ),
                                                                  end:
                                                                      Offset
                                                                          .zero,
                                                                ).animate(
                                                                  animation,
                                                                );
                                                            return FadeTransition(
                                                              opacity:
                                                                  animation,
                                                              child: SlideTransition(
                                                                position:
                                                                    offsetAnimation,
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                          child:
                                                              (callLogs!
                                                                      .isNotEmpty)
                                                                  ? Container(
                                                                    key: const ValueKey(
                                                                      'visibleContainer',
                                                                    ),
                                                                    width:
                                                                        double
                                                                            .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                          color:
                                                                              Colors.transparent,
                                                                        ),
                                                                    child: ListView.builder(
                                                                      shrinkWrap:
                                                                          true,
                                                                      physics:
                                                                          const NeverScrollableScrollPhysics(),
                                                                      itemCount:
                                                                          callLogs!
                                                                              .length,
                                                                      itemBuilder: (
                                                                        context,
                                                                        indexCall,
                                                                      ) {
                                                                        final call =
                                                                            callLogs[indexCall];

                                                                        // Parse the string to DateTime
                                                                        // ✅ Parse the string to DateTime
                                                                        DateTime
                                                                        dateTime = DateTime.parse(
                                                                          call.createdAt
                                                                              .toString(),
                                                                        );
                                                                        // ✅ Convert to local time (optional but recommended)
                                                                        DateTime
                                                                        localTime =
                                                                            dateTime.toLocal();
                                                                        // ✅ Format date and time separately
                                                                        String
                                                                        formattedDate = DateFormat(
                                                                          'dd-MM-yyyy',
                                                                        ).format(
                                                                          localTime,
                                                                        );
                                                                        String
                                                                        formattedTime = DateFormat(
                                                                          'hh:mm a',
                                                                        ).format(
                                                                          localTime,
                                                                        );
                                                                        return Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                6,
                                                                            horizontal:
                                                                                10,
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
                                                                                    radius:
                                                                                        10,
                                                                                    backgroundColor:
                                                                                        Colors.blueAccent,
                                                                                    child: Text(
                                                                                      '${indexCall + 1}',
                                                                                      style: const TextStyle(
                                                                                        fontSize:
                                                                                            12,
                                                                                        color:
                                                                                            Colors.white,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  // The vertical line
                                                                                  Container(
                                                                                    width:
                                                                                        2,
                                                                                    height:
                                                                                        50,
                                                                                    color:
                                                                                        indexCall ==
                                                                                                callLogs.length -
                                                                                                    1
                                                                                            ? Colors.transparent
                                                                                            : Colors.grey,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(
                                                                                width:
                                                                                    12,
                                                                              ),
                                                                              // Right side content
                                                                              Expanded(
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.all(
                                                                                    10,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    color:
                                                                                        Colors.grey.shade100,
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      8,
                                                                                    ),
                                                                                    boxShadow: [
                                                                                      BoxShadow(
                                                                                        color:
                                                                                            Colors.grey.shade300,
                                                                                        blurRadius:
                                                                                            3,
                                                                                        offset: const Offset(
                                                                                          1,
                                                                                          1,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  child: Column(
                                                                                    crossAxisAlignment:
                                                                                        CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        call.notes ??
                                                                                            'No notes',
                                                                                        style: const TextStyle(
                                                                                          fontWeight:
                                                                                              FontWeight.w500,
                                                                                          fontSize:
                                                                                              14,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height:
                                                                                            4,
                                                                                      ),
                                                                                      Text(
                                                                                        'Duration: ${formattedTime ?? 'N/A'}',
                                                                                        style: const TextStyle(
                                                                                          fontSize:
                                                                                              12,
                                                                                          color:
                                                                                              Colors.grey,
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(
                                                                                        height:
                                                                                            2,
                                                                                      ),
                                                                                      Text(
                                                                                        'Date: ${formattedDate ?? 'N/A'}',
                                                                                        style: const TextStyle(
                                                                                          fontSize:
                                                                                              12,
                                                                                          color:
                                                                                              Colors.grey,
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
                                                                  : Text(
                                                                    'No Call Logs',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                        )
                                                        : SizedBox(
                                                          key: ValueKey(
                                                            'hiddenContainer',
                                                          ),
                                                          height: 0,
                                                        ),

                                                    // All meetings
                                                    leadProvider.allMeetingSHowHideIndex ==
                                                            index
                                                        ? // show all meetings
                                                        AnimatedSize(
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    400,
                                                              ),
                                                          curve:
                                                              Curves.easeInOut,
                                                          child:
                                                              meetings.isNotEmpty
                                                                  ? Container(
                                                                    width:
                                                                        double
                                                                            .infinity,

                                                                    decoration: BoxDecoration(
                                                                      color:
                                                                          Colors
                                                                              .transparent,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            15,
                                                                          ),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          blurRadius:
                                                                              6,
                                                                          spreadRadius:
                                                                              1,
                                                                          offset: Offset(
                                                                            0,
                                                                            3,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                      border: Border.all(
                                                                        color:
                                                                            kButtonColor2,
                                                                      ),
                                                                    ),
                                                                    child: Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                            10.0,
                                                                          ),
                                                                      child: ListView.separated(
                                                                        padding:
                                                                            EdgeInsets.all(
                                                                              0,
                                                                            ),
                                                                        shrinkWrap:
                                                                            true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemCount:
                                                                            meetings.length,
                                                                        itemBuilder: (
                                                                          context,
                                                                          indexMeet,
                                                                        ) {
                                                                          return MeetingCard(
                                                                            leadId:
                                                                                leadId,
                                                                            meeting:
                                                                                meetings[indexMeet],
                                                                            scale:
                                                                                MediaQuery.of(
                                                                                  context,
                                                                                ).textScaleFactor,
                                                                            leadProvider:
                                                                                leadProvider,
                                                                          );
                                                                        },
                                                                        separatorBuilder:
                                                                            (
                                                                              context,
                                                                              _,
                                                                            ) =>
                                                                                const Divider(),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  : Text(
                                                                    'No Meetings',
                                                                    style: TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .white,
                                                                    ),
                                                                  ),
                                                        )
                                                        : SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder: (context, index) {
                                            return SizedBox(height: 15);
                                          },
                                        ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  leadProvider.callLogFlag
                      ? AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(seconds: 1),
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
                                decoration: BoxDecoration(color: Colors.white),
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
                                        controller: callLogNoteController,
                                        decoration: InputDecoration(
                                          hintText: "ex : Not Attend...",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton(
                                        onPressed: () async {
                                          print(
                                            'Reason: ${leadProvider.leadIdForCallLog}',
                                          );
                                          if (callLogNoteController
                                              .text
                                              .isNotEmpty) {
                                            await leadProvider
                                                .leadAddcallLogsPro(
                                                  '',
                                                  leadProvider.leadIdForCallLog,
                                                  callLogNoteController.text
                                                      .toString(),
                                                );
                                            if (leadProvider.success != null) {
                                              leadProvider.callLogFlagPro();
                                              showSuccessDialog(
                                                context,
                                                "assets/images/successicons.png",
                                                "Success",
                                                "${leadProvider.success!.message}",
                                              );
                                              leadProvider.getLeadPro('');
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
                                          '${leadProvider.isLoading ? 'Loading.....' : 'Submit'}',
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
    );
  }
}

Widget _buildMeetingColumn({
  required String title,
  required String date,
  required String time,
  required double Function(double) scale,
}) {
  return Column(
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
  );
}

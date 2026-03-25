import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/screens/lead_screen/widget/add_to_client_popup.dart';
import 'package:wisdeals/presentation/screens/lead_screen/widget/validation_date_and_time.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/delete_custome_diloge.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/list_shimmer_effect.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/search_and_filter_field_widget.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({Key? key}) : super(key: key);

  @override
  _LeadListScreenState createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final ScrollController scrollcontrollers = ScrollController();
  // call log controller
  final TextEditingController callLogNoteController = TextEditingController();
  final TextEditingController callLogLanguageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollcontrollers.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLeadData();
    });
  }

  void _loadLeadData() async {
    final leadProvider = Provider.of<LeadProvider>(context, listen: false);

    leadProvider.clearCurrentPage();
    leadProvider.getFilterSelectedIndex('');
    // First load status
    await leadProvider.getLeadStatusPro();
    // Then load lead data
    await leadProvider.getLeadPro('', '', isRefresh: true);
    leadProvider.getLeadSourcePro();
    // Load customer profile
    leadProvider.getCustomerProfilePro();
  }

  void _scrollListener() {
    if (scrollcontrollers.position.pixels >=
        scrollcontrollers.position.maxScrollExtent - 100) {
      final leadProvider = Provider.of<LeadProvider>(context, listen: false);

      if (!leadProvider.isLoadingMore && leadProvider.hasMore) {
        print('listening  and index name${leadProvider.getFilterLeadIndex}');
        leadProvider.getLeadPro(
          '',
          leadProvider.getFilterLeadIndex,
          isRefresh: false,
        );
      }
    } else {
      print('no listening ');
    }
  }

  @override
  void dispose() {
    scrollcontrollers.dispose(); // ✅ Cancel scroll controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isTablet = constraints.maxWidth > 600;
              final bool isSmallScreen = constraints.maxWidth < 400;
              return Consumer<LeadProvider>(
                builder: (context, leadProvider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final failure = leadProvider.failure;
                    if (failure != null) {
                      if (failure is ClientFailure ||
                          failure is ServerFailure ||
                          failure is OtherFailureNon200) {
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
                          leadProvider.failure?.message ??
                          "No internet connection",
                      onRetry: () async {
                        await leadProvider.getLeadPro('', '', isRefresh: true);
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
                            SizedBox(height: 30),
                            CustomAppBarWidget(
                              title: "Leads",
                              drawerIconImage: false,
                            ),

                            SizedBox(height: 50),
                            // filter portion button
                            SearchAndFilterFieldWidget(
                              isTablet: isTablet,
                              title: "Search Leads...",
                              textEditingController: _searchController,
                              onChange: () async {
                                print(
                                  'onchange search variable ${_searchController.text}',
                                );
                                // leadProvider.searchLeadList(
                                //   _searchController.text,
                                // );
                                await leadProvider.getLeadPro(
                                  '${_searchController.text.toString()}',
                                  '',
                                  isRefresh: true,
                                );
                              },
                              onTap: () {},
                              showFilter: false,
                            ),
                            const SizedBox(height: 20),
                            // fav and add
                            FavAndAddWidget(isTablet: isTablet),
                            const SizedBox(height: 20),

                            // filter section container
                            (leadProvider.isLoadingLeadStatus ||
                                    leadProvider.filterStringLead.isEmpty)
                                ? shimmerFilterList(isTablet, 6)
                                : Container(
                                  width: double.infinity,
                                  height: isTablet ? 120 : 60,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        leadProvider.filterStringLead.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          leadProvider.getFilterSelectedIndex(
                                            '${leadProvider.filterStringLead[index]['statusid']}',
                                          );
                                          print(
                                            'assss : ${leadProvider.filterStringLead[index]['statusid']}',
                                          );
                                          leadProvider.getLeadPro(
                                            '',
                                            '${leadProvider.filterStringLead[index]['statusid']}',
                                            isRefresh: true,
                                          );
                                        },
                                        child: Container(
                                          height: isTablet ? 120 : 60,
                                          decoration: BoxDecoration(
                                            color:
                                                (leadProvider
                                                            .filterStringLead[index]['statusid']
                                                            .toString() ==
                                                        leadProvider
                                                            .getFilterLeadIndex)
                                                    ? Colors.black87
                                                    : kButtonColor2.withOpacity(
                                                      0.100,
                                                    ),
                                            border: Border.all(
                                              color: khome3rdSectionColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: Image.asset(
                                                    '${leadProvider.filterStringLead[index]['image']}',
                                                    width: isTablet ? 35 : 24,
                                                    height: isTablet ? 35 : 24,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '${leadProvider.filterStringLead[index]['title']}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: Colors.white,
                                                          fontSize:
                                                              isTablet
                                                                  ? 28
                                                                  : 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      SizedBox(width: 5),
                                                      Text(
                                                        ': ${leadProvider.filterStringLead[index]['count'] ?? '0'}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              "MontrealSerial",
                                                          color: kButtonColor2,
                                                          fontSize:
                                                              isTablet
                                                                  ? 28
                                                                  : 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
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
                            Expanded(
                              child: Container(
                                child:
                                    (leadProvider.isLoading ||
                                            leadProvider.isLoadingLeadStatus ||
                                            leadProvider.searchdLeadList ==
                                                null)
                                        ? const LeadCardShimmer(isTablet: false)
                                        : (leadProvider.searchdLeadList ==
                                                null ||
                                            leadProvider
                                                .searchdLeadList!
                                                .isEmpty)
                                        ? Expanded(
                                          child: RefreshIndicator(
                                            onRefresh: () async {
                                              _loadLeadData();
                                            },
                                            child: SingleChildScrollView(
                                              physics:
                                                  AlwaysScrollableScrollPhysics(),
                                              child: SizedBox(
                                                height:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.6,

                                                child: Center(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Lottie.asset(
                                                        'assets/json/noevents.json',
                                                        width: 150,
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      const Text(
                                                        'No Lead Found',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        : RefreshIndicator(
                                          onRefresh: () async {
                                            _loadLeadData();
                                          },
                                          child: ListView.separated(
                                            controller: scrollcontrollers,
                                            shrinkWrap: false,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            itemCount:
                                                leadProvider
                                                    .searchdLeadList!
                                                    .length +
                                                (leadProvider.isLoadingMore
                                                    ? 1
                                                    : 0),
                                            itemBuilder: (context, index) {
                                              // 🔥 SHOW LOAD MORE INDICATOR AT BOTTOM
                                              if (index ==
                                                  leadProvider
                                                      .searchdLeadList!
                                                      .length) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                    20,
                                                  ),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                );
                                              }
                                              final isExpanded =
                                                  leadProvider
                                                      .hideAndShowAddMeetingIndex ==
                                                  index;
                                              final leadId =
                                                  leadProvider
                                                      .searchdLeadList![index]
                                                      .id
                                                      .toString();
                                              final meetings =
                                                  leadProvider
                                                      .searchdLeadList![index]
                                                      .meetings;
                                              final callLogs =
                                                  leadProvider
                                                      .searchdLeadList![index]
                                                      .callLogs;
                                              final latestMeeting =
                                                  meetings!.isNotEmpty
                                                      ? meetings.reduce((a, b) {
                                                        final ad =
                                                            DateTime.parse(
                                                              a.date,
                                                            );
                                                        final bd =
                                                            DateTime.parse(
                                                              b.date,
                                                            );

                                                        if (ad.isAfter(bd))
                                                          return a;
                                                        if (ad.isAtSameMomentAs(
                                                          bd,
                                                        ))
                                                          return b; // equal date → b wins
                                                        return b; // bd is after
                                                      })
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
                                                                    '${leadProvider.searchdLeadList![index].companyName ?? ''}',
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
                                                                    '${leadProvider.searchdLeadList![index].clientName ?? ''}',
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
                                                                    '${leadProvider.searchdLeadList![index].customerProfile ?? ''}',
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
                                                                    '${leadProvider.searchdLeadList![index].leadStatus ?? ''}',
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
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                      // hide and show add meeting
                                                      AddMeetingShaduleWidget(
                                                        isExpanded: isExpanded,
                                                        index: index,
                                                        leadId:
                                                            leadProvider
                                                                .leadDataList![index]
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
                                                                  "Add to Client",
                                                              onTap: () {
                                                                final lead =
                                                                    leadProvider
                                                                        .searchdLeadList![index];

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
                                                                      // First load status
                                                                      leadProvider
                                                                          .getLeadStatusPro();
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

                                                                      _loadLeadData();
                                                                    }
                                                                  },
                                                                  textMain:
                                                                      "Convert to Client",
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
                                                              color:
                                                                  (leadProvider.searchdLeadList![index].callLogs ==
                                                                              null ||
                                                                          leadProvider
                                                                              .searchdLeadList![index]
                                                                              .callLogs!
                                                                              .isEmpty)
                                                                      ? Colors
                                                                          .transparent
                                                                      : Colors
                                                                          .green
                                                                          .withOpacity(
                                                                            0.3,
                                                                          ),
                                                            ),
                                                            const SizedBox(
                                                              width: 10,
                                                            ),
                                                            ContactSocialWidget(
                                                              image:
                                                                  "assets/images/calllognew.png",
                                                              text: "Call Log",
                                                              onTap: () {
                                                                print(
                                                                  'Call Log',
                                                                );
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
                                                                      leadProvider.getLeadPro(
                                                                        '',
                                                                        '',
                                                                        isRefresh:
                                                                            true,
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
                                                      const SizedBox(
                                                        height: 10,
                                                      ),

                                                      //*******************hide and show call logs with animation ************************** */
                                                      AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 450,
                                                            ),
                                                        switchInCurve:
                                                            Curves.easeOutExpo,
                                                        switchOutCurve:
                                                            Curves.easeInExpo,
                                                        transitionBuilder: (
                                                          child,
                                                          animation,
                                                        ) {
                                                          final fade =
                                                              Tween<double>(
                                                                begin: 0.0,
                                                                end: 1.0,
                                                              ).animate(
                                                                animation,
                                                              );

                                                          final slide = Tween<
                                                            Offset
                                                          >(
                                                            begin: const Offset(
                                                              0,
                                                              0.08,
                                                            ),
                                                            end: Offset.zero,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent: animation,
                                                              curve:
                                                                  Curves
                                                                      .easeOutCubic,
                                                            ),
                                                          );

                                                          final scale = Tween<
                                                            double
                                                          >(
                                                            begin: 0.97,
                                                            end: 1.0,
                                                          ).animate(
                                                            CurvedAnimation(
                                                              parent: animation,
                                                              curve:
                                                                  Curves
                                                                      .easeOutBack,
                                                            ),
                                                          );

                                                          return FadeTransition(
                                                            opacity: fade,
                                                            child: SlideTransition(
                                                              position: slide,
                                                              child:
                                                                  ScaleTransition(
                                                                    scale:
                                                                        scale,
                                                                    child:
                                                                        child,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                        child:
                                                            leadProvider.callLogShowHideIndex ==
                                                                    index
                                                                ? callLogs!
                                                                        .isNotEmpty
                                                                    ? Container(
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
                                                                            callLogs!.length,
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
                                                                            call.createdAt.toString(),
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
                                                                                          call.language ??
                                                                                              'No Language',
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
                                                                    : Container(
                                                                      width:
                                                                          double
                                                                              .infinity,

                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            Colors.transparent,
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
                                                                      child: Center(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(
                                                                            10.0,
                                                                          ),
                                                                          child: Text(
                                                                            'No Call Logs',
                                                                            style: TextStyle(
                                                                              color:
                                                                                  kButtonColor2,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                : SizedBox.shrink(),
                                                      ),

                                                      //*******************hide and show meeting with animation ************************** */
                                                      AnimatedSize(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 400,
                                                            ),
                                                        curve: Curves.easeInOut,
                                                        child:
                                                            // All meetings
                                                            leadProvider.allMeetingSHowHideIndex ==
                                                                    index
                                                                ? // show all meetings
                                                                meetings.isNotEmpty
                                                                    ? Container(
                                                                      width:
                                                                          double
                                                                              .infinity,

                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            Colors.transparent,
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
                                                                    : Container(
                                                                      width:
                                                                          double
                                                                              .infinity,

                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            Colors.transparent,
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
                                                                      child: Center(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(
                                                                            10.0,
                                                                          ),
                                                                          child: Text(
                                                                            'No Lead Meeting',
                                                                            style: TextStyle(
                                                                              color:
                                                                                  kButtonColor2,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                : SizedBox.shrink(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            separatorBuilder: (context, index) {
                                              return SizedBox(height: 15);
                                            },
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
                                            Text('Select Call Log Status...'),
                                            SizedBox(height: 10),
                                            TextFormField(
                                              readOnly: true,
                                              controller: callLogNoteController,
                                              decoration: InputDecoration(
                                                hintText: "ex : Interested...",
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20,
                                                      ), // 👈 change radius here
                                                ),

                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                    ),

                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: Colors.blue,
                                                        width: 2,
                                                      ),
                                                    ),
                                                suffixIcon: Icon(
                                                  leadProvider
                                                          .hideAndShowCallFollowUpForSelect
                                                      ? Icons
                                                          .arrow_drop_up_outlined
                                                      : Icons
                                                          .arrow_drop_down_outlined,
                                                ),
                                              ),
                                              onTap: () {
                                                print('Interested');
                                                leadProvider
                                                    .hideAndShowCallFollowUpForSelectPro();
                                                leadProvider
                                                    .getLeadCallNotePro();
                                              },
                                            ),
                                            const SizedBox(height: 5),
                                            AnimatedContainer(
                                              duration: Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              height:
                                                  leadProvider
                                                          .hideAndShowCallFollowUpForSelect
                                                      ? 140
                                                      : 0,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                boxShadow:
                                                    leadProvider
                                                            .hideAndShowCallFollowUpForSelect
                                                        ? [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.05,
                                                                ),
                                                            blurRadius: 8,
                                                            offset: Offset(
                                                              0,
                                                              3,
                                                            ),
                                                          ),
                                                        ]
                                                        : [],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child:
                                                    leadProvider
                                                            .hideAndShowCallFollowUpForSelect
                                                        ? (leadProvider
                                                                    .isLoadingCallNotes ||
                                                                leadProvider
                                                                        .getLeadCallNotes ==
                                                                    null)
                                                            ? Center(
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                            : (leadProvider
                                                                    .isLoadingCallNotes ||
                                                                leadProvider
                                                                        .getLeadCallNotes ==
                                                                    null)
                                                            ? Center(
                                                              child: Text(
                                                                'Status Empty',
                                                              ),
                                                            )
                                                            : ListView.separated(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              itemCount:
                                                                  leadProvider
                                                                      .getLeadCallNotes!
                                                                      .length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                final data =
                                                                    leadProvider
                                                                        .getLeadCallNotes![index];
                                                                final isSelected =
                                                                    leadProvider
                                                                        .selectedCallFollowUpId ==
                                                                    data.id; // 👈 key line
                                                                return InkWell(
                                                                  onTap: () {
                                                                    leadProvider.selectCallFolowUp(
                                                                      data.id ??
                                                                          '',
                                                                      data.title ??
                                                                          '',
                                                                    );
                                                                    callLogNoteController
                                                                            .text =
                                                                        leadProvider
                                                                            .selectedCallFollowUpName ??
                                                                        '';
                                                                    leadProvider
                                                                        .hideAndShowCallFollowUpForSelectPro();
                                                                    if (leadProvider
                                                                            .selectedCallLanguageName!
                                                                            .toLowerCase() !=
                                                                        "language") {
                                                                      print(
                                                                        '0000000000000000000000000000000',
                                                                      );
                                                                      callLogLanguageController
                                                                          .text = '';
                                                                      leadProvider
                                                                          .clearWhenLanguageNotselected();
                                                                    }
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          12,
                                                                    ),
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(
                                                                          Icons
                                                                              .check_circle,
                                                                          size:
                                                                              18,
                                                                          color:
                                                                              isSelected
                                                                                  ? Colors.green
                                                                                  : Colors.grey,
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                          child: Text(
                                                                            data.title ??
                                                                                '',
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  14,
                                                                              fontWeight:
                                                                                  FontWeight.w500,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              separatorBuilder:
                                                                  (
                                                                    _,
                                                                    __,
                                                                  ) => Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          16,
                                                                    ),
                                                                    child: Divider(
                                                                      color:
                                                                          Colors
                                                                              .grey
                                                                              .shade200,
                                                                      height: 1,
                                                                    ),
                                                                  ),
                                                            )
                                                        : null,
                                              ),
                                            ),

                                            SizedBox(height: 10),
                                            (leadProvider.selectedCallFollowUpName ??
                                                        '')
                                                    .toLowerCase()
                                                    .contains("language")
                                                ? Text('Select Call Language')
                                                : SizedBox.shrink(),
                                            // select language
                                            SizedBox(height: 10),

                                            (leadProvider.selectedCallFollowUpName ??
                                                        '')
                                                    .toLowerCase()
                                                    .contains("language")
                                                ? TextFormField(
                                                  readOnly: true,
                                                  controller:
                                                      callLogLanguageController,
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        "ex : Hindi,English...",
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                20,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color:
                                                                    Colors.blue,
                                                                width: 2,
                                                              ),
                                                        ),
                                                    suffixIcon: Icon(
                                                      leadProvider
                                                              .hideAndShowCallFollowUpForSelect
                                                          ? Icons
                                                              .arrow_drop_up_outlined
                                                          : Icons
                                                              .arrow_drop_down_outlined,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    print('Language clicked');
                                                    leadProvider
                                                        .hideAndShowCallLanguagePro();
                                                    leadProvider
                                                        .getLeadCallLanguagePro();
                                                  },
                                                )
                                                : SizedBox(),
                                            const SizedBox(height: 5),

                                            (leadProvider.selectedCallFollowUpName ??
                                                        '')
                                                    .toLowerCase()
                                                    .contains("language")
                                                ? AnimatedContainer(
                                                  duration: Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                  height:
                                                      leadProvider
                                                              .hideAndShowCallLanguage
                                                          ? 140
                                                          : 0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                    boxShadow:
                                                        leadProvider
                                                                .hideAndShowCallLanguage
                                                            ? [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                      0.05,
                                                                    ),
                                                                blurRadius: 8,
                                                                offset: Offset(
                                                                  0,
                                                                  3,
                                                                ),
                                                              ),
                                                            ]
                                                            : [],
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    child:
                                                        leadProvider
                                                                .hideAndShowCallLanguage
                                                            ? (leadProvider
                                                                        .isLoadingCallNotes ||
                                                                    leadProvider
                                                                            .getLeadCallNotes ==
                                                                        null)
                                                                ? Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                )
                                                                : (leadProvider
                                                                        .isLoadingCallNotes ||
                                                                    leadProvider
                                                                            .getLeadCallNotes ==
                                                                        null)
                                                                ? Center(
                                                                  child: Text(
                                                                    'Status Empty',
                                                                  ),
                                                                )
                                                                : ListView.separated(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                  itemCount:
                                                                      leadProvider
                                                                          .getLeadCallLanguage!
                                                                          .length,
                                                                  itemBuilder: (
                                                                    context,
                                                                    index,
                                                                  ) {
                                                                    final dataLang =
                                                                        leadProvider
                                                                            .getLeadCallLanguage![index];
                                                                    final isSelected =
                                                                        leadProvider
                                                                            .selectedCallLanguageId ==
                                                                        dataLang
                                                                            .id; // 👈 key line
                                                                    return InkWell(
                                                                      onTap: () {
                                                                        leadProvider.selectCallLanguagePro(
                                                                          dataLang.id ??
                                                                              '',
                                                                          dataLang.name ??
                                                                              '',
                                                                        );
                                                                        callLogLanguageController.text =
                                                                            leadProvider.selectedCallLanguageName ??
                                                                            '';
                                                                        leadProvider
                                                                            .hideAndShowCallLanguagePro();
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              16,
                                                                          vertical:
                                                                              12,
                                                                        ),
                                                                        child: Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons.check_circle,
                                                                              size:
                                                                                  18,
                                                                              color:
                                                                                  isSelected
                                                                                      ? Colors.green
                                                                                      : Colors.grey,
                                                                            ),
                                                                            SizedBox(
                                                                              width:
                                                                                  10,
                                                                            ),
                                                                            Expanded(
                                                                              child: Text(
                                                                                dataLang.name ??
                                                                                    '',
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      14,
                                                                                  fontWeight:
                                                                                      FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  separatorBuilder:
                                                                      (
                                                                        _,
                                                                        __,
                                                                      ) => Padding(
                                                                        padding: const EdgeInsets.symmetric(
                                                                          horizontal:
                                                                              16,
                                                                        ),
                                                                        child: Divider(
                                                                          color:
                                                                              Colors.grey.shade200,
                                                                          height:
                                                                              1,
                                                                        ),
                                                                      ),
                                                                )
                                                            : null,
                                                  ),
                                                )
                                                : SizedBox.shrink(),
                                            SizedBox(height: 10),
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              onTap:
                                                  leadProvider.isLoading
                                                      ? null
                                                      : () async {
                                                        /// ✅ 1. Validate Status (Follow Up)
                                                        if (leadProvider
                                                                .selectedCallFollowUpId ==
                                                            null) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Please select call status",
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        /// ✅ 2. Check if Language Required
                                                        bool
                                                        isLanguageRequired =
                                                            leadProvider
                                                                .selectedCallFollowUpName
                                                                ?.toLowerCase()
                                                                .contains(
                                                                  "language",
                                                                ) ??
                                                            false;

                                                        if (isLanguageRequired &&
                                                            callLogLanguageController
                                                                .text
                                                                .isEmpty) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Please select language",
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        /// ✅ 3. Optional Note Validation (your existing one)
                                                        if (callLogNoteController
                                                            .text
                                                            .isEmpty) {
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                "Please select status",
                                                              ),
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        /// ✅ API CALL
                                                        await leadProvider.leadAddcallLogsPro(
                                                          '',
                                                          leadProvider
                                                              .leadIdForCallLog,
                                                          leadProvider
                                                              .selectedCallFollowUpId
                                                              .toString(),
                                                          leadProvider
                                                                  .selectedCallLanguageId
                                                                  ?.toString() ??
                                                              '',
                                                        );

                                                        /// ✅ SUCCESS
                                                        if (leadProvider
                                                                .success !=
                                                            null) {
                                                          leadProvider
                                                              .callLogFlagPro();

                                                          showSuccessDialog(
                                                            context,
                                                            "assets/images/successicons.png",
                                                            "Success",
                                                            "${leadProvider.success!.message}",
                                                          );

                                                          callLogNoteController
                                                              .text = '';
                                                          leadProvider
                                                              .clearSelectdData();

                                                          leadProvider
                                                              .getLeadPro(
                                                                '',
                                                                '',
                                                                isRefresh: true,
                                                              );
                                                        }
                                                      },

                                              child: Container(
                                                height: 50,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  gradient:
                                                      leadProvider.isLoading
                                                          ? LinearGradient(
                                                            colors: [
                                                              Colors
                                                                  .grey
                                                                  .shade400,
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                            ],
                                                          )
                                                          : LinearGradient(
                                                            colors: [
                                                              Color(0xFF4CAF50),
                                                              Color(0xFF2E7D32),
                                                            ], // 👈 green gradient
                                                          ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 6,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child:
                                                    leadProvider.isLoading
                                                        ? SizedBox(
                                                          height: 22,
                                                          width: 22,
                                                          child:
                                                              CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                        )
                                                        : Text(
                                                          "Submit",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
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
        ],
      ),
    );
  }
}

Widget shimmerFilterList(bool isTablet, int itemCount) {
  return SizedBox(
    height: isTablet ? 120 : 60, // height of each card row
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: shimmerFilterCard(isTablet),
        );
      },
    ),
  );
}

Widget shimmerFilterCard(bool isTablet) {
  return SizedBox(
    child: Container(
      width: isTablet ? 160 : 120,
      height: isTablet ? 120 : 60,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              width: isTablet ? 35 : 24,
              height: isTablet ? 35 : 24,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: isTablet ? 80 : 50,
                  height: isTablet ? 25 : 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  width: isTablet ? 40 : 20,
                  height: isTablet ? 25 : 12,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class AddMeetingShaduleWidget extends StatefulWidget {
  final bool isExpanded;
  final int index;
  final String? leadId;
  final LeadProvider provider;
  final TextEditingController dateController;
  final TextEditingController timeFromController;
  final TextEditingController timeToController;
  final TextEditingController noteController;
  const AddMeetingShaduleWidget({
    super.key,
    required this.isExpanded,
    required this.index,
    required this.provider,
    required this.dateController,
    required this.timeFromController,
    required this.timeToController,
    required this.noteController,
    required this.leadId,
  });

  @override
  State<AddMeetingShaduleWidget> createState() =>
      _AddMeetingShaduleWidgetState();
}

class _AddMeetingShaduleWidgetState extends State<AddMeetingShaduleWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      print('hiiiiiii : ${widget.provider.selectedMeetingDate ?? ''}');
      widget.dateController.text = widget.provider.selectedMeetingDate ?? '';
      widget.timeFromController.text = widget.provider.selectedTimeFrom ?? '';
      widget.timeToController.text = widget.provider.selectedTimeTo ?? '';
    });
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: widget.isExpanded ? 450 : 0, // smoothly expands/collapses
      decoration: BoxDecoration(
        color: const Color(0xFFEDFCC5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child:
              widget.isExpanded
                  ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            widget.provider.hideAndShowAddLeadMeeting(
                              widget.index,
                            );
                          },
                          child: Icon(Icons.close),
                        ),
                        Container(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select Date'),
                              SizedBox(height: 10),
                              TextFormField(
                                controller: widget.dateController,
                                onTap: () {
                                  widget.provider.setSelectedDate(context);
                                },
                                readOnly: true, // 🔒 locks typing
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
                                    Text('Time From'),
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
                                    print('${widget.leadId.toString()}');
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
                                      await widget.provider.leadAddMeetingPro(
                                        widget.leadId.toString(),
                                        widget.dateController.text.toString(),
                                        widget.timeFromController.text
                                            .toString(),
                                        widget.timeToController.text.toString(),
                                        widget.noteController.text.toString(),
                                      );

                                      if (widget.provider.success != null) {
                                        widget.provider
                                            .hideAndShowAddLeadMeeting(
                                              widget.index,
                                            );
                                        widget.provider.getLeadPro(
                                          '',
                                          '',
                                          isRefresh: true,
                                        );
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
                              padding: const EdgeInsets.all(15),
                              child:
                                  widget.provider.isLoadingAddMeeting
                                      ? Text(
                                        'Loading.........',
                                        style: TextStyle(color: Colors.white),
                                      )
                                      : Text('Add Meeting'),
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

class FavAndAddWidget extends StatelessWidget {
  final bool isTablet;
  const FavAndAddWidget({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Container(
        //   height: isTablet ? 60 : 45,
        //   width: isTablet ? 60 : 45,
        //   decoration: BoxDecoration(
        //     // borderRadius: BorderRadius.all()
        //     border: Border.all(color: Colors.grey),
        //     shape: BoxShape.circle,
        //   ),
        //   child: Center(
        //     child: Image.asset(
        //       'assets/images/star.png',
        //       width: isTablet ? 30 : 16,
        //       height: isTablet ? 30 : 16,
        //     ),
        //   ),
        // ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/leadaddscreen');
          },
          child: Container(
            height: isTablet ? 60 : 45,
            width: isTablet ? 60 : 45,
            decoration: BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.all()
              border: Border.all(color: Colors.grey),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset(
                'assets/images/pluscircle.png',
                width: isTablet ? 30 : 16,
                height: isTablet ? 30 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ContactSocialWidget extends StatelessWidget {
  final String? image;
  final VoidCallback onTap;
  final String? text;
  final Color? color;
  const ContactSocialWidget({
    super.key,
    required this.image,
    required this.text,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // width: 80,
        // height: 65,
        decoration: BoxDecoration(
          color: color,
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

class MeetingCard extends StatefulWidget {
  final Meeting meeting;
  final String? leadId;
  final double scale;
  final LeadProvider leadProvider;
  const MeetingCard({
    Key? key,
    required this.meeting,
    required this.leadId,
    required this.scale,
    required this.leadProvider,
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

                  print('lead id ${widget.leadId.toString()}');
                  print('meeting id ${widget.meeting.id.toString()}');
                  showDeleteConfirmationDialog(
                    context,
                    onDelete: () async {
                      await widget.leadProvider.deleteLeadMeetingPro(
                        widget.meeting.id.toString(),
                      );
                      if (widget.leadProvider.success != null) {
                        Navigator.pop(context);
                        showSuccessDialog(
                          context,
                          "assets/images/successicons.png",
                          "Success",
                          widget.leadProvider.success!.message.toString(),
                        );
                        widget.leadProvider.getLeadPro('', '', isRefresh: true);
                      }
                    },
                    textMain: "Delete Meeting",
                    provider: widget.leadProvider,
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

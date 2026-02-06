import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/presentation/provider/meeting_provider.dart';
import 'package:wisdeals/presentation/screens/meeting/client_meeting_list_tab.dart';
import 'package:wisdeals/presentation/screens/meeting/lead_meeting_list_tab.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/search_and_filter_field_widget.dart';

class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({Key? key}) : super(key: key);

  @override
  _MeetingListScreenState createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<MeetingProvider>(context, listen: false);
      provider.getFilterSection();
      provider.getClientsInmeetingPro();
      provider.getLeadMeetingPro('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmallScreen = constraints.maxWidth < 400;
          return Consumer<MeetingProvider>(
            builder: (context, meetingProvider, _) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const CustomAppBarWidget(
                      title: "Meetings",
                      drawerIconImage: false,
                    ),
                    const SizedBox(height: 40),

                    // 🔍 Search field
                    SearchAndFilterFieldWidget(
                      isTablet: isTablet,
                      title: "Search Meetings...",
                      textEditingController: _searchController,
                      onChange: () {
                        meetingProvider.searchClientList(
                          _searchController.text.toString(),
                        );
                        meetingProvider.searchLeadList(
                          _searchController.text.toString(),
                        );
                      },
                      onTap: () {},
                      showFilter: false,
                    ),

                    const SizedBox(height: 20),

                    // // 🏷️ Filter Chips
                    // SizedBox(
                    //   height: 50,
                    //   child: ListView.separated(
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: meetingProvider.filterString.length,
                    //     itemBuilder: (context, index) {
                    //       return Container(
                    //         decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.circular(9),
                    //           gradient: const LinearGradient(
                    //             colors: [Color(0xFFE8FFAD), Color(0xFF8B9968)],
                    //             begin: Alignment.topLeft,
                    //             end: Alignment.bottomRight,
                    //           ),
                    //         ),
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(10),
                    //           child: Center(
                    //             child: Text(
                    //               meetingProvider.filterString[index],
                    //               style: TextStyle(
                    //                 fontFamily: "MontrealSerial",
                    //                 color: Colors.black,
                    //                 fontSize: isTablet ? 18 : 12,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     separatorBuilder: (_, __) => const SizedBox(width: 10),
                    //   ),
                    // ),
                    const SizedBox(height: 20),

                    // 🧭 Tabs: Clients | Leads
                    DefaultTabController(
                      length: 2,
                      child: Expanded(
                        child: Column(
                          children: [
                            TabBar(
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD1F66F),
                                    Color(0xFF8B9968),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelColor: Colors.black,
                              unselectedLabelColor: Colors.white,
                              labelStyle: TextStyle(
                                fontFamily: "MontrealSerial",
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 18 : 14,
                              ),
                              tabs: const [
                                Tab(text: "Clients"),
                                Tab(text: "Leads"),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Tab views
                            Expanded(
                              child: TabBarView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  ClientMeetingListTab(),
                                  LeadMeetingListTab(),
                                ],
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
          );
        },
      ),
    );
  }

  // /// Reusable meeting card list
  // Widget _buildMeetingListView(
  //   BuildContext context, {
  //   required bool isTablet,
  //   required String title,
  // }) {
  //   return SingleChildScrollView(
  //     physics: const BouncingScrollPhysics(),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontFamily: "MontrealSerial",
  //             color: Colors.white,
  //             fontSize: 22,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 15),

  //         // Meeting cards
  //         ListView.separated(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: 10,
  //           itemBuilder: (context, index) {
  //             return Container(
  //               width: double.infinity,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 border: Border.all(color: Colors.white.withOpacity(0.2)),
  //                 gradient: LinearGradient(
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                   colors: [
  //                     Colors.white.withOpacity(0.20),
  //                     Colors.white.withOpacity(0.05),
  //                   ],
  //                 ),
  //               ),
  //               child: Padding(
  //                 padding: const EdgeInsets.all(15),
  //                 child: Column(
  //                   children: [
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Text(
  //                               'ABC Company Ltd',
  //                               style: TextStyle(
  //                                 fontFamily: "MontrealSerial",
  //                                 color: Colors.white,
  //                                 fontSize: isTablet ? 28 : 16,
  //                                 fontWeight: FontWeight.w700,
  //                               ),
  //                             ),
  //                             Text(
  //                               'Premium customer',
  //                               style: TextStyle(
  //                                 fontFamily: "MontrealSerial",
  //                                 color: const Color(0xFFD1F66F),
  //                                 fontSize: isTablet ? 16 : 12,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                         InkWell(
  //                           onTap: () {
  //                             Navigator.pushNamed(
  //                               context,
  //                               '/ordersingleviewscreen',
  //                             );
  //                           },
  //                           child: Column(
  //                             children: [
  //                               Image.asset(
  //                                 'assets/images/clientlistarrow.png',
  //                                 width: isTablet ? 60 : 40,
  //                               ),
  //                               const SizedBox(height: 8),
  //                               Text(
  //                                 'Add meeting',
  //                                 style: TextStyle(
  //                                   fontFamily: "MontrealSerial",
  //                                   color: Colors.white,
  //                                   fontSize: isTablet ? 16 : 12,
  //                                   fontWeight: FontWeight.w600,
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     const SizedBox(height: 20),

  //                     // Old and Next Visit
  //                     Row(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         _buildVisitColumn(
  //                           title: 'Old Visit',
  //                           date: 'JUN-21-2025',
  //                           time: '2:30 PM - 6:00 PM',
  //                           isTablet: isTablet,
  //                         ),
  //                         const SizedBox(width: 25),
  //                         _buildVisitColumn(
  //                           title: 'Next Meeting',
  //                           date: 'JUL-05-2025',
  //                           time: '10:00 AM - 1:00 PM',
  //                           isTablet: isTablet,
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //           separatorBuilder: (_, __) => const SizedBox(height: 15),
  //         ),
  //         const SizedBox(height: 100),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildVisitColumn({
  //   required String title,
  //   required String date,
  //   required String time,
  //   required bool isTablet,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         title,
  //         style: TextStyle(
  //           fontFamily: "MontrealSerial",
  //           color: Colors.white,
  //           fontSize: isTablet ? 18 : 14,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       const SizedBox(height: 5),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Image.asset('assets/images/clock.png', width: isTablet ? 22 : 16),
  //           const SizedBox(width: 5),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 date,
  //                 style: TextStyle(
  //                   fontFamily: "MontrealSerial",
  //                   color: Colors.white,
  //                   fontSize: isTablet ? 16 : 13,
  //                 ),
  //               ),
  //               Text(
  //                 time,
  //                 style: TextStyle(
  //                   fontFamily: "MontrealSerial",
  //                   color: Colors.white,
  //                   fontSize: isTablet ? 16 : 13,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }
}

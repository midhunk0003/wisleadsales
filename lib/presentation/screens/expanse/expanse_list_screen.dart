import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/list_shimmer_effect.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/search_and_filter_field_widget.dart';

class ExpanseListScreen extends StatefulWidget {
  const ExpanseListScreen({Key? key}) : super(key: key);

  @override
  _ExpanseListScreenState createState() => _ExpanseListScreenState();
}

class _ExpanseListScreenState extends State<ExpanseListScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialData();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final provider = Provider.of<ExpanseProvider>(context, listen: false);
      provider.selectFilterStatus('${''}');
      provider.getFilterExpansePro();
      await provider.getExpanseTravelTypePro();
      await provider.getExpansePaymentModePro();
      await provider.getExpansePro('');
      provider.clearNetworkimage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmallScreen = constraints.maxWidth < 400;
          return Consumer<ExpanseProvider>(
            builder: (context, expanseProvider, _) {
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
                    SizedBox(height: 30),
                    CustomAppBarWidget(
                      title: "Expense",
                      drawerIconImage: false,
                    ),
                    SizedBox(height: 50),
                    // filter portion button
                    SearchAndFilterFieldWidget(
                      isTablet: isTablet,
                      title: "Search Expense...",
                      textEditingController: searchController,
                      onChange: () {
                        print(
                          'onchange search variable ${searchController.text}',
                        );
                        expanseProvider.searchLeadList(
                          searchController.text.toString(),
                        );
                      },
                      onTap: () {},
                      showFilter: false,
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: Container(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _initialData();
                          },
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                // fav and add
                                FavAndAddWidget(isTablet: isTablet),
                                const SizedBox(height: 20),
                                // filter section
                                Container(
                                  width: double.infinity,
                                  height: isTablet ? 120 : 70,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        expanseProvider
                                            .filterExpanseData
                                            .length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(0),
                                        child: InkWell(
                                          onTap: () {
                                            print(
                                              'status : ${expanseProvider.filterExpanseData[index]['status']}',
                                            );
                                            expanseProvider.selectFilterStatus(
                                              expanseProvider
                                                  .filterExpanseData[index]['status'],
                                            );
                                            expanseProvider.getExpansePro(
                                              expanseProvider.selectedStatus,
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  (expanseProvider
                                                              .selectedStatus ==
                                                          expanseProvider
                                                              .filterExpanseData[index]['status'])
                                                      ? Colors.black
                                                      : khome3rdSectionColor
                                                          .withOpacity(0.100),
                                              border: Border.all(
                                                color: khome3rdSectionColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${expanseProvider.filterExpanseData[index]['amount']}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "MontrealSerial",
                                                        color:
                                                            (expanseProvider
                                                                        .selectedStatus ==
                                                                    expanseProvider
                                                                        .filterExpanseData[index]['status'])
                                                                ? Colors.white
                                                                : Colors
                                                                    .white60,
                                                        fontSize:
                                                            isTablet ? 28 : 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 3),
                                                  Expanded(
                                                    child: Text(
                                                      '${expanseProvider.filterExpanseData[index]['title']}',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "MontrealSerial",
                                                        color:
                                                            (expanseProvider
                                                                        .selectedStatus ==
                                                                    expanseProvider
                                                                        .filterExpanseData[index]['status'])
                                                                ? Colors.white
                                                                : Colors
                                                                    .white60,
                                                        fontSize:
                                                            isTablet ? 28 : 12,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                // list
                                (expanseProvider.isLoading ||
                                        expanseProvider.expanseSearchList ==
                                            null)
                                    ? const LeadCardShimmer(isTablet: false)
                                    : (expanseProvider.expanseSearchList ==
                                            null ||
                                        expanseProvider
                                            .expanseSearchList!
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
                                            'No Expense Found',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : ListView.separated(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          expanseProvider
                                              .expanseSearchList!
                                              .length,
                                      itemBuilder: (context, index) {
                                        final expanseDatas =
                                            expanseProvider
                                                .expanseSearchList![index];
                                        final date =
                                            expanseDatas.createdAt.toString();

                                        final formateDate = DateFormat(
                                          'MMM d, yyyy',
                                        ).format(DateTime.parse(date));

                                        print('date : ${formateDate}');
                                        return Container(
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
                                            padding: const EdgeInsets.all(15),
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
                                                        decoration: BoxDecoration(
                                                          // color: Colors.deepOrange,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,

                                                          children: [
                                                            Text(
                                                              '${expanseDatas.companyName ?? 'N/A'}',
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
                                                              '${expanseDatas.clientName ?? 'N/A'}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "MontrealSerial",
                                                                color:
                                                                    const Color(
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
                                                            isTablet ? 20 : 10,
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          // color: Colors.blue,
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                color: expanseProvider
                                                                    .changeStatusColor(
                                                                      expanseDatas
                                                                          .status,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      8.0,
                                                                    ),
                                                                child: Text(
                                                                  '${expanseDatas.status ?? 'N/A'}',
                                                                  style: TextStyle(
                                                                    color:
                                                                        Colors
                                                                            .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  isTablet
                                                                      ? 10
                                                                      : 8,
                                                            ),
                                                            Text(
                                                              '${formateDate ?? 'N/A'}',
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
                                                            'Expense Type : ${expanseDatas.expenseType ?? 'N/A'}',
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
                                                          Text(
                                                            'Amount : ${expanseDatas.amount ?? 'N/A'}',
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
                                                          Text(
                                                            'Payment Mode : ${expanseDatas.paymentMode ?? 'N/A'}',
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
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          // // time
                                                          // Row(
                                                          //   crossAxisAlignment:
                                                          //       CrossAxisAlignment
                                                          //           .start,
                                                          //   children: [
                                                          //     Image.asset(
                                                          //       'assets/images/clock.png',
                                                          //       width:
                                                          //           isTablet
                                                          //               ? 25
                                                          //               : 17,
                                                          //       height:
                                                          //           isTablet
                                                          //               ? 25
                                                          //               : 17,
                                                          //     ),
                                                          //     SizedBox(
                                                          //       width:
                                                          //           isTablet
                                                          //               ? 10
                                                          //               : 5,
                                                          //     ),
                                                          //     Column(
                                                          //       crossAxisAlignment:
                                                          //           CrossAxisAlignment
                                                          //               .start,
                                                          //       children: [
                                                          //         Text(
                                                          //           'JUN-21-2025',
                                                          //           style: TextStyle(
                                                          //             fontFamily:
                                                          //                 "MontrealSerial",
                                                          //             color:
                                                          //                 Colors
                                                          //                     .white,
                                                          //             fontSize:
                                                          //                 isTablet
                                                          //                     ? 18
                                                          //                     : 14,
                                                          //             fontWeight:
                                                          //                 FontWeight
                                                          //                     .w500,
                                                          //           ),
                                                          //         ),
                                                          //         Text(
                                                          //           '2:30 PM - 6:00 PM',
                                                          //           style: TextStyle(
                                                          //             fontFamily:
                                                          //                 "MontrealSerial",
                                                          //             color:
                                                          //                 Colors
                                                          //                     .white,
                                                          //             fontSize:
                                                          //                 isTablet
                                                          //                     ? 18
                                                          //                     : 14,
                                                          //             fontWeight:
                                                          //                 FontWeight
                                                          //                     .w500,
                                                          //           ),
                                                          //         ),
                                                          //       ],
                                                          //     ),
                                                          //   ],
                                                          // ),
                                                        ],
                                                      ),

                                                      // update expense
                                                      (expanseDatas.status ==
                                                              'Pending')
                                                          ? InkWell(
                                                            onTap: () {
                                                              Navigator.pushNamed(
                                                                context,
                                                                '/updateexpansescreen',
                                                                arguments:
                                                                    expanseDatas,
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
                                                                    'Update Expense',
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          : SizedBox.shrink(),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 15),
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

class FavAndAddWidget extends StatelessWidget {
  final bool isTablet;
  const FavAndAddWidget({super.key, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/addexpansescreen');
          },
          child: Container(
            height: isTablet ? 60 : 45,
            width: isTablet ? 60 : 45,
            decoration: BoxDecoration(
              color: Colors.transparent,
              // borderRadius: BorderRadius.all()
              border: Border.all(color: kButtonColor2),
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

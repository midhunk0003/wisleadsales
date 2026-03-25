import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/business_list_model/business_list_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/main.dart';
import 'package:wisdeals/presentation/provider/business_provider.dart';
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

class BusinessScreen extends StatefulWidget {
  const BusinessScreen({Key? key}) : super(key: key);

  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final ScrollController scrollcontrollers = ScrollController();
  // call log controller
  final TextEditingController callLogNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    scrollcontrollers.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialData();
    });
  }

  void _initialData() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final DateTime now = DateTime.now();

    /// 👉 Get current year
    final String currentYear = businessProvider.selectedYear.toString();

    /// 👉 Get current month (2 digit)

    final String currentMonth = now.month.toString().padLeft(2, '0');
    print('year : ${currentYear}');
    print('month......... : ${currentMonth}');
    businessProvider.getFilterSelectedIndexNamePro('');
    businessProvider.resetDateSelection();
    businessProvider.getAllBusinessListPro(
      currentMonth,
      currentYear,
      '',
      '',
      isRefresh: true,
    );
  }

  void _scrollListener() {
    if (scrollcontrollers.position.pixels >=
        scrollcontrollers.position.maxScrollExtent - 100) {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );

      if (!businessProvider.isLoadingMore && businessProvider.hasMore) {
        print('listening  and index name');
        final DateTime now = DateTime.now();

        /// 👉 Get current year
        final String currentYear = businessProvider.selectedYear.toString();

        /// 👉 Get current month (2 digit)
        final String currentMonth = now.month.toString().padLeft(2, '0');
        businessProvider.getAllBusinessListPro(
          currentMonth,
          currentYear,
          '',
          '',
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
              return Consumer<BusinessProvider>(
                builder: (context, businessProvider, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final failure = businessProvider.failure;
                    if (failure != null) {
                      if (failure is ClientFailure ||
                          failure is ServerFailure ||
                          failure is OtherFailureNon200) {
                        failureDilogeWidget(
                          context,
                          'assets/images/failicon.png',
                          "Failed",
                          '${failure.message}',
                          provider: businessProvider,
                        );
                      }
                    }
                  });
                  if (businessProvider.failure is NetworkFailure) {
                    return NetWorkRetry(
                      failureMessage:
                          businessProvider.failure?.message ??
                          "No internet connection",
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
                            SizedBox(height: 30),
                            CustomAppBarWidget(
                              title: "Business",
                              drawerIconImage: false,
                            ),

                            SizedBox(height: 50),
                            // filter portion button
                            SearchAndFilterFieldWidget(
                              isTablet: isTablet,
                              title: "Search Business...",
                              textEditingController: _searchController,
                              onChange: () async {
                                print(
                                  'onchange search variable ${_searchController.text}',
                                );
                                await businessProvider.getAllBusinessListPro(
                                  '',
                                  '',
                                  '',
                                  _searchController.text.toString(),
                                  isRefresh: true,
                                );
                                // businessProvider.searchLeadList(
                                //   _searchController.text,
                                // );
                              },
                              onTap: () {},
                              showFilter: false,
                            ),
                            const SizedBox(height: 20),
                            // fav and add
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      /// 📅 Month Dropdown (Short form)
                                      Expanded(
                                        child: CustomListDropdown<String>(
                                          label: "Month",
                                          icon: Icons.calendar_month_outlined,
                                          value: businessProvider.selectedMonth,
                                          items:
                                              businessProvider
                                                  .months, // ["Jan","Feb","Mar"...]
                                          onSelected: (value) async {},
                                          showHideTap: () {
                                            businessProvider
                                                .showMonthMainScreenPro();
                                          },
                                          iconArrow:
                                              businessProvider
                                                      .showMonthInMainScreen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                        ),
                                      ),

                                      const SizedBox(width: 8),

                                      /// 📆 Year Dropdown
                                      Expanded(
                                        child: CustomListDropdown<int>(
                                          label: "Year",
                                          icon: Icons.date_range_outlined,
                                          value: int.tryParse(
                                            businessProvider.selectedYear
                                                .toString(),
                                          ),
                                          items: businessProvider.years,
                                          onSelected: (value) async {},
                                          showHideTap: () {
                                            businessProvider
                                                .showYearMainScreenPro();
                                          },
                                          iconArrow:
                                              businessProvider
                                                      .showyearInMainScreen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 12),
                                FavAndAddWidget(isTablet: isTablet),
                              ],
                            ),
                            SizedBox(height: 10),
                            // expand month and year portion
                            if (businessProvider.showMonthInMainScreen ||
                                businessProvider.showyearInMainScreen)
                              Row(
                                children: [
                                  /// Month List
                                  Expanded(
                                    child:
                                        businessProvider.showMonthInMainScreen
                                            ? _DropdownList<String>(
                                              items: businessProvider.months,
                                              onTap: (value) async {
                                                businessProvider.changeMonth(
                                                  value,
                                                );
                                                businessProvider.hideAll();
                                                await businessProvider
                                                    .getAllBusinessListPro(
                                                      businessProvider
                                                          .selectedConvertedMonth,
                                                      businessProvider
                                                          .selectedYear
                                                          .toString(),
                                                      '',
                                                      '',
                                                      isRefresh: true,
                                                    );
                                              },
                                            )
                                            : const SizedBox(),
                                  ),

                                  /// Year List
                                  Expanded(
                                    child:
                                        businessProvider.showyearInMainScreen
                                            ? _DropdownList<int>(
                                              items: businessProvider.years,
                                              onTap: (value) async {
                                                businessProvider.changeYear(
                                                  value.toString(),
                                                );
                                                businessProvider.hideAll();
                                                await businessProvider
                                                    .getAllBusinessListPro(
                                                      businessProvider
                                                          .selectedConvertedMonth,
                                                      businessProvider
                                                          .selectedYear
                                                          .toString(),
                                                      '',
                                                      '',
                                                      isRefresh: true,
                                                    );
                                              },
                                            )
                                            : const SizedBox(),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 20),

                            // filter section container
                            (businessProvider.isLoading ||
                                    businessProvider.businessSingleObjectData ==
                                        null ||
                                    businessProvider.filterStringDatas ==
                                        null ||
                                    businessProvider.businessAllListData ==
                                        null)
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
                                        businessProvider
                                            .filterStringDatas!
                                            .length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () async {
                                          businessProvider
                                              .getFilterSelectedIndexNamePro(
                                                '${businessProvider.filterStringDatas![index]['statusid']}',
                                              );
                                          print(
                                            'status in screen  : ${businessProvider.filterStringDatas![index]['statusid']}',
                                          );
                                          print(
                                            'status in screen month  : ${businessProvider.selectedConvertedMonth}',
                                          );
                                          print(
                                            'status in screen year  : ${businessProvider.selectedYear}',
                                          );
                                          await businessProvider
                                              .getAllBusinessListPro(
                                                businessProvider
                                                    .selectedConvertedMonth,
                                                businessProvider.selectedYear,
                                                businessProvider
                                                    .getFilterSelectedIndexName
                                                    .toString(),
                                                '',
                                                isRefresh: true,
                                              );
                                        },
                                        child: Container(
                                          height: isTablet ? 120 : 60,
                                          decoration: BoxDecoration(
                                            color:
                                                (businessProvider
                                                            .filterStringDatas![index]['statusid']
                                                            .toString() ==
                                                        businessProvider
                                                            .getFilterSelectedIndexName)
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
                                                    '${businessProvider.filterStringDatas![index]['image']}',
                                                    width: isTablet ? 35 : 24,
                                                    height: isTablet ? 35 : 24,
                                                  ),
                                                ),
                                                SizedBox(height: 3),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '${businessProvider.filterStringDatas![index]['title']}',
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
                                                        ': ${businessProvider.filterStringDatas![index]['count'] ?? '0'}',
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
                                    (businessProvider.isLoading ||
                                            businessProvider
                                                    .businessSingleObjectData ==
                                                null ||
                                            businessProvider
                                                    .businessAllListData ==
                                                null)
                                        ? const LeadCardShimmer(isTablet: false)
                                        : (businessProvider
                                                    .businessAllListData ==
                                                null ||
                                            businessProvider
                                                .businessAllListData!
                                                .isEmpty)
                                        ? RefreshIndicator(
                                          onRefresh: () async {
                                            // // Call your API / Provider refresh function here
                                            // await businessProvider
                                            //     .getBusinessList();
                                            _initialData();
                                          },
                                          child: SingleChildScrollView(
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            child: SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.7,
                                              child: Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Lottie.asset(
                                                      'assets/json/noevents.json',
                                                      width: 150,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    const Text(
                                                      'No Business Found',
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
                                        )
                                        : RefreshIndicator(
                                          onRefresh: () async {
                                            /// Call your initial API again

                                            /// OR if you already use this
                                            _initialData();
                                          },
                                          child: ListView.separated(
                                            controller: scrollcontrollers,
                                            shrinkWrap: false,
                                            // physics: BouncingScrollPhysics(),
                                            itemCount:
                                                businessProvider
                                                    .businessAllListData!
                                                    .length +
                                                (businessProvider.isLoadingMore
                                                    ? 1
                                                    : 0),
                                            itemBuilder: (context, index) {
                                              // 🔥 SHOW LOAD MORE INDICATOR AT BOTTOM
                                              if (index ==
                                                  businessProvider
                                                      .businessAllListData!
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

                                              final businessSummery =
                                                  businessProvider
                                                      .businessSingleObjectData!
                                                      .summary;
                                              final allBusinessList =
                                                  businessProvider
                                                      .businessAllListData![index];
                                              final collectedPaymetList =
                                                  businessProvider
                                                      .businessAllListData![index]
                                                      .collectedPayments;

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
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // main first container
                                                      Container(
                                                        width: double.infinity,
                                                        decoration: BoxDecoration(
                                                          // color:
                                                          //     Colors.amber,
                                                        ),

                                                        // 2 row container
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,

                                                          children: [
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,

                                                                children: [
                                                                  Text(
                                                                    allBusinessList
                                                                            .businessName ??
                                                                        '',
                                                                    maxLines:
                                                                        2, // responsive
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                                    allBusinessList
                                                                            .clientName ??
                                                                        '',
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
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
                                                            CollectionPendingAndCollectedWidget(
                                                              allBusinessList:
                                                                  allBusinessList,
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      SizedBox(height: 20),

                                                      // total amount container
                                                      TotalAmountWidget(
                                                        totalAmount:
                                                            allBusinessList
                                                                .totalBusinessCost ??
                                                            '',
                                                      ),
                                                      SizedBox(height: 20),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 18,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(
                                                                .06,
                                                              ), // soft minimal bg
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                14,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                Colors.white12,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            /// -------- Total Business --------
                                                            Expanded(
                                                              child: _buildItem(
                                                                title:
                                                                    "Amount Collected",
                                                                amount:
                                                                    "₹ ${allBusinessList.collectedBusinessCost ?? '0'}",
                                                                isTablet:
                                                                    isTablet,
                                                              ),
                                                            ),

                                                            /// Divider
                                                            Container(
                                                              height: 40,
                                                              width: 1,
                                                              color:
                                                                  Colors
                                                                      .white24,
                                                            ),

                                                            /// -------- Pending --------
                                                            Expanded(
                                                              child: _buildItem(
                                                                title:
                                                                    "Pending Collection",
                                                                amount:
                                                                    "₹ ${allBusinessList.pendingCollection ?? '0'}",
                                                                isTablet:
                                                                    isTablet,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 15,
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
                                                                  "assets/images/lead/allmeetings.png",
                                                              text:
                                                                  "Enter Collected Amount",
                                                              onTap: () {
                                                                print(
                                                                  'Enter Collected Amount',
                                                                );
                                                                businessProvider
                                                                    .hideShowFormFieldPro(
                                                                      index,
                                                                    );
                                                              },
                                                              isTablet:
                                                                  isTablet,
                                                            ),
                                                            SizedBox(width: 5),
                                                            ContactSocialWidget(
                                                              image:
                                                                  "assets/images/lead/allmeetings.png",
                                                              text:
                                                                  "Collected Payments",
                                                              onTap: () {
                                                                print(
                                                                  'Collected Payments',
                                                                );
                                                                businessProvider
                                                                    .hideShowCollectedPaymentsPro(
                                                                      index,
                                                                    );
                                                              },
                                                              isTablet:
                                                                  isTablet,
                                                            ),
                                                            SizedBox(width: 5),
                                                            ContactSocialWidget(
                                                              image:
                                                                  "assets/images/lead/trash.png",
                                                              text: "Delete",
                                                              onTap: () {
                                                                print(
                                                                  'Delete ${allBusinessList.businessId}',
                                                                );
                                                                showDeleteConfirmationDialog(
                                                                  context,
                                                                  onDelete: () async {
                                                                    await businessProvider.deleteBusinessPro(
                                                                      allBusinessList
                                                                          .businessId
                                                                          .toString(),
                                                                    );
                                                                    if (businessProvider
                                                                            .success !=
                                                                        null) {
                                                                      Navigator.pop(
                                                                        context,
                                                                      );
                                                                      showSuccessDialog(
                                                                        context,
                                                                        "assets/images/successicons.png",
                                                                        "Success",
                                                                        businessProvider
                                                                            .success!
                                                                            .message
                                                                            .toString(),
                                                                      );
                                                                      _initialData();
                                                                    }
                                                                  },
                                                                  textMain:
                                                                      "Delete Business",
                                                                  provider:
                                                                      businessProvider,
                                                                );
                                                              },
                                                              isTablet:
                                                                  isTablet,
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      const SizedBox(
                                                        height: 10,
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
                                                            businessProvider
                                                                        .showCollectedPayments ==
                                                                    index
                                                                ? // show all meetings
                                                                (collectedPaymetList ==
                                                                            null ||
                                                                        collectedPaymetList
                                                                            .isEmpty)
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
                                                                      child: Center(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.all(
                                                                            10.0,
                                                                          ),
                                                                          child: Text(
                                                                            'No Payments Collected Yet',
                                                                            style: TextStyle(
                                                                              color:
                                                                                  kButtonColor2,
                                                                            ),
                                                                          ),
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
                                                                      child: Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              10.0,
                                                                            ),
                                                                        child: ListView.separated(
                                                                          padding:
                                                                              const EdgeInsets.all(
                                                                                0,
                                                                              ),
                                                                          shrinkWrap:
                                                                              true,
                                                                          physics:
                                                                              const NeverScrollableScrollPhysics(),
                                                                          itemCount:
                                                                              collectedPaymetList.length,
                                                                          itemBuilder: (
                                                                            context,
                                                                            indexCollected,
                                                                          ) {
                                                                            final data =
                                                                                collectedPaymetList[indexCollected];
                                                                            String
                                                                            formattedDate = DateFormat(
                                                                              'dd-MM-yyyy',
                                                                            ).format(
                                                                              DateTime.parse(
                                                                                data.collecteDate.toString(),
                                                                              ),
                                                                            );

                                                                            return CollectedPaymentCardWidget(
                                                                              data:
                                                                                  data,
                                                                              formattedDate:
                                                                                  formattedDate,
                                                                              businessProvider:
                                                                                  businessProvider,
                                                                            );
                                                                          },
                                                                          separatorBuilder:
                                                                              (
                                                                                context,
                                                                                _,
                                                                              ) => const SizedBox(
                                                                                height:
                                                                                    8,
                                                                              ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                : SizedBox.shrink(),
                                                      ),

                                                      //*******************hide and show form field ************************** */
                                                      AnimatedSize(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 400,
                                                            ),
                                                        curve: Curves.easeInOut,
                                                        child:
                                                            businessProvider
                                                                        .showUpdatePendingField ==
                                                                    index
                                                                ? Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        14,
                                                                      ),

                                                                  decoration: BoxDecoration(
                                                                    color: const Color(
                                                                      0xFF242424,
                                                                    ), // Card BG
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          14,
                                                                        ),
                                                                    border: Border.all(
                                                                      color: const Color(
                                                                        0xFF3A3A3A,
                                                                      ),
                                                                    ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withOpacity(
                                                                              .25,
                                                                            ),
                                                                        blurRadius:
                                                                            8,
                                                                        offset:
                                                                            const Offset(
                                                                              0,
                                                                              4,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),

                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      /// Title
                                                                      Row(
                                                                        children: const [
                                                                          Icon(
                                                                            Icons.payments,
                                                                            color: Color(
                                                                              0xFFD1F66F,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                6,
                                                                          ),
                                                                          Text(
                                                                            "Update Payment",
                                                                            style: TextStyle(
                                                                              color:
                                                                                  Colors.white,
                                                                              fontSize:
                                                                                  15,
                                                                              fontWeight:
                                                                                  FontWeight.w600,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),

                                                                      const SizedBox(
                                                                        height:
                                                                            12,
                                                                      ),

                                                                      /// Amount Field
                                                                      TextFormField(
                                                                        controller:
                                                                            amountController,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        style: const TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                        ),

                                                                        decoration: InputDecoration(
                                                                          hintText:
                                                                              "Enter Amount",
                                                                          hintStyle: const TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                          ),

                                                                          filled:
                                                                              true,
                                                                          fillColor: const Color(
                                                                            0xFF1A1A1A,
                                                                          ),

                                                                          prefixIcon: const Icon(
                                                                            Icons.currency_rupee,
                                                                            color: Color(
                                                                              0xFFD1F66F,
                                                                            ),
                                                                          ),

                                                                          border: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            borderSide:
                                                                                BorderSide.none,
                                                                          ),

                                                                          focusedBorder: OutlineInputBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            borderSide: const BorderSide(
                                                                              color: Color(
                                                                                0xFFD1F66F,
                                                                              ),
                                                                              width:
                                                                                  1.5,
                                                                            ),
                                                                          ),

                                                                          contentPadding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                12,
                                                                            vertical:
                                                                                12,
                                                                          ),
                                                                        ),
                                                                      ),

                                                                      const SizedBox(
                                                                        height:
                                                                            14,
                                                                      ),

                                                                      /// Update Button
                                                                      InkWell(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                        onTap:
                                                                            businessProvider.loadingIndex ==
                                                                                    index
                                                                                ? null
                                                                                : () async {
                                                                                  if (amountController.text.isEmpty) {
                                                                                    ScaffoldMessenger.of(
                                                                                      context,
                                                                                    ).showSnackBar(
                                                                                      const SnackBar(
                                                                                        content: Text(
                                                                                          "Please enter amount",
                                                                                        ),
                                                                                        backgroundColor:
                                                                                            Colors.red,
                                                                                        behavior:
                                                                                            SnackBarBehavior.floating,
                                                                                      ),
                                                                                    );
                                                                                  } else {
                                                                                    /// Await the API call
                                                                                    await businessProvider.addAmountPro(
                                                                                      allBusinessList.businessId.toString(),
                                                                                      amountController.text.toString(),
                                                                                      index,
                                                                                    );

                                                                                    if (!mounted) return;
                                                                                    if (businessProvider.success !=
                                                                                        null) {
                                                                                      showSuccessDialog(
                                                                                        navigatorKey.currentState!.context,
                                                                                        "assets/images/successicons.png",
                                                                                        "Success",
                                                                                        "${businessProvider.success!.message}",
                                                                                      );
                                                                                      amountController.clear();
                                                                                    }
                                                                                  }
                                                                                },
                                                                        child: Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              46,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                            color: const Color(
                                                                              0xFFD1F66F,
                                                                            ),
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                          ),

                                                                          child:
                                                                              businessProvider.loadingIndex ==
                                                                                      index
                                                                                  ? const SizedBox(
                                                                                    height:
                                                                                        20,
                                                                                    width:
                                                                                        20,
                                                                                    child: CircularProgressIndicator(
                                                                                      strokeWidth:
                                                                                          2,
                                                                                      color:
                                                                                          Colors.black,
                                                                                    ),
                                                                                  )
                                                                                  : const Text(
                                                                                    "Update Payment",
                                                                                    style: TextStyle(
                                                                                      fontWeight:
                                                                                          FontWeight.w600,
                                                                                      fontSize:
                                                                                          14,
                                                                                      color:
                                                                                          Colors.black,
                                                                                    ),
                                                                                  ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                                : const SizedBox(),
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

class CollectedPaymentCardWidget extends StatelessWidget {
  const CollectedPaymentCardWidget({
    super.key,
    required this.data,
    required this.formattedDate,
    required this.businessProvider,
  });

  final CollectedPaymentsList data;
  final String formattedDate;
  final BusinessProvider businessProvider;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              /// 🔰 Left Accent Line
              Container(
                width: 5,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(width: 14),

              /// 💰 Amount Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Amount",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "₹ ${data.amount ?? ''}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              /// 📅 Date Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Date",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              /// 🗑 Delete Button
              InkWell(
                /// your delete function
                // onDelete(data.id);
                onTap: () {
                  print('Delete ${data.id}');
                  showDeleteConfirmationDialog(
                    context,
                    onDelete: () async {
                      await businessProvider.deletePaymentPro(
                        data.id.toString(),
                      );
                      if (businessProvider.success != null) {
                        Navigator.pop(context);
                        showSuccessDialog(
                          context,
                          "assets/images/successicons.png",
                          "Success",
                          businessProvider.success!.message.toString(),
                        );
                        final DateTime now = DateTime.now();

                        /// 👉 Get current year
                        final String currentYear =
                            businessProvider.selectedYear.toString();

                        /// 👉 Get current month (2 digit)

                        final String currentMonth = now.month
                            .toString()
                            .padLeft(2, '0');
                        print('year : ${currentYear}');
                        print('month......... : ${currentMonth}');
                        businessProvider.getFilterSelectedIndexNamePro('');
                        businessProvider.resetDateSelection();
                        businessProvider.getAllBusinessListPro(
                          currentMonth,
                          currentYear,
                          '',
                          '',
                          isRefresh: true,
                        );
                      }
                    },
                    textMain: "Delete Payment",
                    provider: businessProvider,
                  );
                },

                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollectionPendingAndCollectedWidget extends StatelessWidget {
  const CollectionPendingAndCollectedWidget({
    super.key,
    required this.allBusinessList,
  });

  final BusinessListData allBusinessList;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    // 🔹 Responsive scale factor
    double scale = width / 375; // base width (mobile design size)

    // 🔹 Status check
    final bool isPending = allBusinessList.collectionPendingStatus == 'true';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color:
            isPending
                ? Colors.orange.withOpacity(0.15)
                : Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: isPending ? Colors.orange : Colors.green,
          width: 1 * scale,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
            color: isPending ? Colors.orange : Colors.green,
            size: 16 * scale, // 🔹 Responsive icon size
          ),
          SizedBox(width: 6 * scale),
          Text(
            isPending ? 'Pending' : 'Collected',
            style: TextStyle(
              fontFamily: "MontrealSerial",
              color: isPending ? Colors.orange.shade800 : Colors.green.shade800,
              fontSize: 12 * scale, // 🔹 Responsive text
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TotalAmountWidget extends StatelessWidget {
  final String? totalAmount;

  const TotalAmountWidget({super.key, required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        /// 🔁 Responsive Breakpoints
        final isTablet = width >= 600;
        final isLargeTablet = width >= 900;

        /// 🔁 Dynamic Sizes
        final horizontalPadding =
            isLargeTablet
                ? 32.0
                : isTablet
                ? 24.0
                : 16.0;

        final verticalPadding =
            isLargeTablet
                ? 24.0
                : isTablet
                ? 20.0
                : 14.0;

        final iconSize =
            isLargeTablet
                ? 36.0
                : isTablet
                ? 30.0
                : 24.0;

        final trendIconSize =
            isLargeTablet
                ? 32.0
                : isTablet
                ? 26.0
                : 22.0;

        final titleFontSize =
            isLargeTablet
                ? 18.0
                : isTablet
                ? 16.0
                : 13.0;

        final amountFontSize =
            isLargeTablet
                ? 30.0
                : isTablet
                ? 26.0
                : 20.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),

          /// 🔹 Content
          child: Row(
            children: [
              /// 💰 Wallet Icon
              Container(
                padding: EdgeInsets.all(isTablet ? 14 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),

              SizedBox(width: isTablet ? 18 : 14),

              /// 📊 Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Amount",
                      style: TextStyle(
                        fontFamily: "MontrealSerial",
                        color: Colors.white70,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// 💵 Amount
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "₹ ${totalAmount ?? '0'}",
                        style: TextStyle(
                          fontFamily: "MontrealSerial",
                          color: Colors.white,
                          fontSize: amountFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// 📈 Trend Icon
              Icon(
                Icons.trending_up_rounded,
                color: Colors.greenAccent,
                size: trendIconSize,
              ),
            ],
          ),
        );
      },
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
            Navigator.pushNamed(context, '/addBusiness');
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
  final bool isTablet;

  const ContactSocialWidget({
    super.key,
    required this.image,
    required this.text,
    required this.onTap,
    this.color,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // Responsive values
    final iconSize = isTablet ? 36.0 : 24.0;
    final fontSize = isTablet ? 16.0 : 12.0;
    final verticalPadding = isTablet ? 18.0 : 10.0;
    final horizontalPadding = isTablet ? 28.0 : 20.0;
    final borderRadius = isTablet ? 16.0 : 10.0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                image ?? '',
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              SizedBox(height: isTablet ? 8 : 3),
              Text(
                text ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "MontrealSerial",
                  color: Colors.white,
                  fontSize: fontSize,
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

Widget _buildItem({
  required String title,
  required String amount,
  required bool isTablet,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      /// Title
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: "MontrealSerial",
          color: Colors.white70,
          fontSize: isTablet ? 16 : 13,
          fontWeight: FontWeight.w500,
        ),
      ),

      SizedBox(height: isTablet ? 10 : 6),

      /// Amount
      Text(
        amount,
        style: TextStyle(
          fontFamily: "MontrealSerial",
          color: Colors.white,
          fontSize: isTablet ? 22 : 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

class CustomListDropdown<T> extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData iconArrow;
  final T? value;
  final List<T> items;
  final Function(T value) onSelected;
  final VoidCallback showHideTap;

  const CustomListDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.iconArrow,
    required this.value,
    required this.items,
    required this.onSelected,
    required this.showHideTap,
  });

  @override
  State<CustomListDropdown<T>> createState() => _CustomListDropdownState<T>();
}

class _CustomListDropdownState<T> extends State<CustomListDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Field UI
        GestureDetector(
          onTap: widget.showHideTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.value?.toString() ?? "Select ${widget.label}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                Icon(widget.iconArrow, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownList<T> extends StatelessWidget {
  final List<T> items;
  final Function(T value) onTap;
  final T? selectedValue;

  const _DropdownList({
    required this.items,
    required this.onTap,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder:
              (_, __) => Divider(height: 1, color: Colors.grey.shade100),

          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item == selectedValue;

            return Material(
              color:
                  isSelected
                      ? Colors.blue.withOpacity(.08)
                      : Colors.transparent,

              child: InkWell(
                onTap: () => onTap(item),
                splashColor: Colors.blue.withOpacity(.15),
                highlightColor: Colors.blue.withOpacity(.05),

                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),

                  child: Row(
                    children: [
                      /// 🔹 Leading Icon / Avatar
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: Colors.blue,
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// 🔹 Title + Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.toString(),
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                color:
                                    isSelected ? Colors.blue : Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              "Select ${item.toString()}",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🔹 Selected Check Icon
                      if (isSelected)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

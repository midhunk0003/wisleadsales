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
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        /// 📅 Month Dropdown
                                        Expanded(
                                          child: DropdownButtonFormField<
                                            String
                                          >(
                                            value:
                                                businessProvider.selectedMonth,
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: "Month",
                                              prefixIcon: const Icon(
                                                Icons.calendar_month,
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade100,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            items:
                                                businessProvider.months
                                                    .map(
                                                      (
                                                        month,
                                                      ) => DropdownMenuItem(
                                                        value: month,
                                                        child: Text(
                                                          month,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) async {
                                              if (value != null) {
                                                businessProvider.changeMonth(
                                                  value,
                                                );

                                                print(
                                                  'month... ${(businessProvider.selectedConvertedMonth)}',
                                                );
                                                print(
                                                  'year... ${businessProvider.selectedYear.toString()}',
                                                );
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
                                              }
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        /// 📆 Year Dropdown
                                        Expanded(
                                          child: DropdownButtonFormField<int>(
                                            value: int.tryParse(
                                              businessProvider.selectedYear
                                                  .toString(),
                                            ),
                                            isExpanded: true,
                                            icon: const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: "Year",
                                              prefixIcon: const Icon(
                                                Icons.date_range,
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade100,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 14,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                            ),
                                            items:
                                                businessProvider.years
                                                    .map(
                                                      (
                                                        year,
                                                      ) => DropdownMenuItem(
                                                        value: year,
                                                        child: Text(
                                                          year.toString(),
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (value) async {
                                              if (value != null) {
                                                businessProvider.changeYear(
                                                  value.toString(),
                                                );

                                                print(
                                                  'month... ${(businessProvider.selectedConvertedMonth)}',
                                                );
                                                print(
                                                  'year... ${businessProvider.selectedYear.toString()}',
                                                );
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
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                FavAndAddWidget(isTablet: isTablet),
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
                                        ? Center(
                                          child: Container(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
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
                                        )
                                        : RefreshIndicator(
                                          onRefresh: () async {
                                            _initialData();
                                          },
                                          child: ListView.separated(
                                            controller: scrollcontrollers,
                                            shrinkWrap: false,
                                            physics: BouncingScrollPhysics(),
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
                                                                    '${allBusinessList.businessName ?? ''}',
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
                                                                    '${allBusinessList.clientName ?? ''}',
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
                                                            Expanded(
                                                              child: collectionPendingANdCOloectedWidget(
                                                                allBusinessList:
                                                                    allBusinessList,
                                                                isTablet:
                                                                    isTablet,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(height: 20),

                                                      // total amount container
                                                      TotalAmountWidget(
                                                        isTablet: isTablet,
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
                                                                        onTap: () async {
                                                                          if (amountController
                                                                              .text
                                                                              .isEmpty) {
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
                                                                            );
                                                                            if (!mounted)
                                                                              return;
                                                                            if (businessProvider.success !=
                                                                                null) {
                                                                              showSuccessDialog(
                                                                                navigatorKey.currentState!.context,
                                                                                "assets/images/successicons.png",
                                                                                "Success",
                                                                                "${businessProvider.success!.message}",
                                                                              );
                                                                              _initialData();
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

                                                                          child: const Text(
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

class collectionPendingANdCOloectedWidget extends StatelessWidget {
  const collectionPendingANdCOloectedWidget({
    super.key,
    required this.allBusinessList,
    required this.isTablet,
  });

  final BusinessListData allBusinessList;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            allBusinessList.collectionPendingStatus == 'true'
                ? Colors.orange.withOpacity(0.15)
                : Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              allBusinessList.collectionPendingStatus == 'true'
                  ? Colors.orange
                  : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allBusinessList.collectionPendingStatus == 'true'
                ? Icons.hourglass_top_rounded
                : Icons.check_circle_rounded,
            color:
                allBusinessList.collectionPendingStatus == 'true'
                    ? Colors.orange
                    : Colors.green,
            size: isTablet ? 20 : 16,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              allBusinessList.collectionPendingStatus == 'true'
                  ? 'Collection Pending'
                  : 'Collection Completed',
              style: TextStyle(
                fontFamily: "MontrealSerial",
                color:
                    allBusinessList.collectionPendingStatus == 'true'
                        ? Colors.orange.shade800
                        : Colors.green.shade800,
                fontSize: isTablet ? 16 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TotalAmountWidget extends StatelessWidget {
  final String? totalAmount;
  const TotalAmountWidget({
    super.key,
    required this.isTablet,
    required this.totalAmount,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 20 : 14,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 💰 Icon Container
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: isTablet ? 32 : 24,
            ),
          ),

          SizedBox(width: 14),

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
                    fontSize: isTablet ? 16 : 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  "₹ ${totalAmount ?? ''}", // 🔁 dynamic amount here
                  style: TextStyle(
                    fontFamily: "MontrealSerial",
                    color: Colors.white,
                    fontSize: isTablet ? 26 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// 📈 Trend Icon
          Icon(
            Icons.trending_up_rounded,
            color: Colors.greenAccent,
            size: isTablet ? 28 : 22,
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

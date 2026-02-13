import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/business_provider.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/reusable_snakebar_widget.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class AddBusiness extends StatefulWidget {
  const AddBusiness({Key? key}) : super(key: key);

  @override
  _AddBusinessState createState() => _AddBusinessState();
}

class _AddBusinessState extends State<AddBusiness> {
  final TextEditingController totalBusinessCostController =
      TextEditingController();
  final TextEditingController businessTypeTextController =
      TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollcontrollers = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollcontrollers.addListener(_scrollListener);
    _initialData();
  }

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BusinessProvider>(context, listen: false);
      provider.getBusinessClientNamePro(isRefresh: true);
      provider.getBusinessNamePro();
    });
  }

  void _scrollListener() {
    if (scrollcontrollers.position.pixels >=
        scrollcontrollers.position.maxScrollExtent - 100) {
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      print('111111111111111');
      if (!businessProvider.isLoadingMore && businessProvider.hasMore) {
        print('listening  and index name');
        businessProvider.getBusinessClientNamePro(isRefresh: false);
      }
    } else {
      print('no listening ');
    }
  }

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    totalBusinessCostController.dispose();
    scrollcontrollers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: Consumer<BusinessProvider>(
        builder: (context, businessProvider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final failure = businessProvider.failure;
            if (failure != null) {
              if (failure is ClientFailure ||
                  failure is ServerFailure ||
                  businessProvider.failure is ClientFailure ||
                  businessProvider.failure is ServerFailure) {
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
                  businessProvider.failure?.message ?? "No internet connection",

              onRetry: () async {},
            );
          }
          return Stack(
            children: [
              LayoutBuilder(
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
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 30),
                          CustomAppBarWidget(
                            title: "Add Business",
                            drawerIconImage: false,
                          ),
                          SizedBox(height: 50),

                          // form section
                          Expanded(
                            child: Container(
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    CustomSelectWidget(
                                      isTablet: isTablet,
                                      text:
                                          businessProvider
                                              .selectedBusinessClientName ??
                                          "Select Client",
                                      maintext: "Select Client",
                                      onTap: () {
                                        businessProvider.hideShowClientList();
                                      },
                                      hideShowIcon:
                                          businessProvider
                                              .hideAndShowClientList!,
                                      businessProvider: businessProvider,
                                      isSelected:
                                          businessProvider
                                              .selectedBusinessClientName !=
                                          null,
                                    ),
                                    const SizedBox(height: 3),
                                    // list of clients
                                    businessProvider.hideAndShowClientList ==
                                            false
                                        ? SizedBox()
                                        : ClientListWidget(
                                          searchController: searchController,
                                          scrollcontrollers: scrollcontrollers,
                                          isTablet: isTablet,
                                          businessProvider: businessProvider,
                                        ),

                                    const SizedBox(height: 10),
                                    CustomSelectWidget(
                                      isTablet: isTablet,
                                      text:
                                          businessProvider
                                              .selectedBusinessName ??
                                          "Select Business Name",
                                      maintext: "Select Business Name",
                                      onTap: () {
                                        businessProvider.hideShowBusinessList();
                                      },
                                      hideShowIcon:
                                          businessProvider
                                              .hideAndShowBusinessList,
                                      businessProvider: businessProvider,
                                      isSelected:
                                          businessProvider
                                              .selectedBusinessName !=
                                          null,
                                    ),
                                    const SizedBox(height: 3),
                                    // list of Business list
                                    businessProvider.hideAndShowBusinessList ==
                                            false
                                        ? SizedBox()
                                        : BusinessListWidget(
                                          businessProvider: businessProvider,
                                        ),

                                    const SizedBox(height: 10),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Business Title",
                                      hintText: "Enter Business Title",
                                      controller: businessTypeTextController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter business Title";
                                        } else {
                                          return null;
                                        }
                                      },
                                      keyboardType:
                                          TextInputType.text, // 👈 pass here
                                    ),
                                    const SizedBox(height: 10),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Business Cost",
                                      hintText: "Enter Business Cost",
                                      controller: totalBusinessCostController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please enter business cost";
                                        } else {
                                          return null;
                                        }
                                      },
                                      keyboardType:
                                          TextInputType.number, // 👈 pass here
                                    ),
                                    const SizedBox(height: 50),
                                    InkWell(
                                      onTap: () async {
                                        if (formKey.currentState!.validate()) {
                                          /// ❌ Client Empty
                                          if (businessProvider
                                                      .selectedBusinessClientName ==
                                                  null ||
                                              businessProvider
                                                  .selectedBusinessClientName!
                                                  .isEmpty) {
                                            showAppSnackBar(
                                              context,
                                              message:
                                                  "Please select client name",
                                            );
                                            return;
                                          }

                                          /// ❌ Business Name Empty
                                          if (businessProvider
                                                      .selectedBusinessName ==
                                                  null ||
                                              businessProvider
                                                  .selectedBusinessName!
                                                  .isEmpty) {
                                            showAppSnackBar(
                                              context,
                                              message:
                                                  "Please select business name",
                                            );
                                            return;
                                          }

                                          await businessProvider.addBusinessPro(
                                            businessProvider
                                                .selectedBusinessClientId
                                                .toString(),
                                            businessProvider.selecttedbusinessId
                                                .toString(),
                                            totalBusinessCostController.text
                                                .toString(),
                                            businessTypeTextController.text
                                                .toString(),
                                          );

                                          if (businessProvider.success !=
                                              null) {
                                            Navigator.pop(context);
                                            showSuccessDialog(
                                              context,
                                              "assets/images/successicons.png",
                                              "Success",
                                              "${businessProvider.success!.message}",
                                            );
                                            businessProvider
                                                .clearBusinessNameAndIdes();
                                            totalBusinessCostController.text =
                                                '';
                                            final DateTime now = DateTime.now();

                                            /// 👉 Get current year
                                            final String currentYear =
                                                businessProvider.selectedYear
                                                    .toString();

                                            /// 👉 Get current month (2 digit)

                                            final String currentMonth = now
                                                .month
                                                .toString()
                                                .padLeft(2, '0');
                                            print('year : ${currentYear}');
                                            print(
                                              'month......... : ${currentMonth}',
                                            );
                                            businessProvider
                                                .getFilterSelectedIndexNamePro(
                                                  '',
                                                );
                                            businessProvider
                                                .resetDateSelection();
                                            businessProvider
                                                .getAllBusinessListPro(
                                                  currentMonth,
                                                  currentYear,
                                                  '',
                                                  '',
                                                  isRefresh: true,
                                                );
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: kButtonColor2,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text('Add Business'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              businessProvider.isLoading
                  ? Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(color: kButtonColor2),
                    ),
                  )
                  : SizedBox.shrink(),
            ],
          );
        },
      ),
    );
  }
}

void showAppSnackBar(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.red,
  IconData icon = Icons.error_outline,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

class BusinessListWidget extends StatelessWidget {
  final BusinessProvider businessProvider;

  const BusinessListWidget({super.key, required this.businessProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FAFF), Color(0xFFEAF1FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child:
          (businessProvider.businessNamesList == null ||
                  businessProvider.businessNamesList!.isEmpty)
              ? Center(
                child: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset('assets/json/noevents.json', width: 150),
                        const SizedBox(height: 10),
                        const Text(
                          'No Client Found',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.all(0),
                itemCount: businessProvider.businessNamesList!.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      businessProvider.setBusinessNameAndId(
                        businessProvider.businessNamesList![index].name
                            .toString(),
                        businessProvider.businessNamesList![index].id
                            .toString(),
                      );
                      businessProvider.hideShowBusinessList();
                    },
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          /// 🔹 Business Logo / Avatar
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF82AE09).withOpacity(.15),
                            child: Icon(
                              Icons.business,
                              color: Color(0xFF82AE09),
                              size: 28,
                            ),
                          ),

                          SizedBox(width: 14),

                          /// 🔹 Business Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Business Name
                                Text(
                                  "${businessProvider.businessNamesList![index].name.toString() ?? ''}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),

                                SizedBox(height: 4),

                                // /// Subtitle
                                // Text(
                                //   "Sales & Services",
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     color: Colors.grey.shade600,
                                //   ),
                                // ),
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
  }
}

class CustomSelectWidget extends StatelessWidget {
  final String? text;
  final String? maintext;
  final VoidCallback onTap;
  final bool hideShowIcon;
  final BusinessProvider businessProvider;
  final bool isSelected;
  const CustomSelectWidget({
    super.key,
    required this.isTablet,
    required this.text,
    required this.maintext,
    required this.onTap,
    required this.hideShowIcon,
    required this.businessProvider,
    this.isSelected = false,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${maintext ?? ''}',
          style: TextStyle(
            fontFamily: "MontrealSerial",
            color: Colors.white70,
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFF82AE09).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft, // 🔥 KEY LINE
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${text ?? ''}',
                    style: TextStyle(
                      fontFamily: "MontrealSerial",
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  hideShowIcon
                      ? Icon(Icons.keyboard_arrow_up, color: Colors.grey)
                      : Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ClientListWidget extends StatelessWidget {
  const ClientListWidget({
    super.key,
    required this.searchController,
    required this.scrollcontrollers,
    required this.isTablet,
    required this.businessProvider,
  });

  final TextEditingController searchController;
  final ScrollController scrollcontrollers;
  final bool isTablet;
  final BusinessProvider businessProvider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: searchController,
            // onChanged: searchClients,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: const Icon(Icons.search, color: Colors.white54),
              hintText: "Search clients...",
              hintStyle: const TextStyle(color: Colors.white38),
              border: InputBorder.none,
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 📋 CLIENT LIST
        Container(
          height: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.03),
            border: Border.all(color: Colors.white12),
          ),
          child:
              (businessProvider.businessClientNameList == null ||
                      businessProvider.businessClientNameList!.isEmpty)
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
                              'No Client Found',
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
                  : ListView.builder(
                    controller: scrollcontrollers, // 👈 attach
                    // primary: false, // 🔥 important
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(12),
                    itemCount:
                        businessProvider.businessClientNameList!.length +
                        (businessProvider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      /// 🔥 SHOW LOAD MORE LOADER
                      if (index ==
                          businessProvider.businessClientNameList!.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return InkWell(
                        onTap: () {
                          businessProvider.setBusinessClientNameAndId(
                            businessProvider
                                .businessClientNameList![index]
                                .clientName
                                .toString(),
                            businessProvider.businessClientNameList![index].id
                                .toString(),
                          );
                          businessProvider.hideShowClientList();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              /// 👤 AVATAR
                              CircleAvatar(
                                radius: isTablet ? 26 : 18,
                                backgroundColor: Colors.blueAccent,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),

                              const SizedBox(width: 12),

                              /// 📄 CLIENT INFO
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${businessProvider.businessClientNameList![index].clientName ?? ''}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 22 : 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontFamily: "MontrealSerial",
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Active Client",
                                      style: TextStyle(
                                        fontSize: isTablet ? 16 : 12,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              /// ➡️ ACTION ICON
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white38,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }
}

class CustomTextFormFieldsWidget extends StatefulWidget {
  final String? title;
  final String? hintText;
  final int? maxLines;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  /// 👇 ADD THIS
  final TextInputType? keyboardType;
  const CustomTextFormFieldsWidget({
    super.key,
    required this.isTablet,
    required this.title,
    required this.hintText,
    this.maxLines,
    this.controller,
    required this.validator,
    this.keyboardType, // 👈 constructor param
  });

  final bool isTablet;

  @override
  State<CustomTextFormFieldsWidget> createState() =>
      _CustomTextFormFieldsWidgetState();
}

class _CustomTextFormFieldsWidgetState
    extends State<CustomTextFormFieldsWidget> {
  final fieldKey = GlobalKey<FormFieldState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // color: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.title}',
            style: TextStyle(
              fontFamily: "MontrealSerial",
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            key: fieldKey,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            onChanged: (value) {
              // ✅ Only revalidate this field
              fieldKey.currentState?.validate();
            },
            controller: widget.controller,
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isTablet ? 20 : 16,
            ),
            maxLines: widget.maxLines,
            decoration: InputDecoration(
              hintText: '${widget.hintText}',
              hintStyle: TextStyle(
                fontFamily: "MontrealSerial",
                color: Colors.white30,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ), // Hint color
              filled: true,

              fillColor: Color(0xFF82AE09).withOpacity(0.15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.blueGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

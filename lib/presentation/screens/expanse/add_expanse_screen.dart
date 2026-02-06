import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/expanse_provider.dart';
import 'package:wisdeals/presentation/screens/expanse/widgets/select_Image_File_widget.dart';
import 'package:wisdeals/presentation/screens/expanse/widgets/showBottomSheet_widget.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class AddExpanseScreen extends StatefulWidget {
  const AddExpanseScreen({Key? key}) : super(key: key);

  @override
  _AddExpanseScreenState createState() => _AddExpanseScreenState();
}

class _AddExpanseScreenState extends State<AddExpanseScreen> {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialData();
  }

  final formKey = GlobalKey<FormState>();

  void _initialData() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<ExpanseProvider>(
        context,
        listen: false,
      ).dropdownItemsExpanseAndTravel();
      Provider.of<ExpanseProvider>(
        context,
        listen: false,
      ).getExpanseTravelTypePro();
      Provider.of<ExpanseProvider>(
        context,
        listen: false,
      ).getExpansePaymentModePro();
      Provider.of<ExpanseProvider>(context, listen: false).clearDataExpanse();
      Provider.of<ExpanseProvider>(context, listen: false).clearNetworkimage();
      clientNameController.text = '';
      amountController.text = '';
      noteController.text = '';
    });
  }

  // -------------------------------
  // dispose()
  // -------------------------------
  @override
  void dispose() {
    clientNameController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 600;
          final bool isSmallScreen = constraints.maxWidth < 400;
          return Form(
            key: formKey,
            child: Consumer<ExpanseProvider>(
              builder: (context, expanseProvider, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final failure = expanseProvider.failure;
                  if (failure != null) {
                    if (failure is ClientFailure ||
                        failure is ServerFailure ||
                        expanseProvider.failure is ClientFailure ||
                        expanseProvider.failure is ServerFailure) {
                      failureDilogeWidget(
                        context,
                        'assets/images/failicon.png',
                        "Failed",
                        '${failure.message}',
                        provider: expanseProvider,
                      );
                    }
                  }
                });

                if (expanseProvider.failure is NetworkFailure) {
                  return NetWorkRetry(
                    failureMessage:
                        expanseProvider.failure?.message ??
                        "No internet connection",

                    onRetry: () async {},
                  );
                }
                return Stack(
                  children: [
                    Padding(
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 30),
                          CustomAppBarWidget(
                            title: "Add Expense",
                            drawerIconImage: false,
                          ),
                          SizedBox(height: 50),
                          // form section
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
                                      CustomTextFormFieldsWidget(
                                        isTablet: isTablet,
                                        title: "Client Name",
                                        hintText: "Enter Client Name",
                                        controller: clientNameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Client Name";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      CustomTextFormFieldsWidget(
                                        isTablet: isTablet,
                                        title: "Company Name",
                                        hintText: "Enter Company Name",
                                        controller: companyNameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Company Name";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 30),
                                      DropdownButtonFormField<String>(
                                        onTap: () async {
                                          expanseProvider
                                              .getExpanseTravelTypePro();
                                        },
                                        value:
                                            expanseProvider
                                                        .expanseSelectedValue
                                                        ?.isNotEmpty ==
                                                    true
                                                ? expanseProvider
                                                    .expanseSelectedValue
                                                : null,

                                        isExpanded: true,

                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white70,
                                        ),

                                        dropdownColor: const Color.fromARGB(
                                          255,
                                          116,
                                          122,
                                          98,
                                        ),

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                        ),

                                        decoration: InputDecoration(
                                          labelText: "Expense Type",
                                          labelStyle: const TextStyle(
                                            color: Colors.white60,
                                          ),

                                          filled: true,
                                          fillColor: const Color(
                                            0xFF82AE09,
                                          ).withOpacity(0.15),

                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 14,
                                                vertical: 14,
                                              ),

                                          // -------------------------
                                          // 🔥 BEST Border Radius Setup
                                          // -------------------------
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.blueGrey,
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.blueGrey,
                                            ),
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),

                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.redAccent,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                        ),

                                        hint: const Text(
                                          "Select Expense Type",
                                          style: TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),

                                        items:
                                            (expanseProvider
                                                        .expenseTravelTypeList ??
                                                    [])
                                                .map(
                                                  (
                                                    value,
                                                  ) => DropdownMenuItem<String>(
                                                    value: value.id.toString(),
                                                    child: Text(
                                                      value.name ?? "Unknown",
                                                    ),
                                                  ),
                                                )
                                                .toList(),

                                        onChanged: (value) {
                                          expanseProvider.expanseSelected(
                                            value,
                                          );
                                        },

                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please select an expense type";
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 20),
                                      CustomTextFormFieldsWidget(
                                        isTablet: isTablet,
                                        title: "Enter Amount",
                                        hintText: "Enter Amount",
                                        controller: amountController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Amount";
                                          } else {
                                            return null;
                                          }
                                        },
                                        keyboardType: TextInputType.number,
                                      ),
                                      const SizedBox(height: 30),
                                      DropdownButtonFormField<String>(
                                        value:
                                            (expanseProvider
                                                        .paymentSelectedValue
                                                        ?.isNotEmpty ??
                                                    false)
                                                ? expanseProvider
                                                    .paymentSelectedValue
                                                : null,

                                        isExpanded: true,

                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white70,
                                          size: isTablet ? 34 : 28,
                                        ),

                                        dropdownColor: const Color.fromARGB(
                                          255,
                                          116,
                                          122,
                                          98,
                                        ),

                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 20 : 16,
                                        ),

                                        decoration: InputDecoration(
                                          labelText: "Payment Mode",
                                          labelStyle: TextStyle(
                                            color: Colors.white70,
                                            fontSize: isTablet ? 20 : 16,
                                          ),

                                          filled: true,
                                          fillColor: const Color(
                                            0xFF82AE09,
                                          ).withOpacity(0.15),

                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: isTablet ? 20 : 14,
                                          ),

                                          // -------------------------
                                          // 🔥 Same Border Radius (12)
                                          // -------------------------
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.blueGrey,
                                            ),
                                          ),

                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.blueGrey.shade400,
                                            ),
                                          ),

                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 1.2,
                                            ),
                                          ),

                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: const BorderSide(
                                              color: Colors.redAccent,
                                            ),
                                          ),

                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                        ),

                                        hint: Text(
                                          "Select Payment Mode",
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: isTablet ? 20 : 16,
                                          ),
                                        ),

                                        items:
                                            (expanseProvider
                                                        .expensesPaymentModeList ??
                                                    [])
                                                .map(
                                                  (
                                                    value,
                                                  ) => DropdownMenuItem<String>(
                                                    value: value.id.toString(),
                                                    child: Text(
                                                      value.name ??
                                                          "Select Payment Method",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize:
                                                            isTablet ? 18 : 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),

                                        onChanged: (value) {
                                          expanseProvider.paymentSelected(
                                            value,
                                          );
                                        },

                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please select a payment type";
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 40),
                                      SelectImageFileAndCameraWidget(
                                        isTablet: isTablet,
                                        expanseProvider: expanseProvider,
                                      ),
                                      const SizedBox(height: 20),

                                      // select image ,camera and file
                                      CustomTextFormFieldsWidget(
                                        isTablet: isTablet,
                                        title: "Notes",
                                        hintText: "Enter Notes",
                                        maxLines: 3,
                                        controller: noteController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please Enter Note";
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 20),
                                      InkWell(
                                        onTap: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            print(
                                              '${clientNameController.text.toString()}',
                                            );
                                            print(
                                              '${companyNameController.text.toString()}',
                                            );
                                            print(
                                              '${expanseProvider.expanseSelectedValue.toString()}',
                                            );
                                            print(
                                              '${amountController.text.toString()}',
                                            );
                                            print(
                                              '${expanseProvider.paymentSelectedValue.toString()}',
                                            );
                                            print(
                                              '${expanseProvider.selectedFile.toString()}',
                                            );
                                            print(
                                              '${noteController.text.toString()}',
                                            );
                                            await expanseProvider
                                                .addExpanseData(
                                                  clientNameController.text
                                                      .toString(),
                                                  companyNameController.text
                                                      .toString(),
                                                  expanseProvider
                                                      .expanseSelectedValue
                                                      .toString(),
                                                  amountController.text
                                                      .toString(),
                                                  expanseProvider
                                                      .paymentSelectedValue
                                                      .toString(),
                                                  expanseProvider.selectedFile
                                                      .toString(),
                                                  noteController.text
                                                      .toString(),
                                                );

                                            if (expanseProvider.success !=
                                                null) {
                                              Navigator.pop(context);
                                              showSuccessDialog(
                                                context,
                                                "assets/images/successicons.png",
                                                "Success",
                                                "${expanseProvider.success!.message}",
                                              );
                                              clientNameController.text = '';
                                              amountController.text = '';
                                              noteController.text = '';
                                              expanseProvider
                                                  .clearDataExpanse();
                                              expanseProvider.getExpansePro('');
                                              print('success....');
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
                                            child: Text('Add Expense'),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 100),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (expanseProvider.isLoading)
                      Container(
                        decoration: BoxDecoration(color: Colors.black45),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: kButtonColor2,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class CustomTextFormFieldsWidget extends StatelessWidget {
  final String? title;
  final String? hintText;
  final int? maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  const CustomTextFormFieldsWidget({
    super.key,
    required this.isTablet,
    required this.title,
    required this.hintText,
    this.maxLines,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // color: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${title}',
            style: TextStyle(
              fontFamily: "MontrealSerial",
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            keyboardType: keyboardType,
            validator: validator,
            controller: controller,
            style: TextStyle(color: Colors.white, fontSize: isTablet ? 20 : 16),
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: '${hintText}',
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

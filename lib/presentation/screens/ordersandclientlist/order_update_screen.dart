import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/presentation/provider/order_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/reusable_snakebar_widget.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class OrderUpdateScreen extends StatefulWidget {
  final Clients clientSingle;
  const OrderUpdateScreen({Key? key, required this.clientSingle})
    : super(key: key);

  @override
  _OrderUpdateScreenState createState() => _OrderUpdateScreenState();
}

class _OrderUpdateScreenState extends State<OrderUpdateScreen> {
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController addNoteController = TextEditingController();
  final TextEditingController leadSourceController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getInitialdatas();
  }

  void _getInitialdatas() {
    clientNameController.text = widget.clientSingle.clientName ?? '';
    companyNameController.text = widget.clientSingle.companyName ?? "";
    phoneNumberController.text = widget.clientSingle.contactNumber ?? "";
    emailController.text = widget.clientSingle.email ?? "";
    addressController.text = widget.clientSingle.address ?? "";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = Provider.of<OrderProvider>(context, listen: false);
      provider.getClientStatus();
      // for update selected index
      provider.clientSelectedStatus(widget.clientSingle.status ?? '');
    });
  }

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    clientNameController.dispose();
    companyNameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    addressController.dispose();
    addNoteController.dispose();
    leadSourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final failure = orderProvider.failure;
            if (failure != null) {
              if (failure is ClientFailure ||
                  failure is ServerFailure ||
                  orderProvider.failure is ClientFailure ||
                  orderProvider.failure is ServerFailure) {
                failureDilogeWidget(
                  context,
                  'assets/images/failicon.png',
                  "Failed",
                  '${failure.message}',
                  provider: orderProvider,
                );
              }
            }
          });

          if (orderProvider.failure is NetworkFailure) {
            return NetWorkRetry(
              failureMessage:
                  orderProvider.failure?.message ?? "No internet connection",

              onRetry: () async {
                await orderProvider.clientUpdatePro(
                  widget.clientSingle.id.toString(),
                  companyNameController.text.toString(),
                  clientNameController.text.toString(),
                  phoneNumberController.text.toString(),
                  emailController.text.toString(),
                  addressController.text.toString(),
                  orderProvider.clientSelectedStatusInd.toString(),
                );
              },
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
                            title: "Update Client",
                            drawerIconImage: false,
                          ),
                          SizedBox(height: 50),
                          // add to client
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: kButtonColor2,
                          //     borderRadius: BorderRadius.circular(10),
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: Text(
                          //       'Added to client',
                          //       style: TextStyle(
                          //         fontFamily: "MontrealSerial",
                          //         color: Colors.black,
                          //         fontSize: 14,
                          //         fontWeight: FontWeight.w300,
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          // form section
                          Expanded(
                            child: Container(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Client Name",
                                      hintText: "Enter Client Name",
                                      controller: clientNameController,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter client name';
                                        }
                                        return null;
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
                                          return 'Please Enter Company Name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Phone Number",
                                      hintText: "Enter Phone Number",
                                      controller: phoneNumberController,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter phone number';
                                        } else if (!RegExp(
                                          r'^[0-9]{10}$',
                                        ).hasMatch(value)) {
                                          return 'Please enter a valid 10-digit phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Email",
                                      hintText: "Enter Valid Email",
                                      controller: emailController,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter email address';
                                        } else if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(value)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                    // const SizedBox(height: 20),
                                    // CustomTextFormFieldsWidget(
                                    //   isTablet: isTablet,
                                    //   title: "Address",
                                    //   hintText: "Enter address",
                                    //   maxLines: 3,
                                    //   controller: addressController,

                                    //   validator: (value) {
                                    //     if (value == null || value.isEmpty) {
                                    //       return 'Please enter addrsss';
                                    //     }
                                    //     return null;
                                    //   },
                                    // ),
                                    const SizedBox(height: 20),

                                    /// Lead Status
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Client  Status',
                                          style: TextStyle(
                                            fontFamily: "MontrealSerial",
                                            color: Colors.white60,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          width: double.infinity,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                          ),
                                          child:
                                              (orderProvider.clientStatus ==
                                                          null ||
                                                      orderProvider
                                                          .clientStatus
                                                          .isEmpty)
                                                  ? const Center(
                                                    child: Text(
                                                      "No client status available",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  )
                                                  : ListView.separated(
                                                    shrinkWrap: true,
                                                    // physics: NeverScrollableScrollPhysics(),
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        orderProvider
                                                            .clientStatus
                                                            .length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return InkWell(
                                                        onTap: () {
                                                          print(
                                                            '${orderProvider.clientStatus[index]}',
                                                          );
                                                          orderProvider
                                                              .clientSelectedStatus(
                                                                orderProvider
                                                                    .clientStatus[index],
                                                              );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                orderProvider
                                                                            .clientSelectedStatusInd ==
                                                                        orderProvider
                                                                            .clientStatus[index]
                                                                    ? Color.fromARGB(
                                                                      101,
                                                                      152,
                                                                      202,
                                                                      13,
                                                                    )
                                                                    : Color(
                                                                      0xFF82AE09,
                                                                    ).withOpacity(
                                                                      0.15,
                                                                    ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            border: Border.all(
                                                              color: Color(
                                                                0xFF82AE09,
                                                              ).withOpacity(
                                                                0.25,
                                                              ),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Text(
                                                              '${orderProvider.clientStatus[index]}',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    "MontrealSerial",
                                                                color:
                                                                    Colors
                                                                        .white70,
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    separatorBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return SizedBox(
                                                        width: 30,
                                                      );
                                                    },
                                                  ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    InkWell(
                                      onTap: () async {
                                        print(
                                          'client name ${clientNameController.text.toString()}',
                                        );
                                        print(
                                          'company name ${companyNameController.text.toString()}',
                                        );
                                        print(
                                          'phone number ${phoneNumberController.text.toString()}',
                                        );
                                        print(
                                          'email ${emailController.text.toString()}',
                                        );
                                        print(
                                          'address ${addressController.text.toString()}',
                                        );
                                        print(
                                          'lead  ${leadSourceController.text.toString()}',
                                        );
                                        print(
                                          'add note ${addNoteController.text.toString()}',
                                        );
                                        print(
                                          'lead status ${orderProvider.clientSelectedStatusInd.toString()}',
                                        );
                                        if (formKey.currentState!.validate()) {
                                          if (orderProvider
                                                  .clientSelectedStatusInd !=
                                              null) {
                                            await orderProvider.clientUpdatePro(
                                              widget.clientSingle.id.toString(),
                                              companyNameController.text
                                                  .toString(),
                                              clientNameController.text
                                                  .toString(),
                                              phoneNumberController.text
                                                  .toString(),
                                              emailController.text.toString(),
                                              addressController.text.toString(),
                                              orderProvider
                                                  .clientSelectedStatusInd
                                                  .toString(),
                                            );
                                            if (orderProvider.success != null) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                              showSuccessDialog(
                                                context,
                                                "assets/images/successicons.png",
                                                "Success",
                                                "${orderProvider.success!.message}",
                                              );
                                              clientNameController.clear();
                                              companyNameController.clear();
                                              phoneNumberController.clear();
                                              emailController.clear();
                                              addressController.clear();
                                              leadSourceController.clear();
                                              addNoteController.clear();
                                              orderProvider.getClientsPro(
                                                '',
                                                isRefresh: true,
                                                '',
                                                '',
                                              );
                                            }
                                          } else {
                                            showCustomSnackBar(
                                              message:
                                                  orderProvider
                                                              .clientSelectedStatusInd ==
                                                          null
                                                      ? 'Please select lead status'
                                                      : 'Please select customer profile',
                                              backgroundColor: Colors.red,
                                              context,
                                              durationSeconds: 2,
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
                                        child: Center(child: Text('Update')),
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
              orderProvider.isLoading
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

class CustomTextFormFieldsWidget extends StatefulWidget {
  final String? title;
  final String? hintText;
  final int? maxLines;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  const CustomTextFormFieldsWidget({
    super.key,
    required this.isTablet,
    required this.title,
    required this.hintText,
    this.maxLines,
    this.controller,
    required this.validator,
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/presentation/provider/lead_provider.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/reusable_snakebar_widget.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class LeadUpdateScreen extends StatefulWidget {
  final LeadData? leadData;
  const LeadUpdateScreen({Key? key, required this.leadData}) : super(key: key);

  @override
  _LeadUpdateScreenState createState() => _LeadUpdateScreenState();
}

class _LeadUpdateScreenState extends State<LeadUpdateScreen> {
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
    clientNameController.text = widget.leadData?.clientName ?? '';
    companyNameController.text = widget.leadData?.companyName ?? "";
    phoneNumberController.text = widget.leadData?.contactNumber ?? "";
    emailController.text = widget.leadData?.email ?? "";
    addressController.text = widget.leadData?.clientAddress ?? "";
    addNoteController.text = widget.leadData?.addNote ?? "";
    leadSourceController.text = widget.leadData?.leadSource ?? "";
    print('aaaaaaaaaaaaaaaaaa : ${widget.leadData!.leadSourceId}');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = Provider.of<LeadProvider>(context, listen: false);
      provider.leadSourceSelectedValuePro(
        widget.leadData!.leadSourceId.toString(),
      );
      // for update selected index
      provider.leadSelectIndex(
        widget.leadData?.leadStatus ?? '',
        widget.leadData?.leadStatusId.toString() ?? '',
      );
      provider.selectedCustomerProfileIndex(
        widget.leadData?.customerProfile ?? '',
        widget.leadData?.customerProfileId.toString() ?? '',
      );
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
      child: Consumer<LeadProvider>(
        builder: (context, leadProvider, _) {
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
                await leadProvider.addLeadPro(
                  clientNameController.text.toString(),
                  companyNameController.text.toString(),
                  phoneNumberController.text.toString(),
                  emailController.text.toString(),
                  addressController.text.toString(),
                  leadSourceController.text.toString(),
                  addNoteController.text.toString(),
                  leadProvider.leadSelectedId.toString(),
                  leadProvider.leadSelectedIndexName.toString(),
                  leadProvider.customerProfileSelectedIndexId.toString(),
                  leadProvider.customerProfileSelectedIndexName.toString(),
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
                            title: "Add Lead",
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
                                      title: "Company name",
                                      hintText: "Enter Company Name",
                                      controller: companyNameController,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter company name';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Phone number",
                                      hintText: "Enter Phone number",
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
                                    const SizedBox(height: 20),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Address",
                                      hintText: "Enter address",
                                      maxLines: 3,
                                      controller: addressController,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter addrsss';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    DropdownButtonFormField<String>(
                                      onTap: () async {
                                        leadProvider.getLeadSourcePro();
                                      },
                                      value:
                                          leadProvider
                                                      .leadSouerceSelectedValue
                                                      ?.isNotEmpty ==
                                                  true
                                              ? leadProvider
                                                  .leadSouerceSelectedValue
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
                                        labelText: "Lead Source",
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

                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      ),

                                      hint: const Text(
                                        "Select Lead Source",
                                        style: TextStyle(color: Colors.white54),
                                      ),

                                      items:
                                          (leadProvider.leadSourceList ?? [])
                                              .map(
                                                (
                                                  value,
                                                ) => DropdownMenuItem<String>(
                                                  value: value.id.toString(),
                                                  child: Text(
                                                    value.source ?? "Unknown",
                                                  ),
                                                ),
                                              )
                                              .toList(),

                                      onChanged: (value) {
                                        leadProvider.leadSourceSelectedValuePro(
                                          value,
                                        );
                                        print('sssssssssssss : ${value}');
                                      },

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Please select an expense type";
                                        }
                                        return null;
                                      },
                                    ),

                                    // CustomTextFormFieldsWidget(
                                    //   isTablet: isTablet,
                                    //   title: "Lead Source",
                                    //   hintText: "Enter Lead Source",
                                    //   controller: leadSourceController,

                                    //   validator: (value) {
                                    //     if (value == null || value.isEmpty) {
                                    //       return 'Please enter lead source';
                                    //     }
                                    //     return null;
                                    //   },
                                    // ),
                                    const SizedBox(height: 20),
                                    CustomTextFormFieldsWidget(
                                      isTablet: isTablet,
                                      title: "Notes",
                                      hintText: "Enter Notes",
                                      maxLines: 3,
                                      controller: addNoteController,

                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter note';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    /// Lead Status
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lead Status',
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
                                              (leadProvider.getLeadStatusList ==
                                                          null ||
                                                      leadProvider
                                                          .getLeadStatusList!
                                                          .isEmpty)
                                                  ? const Center(
                                                    child: Text(
                                                      "No lead status available",
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
                                                        leadProvider
                                                            .getLeadStatusList!
                                                            .length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return InkWell(
                                                        onTap: () {
                                                          print(
                                                            '${leadProvider.getLeadStatusList![index].status}',
                                                          );
                                                          print(
                                                            '${leadProvider.getLeadStatusList![index].id}',
                                                          );
                                                          leadProvider.leadSelectIndex(
                                                            leadProvider
                                                                .getLeadStatusList![index]
                                                                .status
                                                                .toString(),
                                                            leadProvider
                                                                .getLeadStatusList![index]
                                                                .id
                                                                .toString(),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                leadProvider.leadSelectedIndexName ==
                                                                        leadProvider
                                                                            .getLeadStatusList![index]
                                                                            .status
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
                                                              '${leadProvider.getLeadStatusList![index].status}',
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
                                    // Customer profile
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Customer profile',
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
                                              (leadProvider.getCustomerProfileList ==
                                                          null ||
                                                      leadProvider
                                                          .getCustomerProfileList!
                                                          .isEmpty)
                                                  ? const Center(
                                                    child: Text(
                                                      "No customer profile available",
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
                                                        leadProvider
                                                            .getCustomerProfileList!
                                                            .length,
                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      return InkWell(
                                                        onTap: () {
                                                          print(
                                                            '${leadProvider.getCustomerProfileList![index].name}',
                                                          );
                                                          print(
                                                            '${leadProvider.getCustomerProfileList![index].id}',
                                                          );
                                                          leadProvider.selectedCustomerProfileIndex(
                                                            leadProvider
                                                                .getCustomerProfileList![index]
                                                                .name
                                                                .toString(),
                                                            leadProvider
                                                                .getCustomerProfileList![index]
                                                                .id
                                                                .toString(),
                                                          );
                                                        },
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            color:
                                                                leadProvider.customerProfileSelectedIndexName ==
                                                                        leadProvider
                                                                            .getCustomerProfileList![index]
                                                                            .name
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
                                                              '${leadProvider.getCustomerProfileList![index].name}',
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
                                          'lead source ${leadProvider.leadSouerceSelectedValue.toString()}',
                                        );
                                        print(
                                          'add note ${addNoteController.text.toString()}',
                                        );
                                        print(
                                          'lead status id ${leadProvider.leadSelectedId.toString()}',
                                        );
                                        print(
                                          'lead status ${leadProvider.leadSelectedIndexName.toString()}',
                                        );
                                        print(
                                          'customer pro id ${leadProvider.customerProfileSelectedIndexId.toString()}',
                                        );
                                        print(
                                          'customer pro ${leadProvider.customerProfileSelectedIndexName.toString()}',
                                        );
                                        if (formKey.currentState!.validate()) {
                                          if (leadProvider
                                                      .leadSelectedIndexName !=
                                                  null &&
                                              leadProvider
                                                      .customerProfileSelectedIndexName !=
                                                  null) {
                                            await leadProvider.updateLeadPro(
                                              widget.leadData?.id.toString(),
                                              clientNameController.text
                                                  .toString(),
                                              companyNameController.text
                                                  .toString(),
                                              phoneNumberController.text
                                                  .toString(),
                                              emailController.text.toString(),
                                              addressController.text.toString(),
                                              leadProvider
                                                  .leadSouerceSelectedValue
                                                  .toString(),
                                              addNoteController.text.toString(),
                                              leadProvider.leadSelectedId
                                                  .toString(),
                                              leadProvider.leadSelectedIndexName
                                                  .toString(),
                                              leadProvider
                                                  .customerProfileSelectedIndexId
                                                  .toString(),
                                              leadProvider
                                                  .customerProfileSelectedIndexName
                                                  .toString(),
                                            );
                                            if (leadProvider.success != null) {
                                              // First load status
                                              leadProvider.getLeadStatusPro();
                                              leadProvider.getLeadPro(
                                                '',
                                                '',
                                                isRefresh: true,
                                              );

                                              Navigator.pop(context);
                                              showSuccessDialog(
                                                context,
                                                "assets/images/successicons.png",
                                                "Success",
                                                "${leadProvider.success!.message}",
                                              );
                                              clientNameController.clear();
                                              companyNameController.clear();
                                              phoneNumberController.clear();
                                              emailController.clear();
                                              addressController.clear();
                                              leadSourceController.clear();
                                              addNoteController.clear();
                                              leadProvider
                                                  .clearLeadAndCustomerData();
                                            }
                                          } else {
                                            showCustomSnackBar(
                                              message:
                                                  leadProvider.leadSelectedIndexName ==
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
                                        child: Center(child: Text('Save')),
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
              leadProvider.isLoading
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

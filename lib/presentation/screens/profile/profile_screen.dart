import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/api_end_point.dart';
import 'package:wisdeals/core/colors.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/presentation/provider/profile_provider.dart';
import 'package:wisdeals/presentation/screens/profile/DocumentType.dart';
import 'package:wisdeals/presentation/screens/profile/photo_screen.dart';
import 'package:wisdeals/presentation/screens/profile/preview_diloge.dart';
import 'package:wisdeals/presentation/screens/profile/showBottomSheetProfile.dart';
import 'package:wisdeals/widgets/custom_appbar_widget.dart';
import 'package:wisdeals/widgets/failure_diloge_widget.dart';
import 'package:wisdeals/widgets/network_widget.dart';
import 'package:wisdeals/widgets/reusable_scafold_and_glowbackground.dart';
import 'package:wisdeals/widgets/success_diloge_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController employeIdController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController regionController = TextEditingController();
  final TextEditingController resumeController = TextEditingController();
  final TextEditingController addressDocController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountNameController = TextEditingController();
  final TextEditingController ifscCOdeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await provider.getProfileData();
    provider.clearSelectedImages();
    final profile = provider.profileDatas;
    nameController.text = profile!.name ?? '';
    contactController.text = profile.mobilePhone ?? '';
    emailController.text = profile.email ?? '';
    employeIdController.text = profile.empId ?? '';
    designationController.text = profile.designation ?? '';
    regionController.text = profile.branch ?? '';

    resumeController.text = getFileName(profile.resume);
    addressDocController.text = getFileName(profile.addressProof);

    accountNumberController.text = profile.bankDetails?.accountNo ?? '';
    accountNameController.text = profile.bankDetails?.bankName ?? '';
    ifscCOdeController.text = profile.bankDetails?.ifscCode ?? '';
    saveProfileImage(profile.profileImage);
  }

  Future<void> saveProfileImage(String? imageUrl) async {
    final pref = await SharedPreferences.getInstance();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      await pref.setString('profileImage', imageUrl);
    } else {
      await pref.remove('profileImage');
    }
  }

  void updateSelectedFiles(ProfileProvider provider) {
    if (provider.resumeFile != null) {
      resumeController.text = provider.resumeFile!.path.split('/').last;
    }
    if (provider.addressProofFile != null) {
      addressDocController.text =
          provider.addressProofFile!.path.split('/').last;
    }
  }

  String getFileName(String? path) {
    if (path == null || path.isEmpty) return '';
    return path.split('/').last;
  }

  @override
  void dispose() {
    nameController.dispose();
    contactController.dispose();
    emailController.dispose();
    employeIdController.dispose();
    designationController.dispose();
    regionController.dispose();
    resumeController.dispose();
    addressDocController.dispose();
    accountNumberController.dispose();
    accountNameController.dispose();
    ifscCOdeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ReusableScafoldAndGlowbackground(
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool _isTablet = constraints.maxWidth > 600;
            return Padding(
              padding: EdgeInsets.symmetric(
                vertical: _isTablet ? 50 : 25,
                horizontal: _isTablet ? 50 : 25,
              ),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  CustomAppBarWidget(title: 'Profile', drawerIconImage: false),
                  SizedBox(height: 30),
                  // profile image
                  Consumer<ProfileProvider>(
                    builder: (context, profileProvider, _) {
                      if (profileProvider.isLoading ||
                          profileProvider.profileDatas == null) {
                        return Expanded(
                          child: Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                color: kButtonColor2,
                              ),
                            ),
                          ),
                        );
                      }
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        updateSelectedFiles(profileProvider);
                        final failure = profileProvider.failure;
                        if (failure != null) {
                          if (failure is ClientFailure ||
                              failure is ServerFailure ||
                              profileProvider.failure is ClientFailure ||
                              profileProvider.failure is ServerFailure) {
                            failureDilogeWidget(
                              context,
                              'assets/images/failicon.png',
                              "Failed",
                              '${failure.message}',
                              provider: profileProvider,
                            );
                          }
                        }
                      });

                      if (profileProvider.failure is NetworkFailure) {
                        return NetWorkRetry(
                          failureMessage:
                              profileProvider.failure?.message ??
                              "No internet connection",

                          onRetry: () async {
                            profileProvider.addProfileVerificationPro(
                              profileProvider.profileDatas!.id.toString(),
                              profileProvider.selectedFile.toString(),
                              profileProvider.resumeFile.toString(),
                              profileProvider.addressProofFile.toString(),
                              accountNumberController.text.toString(),
                              accountNameController.text.toString(),
                              ifscCOdeController.text.toString(),
                            );
                          },
                        );
                      }

                      final profile = profileProvider.profileDatas;
                      if (profile == null) {
                        return Expanded(
                          child: const Center(
                            child: Text(
                              'No profile data',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _loadInitialData();
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    print('select image');
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const PhotoScreen(),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: _isTablet ? 200 : 100,
                                        height: _isTablet ? 200 : 100,
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.circle,

                                          image: DecorationImage(
                                            image:
                                                (profileProvider
                                                                .profileDatas!
                                                                .profileImage ==
                                                            null &&
                                                        profileProvider
                                                                .selectedFile ==
                                                            null)
                                                    ? AssetImage(
                                                      'assets/images/emptypro.jpg',
                                                    )
                                                    : (profileProvider
                                                            .selectedFile !=
                                                        null)
                                                    ? FileImage(
                                                      profileProvider
                                                          .selectedFile!,
                                                    )
                                                    : NetworkImage(
                                                      '${ApiEndPoint.photoBaseUrl}${profileProvider.profileDatas!.profileImage}',
                                                    ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        right: _isTablet ? 20 : 10,
                                        bottom: 0,
                                        child: Container(
                                          width: _isTablet ? 50 : 25,
                                          height: _isTablet ? 50 : 25,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF4A66E3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: _isTablet ? 28 : 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 30),
                                documentStatusChip(
                                  profileProvider.profileDatas!.docVerified ??
                                      false,
                                ),

                                SizedBox(height: 40),
                                // form Container
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomTextFormFieldWidget(
                                        title: "Name",
                                        hintTitle: "Enter Name",
                                        textEditingController: nameController,
                                        readOnly: true,
                                      ),
                                      SizedBox(height: 12),
                                      CustomTextFormFieldWidget(
                                        title: "Contact",
                                        hintTitle: "Enter Contact",
                                        textEditingController:
                                            contactController,
                                        readOnly: true,
                                      ),
                                      SizedBox(height: 12),
                                      CustomTextFormFieldWidget(
                                        title: "Email",
                                        hintTitle: "Enter email",
                                        textEditingController: emailController,
                                      ),

                                      SizedBox(height: 12),
                                      CustomTextFormFieldWidget(
                                        title: "Employ ID",
                                        hintTitle: "Employ ID",
                                        textEditingController:
                                            employeIdController,
                                      ),
                                      SizedBox(height: 12),
                                      CustomTextFormFieldWidget(
                                        title: "Designation",
                                        hintTitle: "Designation",
                                        textEditingController:
                                            designationController,
                                      ),
                                      SizedBox(height: 12),
                                      CustomTextFormFieldWidget(
                                        title: "Branch",
                                        hintTitle: "Branch",
                                        textEditingController: regionController,
                                      ),

                                      SizedBox(height: 15),
                                      Text(
                                        'Upload Resume',
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          /// Upload Field
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: TextFormField(
                                                controller: resumeController,
                                                readOnly: true,
                                                onTap: () {
                                                  profileProvider
                                                              .profileDatas!
                                                              .docVerified ==
                                                          true
                                                      ? null
                                                      : showPickerBottomSheetProfile(
                                                        context,
                                                        profileProvider,
                                                        DocumentType.resume,
                                                      );
                                                },
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "MontrealSerial",
                                                  fontSize: 15,
                                                ),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12,
                                                      ),
                                                  hintText: "Upload Resume",
                                                  hintStyle: const TextStyle(
                                                    fontFamily:
                                                        "MontrealSerial",
                                                    color: Colors.white54,
                                                    fontSize: 15,
                                                  ),
                                                  suffixIcon: const Icon(
                                                    Icons.upload_file,
                                                    color: Colors.white70,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white
                                                      .withOpacity(0.08),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Resume Proof is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          /// Preview Button
                                          if (profileProvider
                                                          .profileDatas
                                                          ?.resume !=
                                                      null &&
                                                  profileProvider
                                                      .profileDatas!
                                                      .resume!
                                                      .isNotEmpty ||
                                              profileProvider.resumeFile !=
                                                      null &&
                                                  profileProvider
                                                      .resumeFile!
                                                      .path
                                                      .isNotEmpty)
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () {
                                                // TODO: open resume preview
                                                // TODO: open resume preview
                                                final filePathNetWork =
                                                    profileProvider
                                                        .profileDatas!
                                                        .resume ??
                                                    null;
                                                final selectedFilePath =
                                                    profileProvider
                                                        .resumeFile ??
                                                    null;
                                                print('${filePathNetWork}');
                                                print('${selectedFilePath}');
                                                if (selectedFilePath == null ||
                                                    selectedFilePath
                                                        .path
                                                        .isEmpty) {
                                                  print(
                                                    'no file path selected',
                                                  );
                                                  showFilePreviewDialog(
                                                    context,
                                                    filePathNetWork.toString(),
                                                    true,
                                                  );
                                                } else {
                                                  print(
                                                    'selected image 000000000${selectedFilePath}',
                                                  );
                                                  showFilePreviewDialog(
                                                    context,
                                                    selectedFilePath.path,
                                                    false,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 48,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: kButtonColor2,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Preview',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily:
                                                        "MontrealSerial",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),

                                      SizedBox(height: 15),
                                      Text(
                                        'Address proof ( Any govt approved doc )',
                                        style: TextStyle(
                                          fontFamily: "MontrealSerial",
                                          color: Colors.white54,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          /// Upload Field
                                          Expanded(
                                            child: SizedBox(
                                              height: 48,
                                              child: TextFormField(
                                                controller:
                                                    addressDocController,
                                                readOnly: true,
                                                onTap: () {
                                                  profileProvider
                                                              .profileDatas!
                                                              .docVerified ==
                                                          true
                                                      ? null
                                                      : showPickerBottomSheetProfile(
                                                        context,
                                                        profileProvider,
                                                        DocumentType
                                                            .addressProof,
                                                      );
                                                },
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: "MontrealSerial",
                                                  fontSize: 15,
                                                ),
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12,
                                                      ),
                                                  hintText:
                                                      "Address proof ( Any govt approved doc )",
                                                  hintStyle: const TextStyle(
                                                    fontFamily:
                                                        "MontrealSerial",
                                                    color: Colors.white54,
                                                    fontSize: 15,
                                                  ),
                                                  suffixIcon: const Icon(
                                                    Icons.upload_file,
                                                    color: Colors.white70,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white
                                                      .withOpacity(0.08),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Address Proof is required';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 10),

                                          /// Preview Button
                                          if (profileProvider
                                                          .profileDatas
                                                          ?.addressProof !=
                                                      null &&
                                                  profileProvider
                                                      .profileDatas!
                                                      .addressProof!
                                                      .isNotEmpty ||
                                              profileProvider
                                                          .addressProofFile !=
                                                      null &&
                                                  profileProvider
                                                      .addressProofFile!
                                                      .path
                                                      .isNotEmpty)
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () {
                                                // TODO: open resume preview
                                                final filePathNetWork =
                                                    profileProvider
                                                        .profileDatas!
                                                        .addressProof ??
                                                    null;
                                                final selectedFilePath =
                                                    profileProvider
                                                        .addressProofFile ??
                                                    null;
                                                print('$filePathNetWork');
                                                print('$selectedFilePath');
                                                if (selectedFilePath == null ||
                                                    selectedFilePath
                                                        .path
                                                        .isEmpty) {
                                                  print(
                                                    'no file path selected',
                                                  );
                                                  showFilePreviewDialog(
                                                    context,
                                                    filePathNetWork.toString(),
                                                    true,
                                                  );
                                                } else {
                                                  print('selected image');
                                                  showFilePreviewDialog(
                                                    context,
                                                    selectedFilePath.path,
                                                    false,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                height: 48,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: kButtonColor2,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: const Text(
                                                  'Preview',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily:
                                                        "MontrealSerial",
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      CustomTextFormFieldWidget(
                                        readOnly:
                                            profileProvider
                                                        .profileDatas!
                                                        .docVerified ==
                                                    true
                                                ? true
                                                : false,
                                        title: "Bank Account Number",
                                        hintTitle: "Bank Account Number",
                                        textEditingController:
                                            accountNumberController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Bank Account Number is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 15),

                                      CustomTextFormFieldWidget(
                                        readOnly:
                                            profileProvider
                                                        .profileDatas!
                                                        .docVerified ==
                                                    true
                                                ? true
                                                : false,
                                        title: "Bank Name",
                                        hintTitle: "Bank Name",
                                        textEditingController:
                                            accountNameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Bank Name is required';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 15),

                                      CustomTextFormFieldWidget(
                                        readOnly:
                                            profileProvider
                                                        .profileDatas!
                                                        .docVerified ==
                                                    true
                                                ? true
                                                : false,
                                        title: "Bank IFSC Code",
                                        hintTitle: "Bank IFSC Code",
                                        textEditingController:
                                            ifscCOdeController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'IFSC code is required';
                                          }

                                          // final ifscRegex = RegExp(
                                          //   r'^[A-Z]{4}0[A-Z0-9]{6}$',
                                          // );

                                          // if (!ifscRegex.hasMatch(value)) {
                                          //   return 'Enter a valid IFSC code';
                                          // }

                                          return null; // ✅ valid
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 50),
                                // save changes
                                InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      print(
                                        'profile photo : ${profileProvider.selectedFile}',
                                      );
                                      print(
                                        'resume  : ${profileProvider.resumeFile}',
                                      );
                                      print(
                                        'address  : ${profileProvider.addressProofFile == null ? profileProvider.profileDatas!.addressProof : profileProvider.addressProofFile}',
                                      );
                                      print(
                                        'account number  : ${accountNumberController.text.toString()}',
                                      );
                                      print(
                                        'account name  : ${accountNameController.text.toString()}',
                                      );
                                      print(
                                        'ifsc  : ${ifscCOdeController.text.toString()}',
                                      );
                                      final addressProofSelectedOrNetwork =
                                          profileProvider.addressProofFile ==
                                                  null
                                              ? profileProvider
                                                  .profileDatas!
                                                  .addressProof
                                              : profileProvider.addressProofFile
                                                  .toString();
                                      final resumeSelectedOrNetwork =
                                          profileProvider.resumeFile == null
                                              ? profileProvider
                                                  .profileDatas!
                                                  .resume
                                              : profileProvider.resumeFile
                                                  .toString();
                                      print(
                                        'selected or net ${addressProofSelectedOrNetwork}',
                                      );
                                      print(
                                        'selected or net res ${resumeSelectedOrNetwork}',
                                      );
                                      await profileProvider
                                          .addProfileVerificationPro(
                                            profileProvider.profileDatas!.id
                                                .toString(),
                                            profileProvider.selectedFile
                                                .toString(),
                                            resumeSelectedOrNetwork.toString(),
                                            addressProofSelectedOrNetwork
                                                .toString(),
                                            accountNumberController.text
                                                .toString(),
                                            accountNameController.text
                                                .toString(),
                                            ifscCOdeController.text.toString(),
                                          );
                                      if (profileProvider.success != null) {
                                        _loadInitialData();
                                        profileProvider
                                            .getProfilImgFromShared();
                                        showSuccessDialog(
                                          context,
                                          "assets/images/successicons.png",
                                          "Success",
                                          "${profileProvider.success!.message}",
                                        );
                                        profileProvider.clearFailure();
                                        profileProvider.clearSelectedImages();
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: _isTablet ? 400 : 300,
                                    height: _isTablet ? 60 : 60,
                                    decoration: BoxDecoration(
                                      color: kButtonColor2,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        profileProvider.isSaveLoading
                                            ? 'Loading.......'
                                            : 'Update',
                                        style: TextStyle(
                                          fontSize: _isTablet ? 20 : 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomTextFormFieldWidget extends StatelessWidget {
  final String? title;
  final String? hintTitle;
  final String? Function(String?)? validator; // ✅ add validator
  final TextEditingController textEditingController;
  final bool? readOnly;
  const CustomTextFormFieldWidget({
    super.key,
    required this.title,
    required this.hintTitle,
    this.validator,
    required this.textEditingController,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.transparent),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${title ?? 'No title'}',
            style: TextStyle(
              fontFamily: "MontrealSerial",
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          TextFormField(
            readOnly: readOnly!,
            validator: validator, // ✅ attach validator
            controller: textEditingController,
            style: const TextStyle(
              // 👈 text color
              color: Colors.white,
              fontFamily: "MontrealSerial",
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: "${hintTitle}",
              hintStyle: TextStyle(
                fontFamily: "MontrealSerial",
                color: Colors.white54,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget documentStatusChip(bool? isVerified) {
  final bool verified = isVerified ?? false;

  final Color mainColor =
      verified ? const Color(0xFF2ECC71) : const Color(0xFFF39C12);

  final IconData icon =
      verified ? Icons.verified_rounded : Icons.pending_actions_rounded;

  final String label =
      verified ? 'Document Verified' : 'Document Verification Pending';

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
    decoration: BoxDecoration(
      color: mainColor.withOpacity(0.12),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: mainColor.withOpacity(0.35), width: 1),
      boxShadow: [
        BoxShadow(
          color: mainColor.withOpacity(0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: mainColor),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: mainColor,
            letterSpacing: 0.3,
            fontFamily: "MontrealSerial",
          ),
        ),
      ],
    ),
  );
}

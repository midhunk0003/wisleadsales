import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/call_follow_up_languages/call_follow_up_languages.dart';
import 'package:wisdeals/data/model/call_follow_up_note_model/call_follow_up_note_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_customer_profile_model/lead_customer_profile_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_status_model/lead_status_model.dart';
import 'package:wisdeals/data/model/lead_source_model/lead_source_model.dart';
import 'package:wisdeals/domain/repository/lead_managment_repository.dart';
import 'package:wisdeals/services/auth_services.dart';

class LeadProvider extends ChangeNotifier {
  LeadManagmentRepository leadManagmentRepository;

  LeadProvider({required this.leadManagmentRepository});

  // setter
  bool _isLoading = false;
  bool _isLoadingDelete = false;
  bool _isLoadingAddMeeting = false;
  bool _isLoadingLeadStatus = false;
  bool _isLoadingCallNotes = false;
  bool _callLogFlag = false;
  String? _getFilterLeadIndex;
  String? _leadSelectedIndexName;
  String? _leadSelectedId;
  String? _customerProfileSelectedIndexName;
  String? _customerProfileSelectedIndexId;
  Success? _success;
  Failure? _failure;
  List<Map<String, dynamic>> _filterStringLead = [];
  String? _selectedMeetingDate;
  String? _selectedTimeFrom;
  String? _selectedTimeTo;
  int? _hideAndShowAddMeetingIndex;
  int _leadStatusSelectIndex = 0;
  List<LeadData>? _leadDataList;
  List<LeadData>? _searchdLeadList;
  List<LeadStatus>? _getLeadStatusList;
  List<LeadSourceList>? _leadSourceList;
  List<CustomerProfileList>? _getCustomerProfileList;
  LeadManagmentModel? _leadDataAll;
  String _searchQuery = '';
  String? _leadIdForCallLog;
  int? _callLogShowHideIndex;
  int? _allMeetingSHowHideIndex;
  String? _selectedCallFollowUpId;
  String? _selectedCallFollowUpName;
  bool _hideAndShowCallFollowUpForSelect = false;
  String? _selectedCallLanguageId;
  String? _selectedCallLanguageName;
  bool _hideAndShowCallLanguage = false;

  // lead count
  String? _totalLeads;
  String? _convertedLeads;
  String? _pendingLeads;
  String? _lostLeads;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  String? _filterSelectedIndexName;

  List<CallNote>? _getLeadCallNotes;
  List<CallNote>? get getLeadCallNotes => _getLeadCallNotes;

  List<CallLanguage>? _getLeadCallLanguage;
  List<CallLanguage>? get getLeadCallLanguage => _getLeadCallLanguage;

  // getter
  bool get isLoading => _isLoading;
  bool get isLoadingDelete => _isLoadingDelete;
  bool get isLoadingAddMeeting => _isLoadingAddMeeting;
  bool get isLoadingLeadStatus => _isLoadingLeadStatus;
  bool get isLoadingCallNotes => _isLoadingCallNotes;
  bool get callLogFlag => _callLogFlag;
  String? get getFilterLeadIndex => _getFilterLeadIndex;
  String? get leadSelectedIndexName => _leadSelectedIndexName;
  String? get leadSelectedId => _leadSelectedId;
  String? get customerProfileSelectedIndexName =>
      _customerProfileSelectedIndexName;
  String? get customerProfileSelectedIndexId => _customerProfileSelectedIndexId;
  Success? get success => _success;
  Failure? get failure => _failure;
  List<Map<String, dynamic>> get filterStringLead => _filterStringLead;
  String? get selectedMeetingDate => _selectedMeetingDate;
  String? get selectedTimeFrom => _selectedTimeFrom;
  String? get selectedTimeTo => _selectedTimeTo;
  int? get hideAndShowAddMeetingIndex => _hideAndShowAddMeetingIndex;
  int get leadStatusSelectIndex => _leadStatusSelectIndex;
  List<LeadData>? get leadDataList => _leadDataList;
  List<LeadData>? get searchdLeadList =>
      _searchQuery.isEmpty ? _leadDataList : _searchdLeadList;
  List<LeadStatus>? get getLeadStatusList => _getLeadStatusList;
  List<LeadSourceList>? get leadSourceList => _leadSourceList;
  List<CustomerProfileList>? get getCustomerProfileList =>
      _getCustomerProfileList;
  LeadManagmentModel? get leadDataAll => _leadDataAll;

  // lead counts
  String? get totalLeads => _totalLeads;
  String? get convertedLeads => _convertedLeads;
  String? get pendingLeads => _pendingLeads;
  String? get lostLeads => _lostLeads;
  String? get leadIdForCallLog => _leadIdForCallLog;

  int? get callLogShowHideIndex => _callLogShowHideIndex;
  int? get allMeetingSHowHideIndex => _allMeetingSHowHideIndex;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
  String? get filterSelectedIndexName => _filterSelectedIndexName;

  String? _leadSouerceSelectedValue;
  String? get leadSouerceSelectedValue => _leadSouerceSelectedValue;

  String? get selectedCallFollowUpId => _selectedCallFollowUpId;
  String? get selectedCallFollowUpName => _selectedCallFollowUpName;
  bool get hideAndShowCallFollowUpForSelect =>
      _hideAndShowCallFollowUpForSelect;
  String? get selectedCallLanguageId => _selectedCallLanguageId;
  String? get selectedCallLanguageName => _selectedCallLanguageName;
  bool get hideAndShowCallLanguage => _hideAndShowCallLanguage;

  // functions

  void hideAndShowCallFollowUpForSelectPro() {
    _hideAndShowCallFollowUpForSelect = !_hideAndShowCallFollowUpForSelect;
    notifyListeners();
  }

  void hideAndShowCallLanguagePro() {
    _hideAndShowCallLanguage = !_hideAndShowCallLanguage;
    notifyListeners();
  }

  void selectCallFolowUp(
    String? selectCallFolowUpId,
    String? selectCallFolowUpTitle,
  ) {
    _selectedCallFollowUpId = selectCallFolowUpId;
    _selectedCallFollowUpName = selectCallFolowUpTitle;
    notifyListeners();
  }

  void selectCallLanguagePro(
    String? selectCallLanguageIds,
    String? selectCallLanguageTitles,
  ) {
    _selectedCallLanguageId = selectCallLanguageIds;
    _selectedCallLanguageName = selectCallLanguageTitles;
    notifyListeners();
  }

  void clearWhenLanguageNotselected() {
    print('clear when select not language');
    _selectedCallLanguageId = '';
    _selectedCallLanguageName = '';
    notifyListeners();
  }

  void callShowHideIndex(int? index) {
    if (_callLogShowHideIndex == index) {
      _callLogShowHideIndex = null; // collapse if already open
      // IMPORTANT: close all meeting  if open
      _allMeetingSHowHideIndex = null;
    } else {
      _callLogShowHideIndex = index; // expand this index
      _allMeetingSHowHideIndex = null;
    }
    print('${_callLogShowHideIndex}');
    notifyListeners();
  }

  void allMeetingsShowHideIndex(int? index) {
    if (_allMeetingSHowHideIndex == index) {
      _allMeetingSHowHideIndex = null; // collapse if already open
      // IMPORTANT: close call log if open
      _callLogShowHideIndex = null;
    } else {
      _allMeetingSHowHideIndex = index; // expand this index
      _callLogShowHideIndex = null;
    }
    print('${_allMeetingSHowHideIndex}');
    notifyListeners();
  }

  void callLogFlagPro() {
    _callLogFlag = !_callLogFlag;
    notifyListeners();
  }

  void setLeadIdForCallLog(String? leadId) {
    _leadIdForCallLog = leadId;
    notifyListeners();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    print('make call to : ${phoneNumber}');
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);
    notifyListeners();
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
      notifyListeners();
    } else {
      throw 'Could not launch $callUri';
    }
  }

  Future<void> openWhatsApp(String phoneNumber, {String? message}) async {
    final String encodedMessage = Uri.encodeComponent(message ?? '');
    final Uri whatsappUri = Uri.parse(
      'whatsapp://send?phone=$phoneNumber&text=$encodedMessage',
    );

    try {
      // Use external application mode for Android/iOS
      if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      print('Error opening WhatsApp: $e');
    }
  }

  void leadStatusSelect(int index) {
    _leadStatusSelectIndex = index;
    notifyListeners();
  }

  void clearFailure() {
    print('clear failure called');
    _failure = null;
    notifyListeners();
  }

  void clearSelectdData() {
    print('clear failure called');
    _selectedCallFollowUpId = '';
    _selectedCallFollowUpName = '';
    _selectedCallLanguageId = '';
    _selectedCallLanguageName = '';
    notifyListeners();
  }

  void hideAndShowAddLeadMeeting(int? index) {
    if (_hideAndShowAddMeetingIndex == index) {
      _hideAndShowAddMeetingIndex = null; // collapse if already open
    } else {
      _hideAndShowAddMeetingIndex = index; // expand this index
    }
    print('${_hideAndShowAddMeetingIndex}');
    notifyListeners();
  }

  Future<void> setSelectedDate(BuildContext context) async {
    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // current date
      firstDate: today, // earliest date
      lastDate: DateTime(2100), // latest date
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      _selectedMeetingDate = formattedDate;
      notifyListeners();
    }
  }

  Future<void> setSelectedTimeFrom(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        ),
      );
      _selectedTimeFrom = formattedTime;
      notifyListeners();
    }
  }

  Future<void> setSelectedTimeTo(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        ),
      );
      _selectedTimeTo = formattedTime;
      notifyListeners();
    }
  }

  void clearMeetingData() {
    _selectedMeetingDate = '';
    _selectedTimeFrom = '';
    _selectedTimeTo = '';
    notifyListeners();
  }

  String _getStatusImage(String status) {
    switch (status) {
      case 'Pending':
        return 'assets/images/lead/pending.png';
      case 'Converted':
        return 'assets/images/lead/convertlead.png';
      case 'Lost':
        return 'assets/images/lead/lostlead.png';
      default:
        return 'assets/images/lead/totalleed.png';
    }
  }

  void getFilterLeadSection() {
    // // Step 1: calculate total leads
    // final totalLeadsCount = leadDataList?.length ?? 0;
    // final allCount = leadDataList!.where((lead) => lead.leadStatus == 'All');
    if (getLeadStatusList == null || getLeadStatusList!.isEmpty) {
      _filterStringLead = [];
      notifyListeners();
      return;
    }
    // Step 2: build dynamic list from API
    final dynamicList =
        getLeadStatusList!.map((statusItem) {
          final status = statusItem.status ?? '';
          print('11111111111111 : ${status}');
          final statusid = statusItem.id ?? '';
          final leadCount = statusItem.leadCount ?? '0';
          // final allCount = leadDataList!.where(
          //   (lead) => lead.leadStatus == 'All',
          // );

          return {
            'image': _getStatusImage(status),
            'title': status,
            'status': status,
            'statusid': statusid,
            'count': leadCount,
          };
        }).toList();

    // Step 3: Insert static "Total Leads" at first position
    _filterStringLead = dynamicList;

    notifyListeners();
  }

  void getFilterSelectedIndex(String? leadIndex) {
    _getFilterLeadIndex = leadIndex;
    notifyListeners();
  }

  void leadSelectIndex(String selectedIndex, String? leadStatusid) {
    _leadSelectedIndexName = selectedIndex;
    _leadSelectedId = leadStatusid;
    notifyListeners();
  }

  void selectedCustomerProfileIndex(
    String selectedIndex,
    String? customerProfileId,
  ) {
    _customerProfileSelectedIndexName = selectedIndex;
    _customerProfileSelectedIndexId = customerProfileId;
    print('${_customerProfileSelectedIndexName}');
    notifyListeners();
  }

  // customer profile end

  void clearLeadAndCustomerData() {
    _leadSelectedIndexName = null;
    _customerProfileSelectedIndexName = null;
    notifyListeners();
  }

  // add lead
  Future<void> addLeadPro(
    String? clientName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? leadSource,
    String? addNote,
    String? leadStatusId,
    String? leadStatus,
    String? customerProfileId,
    String? customerProfile,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.addLead(
      token,
      clientName,
      companyName,
      contactNumber,
      email,
      clientAddress,
      leadSource,
      addNote,
      leadStatusId,
      leadStatus,
      customerProfileId,
      customerProfile,
    );

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success message in provider : ${success.message}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getLeadPro(
    String? search,
    String? leadStatusId, {
    bool isRefresh = false,
  }) async {
    print('current page prooo : ${currentPage ?? ''}');
    print('leadStatusId  pro: ${leadStatusId ?? ''}');
    print('refresh main loading : ${isRefresh ?? ''}');
    print('refresh main loading : ${isRefresh ?? ''}');
    if (_currentPage == 1) {
      _currentPage++;
      notifyListeners();
    }

    if (isRefresh == false) {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
      _failure = null;
      notifyListeners();
    } else {
      if (isRefresh == true) {
        print('refresh main loading2 : ${isRefresh}');
        _isLoading = true;
        _failure = null;
        clearCurrentPage();
        notifyListeners();
      }
    }

    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await leadManagmentRepository.getLead(
      token,
      search.toString(),
      leadStatusId,
      _currentPage.toString(),
    );

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _isLoading = false;
        _isLoadingMore = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        final fetchedList = success.data ?? [];

        if (isRefresh == true) {
          print('initial content :  and current page:${_currentPage}');
          // First page → replace list
          _leadDataList = fetchedList;
          print('aaaaaaaaaaaaaaaaaaaaaaaaa : ${_leadDataList!.length}');
        } else {
          print('next page content');
          // Next pages → append list
          _leadDataList!.addAll(fetchedList);
        }

        // Check if more pages exist
        _hasMore = fetchedList.isNotEmpty;
        print("Loaded page $_currentPage");

        if (isRefresh == false) {
          // print('page incriment ${_currentPage} : ${isRefresh}');
          _currentPage++;
          print('page incriment ${_currentPage} : ${isRefresh}');
          notifyListeners();
        }

        // Copy extra params
        _totalLeads = success.totalLeads?.toString() ?? "0";
        _convertedLeads = success.convertedLeads?.toString() ?? "0";
        _pendingLeads = success.pendingFollowups?.toString() ?? "0";
        _lostLeads = success.lostLeads?.toString() ?? "0";

        print('total : ${_totalLeads}');
        print('converted  : ${_convertedLeads}');
        print('pending : ${_pendingLeads}');
        print('lost : ${_lostLeads}');
        getFilterLeadSection();
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> getLeadStatusPro() async {
    _isLoadingLeadStatus = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('inside lead status pro : token ${token}');
    final result = await leadManagmentRepository.getLeadStatus(token);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _isLoadingLeadStatus = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _getLeadStatusList = success;
        _isLoadingLeadStatus = false;
        getFilterLeadSection();
        notifyListeners();
      },
    );
  }

  Future<void> getCustomerProfilePro() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await leadManagmentRepository.getCustomerProfile(token);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _isLoading = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _getCustomerProfileList = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void clearCurrentPage() async {
    _currentPage = 1;
    _hasMore = true;
    _leadDataList = [];
    notifyListeners();
  }

  void searchLeadList(String? query) {
    _searchQuery = query!.toLowerCase().trim() ?? '';
    print('search query in provider : ${_searchQuery}');
    _searchdLeadList =
        _leadDataList?.where((lead) {
          final clientName = lead.clientName?.toLowerCase() ?? '';
          final companyName = lead.companyName?.toLowerCase() ?? '';
          final contactNumber = lead.contactNumber?.toLowerCase() ?? '';
          final email = lead.email?.toLowerCase() ?? '';
          return clientName.contains(_searchQuery) ||
              companyName.contains(_searchQuery) ||
              contactNumber.contains(_searchQuery) ||
              email.contains(_searchQuery);
        }).toList();
    print('searchdLeadList in provider : ${_searchdLeadList}');
    notifyListeners();
  }

  Future<void> deleteLeadPro(String? id) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.deleteLead(token, id);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoadingDelete = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoadingDelete = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateLeadPro(
    String? id,
    String? clientName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? leadSource,
    String? addNote,
    String? leadStatusId,
    String? leadStatus,
    String? customerProfileId,
    String? customerProfile,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.updateLead(
      token,
      id,
      clientName,
      companyName,
      contactNumber,
      email,
      clientAddress,
      leadSource,
      addNote,
      leadStatusId,
      leadStatus,
      customerProfileId,
      customerProfile,
    );

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success update message in provider : ${success.message}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> leadConvertToClientPro(
    String? id,
    String? clientName,
    String? companyName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? leadSource,
    String? addNote,
    String? leadStatus,
    String? customerProfile,
  ) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.leadConvertToclient(
      token,
      id,
      clientName,
      companyName,
      contactNumber,
      email,
      clientAddress,
      leadSource,
      addNote,
      leadStatus,
      customerProfile,
    );

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoadingDelete = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print(
          'success convert to client message in provider : ${success.message}',
        );
        _isLoadingDelete = false;
        notifyListeners();
      },
    );
  }

  Future<void> leadAddMeetingPro(
    String? leadId,
    String? date,
    String? timeFrom,
    String? timaTo,
    String? note,
  ) async {
    _isLoadingAddMeeting = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.addMeetingLead(
      token,
      leadId,
      date,
      timeFrom,
      timaTo,
      note,
    );
    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoadingAddMeeting = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success add meeting : ${success.message}');
        _isLoadingAddMeeting = false;
        notifyListeners();
      },
    );
  }

  Future<void> leadAddcallLogsPro(
    String? clientId,
    String? leadId,
    String? notesId,
    String? languageId,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.addCallLogs(
      token,
      clientId,
      leadId,
      notesId,
      languageId,
    );
    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        print('success add meeting : ${success.message}');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void leadSourceSelectedValuePro(String? value) {
    _leadSouerceSelectedValue = value;
    notifyListeners();
  }

  Future<void> getLeadSourcePro() async {
    _isLoadingLeadStatus = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('inside lead status pro : token ${token}');
    final result = await leadManagmentRepository.getLeadSource(token);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _isLoadingLeadStatus = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _leadSourceList = success;
        _isLoadingLeadStatus = false;
        getFilterLeadSection();
        notifyListeners();
      },
    );
  }

  Future<void> deleteLeadMeetingPro(String? meetingId) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await leadManagmentRepository.deleteLeadMeeting(
      token,
      meetingId,
    );

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _failure = failure;
        _isLoadingDelete = false;
        notifyListeners();
      },
      (success) {
        _success = success;
        _isLoadingDelete = false;
        notifyListeners();
      },
    );
  }

  Future<void> getLeadCallNotePro() async {
    _isLoadingCallNotes = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('inside lead call note pro : token ${token}');
    final result = await leadManagmentRepository.getLeadCallNote(token);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _isLoadingCallNotes = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _getLeadCallNotes = success;
        _isLoadingCallNotes = false;
        getFilterLeadSection();
        notifyListeners();
      },
    );
  }

  Future<void> getLeadCallLanguagePro() async {
    _isLoadingCallNotes = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('inside lead call note pro : token ${token}');
    final result = await leadManagmentRepository.getLeadCallLAnguage(token);

    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        _isLoadingCallNotes = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _getLeadCallLanguage = success;
        _isLoadingCallNotes = false;
        getFilterLeadSection();
        notifyListeners();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';
import 'package:wisdeals/domain/repository/order_and_client_repository.dart';
import 'package:wisdeals/services/auth_services.dart';

class OrderProvider extends ChangeNotifier {
  final OrderAndClientRepository orderAndClientRepository;

  OrderProvider({required this.orderAndClientRepository});

  // setter
  bool _isLoading = false;
  bool _isLoadingDelete = false;
  bool _isLoadingAddMeeting = false;
  bool _showMeetings = false;
  Failure? _failure;
  Success? _success;
  List<Clients>? _clientList = [];
  List<Clients>? _searchedclientList = [];
  List<Meeting>? _meetingList;
  String? _totalClient;
  bool _hideAndShowStatus = false;
  bool _hideAndShowMeeting = false;
  int? _selectedStatusvalue;
  String? _selectedStatusName;
  int? _selectedPriorityvalue;
  String? _selectedPriorityName;
  String? _selectedCustomerProfileId;
  List<String> _leadStatusList = [];
  List<String> _selectedPriorityList = [];

  String? _selectedMeetingDate;
  String? _selectedTimeFrom;
  String? _selectedTimeTo;

  final now = DateTime.now();
  Meeting? _firstPastMeeting;
  Meeting? _firstUpcomingMeeting;

  // search
  String searchQuery = '';

  bool _callLogFlag = false;
  String? _clientIdForCallLog;

  bool _showHideCallLogs = false;
  List<String?> _clientStatus = [];
  String? _clientSelectedStatusInd;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // getter
  bool get isLoading => _isLoading;
  bool get isLoadingDelete => _isLoadingDelete;
  bool get isLoadingAddMeeting => _isLoadingAddMeeting;
  bool get showMeetings => _showMeetings;
  Failure? get failure => _failure;
  Success? get success => _success;

  List<Clients>? get clientList => _clientList;
  List<Clients>? get searchedclientList =>
      searchQuery.isEmpty ? _clientList : _searchedclientList;
  List<Meeting>? get meetingList => _meetingList;
  String? get totalClient => _totalClient;
  bool get hideAndShowStatus => _hideAndShowStatus;
  bool get hideAndShowMeeting => _hideAndShowMeeting;

  ///
  int? get selectedStatusvalue => _selectedStatusvalue;
  int? get selectedPriorityvalue => _selectedPriorityvalue;

  ///
  String? get selectedStatusName => _selectedStatusName;
  String? get selectedPriorityName => _selectedPriorityName;
  String? get selectedCustomerProfileId => _selectedCustomerProfileId;

  ///
  List<String> get leadStatusList => _leadStatusList;
  List<String> get selectedPriorityList => _selectedPriorityList;

  ///
  String? get selectedMeetingDate => _selectedMeetingDate;
  String? get selectedTimeFrom => _selectedTimeFrom;
  String? get selectedTimeTo => _selectedTimeTo;

  // meeting list next and old meeting
  Meeting? get firstPastMeeting => _firstPastMeeting;
  Meeting? get firstUpcomingMeeting => _firstUpcomingMeeting;

  bool get callLogFlag => _callLogFlag;

  String? get clientIdForCallLog => _clientIdForCallLog;

  bool get showHideCallLogs => _showHideCallLogs;
  List<String?> get clientStatus => _clientStatus;

  String? get clientSelectedStatusInd => _clientSelectedStatusInd;

  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  //call logs

  void callLogFlagPro() {
    _callLogFlag = !_callLogFlag;
    notifyListeners();
  }

  void setClientIdPro(String? clientids) {
    _clientIdForCallLog = clientids;
    notifyListeners();
  }

  void showCallLogListHideAndShow() {
    _showHideCallLogs = !_showHideCallLogs;
    notifyListeners();
  }

  // show meeting

  void showMeetingsPro() {
    _showMeetings = !_showMeetings;
    notifyListeners();
  }

  // lead Status
  void getClientStatus() {
    _isLoading = true;
    notifyListeners();
    _clientStatus = ["Active", "Inactive", "Pending"];
    _isLoading = false;
    notifyListeners();
  }

  void clientSelectedStatus(String? status) {
    _clientSelectedStatusInd = status;
    print('${_clientSelectedStatusInd}');
    notifyListeners();
  }

  // search client
  void searchLeadList(String? query) {
    searchQuery = query!.toLowerCase().trim();
    print('search query in provider : ${searchQuery}');
    _searchedclientList =
        _clientList?.where((lead) {
          final clientName = lead.clientName?.toLowerCase() ?? '';
          final companyName = lead.companyName?.toLowerCase() ?? '';
          final contactNumber = lead.contactNumber?.toLowerCase() ?? '';
          final email = lead.email?.toLowerCase() ?? '';
          return clientName.contains(searchQuery) ||
              companyName.contains(searchQuery) ||
              contactNumber.contains(searchQuery) ||
              email.contains(searchQuery);
        }).toList();
    print('searchdLeadList in provider : ${searchQuery}');
    notifyListeners();
  }

  // make phone call and whats app message

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

  void clearFailure() {
    _failure = null;
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

  /******************filter section start ********************/
  void getleadStatusPro() {
    _leadStatusList = [
      "New Lead",
      "Contacted",
      "Qualified",
      'Proposal Sent',
      'Closed',
    ];
    notifyListeners();
  }

  void getleadPriorityPro() {
    _selectedPriorityList = ['Premium', 'Prospect', 'Regular', 'Lost'];
    notifyListeners();
  }

  void selectedStatusPro(int value, String? selectedName) {
    _selectedStatusvalue = value;
    _selectedStatusName = selectedName;
    print(_selectedStatusvalue);
    print(_selectedStatusName);
    notifyListeners();
  }

  void selectedPriorityPro(
    int value,
    String? selectedName,
    String? customerProfileid,
  ) {
    _selectedPriorityvalue = value;
    _selectedPriorityName = selectedName;
    _selectedCustomerProfileId = customerProfileid;
    print(_selectedPriorityvalue);
    print(_selectedPriorityName);
    print("APi ID : ${_selectedCustomerProfileId}");
    notifyListeners();
  }

  // hide and show filter
  void hideandShowFilter() {
    _hideAndShowStatus = !_hideAndShowStatus;
    print('${hideAndShowStatus}');
    notifyListeners();
  }

  // hide and show add Meeting
  void hideandShowMeetings() {
    _hideAndShowMeeting = !_hideAndShowMeeting;
    print('${_hideAndShowMeeting}');
    notifyListeners();
  }

  void clearMeetingData() {
    _selectedMeetingDate = '';
    _selectedTimeFrom = '';
    _selectedTimeTo = '';
    notifyListeners();
  }

  /****************** section end ********************/

  /****************** crud function start********************/

  // get clients
  Future<void> getClientsPro(
    String? search,
    String? status,
    String? customerPriorityId, {
    bool isRefresh = false,
  }) async {
    print('current page : ${currentPage}');
    // print('status : ${status}');
    print('refresh main loading : ${isRefresh}');
    print('refresh main loading : ${isRefresh}');
    if (_currentPage == 1) {
      _currentPage++;
      notifyListeners();
    }

    if (isRefresh == false) {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;
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
    final result = await orderAndClientRepository.getClients(
      token,
      search,
      currentPage.toString(),
      status,
      customerPriorityId,
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
        final fetchedList = success ?? [];
        if (isRefresh == true) {
          print('initial content :  and current page:${_currentPage}');
          // First page → replace list
          _clientList = fetchedList;
          print('aaaaaaaaaaaaaaaaaaaaaaaaa : ${_clientList!.length}');
        } else {
          print('next page content');
          // Next pages → append list
          _clientList!.addAll(fetchedList);
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
        // _clientList = success;
        _totalClient = _clientList!.length.toString();
        // meeting logic for next and old meeting
        // for (var client in _clientList!) {
        //   if (client.meetings != null && client.meetings!.isNotEmpty) {
        //     for (var meeting in client.meetings!) {
        //       if (meeting.date == null) continue;
        //       final meetingDate = DateTime.parse(meeting.date!);
        //       final now = DateTime.now();
        //       if (meetingDate.isBefore(now)) {
        //         // Latest past meeting (closest to now but before)
        //         if (_firstPastMeeting == null || meetingDate.isAfter(now)) {
        //           _firstPastMeeting = meeting;
        //         }
        //       } else {
        //         // Earliest upcoming meeting (closest to now but after)
        //         if (_firstUpcomingMeeting == null ||
        //             meetingDate.isBefore(now)) {
        //           _firstUpcomingMeeting = meeting;
        //         }
        //       }
        //     }
        //   }
        // }
        // print("Latest Past Meeting: ${_firstPastMeeting!.date}");
        // print("Next Upcoming Meeting: ${_firstUpcomingMeeting!.date}");
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  void clearCurrentPage() async {
    _currentPage = 1;
    _hasMore = true;
    _clientList = [];
    notifyListeners();
  }

  Future<void> deleteClientPro(String? id) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await orderAndClientRepository.deleteClients(token, id);

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

  Future<void> orderAndCLientAddMeetingPro(
    String? clientId,
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
    final result = await orderAndClientRepository.addMeetingClient(
      token,
      clientId,
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

  Future<void> clientUpdatePro(
    String? clientId,
    String? companyName,
    String? clientName,
    String? contactNumber,
    String? email,
    String? clientAddress,
    String? status,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await orderAndClientRepository.updateClient(
      token,
      clientId,
      companyName,
      clientName,
      contactNumber,
      email,
      clientAddress,
      status,
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
  /****************** crud function end ********************/

  Future<void> clientAddcallLogsPro(
    String? clientId,
    String? leadId,
    String? callNote,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await orderAndClientRepository.addCallLogsClient(
      token,
      clientId,
      '',
      callNote,
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

  Future<void> isImportant(String? clientId, String? isImportant) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await orderAndClientRepository.markAsImportant(
      token,
      clientId,
      isImportant,
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

  Future<void> deleteClientMeetingPro(String? clientMeetingId) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await orderAndClientRepository.deleteClientMeeting(
      token,
      clientMeetingId,
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
}

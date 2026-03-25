import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/data/model/lead_managment_model/lead_managment_model.dart'
    show LeadData;
import 'package:wisdeals/data/model/order_and_client_model/order_and_client_model.dart';
import 'package:wisdeals/domain/repository/lead_managment_repository.dart';
import 'package:wisdeals/domain/repository/order_and_client_repository.dart';

class MeetingProvider extends ChangeNotifier {
  final OrderAndClientRepository orderAndClientRepository;
  final LeadManagmentRepository leadManagmentRepository;

  MeetingProvider({
    required this.orderAndClientRepository,
    required this.leadManagmentRepository,
  });

  bool _isLoading = false;
  List<String> _filterString = [];
  List<Clients>? _clientList = [];
  List<Clients>? _clientListSearched = [];
  Failure? _failure;
  String? _totalClient;
  List<LeadData>? _leadDataList = [];
  List<LeadData>? _leadDataListSearched = [];
  String searchQuery = '';

  // meeting list next and old meeting
  Meeting? _firstPastMeeting;
  Meeting? _firstUpcomingMeeting;

  // getter
  bool get isLoading => _isLoading;
  List<String> get filterString => _filterString;
  List<Clients>? get clientList => _clientList;
  List<Clients>? get clientListSearched =>
      searchQuery.isEmpty ? _clientList : _clientListSearched;
  Failure? get failure => _failure;
  String? get totalClient => _totalClient;

  // meeting list next and old meeting
  Meeting? get firstPastMeeting => _firstPastMeeting;
  Meeting? get firstUpcomingMeeting => _firstUpcomingMeeting;

  List<LeadData>? get leadDataList => _leadDataList;
  List<LeadData>? get leadDataListSearched =>
      searchQuery.isEmpty ? _leadDataList : _leadDataListSearched;

  void getFilterSection() {
    _filterString = ['All', 'Important', 'today'];
    notifyListeners();
  }

  // get clients
  Future<void> getClientsInmeetingPro() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    final result = await orderAndClientRepository.getClients(
      token,
      '',
      '',
      '',
      '',
    );
    result.fold(
      (failure) {
        _failure = failure;
        _isLoading = false;
        notifyListeners();
      },
      (success) {
        _isLoading = false;
        _clientList =
            success.data?.where((data) {
              return data.meetings!.isNotEmpty;
            }).toList();
        _totalClient = _clientList!.length.toString();
        print('meetings data : ${_clientList}');
        // meeting logic for next and old meeting
        for (var client in _clientList!) {
          if (client.meetings != null && client.meetings!.isNotEmpty) {
            for (var meeting in client.meetings!) {
              if (meeting.date == null) continue;
              final meetingDate = DateTime.parse(meeting.date!);
              final now = DateTime.now();
              if (meetingDate.isBefore(now)) {
                // Latest past meeting (closest to now but before)
                if (_firstPastMeeting == null || meetingDate.isAfter(now)) {
                  _firstPastMeeting = meeting;
                }
              } else {
                // Earliest upcoming meeting (closest to now but after)
                if (_firstUpcomingMeeting == null ||
                    meetingDate.isBefore(now)) {
                  _firstUpcomingMeeting = meeting;
                }
              }
            }
          }
        }
        print("Latest Past Meeting: ${_firstPastMeeting!.date}");
        print("Next Upcoming Meeting: ${_firstUpcomingMeeting!.date}");

        notifyListeners();
      },
    );
  }

  // get lead pro
  Future<void> getLeadMeetingPro(String? status) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print("token ${token}");
    final result = await leadManagmentRepository.getLead(token, status, '', '');
    result.fold(
      (failure) {
        _isLoading = false;
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _isLoading = false;
        // _leadDataAll = success;
        _leadDataList =
            success.data!.where((data) {
              return data.meetings!.isNotEmpty;
            }).toList();
        // total leads count
        // _totalLeads = _leadDataAll!.totalLeads.toString();
        // other lead count
        // _convertedLeads = _leadDataAll!.convertedLeads.toString();
        // _pendingLeads = _leadDataAll!.pendingFollowups.toString();
        // _lostLeads = _leadDataAll!.lostLeads.toString();

        print('lead data list in meeting providersssss : ${_leadDataList}');
        notifyListeners();
      },
    );
  }

  void clearFailure() {
    _failure = null;
    notifyListeners();
  }

  void searchClientList(String? query) {
    searchQuery = query!.toLowerCase().trim();
    print('search query in provider : ${searchQuery}');
    _clientListSearched =
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
    print('searchdLeadList in provider : ${_clientListSearched}');
    notifyListeners();
  }

  void searchLeadList(String? query) {
    searchQuery = query!.toLowerCase().trim();
    print('search query in provider : ${searchQuery}');
    _leadDataListSearched =
        _leadDataList?.where((lead) {
          final clientName = lead.clientName?.toLowerCase() ?? '';
          final companyName = lead.companyName?.toLowerCase() ?? '';
          final contactNumber = lead.contactNumber?.toLowerCase() ?? '';
          final email = lead.email?.toLowerCase() ?? '';
          return clientName.contains(searchQuery) ||
              companyName.contains(searchQuery) ||
              contactNumber.contains(searchQuery) ||
              email.contains(searchQuery);
        }).toList();
    print('searchdLeadList in provider : ${_leadDataListSearched}');
    notifyListeners();
  }
}

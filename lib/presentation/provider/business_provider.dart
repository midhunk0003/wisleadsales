import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wisdeals/core/failure.dart';
import 'package:wisdeals/core/success.dart';
import 'package:wisdeals/data/model/business_client_name_model/business_client_name_model.dart';
import 'package:wisdeals/data/model/business_list_model/business_list_model.dart';
import 'package:wisdeals/data/model/business_name_model/business_name_model.dart';
import 'package:wisdeals/domain/repository/business_repository.dart';
import 'package:wisdeals/services/auth_services.dart';

class BusinessProvider extends ChangeNotifier {
  final BusinessRepository businessRepository;

  BusinessProvider({required this.businessRepository});

  bool _isLoading = false;
  bool _isLoadingDelete = false;
  Failure? _failure;
  Success? _success;
  int? _showCollectedPayments;
  int? _showUpdatePendingField;
  bool _hideAndShowClientList = false;
  bool _hideAndShowBusinessList = false;
  List<Map<String, dynamic>> _businessList = [];
  BusinessClientNameModel? _businessClientName;
  List<BusinessClientName>? _businessClientNameList;
  List<BusinessName>? _businessNamesList;
  List<Map<String, dynamic>>? _filterStringDatas;
  String? _getFilterSelectedIndexName;
  bool _showMonthInMainScreen = false;
  bool _showyearInMainScreen = false;

  // business name and id
  String? _selectedBusinessName;
  String? _selecttedbusinessId;

  // business client name and id
  String? _selectedBusinessClientName;
  String? _selectedBusinessClientId;

  // selected year and month
  String? _selectedMonth = _currentMonth();
  String? _selectedConvertedMonth;
  String? get selectedConvertedMonth => _selectedConvertedMonth;
  String? _selectedYear = DateTime.now().year.toString();

  /// Month List
  final List<String> months = const [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  /// Year List (Last 3 Years)
  late final List<int> years = List.generate(
    3,
    (index) => DateTime.now().year - index,
  );

  int _currentPage = 1;
  int _limit = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // business list
  BusinessData? _businessSingleObjectData;
  List<BusinessListData>? _businessAllListData;

  int? _loadingIndex; // which item loading
  int? get loadingIndex => _loadingIndex;

  List<BusinessListData> _businessListLocal = [];
  List<BusinessListData> get businessListLocal => _businessListLocal;

  // getter
  bool get isLoading => _isLoading;
  bool get isLoadingDelete => _isLoadingDelete;
  Failure? get failure => _failure;
  Success? get success => _success;
  int? get showCollectedPayments => _showCollectedPayments;
  int? get showUpdatePendingField => _showUpdatePendingField;
  bool? get hideAndShowClientList => _hideAndShowClientList;
  bool get hideAndShowBusinessList => _hideAndShowBusinessList;
  List<Map<String, dynamic>>? get businessList => _businessList;
  BusinessClientNameModel? get businessClientName => _businessClientName;
  List<BusinessClientName>? get businessClientNameList =>
      _businessClientNameList;
  List<BusinessName>? get businessNamesList => _businessNamesList;
  List<Map<String, dynamic>>? get filterStringDatas => _filterStringDatas;
  String? get getFilterSelectedIndexName => _getFilterSelectedIndexName;
  bool get showMonthInMainScreen => _showMonthInMainScreen;
  bool get showyearInMainScreen => _showyearInMainScreen;
  // business name and id
  String? get selectedBusinessName => _selectedBusinessName;
  String? get selecttedbusinessId => _selecttedbusinessId;

  // business client name and id
  String? get selectedBusinessClientName => _selectedBusinessClientName;
  String? get selectedBusinessClientId => _selectedBusinessClientId;

  // selected year and month
  String? get selectedMonth => _selectedMonth;
  String? get selectedYear => _selectedYear;

  int get currentPage => _currentPage;
  int get limit => _limit;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  // business list
  BusinessData? get businessSingleObjectData => _businessSingleObjectData;
  List<BusinessListData>? get businessAllListData => _businessAllListData;

  void showMonthMainScreenPro() {
    _showMonthInMainScreen = !_showMonthInMainScreen;
    notifyListeners();
  }

  void showYearMainScreenPro() {
    _showyearInMainScreen = !_showyearInMainScreen;
    notifyListeners();
  }

  void hideAll() {
    _showMonthInMainScreen = false;
    _showyearInMainScreen = false;
    notifyListeners();
  }

  /// Get Current Month Name
  static String _currentMonth() {
    final now = DateTime.now();
    const monthNames = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return monthNames[now.month - 1];
  }

  /// Change Month
  void changeMonth(String month) {
    _selectedMonth = month;
    _selectedConvertedMonth = _convertMonthToNumber(month);
    notifyListeners();
  }

  String _convertMonthToNumber(String month) {
    const monthMap = {
      'January': '01',
      'February': '02',
      'March': '03',
      'April': '04',
      'May': '05',
      'June': '06',
      'July': '07',
      'August': '08',
      'September': '09',
      'October': '10',
      'November': '11',
      'December': '12',
    };

    return monthMap[month] ?? '';
  }

  /// Change Year
  void changeYear(String year) {
    _selectedYear = year;
    print(_selectedMonth);
    print(_selectedYear);
    notifyListeners();
  }

  void resetDateSelection() {
    final now = DateTime.now();

    _selectedMonth = _currentMonth();
    _selectedYear = now.year.toString();
    _selectedConvertedMonth = now.month.toString().padLeft(2, '0');

    notifyListeners(); // if using Provider / ChangeNotifier
  }

  // filter section
  void getFilterData() {
    _filterStringDatas = [
      {
        "statusid": "",
        "title": "All",
        "image": _getStatusImage(''),
        "count": "${_businessSingleObjectData!.summary!.totalCount}",
      },
      {
        "statusid": "pending",
        "title": "Pending",
        "image": _getStatusImage('Pending'),
        "count": "${_businessSingleObjectData!.summary!.pendingCount}",
      },
      {
        "statusid": "collected",
        "title": "Collected",
        "image": _getStatusImage('Collected'),
        "count": "${_businessSingleObjectData!.summary!.completedCount}",
      },
    ];
    notifyListeners();
  }

  void getFilterSelectedIndexNamePro(String? statusid) {
    print('00000000000000 : ${statusid}');
    _getFilterSelectedIndexName = statusid;
    notifyListeners();
  }

  String _getStatusImage(String status) {
    switch (status) {
      case 'Pending':
        return 'assets/images/lead/pending.png';
      case 'Collected':
        return 'assets/images/lead/convertlead.png';
      default:
        return 'assets/images/lead/totalleed.png';
    }
  }

  void hideShowCollectedPaymentsPro(int? index) {
    if (_showCollectedPayments == index) {
      _showCollectedPayments = null; // collapse if already open
      // IMPORTANT: close all meeting  if open
      _showUpdatePendingField = null;
    } else {
      _showCollectedPayments = index; // expand this index
      _showUpdatePendingField = null;
    }
    print('${_showCollectedPayments}');
    notifyListeners();
  }

  void hideShowFormFieldPro(int? index) {
    if (_showUpdatePendingField == index) {
      _showUpdatePendingField = null; // collapse if already open
      // IMPORTANT: close all meeting  if open
      _showCollectedPayments = null;
    } else {
      _showUpdatePendingField = index; // expand this index
      _showCollectedPayments = null;
    }
    print('${_showUpdatePendingField}');
    notifyListeners();
  }

  void hideShowClientList() {
    _hideAndShowClientList = !_hideAndShowClientList;
    notifyListeners();
  }

  void hideShowBusinessList() {
    _hideAndShowBusinessList = !_hideAndShowBusinessList;
    notifyListeners();
  }

  void setBusinessClientNameAndId(String? name, String? id) {
    _selectedBusinessClientName = name;
    _selectedBusinessClientId = id;
    notifyListeners();
  }

  void setBusinessNameAndId(String? name, String? id) {
    _selectedBusinessName = name;
    _selecttedbusinessId = id;
    notifyListeners();
  }

  Future<void> getViewPaymentPro() async {
    _businessList = [
      {
        "business_name": "Hovictus Solutions",
        "client_name": "ABC Traders",
        "collection_pending_status": true,
        "total_business_cost": 50000,
        "pending_collection": 20000,
        "collected_payments": [
          {
            "collected_payment": "Invoice #INV-1001",
            "amount": 5000,
            "collected_date": "2026-01-05",
          },
          {
            "collected_payment": "Invoice #INV-1002",
            "amount": 7000,
            "collected_date": "2026-01-10",
          },
        ],
      },
      {
        "business_name": "TechNova Pvt Ltd",
        "client_name": "Global Mart",
        "collection_pending_status": true,
        "total_business_cost": 65000,
        "pending_collection": 15000,
        "collected_payments": [
          {
            "collected_payment": "Invoice #INV-2001",
            "amount": 10000,
            "collected_date": "2026-01-08",
          },
          {
            "collected_payment": "Invoice #INV-2002",
            "amount": 12000,
            "collected_date": "2026-01-18",
          },
        ],
      },
      {
        "business_name": "BlueWave Technologies",
        "client_name": "City Builders",
        "collection_pending_status": false,
        "total_business_cost": 40000,
        "pending_collection": 0,
        "collected_payments": [
          {
            "collected_payment": "Invoice #INV-3001",
            "amount": 20000,
            "collected_date": "2026-01-12",
          },
          {
            "collected_payment": "Invoice #INV-3002",
            "amount": 20000,
            "collected_date": "2026-01-22",
          },
        ],
      },
      {
        "business_name": "PixelCraft Studio",
        "client_name": "Fashion Hub",
        "collection_pending_status": true,
        "total_business_cost": 30000,
        "pending_collection": 10000,
        "collected_payments": [
          {
            "collected_payment": "Invoice #INV-4001",
            "amount": 8000,
            "collected_date": "2026-01-07",
          },
          {
            "collected_payment": "Invoice #INV-4002",
            "amount": 12000,
            "collected_date": "2026-01-19",
          },
        ],
      },
      {
        "business_name": "NextGen Softwares",
        "client_name": "Sunrise Supermarket",
        "collection_pending_status": true,
        "total_business_cost": 55000,
        "pending_collection": 25000,
        "collected_payments": [
          {
            "collected_payment": "Invoice #INV-5001",
            "amount": 15000,
            "collected_date": "2026-01-09",
          },
          {
            "collected_payment": "Invoice #INV-5002",
            "amount": 15000,
            "collected_date": "2026-01-21",
          },
        ],
      },
    ];
    notifyListeners();
  }

  Future<void> getBusinessClientNamePro(
    String? search, {
    bool isRefresh = false,
  }) async {
    print('is refresh............ :  ${isRefresh}');
    if (isRefresh) {
      _isLoading = true;
      _failure = null;
      _limit = 10; // reset
      _hasMore = true;
      _businessClientNameList = [];
      notifyListeners();
    } else {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;

      // 🔥 Increase limit by 10
      _limit += 10;
      notifyListeners();
    }
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await businessRepository.getBusinessClientName(
      token,
      search,
      _limit.toString(),
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
        _businessClientName = success;
        final clientList = success.data ?? [];
        // 🔥 Replace full list every time
        _businessClientNameList = clientList;
        // Stop pagination if API returns less than limit
        _hasMore = clientList.length == _limit;
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Future<void> getBusinessNamePro(String? search) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await businessRepository.getBusinessName(token, search);
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
        _businessNamesList = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addBusinessPro(
    String? clientId,
    String? businessId,
    String? businessCost,
    String? businessType,
  ) async {
    _isLoading = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await businessRepository.addBusiness(
      token,
      clientId,
      businessId,
      businessCost,
      businessType,
    );
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
        _success = success;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> getAllBusinessListPro(
    String? month,
    String? year,
    String? status,
    String? search, {
    bool isRefresh = false,
  }) async {
    print('is refresh get business............ :  ${isRefresh}');
    print('is search get search............ :  ${isRefresh}');
    if (isRefresh) {
      _isLoading = true;
      _failure = null;
      _limit = 10; // reset
      _hasMore = true;
      // _businessSingleObjectData = null;
      _businessAllListData = [];
      notifyListeners();
    } else {
      if (_isLoadingMore || !_hasMore) return;
      _isLoadingMore = true;

      // 🔥 Increase limit by 10
      _limit += 10;
      notifyListeners();
    }
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await businessRepository.getAllBusinessData(
      token,
      month,
      year,
      status,
      search,
      _limit.toString(),
    );
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
        _businessSingleObjectData = success;
        final businessesList = success.businesses ?? [];
        // 🔥 Replace full list every time
        _businessAllListData = businessesList;
        // Stop pagination if API returns less than limit
        _hasMore = businessesList.length == _limit;
        _isLoading = false;
        _isLoadingMore = false;

        /// 👉 CALL FILTER HERE ✅
        getFilterData();

        notifyListeners();
      },
    );
  }

  Future<void> addAmountPro(
    String? businessId,
    String? collectedAmount,
    int index,
  ) async {
    // _isLoading = true;
    _success = null;
    _failure = null;
    _loadingIndex = index;
    notifyListeners();
    print('aaaaaaaaaaa : ${businessId}');
    print('bbbbbbbbbbb :${collectedAmount}');
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');

    final result = await businessRepository.addAmount(
      token,
      businessId,
      collectedAmount,
    );
    result.fold(
      (failure) async {
        if (failure is AuthFailure) {
          print('vvvvvvvvvvvvvvvvvvvv...${failure.message}');
          await AuthService.forceLogout();
        }
        // _isLoading = false;
        _loadingIndex = null; // stop loader
        _failure = failure;
        notifyListeners();
      },
      (success) {
        _success = success;

        /// 🔥 Update only that business locally
        _updateCollectedAmount(index, collectedAmount);
        // _isLoading = false;
        _loadingIndex = null; // stop loader
        notifyListeners();
      },
    );
  }

  void _updateCollectedAmount(int index, String? amount) {
    if (amount == null) return;

    final business = businessAllListData![index];

    double collected =
        double.tryParse(business.collectedBusinessCost ?? "0") ?? 0;

    double added = double.tryParse(amount) ?? 0;

    business.collectedBusinessCost = (collected + added).toStringAsFixed(2);

    double pending =
        double.tryParse(business.pendingCollection.toString()) ?? 0;

    business.pendingCollection = (pending - added).toStringAsFixed(2);

    /// ---------- 3️⃣ Update Payment List ----------
    business.collectedPayments ??= [];

    business.collectedPayments!.insert(
      0,
      CollectedPaymentsList(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,

        /// ✅ same format as API
        collecteDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      ),
    );
  }

  Future<void> deleteBusinessPro(String? id) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await businessRepository.deleteBusiness(token, id);

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

  Future<void> deletePaymentPro(String? id) async {
    _isLoadingDelete = true;
    _success = null;
    _failure = null;
    notifyListeners();
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? token = pref.getString('token');
    print('token : ${token}');
    final result = await businessRepository.deletePayment(token, id);

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

  void clearBusinessNameAndIdes() {
    _selectedBusinessClientName = null;
    _selectedBusinessName = null;
    _selectedBusinessClientId = null;
    _selecttedbusinessId = null;
    notifyListeners();
  }

  void clearFailure() {
    print('clear failure called');
    _failure = null;
    notifyListeners();
  }
}

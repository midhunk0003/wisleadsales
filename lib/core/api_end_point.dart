class ApiEndPoint {
  // static const String baseUrl = "http://192.168.29.195:8000/api/";
  // static const String photoBaseUrl = "http://192.168.29.195:8000/storage/";

  // static const String baseUrl = "https://app.wisleadcrm.com/api/";
  // static const String photoBaseUrl =
  //     "https://app.wisleadcrm.com/storage/app/public/";

  static const String baseUrl = "https://teams.wwitpl.com/sales-backend/api/";
  static const String photoBaseUrl =
      "https://teams.wwitpl.com/sales-backend/storage/app/public/";

  // https://teams.wwitpl.com/sales-backend/api/login
  // http://app.wisleadcrm.com/api/login

  // auth
  static const String loginEndPoint = "login";

  // addNewLocation
  static const String addNewLocationEndPoint = "addNewLocation";
  // app update version  Api
  static const String versionEndPoint = "Version";

  // addmeeting common api
  static const String addMeetingEndPoint = "AddMeeting";

  // profile
  static const String profileEndPoint = "profile";
  static const String updateProfile = "updateProfile";

  // home api end point
  static const String getHomeEndPoint = "getHome";

  // notification list APi
  static const String notificationsEndPoint = "notifications";
  static const String notificationsReadEndPoint = "notificationsRead";

  // lead managment
  static const String addLeadsEndPoint = "AddLeads";
  static const String leadsEndPoint = "Leads";
  static const String deleteLeadsEndPoint = "DeleteLeads";
  static const String updateLeadsEndPoint = "UpdateLeads";
  static const String leadsConvertToClientEndPoint = "LeadsConvertToClient";
  static const String addcallLogNotesEndPoint = "AddcallLogNotes";
  static const String leadStatusEndPoint = "leadStatus";
  static const String customerProfileEndPoint = "customerProfile";
  static const String leadStatusSummaryEndPoint = "LeadStatusSummary";
  static const String leadSourceEndPoint = "leadSource";

  // delete lead and client meeting
  static const String deleteMeetingEndPoint = "DeleteMeeting";

  // orders and clients
  static const String clientsEndPoint = "Clients";
  static const String showClientsEndPoint = "ShowClients";
  static const String updateClientsEndPoint = "UpdateClients";
  static const String deleteClientsEndPoint = "DeleteClients";
  static const String clientsUpdateImportantEndPoint = "clientsUpdateImportant";

  // attendance and leave
  static const String leaveApplyEndPoint = "leaveApply";
  static const String leaveListEndPoint = "leaveList";
  static const String leaveUpdateEndPoint = "leaveUpdate";
  static const String leaveDeleteEndPoint = "leaveDelete";
  static const String leaveTypesEndPoint = "leaveTypes";

  // expanse
  static const String addExpenseEndPoint = "AddExpense";
  static const String expenseListEndPoint = "ExpenseList";
  static const String updateExpenseEndPoint = "UpdateExpense";
  static const String expenseTypeEndPoint = "expenseType";
  static const String paymentModeEndPoint = "paymentMode";

  // report
  static const String reportsEndPoint = "reports";

  // clock in and clock out
  static const String clockInEndPoint = "clockIn";
  static const String clockOutEndPoint = "clockOut";
}

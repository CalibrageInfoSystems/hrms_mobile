library APIConstants;

var baseUrl = "http://182.18.157.215/HRMS/API"; //  test
//var baseUrl = "http://182.18.157.215/BHRMS/API"; // beta version url
// var baseUrl = "https://hrms.calibrage.in/api"; // live url

const leaveApplyURL = 'http://182.18.157.215:/';
// const leaveApplyURL = 'https://hrms.calibrage.in:/';
//https://localhost:7215/api/Track/SyncTransactions
var getlogin = "/hrmsapi/Security/Login"; // login url post api
var getselfempolyee = "/hrmsapi/Employee/GetSelfEmployeeData/"; // need to pass the empolyeeid
var applyleaveapi = "/hrmsapi/Attendance/CreateEmployeeLeave"; //post api
var getquestions =
    '/hrmsapi/Security/ValidateUserQuestions/'; // pass the username
var changepassword = '/hrmsapi/Security/Forgotpassword';
var getleavesapi = "/hrmsapi/Attendance/GetLeavesForSelfEmployee/";
var getmontlyleaves =
    "/hrmsapi/Attendance/GetLeavesForSelfInMonth"; //parameter months id, employeid
var GetHolidayList = "/hrmsapi/Admin/GetHolidays/";
var getdropdown = "/hrmsapi/Lookup/LookupDetails/";
var lookupkeys = "/hrmsapi/Lookup/LookupKeys";
var GetEmployeePhoto = "/hrmsapi/Employee/GetEmployeePhoto/";
var sendingquestionapi = "/hrmsapi/Security/CreateUserQuestion";
var addquestionsuser = "/hrmsapi/Security/UpdateUserOnFirstLogin";
var fetchquestion = '/hrmsapi/Security/SecureQuestions';
var deleteleave = '/hrmsapi/Attendance/DeleteLeave'; //pass the employeeleaveid
var feedbackapi = '/hrmsapi/Admin/UpdateFeedback'; //post api
var getprojectemployeslist =
    '/hrmsapi/Employee/GetProjectsForSelfEmployee/'; //pass the employeeid
var getadminsettings = '/hrmsapi/AdminDashboard/GetAppSettings';
var getnotification = '/hrmsapi/Notification/GetNotifications';
var sendgreeting = '/hrmsapi/Notification/CreateNotificationReplies';
var getnotificationreplies = '/hrmsapi/Notification/GetNotificationReplies/';
var getupcomingbirthdays =
    '/hrmsapi/Notification/GetUpcomingBirthdaysNotifications';
var getResignations = '/hrmsapi/Resignation/GetResignations';
var applyResignation = '/hrmsapi/Resignation/CreateResignationRequest';
var WithdrawResignation = '/hrmsapi/Resignation/RejectResignationRequest';
var uploadimage = '/hrmsapi/Employee/UpdateEmployeeBasicDetails';
var getemployedata = '/hrmsapi/Employee/GetEmployeeBasedOnId/';
var getleaveStatistics = '/hrmsapi/Attendance/GetLeaveStatistics/';
/* const testLeaveApplyURL = 'http://182.18.157.215:/';
const uatLeaveApplyURL = 'https://hrms.calibrage.in:/'; */
var SyncTransactions = "/hrmsapi/Track/SyncTransactions";
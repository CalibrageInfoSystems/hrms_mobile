class Constants {
  static const String IS_LOGIN = "login_verification";
  static const String USER_ID = "userID";
  static const String WELCOME = "welcome";

  static const String isPunchIn = 'isPunchIn';

  static const String futureDatesErrMsg =
      "The leaves will be allocated for the following year between 16th and 31st December of every year. Apply for the leave(s) by checking this form after 16th Dec.";

  static const String plCurrentDateErrorMessage =
      '''As per the guidelines, applying for today's leave is not supported in the system. For any reason, if the leave or the work from home is required, please contact the HR manager or admin.''';

  static const String wfhDialogMessage =
      '''Your leave request is within the WFH span. Will you want to split this? Please confirm this by clicking 'Confirm' or 'Cancel'.''';

// Cl error msg when try to apply cl on existing cl month
// Kindly confirm whether you wish to retract the previously submitted a leave for the month of April on 10-Apr-2025 which has not yet been approved. Please click 'Confirm' to proceed with revoking the previously applied leave request or 'Cancel' to stop the creation of the current leave.

// applying cl same day as existing cl
// The current leave request on 10-Apr-2025 is overlapping with applied leaves. Please check and try again.
}

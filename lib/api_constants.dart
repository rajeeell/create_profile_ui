class apiConstants {
  static String API_KEY = "AIzaSyDpGhzkSQb1X2Jij4pxy2EXYC3lorZS3q8";

  static String base_url =
      "https://identitytoolkit.googleapis.com/v1/accounts:";
  static String api_Signup = "${base_url}signUp?key=$API_KEY";
  static String api_SignIn = "${base_url}signInWithPassword?key=$API_KEY";
  static String api_ForgetPassword = "${base_url}sendOobCode?key=$API_KEY";
  static String api_ChangePassword = "${base_url}update?key=$API_KEY";
}

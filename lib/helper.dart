class Helper {
  static authErrorHandler(String message) {
    if (message == "INVALID_EMAIL") {
      return "Please enter a valid email";
    } else if (message == "EMAIL_EXISTS") {
      return "The email address is already being used by another account";
    } else if (message == "OPERATION_NOT_ALLOWED") {
      return "Password sign-in is disabled for this project";
    } else if (message == "TOO_MANY_ATTEMPTS_TRY_LATER") {
      return "We have blocked all requests from this device due to unusual activity. Try again later.";
    } else if (message == "EMAIL_NOT_FOUND") {
      return "There is no user record corresponding to this identifier. The user may have been deleted.";
    } else if (message == "INVALID_PASSWORD") {
      return "The password is invalid or the user does not have a password.";
    } else if (message == "USER_DISABLED") {
      return "The user account has been disabled by an administrator.";
    } else {
      return message;
    }
  }
}

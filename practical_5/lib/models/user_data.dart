class UserData {
  static String name = '';
  static String email = '';
  static String password = '';
  static String branch = '';
  static String phoneNumber = '';
  static String city = '';
  static bool isLoggedIn = false;

  static void setUserData({
    required String userName,
    required String userEmail,
    required String userPassword,
    required String userBranch,
    required String userPhone,
    required String userCity,
  }) {
    name = userName;
    email = userEmail;
    password = userPassword;
    branch = userBranch;
    phoneNumber = userPhone;
    city = userCity;
    isLoggedIn = true;
  }

  static void logout() {
    name = '';
    email = '';
    password = '';
    branch = '';
    phoneNumber = '';
    city = '';
    isLoggedIn = false;
  }
}

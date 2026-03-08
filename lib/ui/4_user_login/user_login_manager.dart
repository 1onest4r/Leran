class UserLoginManager {
  Future<bool> login({required String email, required String password}) async {
    // TODO
    return true;
  }

  /// Registers a new user.
  Future<bool> signUp({required String email, required String password}) async {
    // TODO
    return true;
  }

  /// Logs out the current user.
  Future<void> logout() async {
    // TODO
  }

  /// Sends a password reset email or OTP.
  Future<bool> resetPassword({required String email}) async {
    // TODO: delete me
    return true;
  }

  /// Checks if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    // TODO
    return false;
  }
}

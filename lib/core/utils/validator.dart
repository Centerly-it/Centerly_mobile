class AuthValidator {
  // ================= EMAIL =================
  static String? validateEmail(String value) {
    if (value.trim().isEmpty) {
      return 'identifier_required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');

    if (!emailRegex.hasMatch(value.trim())) {
      return 'identifier_invalid';
    }

    return null;
  }

  // ================= PHONE =================
  static String? validatePhone(String value) {
    if (value.trim().isEmpty) {
      return 'identifier_required';
    }

    // international format +2010xxxxxxx
    final egyptPhoneRegex = RegExp(r'^(\+20|0)?1[0-9]{9}$');

    if (!egyptPhoneRegex.hasMatch(value.trim())) {
      return 'identifier_invalid';
    }

    return null;
  }

  // ================= IDENTIFIER (Email or Phone) =================
  static String? validateIdentifier(String value) {
    final input = value.trim();

    if (input.isEmpty) {
      return 'identifier_required';
    }

    if (input.contains('@')) {
      return validateEmail(input);
    } else {
      return validatePhone(input);
    }
  }

  // ================= PASSWORD =================
  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'password_required';
    }

    if (value.length < 6) {
      return 'password_short';
    }

    // at least 1 uppercase
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'password_uppercase';
    }

    // at least 1 lowercase
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'password_lowercase';
    }

    // at least 1 number
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'password_number';
    }

    // at least 1 special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'password_special';
    }

    return null;
  }

  // ================= PRIVATE HELPERS =================
  static bool _isValidEmail(String value) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$');
    return emailRegex.hasMatch(value.trim());
  }

  static bool _isValidPhone(String value) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(value.trim());
  }
}

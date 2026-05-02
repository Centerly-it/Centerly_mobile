import 'package:centrally/core/res/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthValidator {
  // ================= EMAIL =================
  static String? validateEmail(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return StringsManager.validationEmailRequired.tr();
    }

    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');

    if (!emailRegex.hasMatch(v.trim())) {
      return StringsManager.validationEmailInvalid.tr();
    }

    return null;
  }

  // ================= PHONE =================
  static String? validatePhone(String value) {
    if (value.trim().isEmpty) {
      return StringsManager.validationPhoneRequired.tr();
    }

    // Egyptian phone (11 digits)
    final phoneRegex = RegExp(r'^01[0-9]{9}$');

    if (!phoneRegex.hasMatch(value.trim())) {
      return StringsManager.validationPhoneInvalid.tr();
    }

    return null;
  }

  // ================= PASSWORD =================
  static String? validatePassword(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return StringsManager.validationPasswordRequired.tr();
    }

    if (v.length < 8) {
      return StringsManager.passwordMin.tr();
    }

    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return StringsManager.passwordUpperCase.tr();
    }

    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return StringsManager.paswordLowerCase.tr();
    }

    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return StringsManager.passwordNumber.tr();
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
      return StringsManager.passwordSpecial.tr();
    }

    return null;
  }

  //========== password chech state ====================
  static PasswordValidationState validatePasswordLive(String value) {
    return PasswordValidationState(
      hasMinLength: value.length >= 8,
      hasUppercase: RegExp(r'[A-Z]').hasMatch(value),
      hasLowercase: RegExp(r'[a-z]').hasMatch(value),
      hasNumber: RegExp(r'[0-9]').hasMatch(value),
      hasSpecial: RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value),
    );
  }
}

//? i want to return to this point to check if it is in a correct place or not

class PasswordValidationState {
  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  const PasswordValidationState({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasLowercase,
    required this.hasNumber,
    required this.hasSpecial,
  });

  bool get isValid =>
      hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecial;
}

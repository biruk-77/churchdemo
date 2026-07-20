class AppValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? ethiopianPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Accepts: +2519xxxxxxxx, 09xxxxxxxx, 9xxxxxxxx
    final regex = RegExp(r'^(\+251|0)?(9[0-9]{8})$');
    if (!regex.hasMatch(cleaned)) {
      return 'Enter a valid Ethiopian phone number';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null; // optional
    final regex = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$', caseSensitive: false);
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? amount(String? value, {double min = 10.0}) {
    if (value == null || value.trim().isEmpty) return 'Amount is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid amount';
    if (parsed < min) return 'Minimum amount is ${min.toStringAsFixed(0)} ETB';
    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) return 'OTP is required';
    if (value.trim().length != 6) return 'OTP must be 6 digits';
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) return 'OTP must be numeric';
    return null;
  }

  /// Normalizes an Ethiopian phone number to +2519XXXXXXXX format
  static String normalizeEthiopianPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+251')) return cleaned;
    if (cleaned.startsWith('251')) return '+$cleaned';
    if (cleaned.startsWith('0')) return '+251${cleaned.substring(1)}';
    return '+251$cleaned';
  }
}

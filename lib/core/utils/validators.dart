/// Simple form validators for auth screens (error prevention).
class Validators {
  static final _emailRegex =
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$');

  /// Returns an error string, or null if valid.
  static String? email(String value) {
    if (value.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String value, {int min = 6}) {
    if (value.isEmpty) return 'Password is required';
    if (value.length < min) return 'Must be at least $min characters';
    return null;
  }

  static String? required(String value, String field) {
    if (value.trim().isEmpty) return '$field is required';
    return null;
  }
}

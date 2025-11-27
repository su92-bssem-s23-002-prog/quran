/// Input validation utilities
class Validators {
  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  /// Validate password strength
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    return null; // Valid
  }

  /// Validate password strength (lenient version for existing users)
  static String? validatePasswordLenient(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  /// Validate full name
  static String? validateName(String name) {
    if (name.isEmpty) {
      return 'Name cannot be empty';
    }
    if (name.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String phone) {
    if (phone.isEmpty) {
      return 'Phone number cannot be empty';
    }
    // Remove common separators
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Password strength score (0-4)
  static int getPasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password))
      score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score > 4 ? 4 : score;
  }

  /// Get password strength label
  static String getPasswordStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  /// Validate that two passwords match
  static String? validatePasswordMatch(
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Generic required field validator
  static String? validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }
}

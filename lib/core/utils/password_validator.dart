/// Password validation utilities with enhanced security
class PasswordValidator {
  /// Minimum password length (industry standard for security)
  static const int minLength = 12;

  /// Validate password with comprehensive checks
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    if (password.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    // Check for at least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return r'Password must contain at least one special character (!@#$%^&*...)';
    }

    return null;
  }

  /// Calculate password strength (0-4)
  /// 0 = Very Weak, 1 = Weak, 2 = Fair, 3 = Strong, 4 = Very Strong
  static int calculateStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;

    // Length bonus
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character variety
    if (password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[A-Z]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[0-9]'))) {
      strength++;
    }

    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      strength++;
    }

    // Cap at 4
    return strength > 4 ? 4 : strength;
  }

  /// Get strength label
  static String getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Very Weak';
      case 2:
        return 'Weak';
      case 3:
        return 'Fair';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  /// Get strength color for UI
  static String getStrengthColorHex(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return '#DC2626'; // Red
      case 2:
        return '#F59E0B'; // Orange
      case 3:
        return '#10B981'; // Green
      case 4:
        return '#059669'; // Dark Green
      default:
        return '#6B7280'; // Gray
    }
  }

  /// Generate password suggestions
  static List<String> getSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < minLength) {
      suggestions.add('Use at least $minLength characters');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      suggestions.add('Add uppercase letters');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      suggestions.add('Add lowercase letters');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      suggestions.add('Add numbers');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      suggestions.add(r'Add special characters (!@#$%...)');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Great! Your password is strong');
    }

    return suggestions;
  }

  /// Check if password is compromised (to be used with Supabase backend)
  /// This is handled by Supabase Auth automatically when enabled
  static String getLeakedPasswordMessage() {
    return 'This password has appeared in a data breach and is not secure. '
        'Please choose a different password to protect your account.';
  }
}

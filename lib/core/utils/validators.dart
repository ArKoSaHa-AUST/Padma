class AppValidators {
  AppValidators._();

  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? emailOrStudentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter your university email or Student ID';
    }
    final trimmed = value.trim();
    final isEmail = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed);
    final isStudentId = RegExp(r'^\d{2}[-\s]?\d{5}[-\s]?\d{1}$').hasMatch(trimmed) ||
        RegExp(r'^\d{7,9}$').hasMatch(trimmed);

    if (!isEmail && !isStudentId) {
      return 'Please enter a valid AUST email or Student ID (e.g. 20-01234-1)';
    }
    return null;
  }

  static String? universityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'University email is required';
    }
    final trimmed = value.trim();
    if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? studentId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student ID is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 5) {
      return 'Student ID is too short';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact phone number is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 8) {
      return 'Please enter a valid contact number';
    }
    return null;
  }
}

String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) return '$fieldName is required';
  return null;
}

String? validatePhone(String? value) {
  if (value == null || value.trim().isEmpty) return 'Phone number is required';
  if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
    return 'Enter a valid 10-digit phone number';
  }
  return null;
}

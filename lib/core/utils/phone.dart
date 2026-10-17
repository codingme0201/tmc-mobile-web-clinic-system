import 'package:flutter/services.dart';

/// Philippine mobile numbers are exactly 11 digits (e.g. 09171234567),
/// matching the backend PhoneNumber rule.
const int phoneDigits = 11;

/// Digits only, never more than 11.
final List<TextInputFormatter> phoneInputFormatters = [
  FilteringTextInputFormatter.digitsOnly,
  LengthLimitingTextInputFormatter(phoneDigits),
];

String? validatePhone(String? value, {String? requiredMessage}) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return requiredMessage;
  if (digits.length != phoneDigits) {
    return 'Phone number must be exactly $phoneDigits digits (e.g. 09171234567).';
  }
  return null;
}

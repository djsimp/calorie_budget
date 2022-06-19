String? emailValidator(String? value) {
  RegExp emailRegExp = RegExp(r'(@)(.+)$');
  return !emailRegExp.hasMatch(value?.trim() ?? '')
      ? 'Please enter a valid email address.'
      : null;
}

String? passwordValidator(String? value) =>
    value?.isEmpty ?? true ? 'Please enter a password.' : null;

String? verifyPasswordValidator(String? value, String? compareValue) =>
    value != compareValue ? 'Passwords must match.' : null;

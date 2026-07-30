import 'dart:ui';

String ordinal(int number, Locale locale) {
  switch (locale.languageCode) {
    case 'de':
      return '$number.';

    case 'en':
      final mod100 = number % 100;
      if (mod100 >= 11 && mod100 <= 13) {
        return '${number}th';
      }

      return switch (number % 10) {
        1 => '${number}st',
        2 => '${number}nd',
        3 => '${number}rd',
        _ => '${number}th',
      };

    default:
      return number.toString();
  }
}

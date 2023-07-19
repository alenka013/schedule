import 'package:intl/intl.dart';

DateFormat customDateFormat = DateFormat('dd.MM.yyyy H:mm');

String extractTime(String? dateTimeString) {
  try {
    if (dateTimeString != null) {
      final parsedDateTime = customDateFormat.parse(dateTimeString);
      final timeFormat = DateFormat.Hm();
      return timeFormat.format(parsedDateTime);
    }
  } catch (e) {
    print('Ошибка при разборе даты: $e');
  }
  return '';
}

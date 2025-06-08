import 'package:intl/intl.dart';

class TimezoneService {
  static const Map<String, int> timezoneOffsets = {
    'WIB': 7, // UTC+7
    'WITA': 8, // UTC+8
    'WIT': 9, // UTC+9
    'London': 0, // UTC+0 (atau UTC+1 saat daylight saving)
  };

  static DateTime convertToTimezone(DateTime utcTime, String timezone) {
    if (!timezoneOffsets.containsKey(timezone)) {
      return utcTime;
    }

    int offset = timezoneOffsets[timezone]!;
    return utcTime.add(Duration(hours: offset));
  }

  static String formatTime(DateTime dateTime, String timezone) {
    DateTime convertedTime = convertToTimezone(dateTime.toUtc(), timezone);
    return DateFormat('HH:mm:ss').format(convertedTime);
  }

  static String formatDateTime(DateTime dateTime, String timezone) {
    DateTime convertedTime = convertToTimezone(dateTime.toUtc(), timezone);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(convertedTime);
  }

  static List<String> getSupportedTimezones() {
    return ['WIB', 'WITA', 'WIT', 'London'];
  }

  static String getCurrentTimeInTimezone(String timezone) {
    DateTime now = DateTime.now().toUtc();
    return formatTime(now, timezone);
  }
}

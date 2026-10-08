import 'package:intl/intl.dart';

class AppFormatters {
  AppFormatters._();

  static String time(DateTime dateTime, [String locale = 'en']) {
    return DateFormat('hh:mm a', locale).format(dateTime);
  }

  static String date(DateTime dateTime, [String locale = 'en']) {
    return DateFormat('MMM dd, yyyy', locale).format(dateTime);
  }

  static String shortDate(DateTime dateTime, [String locale = 'en']) {
    return DateFormat('MMM dd', locale).format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  static String toBanglaDigits(String input) {
    const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bn = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    var result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(en[i], bn[i]);
    }
    return result;
  }
}

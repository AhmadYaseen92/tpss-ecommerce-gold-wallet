import 'package:intl/intl.dart';

class AppDateFormats {
  AppDateFormats._();

  static final DateFormat transactionDateTime = DateFormat('yyyy-MM-dd HH:mm');
  static final DateFormat readableDateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat readableDate = DateFormat('EEE, dd MMM yyyy');
}

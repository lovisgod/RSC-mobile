import 'package:intl/intl.dart';

final _nairaFormatter = NumberFormat('#,##0', 'en_NG');
final _dateFormatter = DateFormat('MMM d, yyyy');
final _dateTimeFormatter = DateFormat('M/d/yyyy hh:mm a');

String formatNaira(double amount) => '₦${_nairaFormatter.format(amount)}';

String formatDate(String isoDate) => _dateFormatter.format(DateTime.parse(isoDate));

String formatDateTime(DateTime dt) => _dateTimeFormatter.format(dt);

class HubDateFormat {
  const HubDateFormat._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String short(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}

class StreakCalendarResponse {
  final String month;
  final List<DateTime> activeDates;

  const StreakCalendarResponse({
    required this.month,
    required this.activeDates,
  });

  factory StreakCalendarResponse.fromJson(Map<String, dynamic> json) {
    final list = json['activeDates'];
    final dates = list is List
        ? list
              .whereType<String>()
              .map(DateTime.tryParse)
              .whereType<DateTime>()
              .toList()
        : <DateTime>[];
    return StreakCalendarResponse(
      month: (json['month'] ?? '').toString(),
      activeDates: dates,
    );
  }
}

class XpHistoryItem {
  final DateTime date;
  final int xp;

  const XpHistoryItem({required this.date, required this.xp});

  factory XpHistoryItem.fromJson(Map<String, dynamic> json) {
    final raw = json['date'];
    final parsed = raw is String ? DateTime.tryParse(raw) : null;
    return XpHistoryItem(
      date: parsed ?? DateTime.now(),
      xp: (json['xp'] as num?)?.toInt() ?? 0,
    );
  }
}

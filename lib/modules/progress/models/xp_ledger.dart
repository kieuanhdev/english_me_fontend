/// Một transaction XP trả từ `GET /api/users/me/xp/ledger`.
/// Spec §9.4.2.
class XpLedgerItem {
  final int id;
  final int amount;
  final String sourceType;
  final String sourceId;
  final DateTime occurredAt;

  const XpLedgerItem({
    required this.id,
    required this.amount,
    required this.sourceType,
    required this.sourceId,
    required this.occurredAt,
  });

  factory XpLedgerItem.fromJson(Map<String, dynamic> json) {
    return XpLedgerItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      sourceType: (json['sourceType'] ?? '').toString(),
      sourceId: (json['sourceId'] ?? '').toString(),
      occurredAt:
          DateTime.tryParse(json['occurredAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Trang cursor-based của ledger. `nextCursor: null` ⇒ hết trang.
class XpLedgerPage {
  final List<XpLedgerItem> items;
  final String? nextCursor;

  const XpLedgerPage({required this.items, this.nextCursor});

  bool get hasMore => nextCursor != null && nextCursor!.isNotEmpty;

  factory XpLedgerPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return XpLedgerPage(
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(XpLedgerItem.fromJson)
                .toList(growable: false)
          : const [],
      nextCursor: json['nextCursor']?.toString(),
    );
  }
}

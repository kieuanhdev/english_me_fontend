/// Trạng thái mục tiêu XP/ngày — khớp `DailyGoalResponse` backend
/// (`GET/PUT /api/users/me/daily-goal`).
class DailyGoal {
  final int targetXp;
  final int earnedXp;
  final bool reached;

  /// Các mức preset hợp lệ để render lựa chọn (vd 20/30/50/80).
  final List<int> allowedGoals;

  const DailyGoal({
    required this.targetXp,
    required this.earnedXp,
    required this.reached,
    required this.allowedGoals,
  });

  factory DailyGoal.fromJson(Map<String, dynamic> json) => DailyGoal(
    targetXp: (json['targetXp'] as num?)?.toInt() ?? 30,
    earnedXp: (json['earnedXp'] as num?)?.toInt() ?? 0,
    reached: json['reached'] as bool? ?? false,
    allowedGoals: (json['allowedGoals'] as List?)
            ?.map((e) => (e as num).toInt())
            .toList() ??
        const [20, 30, 50, 80],
  );

  /// Nhãn mô tả cường độ theo mức XP (cho UI lựa chọn).
  static String labelFor(int goal) {
    if (goal <= 20) return 'Nhẹ nhàng';
    if (goal <= 30) return 'Vừa phải';
    if (goal <= 50) return 'Chăm chỉ';
    return 'Cường độ cao';
  }
}

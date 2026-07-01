/// Cờ báo tiến độ giáo trình đã thay đổi (xem lý thuyết / nộp luyện tập / nộp
/// bài) để màn danh sách Unit & chi tiết Unit biết có cần refetch khi quay lại
/// hay không. Tránh gọi API thừa khi người dùng chỉ mở rồi back ra ngay (không
/// làm gì) — lúc đó dữ liệu không đổi, refetch là lãng phí.
///
/// Static thuần (không GetxController) vì chỉ là 1 bit trạng thái dùng chung,
/// không cần reactive/binding.
class CurriculumProgressBus {
  CurriculumProgressBus._();

  static bool _dirty = false;

  /// Đánh dấu tiến độ đã đổi — gọi sau mỗi lần ghi tiến độ lên server.
  static void markDirty() => _dirty = true;

  /// Đọc cờ KHÔNG reset. Dùng cho màn trung gian (unit detail) — vẫn cần để
  /// màn ngoài (unit list) thấy cờ khi back tiếp ra.
  static bool get isDirty => _dirty;

  /// Đọc cờ RỒI reset. Dùng cho màn ngoài cùng (unit list) — chốt 1 chu kỳ.
  static bool consume() {
    final v = _dirty;
    _dirty = false;
    return v;
  }
}

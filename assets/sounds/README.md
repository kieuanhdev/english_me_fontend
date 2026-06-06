# Hiệu ứng âm thanh (SFX)

Đặt 5 file `.mp3` ngắn (≈0.3–1.5 giây) vào thư mục này. Tên file phải **đúng chính xác**
như dưới đây (khớp với `lib/core/services/sound_service.dart`):

| File             | Khi nào phát                                  | Gợi ý âm thanh           |
|------------------|-----------------------------------------------|--------------------------|
| `correct.mp3`    | Trả lời đúng 1 câu                            | tiếng "ting"/"ding" vui  |
| `wrong.mp3`      | Trả lời sai 1 câu                             | tiếng "buzz"/"uh-oh" nhẹ |
| `complete.mp3`   | Hoàn thành 1 bài tập / test / phiên ôn        | fanfare ngắn             |
| `daily_goal.mp3` | Đạt mục tiêu XP trong ngày (daily goal)       | chuông chúc mừng         |
| `level_up.mp3`   | Lên cấp CEFR / vượt checkpoint                | fanfare "level up" dài hơn|

## Nguồn miễn phí (license thương mại OK, không cần ghi công)

- **Pixabay Sound Effects** — https://pixabay.com/sound-effects/
  (tìm: "correct", "wrong answer", "success", "level up", "win")
- **Mixkit** — https://mixkit.co/free-sound-effects/game/
- **freesound.org** — https://freesound.org (chú ý lọc license CC0)

## Lưu ý

- App **không crash** nếu thiếu file: `SoundService.play` nuốt lỗi và chỉ rung
  haptic làm phản hồi. Cứ thêm dần từng file.
- Dùng `.mp3` cho gọn dung lượng. Giữ file < ~50 KB mỗi cái.
- Sau khi thêm file, chạy lại `flutter pub get` rồi rebuild app (asset mới cần
  được bundle lại).

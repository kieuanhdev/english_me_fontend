# EnglishMe — Mobile (Flutter)

Ứng dụng học tiếng Anh thích nghi cho đồ án tốt nghiệp (Nguyễn Kiều Anh — 64KTPM4).
Mobile client kết nối Spring Boot backend; tập trung vào 3 trụ kỹ thuật:

1. **SM-2 Spaced Repetition** — lịch ôn flashcard theo `easinessFactor` + `intervalDays`.
2. **Pronunciation scoring** — chấm phát âm bằng Levenshtein + WER (multipart upload).
3. **Adaptive Placement Test** — gợi ý CEFR (A1..C2) sau bài test khởi tạo.

Các module vệ tinh: Home dashboard, Profile, Progress, Vocabulary, Grammar, Exercise, User Test.

## Cấu trúc nhanh

```
lib/
├── core/        # config, network (DioClient + ApiException), widgets dùng chung (ApiStateView)
├── data/        # models + repositories cấp app (user, auth, flashcard, ...)
├── modules/     # 1 thư mục = 1 màn hình lớn (bindings + controllers + repositories + views)
├── routes/      # AppRoutes + AppPages
└── theme/       # AppColors / AppTypography
test/             # unit + widget test
docs/
├── PROJECT_DOCUMENTATION.md  # spec backend (source of truth)
├── MOBILE_ALIGNMENT_PLAN.md  # nhật ký refactor mobile theo từng phase
└── MOBILE_DEV_SETUP.md       # hướng dẫn clone + chạy trong 5 phút
```

## Bắt đầu

Xem [docs/MOBILE_DEV_SETUP.md](docs/MOBILE_DEV_SETUP.md) — clone tới chạy được app trong ≤ 5 phút.

Nếu cần đối chiếu shape API backend: [docs/PROJECT_DOCUMENTATION.md](docs/PROJECT_DOCUMENTATION.md).
Nếu muốn xem từng quyết định refactor: [docs/MOBILE_ALIGNMENT_PLAN.md](docs/MOBILE_ALIGNMENT_PLAN.md).

## Verify

```powershell
flutter analyze   # 0 issues
flutter test      # 17 test cases pass (api_exception, api_state_view, vocabulary level, exercise question)
```

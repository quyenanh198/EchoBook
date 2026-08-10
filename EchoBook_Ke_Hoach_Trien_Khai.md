# EchoBook – Kế hoạch triển khai chi tiết

## 1. Quyết định phạm vi (theo xác nhận của bạn)

| Hạng mục | Quyết định |
|---|---|
| Nền tảng ưu tiên | Windows desktop hoàn thiện trước. iOS/Android: code sẵn sàng cross-platform nhưng **không build binary thật** trong phiên này (sandbox không có Xcode/Android SDK). |
| Tech stack | **Flutter (Dart)** — 1 codebase cho Windows/iOS/Android/macOS/Linux |
| TTS | Dùng TTS hệ thống (giọng VN mặc định, US phụ) qua `flutter_tts`. Kiến trúc `VoiceEngine` tách lớp để cắm model cloning thật sau này. |
| Voice cloning | Kiến trúc đầy đủ (ghi âm/upload mẫu, lưu profile, dùng cho export) nhưng bản đầu dùng giải pháp nhẹ (biến đổi pitch/timbre theo mẫu), gắn nhãn **Beta**, có interface để nâng cấp lên engine nặng (vd Coqui XTTS) sau. |
| Cách triển khai | Làm liên tục qua các giai đoạn, **không dừng xin xác nhận giữa chừng**, báo cáo kết quả + test cuối cùng. |

## 2. Kiến trúc tổng thể

- **State management:** Riverpod
- **Local DB:** Drift (SQLite) — bảng `Book`, `ReadingProgress`, `Bookmark`, `VoiceProfile`, `ExportJob`
- **Lưu file:** `path_provider` — ebook gốc + audio export lưu local
- **Parse ebook:** `epubx`/`epub` cho EPUB, `pdfx`/`syncfusion_flutter_pdfviewer` cho PDF, đọc thẳng cho TXT. MOBI/AZW3: hỗ trợ cơ bản, nếu thư viện Dart không đủ sẽ ghi rõ giới hạn + gợi ý convert bằng Calibre trước khi import.
- **TTS:** `flutter_tts` (bọc TTS gốc của Windows/iOS/Android) + interface `VoiceEngine` trừu tượng
- **Audio pipeline:** ffmpeg (qua binary local hoặc `ffmpeg_kit`) để ghép câu, convert MP3 (128/192/320kbps)/M4A/WAV
- **Testing:** `flutter_test` (unit/widget), `mocktail`, `integration_test`

## 3. Cấu trúc thư mục

```
lib/
  core/            # theme (dark + teal accent), constants, utils
  data/            # models, Drift schema, repositories
  features/
    library/
    reader/
    tts_player/
    voices/
    export/
  services/        # tts_service, parsing_service, export_service, voice_clone_service
  app.dart
  main.dart
test/
```

## 4. Các giai đoạn triển khai

1. **Setup** — Flutter project, theme dark/teal, navigation shell 4 tab (Library/Reader/Voices/Export), responsive desktop + mobile.
2. **Library & Import** — Drift schema, import EPUB/PDF/TXT (drag-drop Windows + file picker), extract metadata/cover, grid/list, search/sort (Recent/Title/Author/Progress), xoá sách kèm dữ liệu liên quan, nút "+ Import Ebook" nổi.
3. **Reader** — render EPUB/PDF/TXT, page-turn + scroll, tuỳ chỉnh font/theme (Dark/Sepia/Light)/line-height/margin, TOC, bookmark, auto-save vị trí (chương + % + timestamp), hiển thị tiến độ + thời gian còn lại.
4. **TTS + Mini Player** — `flutter_tts` (VN mặc định, US phụ), tách câu để highlight khi đọc, controls (play/pause, ±15s, tốc độ 0.5–3.0x, sleep timer), mini player bar theo thiết kế, giữ phát khi chuyển tab.
5. **Voices & Cloning** — danh sách giọng hệ thống + giọng clone, slider speed/pitch, luồng ghi âm/upload mẫu 1–2 phút → lưu voice profile offline, đánh dấu giọng mặc định. Cloning: kiến trúc pluggable, bản đầu dùng biến đổi giọng nhẹ, nhãn Beta.
6. **Audio Export** — chọn chương hiện tại/nhiều chương/toàn sách/khoảng tuỳ chỉnh, chọn giọng + tốc độ + định dạng, ước tính dung lượng & thời gian, progress bar, lưu + chia sẻ file.
7. **UI polish** — khớp thiết kế tham chiếu: charcoal nền, teal accent, rounded card, spacing, responsive Windows/mobile, touch target lớn trên mobile.
8. **Automated tests** — unit test (parsing, progress save/restore, DB CRUD), widget test (player, cloning flow), integration test (luồng import → đọc → nghe → export). Chạy tới khi pass hết, báo cáo kết quả rõ ràng.
9. **Windows build** — `flutter build windows`, hướng dẫn đóng gói installer (Inno Setup/MSIX).
10. **Chuẩn bị mobile** — code cross-platform sẵn; README hướng dẫn build iOS (cần macOS+Xcode) và Android (cần Android Studio/SDK) trên máy thật của bạn.

## 5. Giới hạn cần lưu ý

- Sandbox chỉ chạy Linux: viết code Flutter đầy đủ + chạy được unit/widget test, nhưng **không tạo được file .exe Windows hay build iOS thật** trong phiên này — bạn cần chạy `flutter build` trên máy tương ứng theo hướng dẫn README.
- Voice cloning chất lượng cao thật sự (model neural lớn, cần GPU) không khả thi chạy trong sandbox — sẽ triển khai kiến trúc + giải pháp nhẹ, có đường nâng cấp rõ ràng.
- MOBI/AZW3: hỗ trợ ở mức cơ bản tuỳ thư viện có sẵn, sẽ báo rõ nếu có giới hạn.

## 6. Deliverables cuối phiên

- Toàn bộ source code Flutter, module hoá, có comment
- README: kiến trúc, chạy dev/test trên Linux, hướng dẫn build Windows/iOS/Android trên máy thật
- Bộ test tự động + kết quả pass/fail
- Danh sách giới hạn đã biết + đề xuất bước tiếp theo

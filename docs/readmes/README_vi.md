# `System26`

System26 là một tiện ích gốc được thiết kế để thử framework `SystemLanguageModel` ngay trên thiết bị Apple. Nó hiển thị các chỉ số hiệu suất thời gian thực cho các Mô hình Nền tảng cục bộ trên toàn hệ sinh thái Apple.

## Mục đích

Ứng dụng giúp nhà phát triển và người đam mê xem cách suy luận trên thiết bị hoạt động trên Apple Silicon mà không cần dựa vào kết nối đám mây.

## Nền tảng Hỗ trợ

*   **macOS:** Được tối ưu hóa cho quy trình làm việc trên máy tính để bàn.
*   **iOS (iPhone):** Giao diện di động phản hồi hoàn toàn.
*   **iPadOS:** Hỗ trợ chế độ xem chia đôi và bố cục màn hình lớn.

## Tính năng

*   **Xem hiệu suất thời gian thực:**
    *   **Thông lượng:** Đo tốc độ tạo theo Token Mỗi Giây (TPS).
    *   **Độ trễ:** Theo dõi Thời gian đến Token Đầu tiên (TTFT) với độ chính xác mili giây.
    *   **Bộ nhớ:** Giám sát mức sử dụng bộ nhớ thường trú trong quá trình suy luận.
    *   **Nhiệt:** Báo cáo trạng thái nhiệt của thiết bị (Bình thường, Khá, Nghiêm trọng, Nguy kịch).
*   **Chế độ có sẵn:**
    *   **Mục đích Chung:** Tạo văn bản tiêu chuẩn.
    *   **Gắn thẻ Nội dung:** Các tác vụ trích xuất và phân loại chuyên biệt.
    *   **Công cụ Viết:** Mô phỏng hiệu đính và chỉnh sửa.
    *   **Tóm tắt:** Kiểm tra nén văn bản.
    *   **Dịch Trực tiếp:** Hiệu suất dịch ngôn ngữ thời gian thực.
*   **Tùy chỉnh:** Hướng dẫn hệ thống và lời nhắc hoàn toàn có thể chỉnh sửa để kiểm tra các hành vi mô hình khác nhau.
*   **Bản địa hóa:** Được bản địa hóa hoàn toàn bằng 10 ngôn ngữ (Tiếng Anh, Tiếng Trung, Tiếng Tây Ban Nha, Tiếng Pháp, Tiếng Bồ Đào Nha, Tiếng Đức, Tiếng Ý, Tiếng Nhật, Tiếng Hàn, Tiếng Việt).

## Điều kiện Tiên quyết

*   **Hệ điều hành:** macOS 26 (Tahoe), iOS 26, iPadOS 26, visionOS 26 hoặc mới hơn.
*   **Phần cứng:** Thiết bị có Apple Neural Engine (Chip Apple Silicon M-Series hoặc A-Series).
*   **Phát triển:** Cần có Xcode 26+ để xây dựng.

## Cách Chạy

1.  Mở `System26.xcodeproj` trong Xcode.
2.  Chọn thiết bị mục tiêu của bạn (Mac, iPhone hoặc iPad).
3.  Xây dựng và Chạy (Cmd + R).

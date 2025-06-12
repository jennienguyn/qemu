# QEMU Quick Setup Script

Script `setup_qemu.sh` giúp bạn tự động cấu hình và khởi tạo một máy ảo QEMU dựa theo cấu hình bạn nhập. Nó hỗ trợ chọn CPU, RAM, card mạng, card âm thanh, giao diện hiển thị và tự động tải file ISO. Cuối cùng, script sẽ tạo một file `.sh` để bạn dễ dàng khởi động máy ảo.

## 🛠 Tính năng

- Cài đặt QEMU tự động nếu chưa có
- Tải file ISO từ link bạn nhập (tự động thử lại bằng `curl` nếu `wget` lỗi)
- Tạo ổ cứng ảo định dạng QCOW2
- Hỗ trợ cấu hình:
  - Số nhân CPU
  - RAM (hỗ trợ định dạng như `2048M`, `2G`, v.v.)
  - Có hoặc không dùng VNC
  - Card mạng (gõ `listethernet` để xem danh sách)
  - Card âm thanh (gõ `listaudio` để xem danh sách)
- Tạo sẵn file `.sh` để khởi động máy ảo

## 🚀 Hướng dẫn sử dụng

### 1. Tải và cấp quyền chạy cho script

```bash
wget https://yourdomain.com/setup_qemu.sh
chmod +x setup_qemu.sh
````

### 2. Chạy script

> ⚠️ Bạn có thể cần chạy với quyền `sudo` nếu QEMU chưa được cài.

```bash
./setup_qemu.sh
```

### 3. Trả lời các câu hỏi sau:

* Số nhân CPU bạn muốn dùng
* Dung lượng RAM (ví dụ: `2048M` hoặc `2G`)
* Có muốn dùng VNC không? (`Y/N`)
* Card mạng bạn muốn dùng (gõ `listethernet` để xem các lựa chọn)
* Card âm thanh bạn muốn dùng (gõ `listaudio` để xem các lựa chọn)
* Dung lượng ổ cứng ảo muốn tạo (ví dụ `150G`)
* Link tải file ISO
* Tên file `.sh` đầu ra (ví dụ `run_ubuntu.sh`)

Script sẽ tiến hành tải ISO (dùng `wget`, nếu lỗi sẽ thử `curl`) và tạo script khởi động tương ứng.

### 4. Chạy máy ảo

Sau khi script tạo xong, chạy máy ảo bằng lệnh:

```bash
./ten_file_ban_nhap.sh
```

Ví dụ:

```bash
./run_ubuntu.sh
```

## 📦 Yêu cầu

* Hệ điều hành: Ubuntu/Debian
* Gói `qemu-system` (script sẽ tự cài nếu chưa có)
* Kết nối Internet để tải file ISO

## ❗ Lưu ý

* Nếu bạn nhập `listethernet` hoặc `listaudio`, script sẽ liệt kê các thiết bị tương ứng rồi yêu cầu bạn nhập lại.
* Nếu tải ISO thất bại cả bằng `wget` và `curl`, script sẽ dừng với thông báo lỗi.
* Ổ đĩa ảo và file ISO sẽ nằm trong cùng thư mục với script.

## 📃 License

MIT License

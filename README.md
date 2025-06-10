# QEMU Quick Setup Script

Script `setup_qemu.sh` giúp bạn tự động cấu hình và khởi tạo một máy ảo QEMU với file ISO bạn cung cấp. Nó sẽ hỏi các thông số cần thiết, tải ISO, tạo ổ cứng ảo, và tạo sẵn file `start.sh` để chạy máy ảo.

## 🛠 Tính năng

- Cài đặt QEMU tự động nếu chưa có
- Tải file ISO từ link bạn nhập
- Tạo ổ cứng ảo định dạng QCOW2
- Hỗ trợ chọn:
  - Số nhân & luồng CPU
  - RAM
  - Chế độ mạng (NAT hoặc Bridge)
  - Giao diện đồ họa hoặc VNC
- Tạo sẵn file `start.sh` để chạy máy ảo

## 🚀 Hướng dẫn sử dụng

### 1. Tải và cấp quyền chạy cho script

```bash
wget https://yourlink.com/setup_qemu.sh
chmod +x setup_qemu.sh
````

### 2. Chạy script

> ⚠️ Cần chạy với quyền `sudo` để có thể cài QEMU và tạo bridge nếu cần.

```bash
sudo ./setup_qemu.sh
```

### 3. Trả lời các câu hỏi

Script sẽ hỏi bạn các thông số cấu hình như:

* Số nhân CPU
* Số luồng CPU
* Dung lượng RAM
* Kích hoạt VNC không
* Chế độ mạng (NAT hoặc Bridge)
* Dung lượng ổ đĩa ảo
* Link file ISO để tải

### 4. Chạy máy ảo

Sau khi cấu hình xong, chạy máy ảo bằng file:

```bash
./start.sh
```

## 📦 Yêu cầu

* Hệ điều hành: Ubuntu/Debian
* QEMU (sẽ được cài tự động nếu chưa có)
* Kết nối Internet để tải ISO

## ❗ Lưu ý

* Nếu bạn chọn chế độ `Bridge`, cần có bridge mạng tên `br0`. Nếu chưa có, bạn cần cấu hình bridge thủ công.
* File ISO và ổ đĩa ảo sẽ được lưu cùng thư mục với script.

## 📃 License

MIT License
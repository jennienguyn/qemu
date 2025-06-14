# Hướng dẫn cài đặt và cấu hình máy ảo QEMU tự động

---

Tập lệnh Bash này giúp tự động hóa quá trình cài đặt QEMU/KVM và tạo một máy ảo với các tùy chọn cấu hình do người dùng cung cấp.

---

## Các tính năng chính

* **Cài đặt tự động:** Tự động cài đặt các gói QEMU, KVM và Libvirt cần thiết.
* **Kiểm tra KVM:** Xác minh khả năng tương thích của CPU với KVM để đảm bảo hiệu suất tối ưu.
* **Cấu hình linh hoạt:** Hỏi người dùng các thông số quan trọng cho máy ảo như:
    * **Số nhân CPU**
    * **Dung lượng RAM**
    * **Dung lượng ổ đĩa**
    * **Sử dụng card mạng Virtio** (để có hiệu suất I/O tốt hơn)
    * **Sử dụng VNC** để truy cập máy ảo từ xa
    * **Đường dẫn đến file ISO chính** để cài đặt hệ điều hành
    * **Khả năng gắn thêm một file ISO phụ** (hữu ích cho driver, công cụ, v.v.)
* **Tạo ổ đĩa ảo:** Tự động tạo file ổ đĩa ảo (định dạng `qcow2`) với dung lượng được chỉ định.
* **Khởi động tức thì:** Cung cấp tùy chọn khởi động máy ảo ngay sau khi cấu hình hoàn tất.

---

## Yêu cầu hệ thống

* Hệ điều hành dựa trên Debian/Ubuntu (ví dụ: Ubuntu, Linux Mint).
* Quyền `sudo` để cài đặt các gói.
* CPU có hỗ trợ ảo hóa (Intel VT-x hoặc AMD-V) được bật trong BIOS/UEFI để tận dụng KVM.

---

## Cách sử dụng

1.  **Lưu tập lệnh:**
    Lưu nội dung tập lệnh vào một tệp, ví dụ: `setup_qemu_vm.sh`.

    ```bash
    nano setup_qemu_vm.sh
    ```

2.  **Cấp quyền thực thi:**
    Mở Terminal và cấp quyền thực thi cho tệp đã lưu:

    ```bash
    chmod +x setup_qemu_vm.sh
    ```

3.  **Chạy tập lệnh:**
    Thực thi tập lệnh từ Terminal:

    ```bash
    ./setup_qemu_vm.sh
    ```

4.  **Làm theo hướng dẫn:**
    Tập lệnh sẽ hỏi bạn một loạt câu hỏi để cấu hình máy ảo. Hãy nhập các giá trị mong muốn khi được yêu cầu.

    * **Số nhân CPU bạn muốn dùng cho máy ảo:** (ví dụ: `2`)
    * **Số GB RAM bạn muốn dùng cho máy ảo:** (ví dụ: `4`)
    * **Dung lượng ổ đĩa (GB) bạn muốn dùng cho máy ảo:** (ví dụ: `50`)
    * **Bạn có muốn dùng card mạng virtio không? [Y/N]:** (nên chọn `Y` để có hiệu suất tốt hơn)
    * **Bạn có muốn dùng VNC không? [Y/N]:** (chọn `Y` nếu muốn truy cập máy ảo qua VNC; cổng mặc định là 5900)
    * **Đường dẫn đến file ISO chính của bạn:** (ví dụ: `/home/user/ubuntu-22.04-desktop-amd64.iso`)
    * **Bạn có muốn gắn thêm một file ISO nào nữa không? [Y/N]:** (chọn `Y` nếu cần thêm ISO phụ, ví dụ: đĩa driver)
        * Nếu chọn `Y`, bạn sẽ được hỏi **Đường dẫn đến file ISO phụ của bạn:**
    * **Bạn có muốn khởi động máy ảo ngay bây giờ không? [Y/N]:**

---

## Ghi chú quan trọng

* **Đường dẫn ISO:** Đảm bảo rằng đường dẫn đến các file ISO là chính xác và các file đó tồn tại trên hệ thống của bạn.
* **Chế độ mạng:** Tập lệnh sử dụng chế độ mạng **NAT (User Mode)** của QEMU. Đây là cách đơn giản nhất để bắt đầu, nhưng máy ảo sẽ không có địa chỉ IP trực tiếp trên mạng cục bộ của bạn. Để có các cấu hình mạng phức tạp hơn (ví dụ: bridge), bạn sẽ cần cấu hình thủ công sau này.
* **Truy cập VNC:** Nếu bạn chọn sử dụng VNC, máy ảo sẽ được khởi động với máy chủ VNC trên cổng 5900 (màn hình `:0`). Bạn sẽ cần một **ứng dụng khách VNC** (như Remmina, VNC Viewer) để kết nối đến máy ảo từ máy chủ của mình (thường là `127.0.0.1:5900`).
* **KVM:** Việc sử dụng KVM là rất quan trọng để có hiệu suất máy ảo tốt. Nếu CPU của bạn không hỗ trợ KVM hoặc KVM chưa được bật trong BIOS/UEFI, máy ảo có thể chạy rất chậm.

---

## Giấy phép

Mã nguồn này được cấp phép theo Giấy phép MIT. Xem file `LICENSE` để biết thêm chi tiết.

```
MIT License

Copyright (c) 2025 Jennie Nguyen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

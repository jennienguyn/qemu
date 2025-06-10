#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script bằng quyền root (sudo)"
   exit 1
fi

echo "=== CẤU HÌNH MÁY ẢO QEMU ==="
read -p "Tổng số CPU (vCPU) bạn muốn dùng cho máy ảo (ví dụ: 2): " TOTAL_VCPUS
read -p "Số RAM bạn muốn dùng (ví dụ: 2G cho 2GB, 512M cho 512MB): " RAM_SIZE
read -p "Dung lượng ổ cứng (ví dụ: 20G cho 20GB): " DISK_SIZE
read -p "Link tải file ISO của bạn: " ISO_LINK
read -p "Kích hoạt truy cập VNC (Y/N, nếu N sẽ hiển thị trực tiếp trên console): " VNC_ENABLE
read -p "Chế độ mạng (NAT/Bridge): " NET_MODE

ISO_FILENAME=$(basename "$ISO_LINK")
DISK_FILENAME="vm_disk.qcow2"

if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "QEMU chưa được cài đặt. Đang tiến hành cài đặt..."
    apt update && apt install -y qemu-system-x86 qemu-utils wget
    if [ $? -ne 0 ]; then
        echo "Lỗi: Không thể cài đặt QEMU. Vui lòng kiểm tra lại kết nối mạng hoặc quyền sudo."
        exit 1
    fi
else
    echo "QEMU đã được cài đặt."
fi

if [ ! -f "$ISO_FILENAME" ]; then
    echo "Đang tải file ISO từ $ISO_LINK..."
    wget -O "$ISO_FILENAME" "$ISO_LINK"
    if [ $? -ne 0 ]; then
        echo "Lỗi: Không thể tải file ISO. Vui lòng kiểm tra lại đường dẫn."
        exit 1
    fi
else
    echo "File ISO $ISO_FILENAME đã tồn tại."
fi

if [ ! -f "$DISK_FILENAME" ]; then
    echo "Đang tạo ổ đĩa ảo $DISK_FILENAME với dung lượng $DISK_SIZE..."
    qemu-img create -f qcow2 "$DISK_FILENAME" "$DISK_SIZE"
    if [ $? -ne 0 ]; then
        echo "Lỗi: Không thể tạo ổ đĩa ảo."
        exit 1
    fi
else
    echo "Ổ đĩa ảo $DISK_FILENAME đã tồn tại."
fi

echo "Đang tạo file start.sh..."

cat << EOF > start.sh
#!/bin/bash

qemu-system-x86_64 \\
  -enable-kvm \\
  -m "$RAM_SIZE" \\
  -smp "$TOTAL_VCPUS" \\
  -hda "$DISK_FILENAME" \\
  -cdrom "$ISO_FILENAME" \\
  -boot d \\
EOF

if [[ "$VNC_ENABLE" == "Y" || "$VNC_ENABLE" == "y" ]]; then
  echo "  -vnc :0 \\" >> start.sh
else
  echo "  -display default \\" >> start.sh
fi

if [[ "$NET_MODE" == "Bridge" || "$NET_MODE" == "bridge" ]]; then
  read -p "Nhập tên bridge của bạn (ví dụ: br0, nếu không có hãy tạo hoặc để trống để sử dụng mặc định br0): " BRIDGE_NAME_INPUT
  BRIDGE_NAME="${BRIDGE_NAME_INPUT:-br0}"
  echo "  -netdev bridge,id=net0,br=$BRIDGE_NAME \\" >> start.sh
  echo "  -device virtio-net-pci,netdev=net0 \\" >> start.sh
else
  echo "  -netdev user,id=net0 \\" >> start.sh
  echo "  -device virtio-net-pci,netdev=net0" >> start.sh
fi

if [[ "$NET_MODE" == "Bridge" || "$NET_MODE" == "bridge" ]]; then
    sed -i '$ s/ \\$//' start.sh
fi

chmod +x start.sh

echo "✅ Đã tạo xong file start.sh. Bạn có thể chạy máy ảo bằng lệnh: ./start.sh"
echo "Lưu ý: Để cài đặt hệ điều hành, máy ảo sẽ boot từ ISO. Sau khi cài đặt xong, bạn có thể chỉnh sửa file start.sh để bỏ dòng '-cdrom' hoặc thay đổi '-boot d' thành '-boot c' để boot từ ổ cứng."

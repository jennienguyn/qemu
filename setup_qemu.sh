#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "Vui lòng chạy script bằng quyền root (sudo)"
   exit 1
fi

echo "=== CẤU HÌNH QEMU ==="
read -p "Số nhân bạn muốn dùng: " CPUS
read -p "Số luồng bạn muốn dùng: " THREADS
read -p "Kích hoạt VNC [Y/N]: " VNC
read -p "Chế độ mạng [NAT/Bridge]: " NET_MODE
read -p "Số RAM bạn muốn dùng (ví dụ: 2048 cho 2GB): " RAM
read -p "Dung lượng ổ cứng (GB): " DISK_SIZE
read -p "Link tải file ISO: " ISO_LINK

ISO_NAME=$(basename "$ISO_LINK")
DISK_NAME="vm_disk.qcow2"

# Cài qemu nếu chưa có (dùng sudo)
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Đang cài đặt QEMU..."
    apt update && apt install -y qemu-kvm qemu-utils wget
fi

echo "Đang tải ISO..."
wget -O "$ISO_NAME" "$ISO_LINK"

echo "Đang tạo ổ đĩa ảo $DISK_NAME với dung lượng ${DISK_SIZE}G..."
qemu-img create -f qcow2 "$DISK_NAME" "${DISK_SIZE}G"

# Tính số cores từ CPUS và THREADS, đảm bảo cores >=1
CORES=$((CPUS / THREADS))
if [[ $CORES -lt 1 ]]; then
  CORES=1
fi

echo "Đang tạo file start.sh..."

cat << EOF > start.sh
#!/bin/bash

qemu-system-x86_64 \\
  -enable-kvm \\
  -m $RAM \\
  -smp sockets=1,cores=$CORES,threads=$THREADS \\
  -hda $DISK_NAME \\
  -cdrom $ISO_NAME \\
  -boot d \\
EOF

if [[ "$VNC" == "Y" || "$VNC" == "y" ]]; then
  echo "  -vnc :1 \\" >> start.sh
else
  echo "  -display default \\" >> start.sh
fi

if [[ "$NET_MODE" == "Bridge" || "$NET_MODE" == "bridge" ]]; then
  echo "  -netdev bridge,id=net0,br=br0 \\" >> start.sh
  echo "  -device e1000,netdev=net0 \\" >> start.sh
else
  echo "  -netdev user,id=net0 \\" >> start.sh
  echo "  -device e1000,netdev=net0 \\" >> start.sh
fi

sed -i '$ s/ \\$//' start.sh
chmod +x start.sh

USER_NAME=$(logname)

chown $USER_NAME:$USER_NAME start.sh "$ISO_NAME" "$DISK_NAME"

echo "✅ Đã tạo xong! Chạy máy ảo bằng lệnh: ./start.sh"

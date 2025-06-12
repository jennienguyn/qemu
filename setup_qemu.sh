#!/bin/bash

install_qemu() {
  if ! command -v qemu-system-x86_64 > /dev/null; then
    echo "QEMU chưa được cài đặt, bắt đầu cài đặt..."
    sudo apt update
    sudo apt install -y qemu qemu-system-x86 qemu-utils
    if [ $? -ne 0 ]; then
      echo "Cài đặt QEMU thất bại, vui lòng kiểm tra kết nối mạng hoặc quyền sudo."
      exit 1
    fi
    echo "Đã cài đặt QEMU thành công."
  else
    echo "QEMU đã được cài đặt."
  fi
}

# Gọi hàm cài đặt QEMU
install_qemu

echo "Số nhân bạn muốn dùng:"
read CPUS

echo "Số ram bạn muốn dùng (2G cho 2GB, 2048M cho 2GB):"
read RAM
# Kiểm tra định dạng RAM
if [[ ! "$RAM" =~ ^[0-9]+(G|M)$ ]]; then
  echo "Bạn phải nhập RAM dạng số kèm G hoặc M, ví dụ: 2G hoặc 2048M"
  exit 1
fi

echo "Bạn có muốn dùng vnc không (Y, N):"
read USE_VNC

echo "Card mạng bạn muốn dùng (nhập listethenet để xem các card mạng có sẵn trong qemu):"
read NET_CARD
if [ "$NET_CARD" == "listethenet" ]; then
  echo "Danh sách card mạng có sẵn:"
  qemu-system-x86_64 -net nic,model=help
  exit
fi

echo "Card âm thanh bạn muốn dùng (nhập listaudio để xem các card audio có sẵn trong qemu):"
read AUDIO_CARD
if [ "$AUDIO_CARD" == "listaudio" ]; then
  echo "Danh sách card âm thanh có sẵn:"
  qemu-system-x86_64 -soundhw help
  exit
fi

echo "Dung lượng ổ cứng ảo bạn muốn dùng (150G cho 150GB):"
read HDD_SIZE

echo "Link tải ISO của bạn:"
read ISO_LINK

echo "Tên file .sh đầu ra bạn muốn đặt là:"
read OUT_FILE

# Tải ISO
ISO_NAME=$(basename "$ISO_LINK")
if [ ! -f "$ISO_NAME" ]; then
  echo "Đang tải $ISO_NAME..."
  if command -v wget > /dev/null; then
    wget "$ISO_LINK" -O "$ISO_NAME"
  elif command -v curl > /dev/null; then
    curl -L "$ISO_LINK" -o "$ISO_NAME"
  else
    echo "Không tìm thấy wget hoặc curl để tải ISO."
    exit 1
  fi

  # Kiểm tra lại sau khi tải
  if [ ! -f "$ISO_NAME" ] || [ ! -s "$ISO_NAME" ]; then
    echo "Tải ISO thất bại."
    exit 1
  fi
fi

# Tạo ổ cứng ảo
QCOW_NAME="disk.qcow2"
qemu-img create -f qcow2 "$QCOW_NAME" "$HDD_SIZE"

# Tạo script chạy QEMU
echo "#!/bin/bash" > "$OUT_FILE"
echo "" >> "$OUT_FILE"
echo "qemu-system-x86_64 \\" >> "$OUT_FILE"
echo "  -smp $CPUS \\" >> "$OUT_FILE"
echo "  -m $RAM \\" >> "$OUT_FILE"

if [[ "$USE_VNC" == "Y" || "$USE_VNC" == "y" ]]; then
  echo "  -vnc :1 \\" >> "$OUT_FILE"
else
  echo "  -display sdl \\" >> "$OUT_FILE"
fi

echo "  -net nic,model=$NET_CARD \\" >> "$OUT_FILE"
echo "  -net user \\" >> "$OUT_FILE"
echo "  -soundhw $AUDIO_CARD \\" >> "$OUT_FILE"
echo "  -drive file=$QCOW_NAME,format=qcow2 \\" >> "$OUT_FILE"
echo "  -cdrom $ISO_NAME \\" >> "$OUT_FILE"
echo "  -boot d" >> "$OUT_FILE"

chmod +x "$OUT_FILE"
echo "Đã tạo file script chạy QEMU: $OUT_FILE"

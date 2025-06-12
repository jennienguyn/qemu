#!/bin/bash

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "Vui lòng chạy script với quyền root (sudo)."
  exit 1
fi

echo "Kiểm tra và cài đặt QEMU nếu chưa có..."
if ! command -v qemu-system-x86_64 > /dev/null; then
  apt update
  apt install -y qemu-system
  if [ $? -ne 0 ]; then
    echo "Cài đặt QEMU thất bại."
    exit 1
  fi
fi

read -p "Số nhân bạn muốn dùng: " CPUS
# Kiểm tra số nhân có phải số nguyên dương không
if ! [[ "$CPUS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Số nhân không hợp lệ. Vui lòng nhập số nguyên dương."
  exit 1
fi

read -p "Số RAM bạn muốn dùng (2G cho 2GB, 2048M cho 2GB): " RAM
if [[ ! "$RAM" =~ ^[0-9]+(G|M)$ ]]; then
  echo "Bạn phải nhập RAM dạng số kèm G hoặc M, ví dụ: 2G hoặc 2048M"
  exit 1
fi

read -p "Bạn có muốn dùng VNC không (Y/N): " USE_VNC

read -p "Card mạng bạn muốn dùng (nhập listethenet để xem các card mạng có sẵn trong qemu): " NET_CARD
if [ "$NET_CARD" == "listethenet" ]; then
  echo "Danh sách card mạng có sẵn:"
  qemu-system-x86_64 -net nic,model=help
  exit 0
fi

read -p "Card âm thanh bạn muốn dùng (nhập listaudio để xem các card audio có sẵn trong qemu): " AUDIO_CARD
if [ "$AUDIO_CARD" == "listaudio" ]; then
  echo "Danh sách card âm thanh có sẵn:"
  qemu-system-x86_64 -device help | grep audio
  exit 0
fi

read -p "Dung lượng ổ cứng ảo bạn muốn dùng (ví dụ 150G cho 150GB): " HDD_SIZE
# Kiểm tra định dạng dung lượng ổ cứng ảo
if [[ ! "$HDD_SIZE" =~ ^[0-9]+(G|M)$ ]]; then
  echo "Bạn phải nhập dung lượng ổ cứng dạng số kèm G hoặc M, ví dụ: 150G hoặc 10240M"
  exit 1
fi

read -p "Link tải ISO của bạn: " ISO_LINK

read -p "Tên file .sh đầu ra bạn muốn đặt là: " OUT_FILE

# Tải ISO nếu chưa có
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

# Tạo ổ cứng ảo qcow2
QCOW_NAME="disk.qcow2"
echo "Tạo ổ cứng ảo $QCOW_NAME với dung lượng $HDD_SIZE..."
qemu-img create -f qcow2 "$QCOW_NAME" "$HDD_SIZE"
if [ $? -ne 0 ]; then
  echo "Tạo ổ cứng ảo thất bại."
  exit 1
fi

# Tạo file script chạy QEMU
echo "#!/bin/bash" > "$OUT_FILE"
echo "" >> "$OUT_FILE"
echo "qemu-system-x86_64 \\" >> "$OUT_FILE"
echo "  -smp $CPUS \\" >> "$OUT_FILE"
echo "  -m $RAM \\" >> "$OUT_FILE"

if [[ "$USE_VNC" =~ ^[Yy]$ ]]; then
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

#!/bin/bash
download_file() {
    local url="$1"
    local output_path="$2"
    echo "Đang tải xuống: $url"
    echo "Lưu vào: $output_path"
    if command -v wget &> /dev/null; then
        echo "Thử tải xuống bằng wget..."
        if wget -O "$output_path" "$url"; then
            echo "Tải xuống thành công bằng wget."
            return 0
        else
            echo "wget thất bại."
        fi
    else
        echo "wget không được cài đặt. Bỏ qua wget."
    fi
    if command -v curl &> /dev/null; then
        echo "Thử tải xuống bằng curl..."
        if curl -L -o "$output_path" "$url"; then
            echo "Tải xuống thành công bằng curl."
            return 0
        else
            echo "curl thất bại."
        fi
    else
        echo "curl không được cài đặt. Bỏ qua curl."
    fi
    echo "Lỗi: Không thể tải xuống file từ $url bằng cả wget và curl."
    return 1
}
sudo apt update && sudo apt upgrade -y
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager wget curl
if ! grep -q vmx /proc/cpuinfo && ! grep -q svm /proc/cpuinfo; then
    echo "Lỗi: KVM không được hỗ trợ trên CPU của bạn. Máy ảo có thể chạy chậm."
    read -p "Bạn vẫn muốn tiếp tục không? [Y/N]: " continue_without_kvm
    if [[ ! "$continue_without_kvm" =~ ^[Yy]$ ]]; then
        echo "Thoát cài đặt."
        exit 1
    fi
fi
echo ""
echo "--- Cấu hình máy ảo ---"
read -p "Số nhân CPU bạn muốn dùng cho máy ảo: " cpu_cores
while ! [[ "$cpu_cores" =~ ^[0-9]+$ ]] || [ "$cpu_cores" -eq 0 ]; do
    read -p "Số nhân không hợp lệ. Vui lòng nhập một số nguyên dương: " cpu_cores
done
read -p "Số GB RAM bạn muốn dùng cho máy ảo: " ram_gb
while ! [[ "$ram_gb" =~ ^[0-9]+$ ]] || [ "$ram_gb" -eq 0 ]; do
    read -p "Số GB RAM không hợp lệ. Vui lòng nhập một số nguyên dương: " ram_gb
done
read -p "Dung lượng ổ đĩa (GB) bạn muốn dùng cho máy ảo: " disk_gb
while ! [[ "$disk_gb" =~ ^[0-9]+$ ]] || [ "$disk_gb" -eq 0 ]; do
    read -p "Dung lượng ổ đĩa không hợp lệ. Vui lòng nhập một số nguyên dương: " disk_gb
done
read -p "Bạn có muốn dùng card mạng virtio không? [Y/N]: " use_virtio_net
use_virtio_net=$(echo "$use_virtio_net" | tr '[:upper:]' '[:lower:]')
read -p "Bạn có muốn dùng VNC không? [Y/N]: " use_vnc
use_vnc=$(echo "$use_vnc" | tr '[:upper:]' '[:lower:]')
read -p "Đường dẫn đến file ISO chính của bạn (có thể là đường dẫn cục bộ hoặc URL): " primary_iso_input
read -p "Bạn có muốn gắn thêm một file ISO nào nữa không? [Y/N]: " add_secondary_iso
add_secondary_iso=$(echo "$add_secondary_iso" | tr '[:upper:]' '[:lower:]')
read -p "Nhập tên cho máy ảo của bạn (sẽ dùng làm tên file khởi động): " vm_name
if [ -z "$vm_name" ]; then
    vm_name="my_qemu_vm"
fi
VM_DIR="$HOME/qemu_vms/$vm_name"
mkdir -p "$VM_DIR"
primary_iso_path=""
if [[ "$primary_iso_input" =~ ^https?:// ]]; then
    primary_iso_filename=$(basename "$primary_iso_input")
    primary_iso_path="$VM_DIR/$primary_iso_filename"
    if [ ! -f "$primary_iso_path" ]; then
        if ! download_file "$primary_iso_input" "$primary_iso_path"; then
            echo "Thoát cài đặt do lỗi tải ISO chính."
            exit 1
        fi
    else
        echo "File ISO chính đã tồn tại tại $primary_iso_path. Bỏ qua tải xuống."
    fi
else
    if [ -f "$primary_iso_input" ]; then
        primary_iso_path="$primary_iso_input"
    else
        echo "Lỗi: File ISO chính cục bộ không tìm thấy tại $primary_iso_input."
        exit 1
    fi
fi
SECONDARY_ISO_ARG=""
if [[ "$add_secondary_iso" == "y" ]]; then
    read -p "Đường dẫn đến file ISO phụ của bạn (có thể là đường dẫn cục bộ hoặc URL): " secondary_iso_input
    secondary_iso_path=""
    if [[ "$secondary_iso_input" =~ ^https?:// ]]; then
        secondary_iso_filename=$(basename "$secondary_iso_input")
        secondary_iso_path="$VM_DIR/$secondary_iso_filename"
        if [ ! -f "$secondary_iso_path" ]; then
            if ! download_file "$secondary_iso_input" "$secondary_iso_path"; then
                echo "Thoát cài đặt do lỗi tải ISO phụ."
                exit 1
            fi
        else
            echo "File ISO phụ đã tồn tại tại $secondary_iso_path. Bỏ qua tải xuống."
        fi
    else
        if [ -f "$secondary_iso_input" ]; then
            secondary_iso_path="$secondary_iso_input"
        else
            echo "Lỗi: File ISO phụ cục bộ không tìm thấy tại $secondary_iso_input."
            exit 1
        fi
    fi
    SECONDARY_ISO_ARG="-drive file=\"$secondary_iso_path\",if=ide,media=cdrom,index=2"
fi
VM_DISK="$VM_DIR/${vm_name}_disk.qcow2"
echo "Đang tạo ổ đĩa ảo ${disk_gb}GB tại $VM_DISK..."
if [ ! -f "$VM_DISK" ]; then
    qemu-img create -f qcow2 "$VM_DISK" "${disk_gb}G"
else
    echo "File ổ đĩa ảo $VM_DISK đã tồn tại. Bỏ qua tạo ổ đĩa."
fi
QEMU_CMD="qemu-system-x86_64"
QEMU_CMD+=" -enable-kvm"
QEMU_CMD+=" -name \"$vm_name\""
QEMU_CMD+=" -smp cores=$cpu_cores,sockets=1,threads=1"
QEMU_CMD+=" -m ${ram_gb}G"
QEMU_CMD+=" -hda \"$VM_DISK\""
if [ -n "$primary_iso_path" ]; then
    QEMU_CMD+=" -drive file=\"$primary_iso_path\",if=ide,media=cdrom,index=1"
    QEMU_CMD+=" -boot d"
fi
QEMU_CMD+=" $SECONDARY_ISO_ARG"
if [[ "$use_virtio_net" == "y" ]]; then
    QEMU_CMD+=" -net nic,model=virtio -net user"
else
    QEMU_CMD+=" -net nic -net user"
fi
if [[ "$use_vnc" == "y" ]]; then
    QEMU_CMD+=" -vnc :0"
    echo "Máy ảo sẽ được truy cập qua VNC trên cổng 5900. Địa chỉ: Your_IP_Address:0"
fi
QEMU_CMD+=" -vga std"
echo ""
echo "--- Cấu hình QEMU đã sẵn sàng ---"
echo "Lệnh chạy QEMU của bạn:"
echo "$QEMU_CMD"
echo ""
START_VM_SCRIPT="$VM_DIR/start_${vm_name}.sh"
echo "#!/bin/bash" > "$START_VM_SCRIPT"
echo "$QEMU_CMD" >> "$START_VM_SCRIPT"
chmod +x "$START_VM_SCRIPT"
echo "Đã tạo file script khởi động máy ảo: $START_VM_SCRIPT"
echo "Bạn có thể dùng lệnh 'bash $START_VM_SCRIPT' để khởi động lại máy ảo này."
read -p "Bạn có muốn khởi động máy ảo ngay bây giờ không? [Y/N]: " start_vm_now
if [[ "$start_vm_now" =~ ^[Yy]$ ]]; then
    echo "Đang khởi động máy ảo..."
    eval "$QEMU_CMD" &
    echo "Máy ảo đã được khởi động. Bạn có thể cần một ứng dụng khách VNC để kết nối nếu đã chọn VNC."
else
    echo "Máy ảo chưa được khởi động. Bạn có thể chạy lại lệnh trên bất cứ lúc nào bằng cách sử dụng file script khởi động đã tạo."
fi
echo "Hoàn tất."

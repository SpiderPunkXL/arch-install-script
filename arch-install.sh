#!/bin/bash

# Redirect stdout and stderr to archsetup.txt and still output to console
exec > >(tee -i archsetup.txt)
exec 2>&1

# Color definitions
C_BOLD="\033[1m"
C_BLUE="\033[34m"
C_GREEN="\033[32m"
C_RED="\033[31m"
C_YELLOW="\033[33m"
C_MAGENTA="\033[35m"
C_CYAN="\033[36m"
C_WHITE="\033[37m"
C_BG_BLUE="\033[44m"
C_BG_GREEN="\033[42m"
C_BG_YELLOW="\033[43m"
C_BG_MAGENTA="\033[45m"
C_BG_CYAN="\033[46m"
C_BG_WHITE="\033[47m"
C_RESET="\033[0m"

# Display the logo with color and style
logo() {
    # Arch Linux ASCII art
    echo -e "${C_BLUE}${C_BOLD}"
    echo -e "                                       -\`"
    echo -e "                                       .o+\`"
    echo -e "                                      \`ooo/"
    echo -e "                                     \`+oooo:"
    echo -e "                                    \`+oooooo:"
    echo -e "                                    -+oooooo+:"
    echo -e "                                  \`/:-:++oooo+:"
    echo -e "                                 \`/++++/+++++++:"
    echo -e "                                \`/++++++++++++++:"
    echo -e "                               \`/+++ooooooooooooo/\`"
    echo -e "                              ./ooosssso++osssssso+\`"
    echo -e "                             .oossssso-\`\`\`\`/ossssss+\`"
    echo -e "                            -osssssso.      :ssssssso."
    echo -e "                           :osssssss/        osssso+++."
    echo -e "                          /ossssssss/        +ssssooo/-"
    echo -e "                        \`/ossssso+/:-        -:/+osssso+-"
    echo -e "                       \`+sso+:-\`                 \`.-/+oso:"
    echo -e "                      \`++:.                           \`-/+/"
    echo -e "                     \`\`                                 \`/"
    echo -e "-------------------------------------------------------------------------------------------"
    echo -e "                   Introducing the Automated Arch Linux Installer, baby!                   "
    echo -e "It's your one-stop ticket to a sleek, streamlined Arch experience without all the hassle!  "
    echo -e "-------------------------------------------------------------------------------------------"
    echo -e "${C_RESET}"
}

Verifying Arch Linux ISO is Booted

"
if [ ! -f /usr/bin/pacstrap ]; then
    echo "This script must be run from an Arch Linux ISO environment."
    exit 1
fi

root_check() {
    if [[ "$(id -u)" != "0" ]]; then
        echo -ne "ERROR! This script must be run under the 'root' user!\n"
        exit 0
    fi
}

docker_check() {
    if awk -F/ '$2 == "docker"' /proc/self/cgroup | read -r; then
        echo -ne "ERROR! Docker container is not supported (at the moment)\n"
        exit 0
    elif [[ -f /.dockerenv ]]; then
        echo -ne "ERROR! Docker container is not supported (at the moment)\n"
        exit 0
    fi
}

arch_check() {
    if [[ ! -e /etc/arch-release ]]; then
        echo -ne "ERROR! This script must be run in Arch Linux!\n"
        exit 0
    fi
}

pacman_check() {
    if [[ -f /var/lib/pacman/db.lck ]]; then
        echo "ERROR! Pacman is blocked."
        echo -ne "If not running remove /var/lib/pacman/db.lck.\n"
        exit 0
    fi
}

background_checks() {
    root_check
    arch_check
    pacman_check
    docker_check
}

select_option() {
    local options=("$@")
    local num_options=${#options[@]}
    local selected=0
    local last_selected=-1

    while true; do
        # Move cursor up to the start of the menu
        if [ $last_selected -ne -1 ]; then
            echo -ne "\033[${num_options}A"
        fi

        if [ $last_selected -eq -1 ]; then
            echo "Please select an option using the arrow keys and Enter:"
        fi
        for i in "${!options[@]}"; do
            if [ "$i" -eq $selected ]; then
                echo "> ${options[$i]}"
            else
                echo "  ${options[$i]}"
            fi
        done

        last_selected=$selected

        # Read user input
        read -rsn1 key
        case $key in
            $'\x1b') # ESC sequence
                read -rsn2 -t 0.1 key
                case $key in
                    '[A') # Up arrow
                        ((selected--))
                        if [ $selected -lt 0 ]; then
                            selected=$((num_options - 1))
                        fi
                        ;;
                    '[B') # Down arrow
                        ((selected++))
                        if [ $selected -ge $num_options ]; then
                            selected=0
                        fi
                        ;;
                esac
                ;;
            '') # Enter key
                break
                ;;
        esac
    done

    return $selected
}

# New function to select desktop environment
desktop_environment() {
    echo -ne "
    Please select your desired desktop environment:
    "
    options=("GNOME" "KDE Plasma" "XFCE" "Cosmic" "No Desktop Environment" "exit")
    select_option "${options[@]}"

    case $? in
    0) export DE=gnome;;
    1) export DE=kde;;
    2) export DE=xfce;;
    3) export DE=cosmic;;
    4) export DE=none;;
    5) exit ;;
    *) echo "Wrong option please select again"; desktop_environment;;
    esac
}

filesystem () {
    echo -ne "
    Please Select your file system for both boot and root
    "
    options=("ext4" "btrfs" "luks" "exit")
    select_option "${options[@]}"

    case $? in
    0) export FS=ext4;;
    1) export FS=btrfs;;
    2)
        set_password "LUKS_PASSWORD"
        export FS=luks
        ;;
    3) exit ;;
    *) echo "Wrong option please select again"; filesystem;;
    esac
}

timezone () {
    time_zone="$(curl --fail https://ipapi.co/timezone)"
    echo -ne "
    System detected your timezone to be '$time_zone' \n"
    echo -ne "Is this correct?
    "
    options=("Yes" "No")
    select_option "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        echo "${time_zone} set as timezone"
        export TIMEZONE=$time_zone;;
        n|N|no|NO|No)
        echo "Please enter your desired timezone e.g. Europe/London :"
        read -r new_timezone
        echo "${new_timezone} set as timezone"
        export TIMEZONE=$new_timezone;;
        *) echo "Wrong option. Try again";timezone;;
    esac
}

keymap () {
    echo -ne "
    Please select key board layout from this list"
    options=(us by ca cf cz de dk es et fa fi fr gr hu il it lt lv mk nl no pl ro ru se sg ua uk)

    select_option "${options[@]}"
    keymap=${options[$?]}

    echo -ne "Your key boards layout: ${keymap} \n"
    export KEYMAP=$keymap
}

drivessd () {
    echo -ne "
    Is this an ssd? yes/no:
    "

    options=("Yes" "No")
    select_option "${options[@]}"

    case ${options[$?]} in
        y|Y|yes|Yes|YES)
        export MOUNT_OPTIONS="noatime,compress=zstd,ssd,commit=120";;
        n|N|no|NO|No)
        export MOUNT_OPTIONS="noatime,compress=zstd,commit=120";;
        *) echo "Wrong option. Try again";drivessd;;
    esac
}

diskpart () {

echo -ne "
${C_RED}${C_BOLD}
-------------------------------------------------------------------------------------
    Whoa there, Hold your horses! 
    This bad boy is about to wipe the disk clean and erase all your precious data! 
    Make sure you know what you're getting into... 
    'cause once it's gone... 
    it's gone for good!

    BACKUP YOUR STUFF BEFORE YOU GO ANY FURTHER!

    I CAN'T BE HELD LIABLE FOR ANY DATA DRAMA!
-------------------------------------------------------------------------------------
${C_RESET}
"

    PS3='
    Select the disk to install on: '
    options=($(lsblk -n --output TYPE,KNAME,SIZE | awk '$1=="disk"{print "/dev/"$2"|"$3}'))

    select_option "${options[@]}"
    disk=${options[$?]%|*}

    echo -e "\n${disk%|*} selected \n"
        export DISK=${disk%|*}

    drivessd
}

userinfo () {
    while true
    do
            read -r -p "Please enter username: " username
            if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
            then
                    break
            fi
            echo "Incorrect username."
    done
    export USERNAME=$username

    while true
    do
        read -rs -p "Please enter password: " PASSWORD1
        echo -ne "\n"
        read -rs -p "Please re-enter password: " PASSWORD2
        echo -ne "\n"
        if [[ "$PASSWORD1" == "$PASSWORD2" ]]; then
            break
        else
            echo -ne "ERROR! Passwords do not match. \n"
        fi
    done
    export PASSWORD=$PASSWORD1

    while true
    do
            read -r -p "Please name your machine: " name_of_machine
            if [[ "${name_of_machine,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
            then
                    break
            fi
            read -r -p "Hostname doesn't seem correct. Do you still want to save it? (y/n)" force
            if [[ "${force,,}" = "y" ]]
            then
                    break
            fi
    done
    export NAME_OF_MACHINE=$name_of_machine
}

# Starting functions
background_checks
clear
logo
userinfo
clear
logo
desktop_environment
clear
logo
diskpart
clear
logo
filesystem
clear
logo
timezone
clear
logo
keymap

echo "Setting up mirrors for optimal download"
iso=$(curl -4 ifconfig.co/country-iso)
timedatectl set-ntp true
pacman -Sy
pacman -S --noconfirm archlinux-keyring
pacman -S --noconfirm --needed pacman-contrib terminus-font
setfont ter-v18b
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm --needed reflector rsync grub
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo -ne "
${C_YELLOW}${C_BOLD}
-------------------------------------------------------------------------
                    Setting up $iso mirrors for faster downloads
-------------------------------------------------------------------------
${C_RESET}
"
reflector -a 48 -c "$iso" -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
mkdir -p /mnt

echo -ne "
${C_GREEN}${C_BOLD}
-------------------------------------------------------------------------
                    Installing Prerequisites
-------------------------------------------------------------------------
${C_RESET}
"
pacman -S --noconfirm --needed gptfdisk btrfs-progs glibc
echo -ne "
${C_CYAN}${C_BOLD}
-------------------------------------------------------------------------
                    Formatting Disk
-------------------------------------------------------------------------
${C_RESET}
"
umount -A --recursive /mnt # make sure everything is unmounted before we start
sgdisk -Z "${DISK}" # zap all on disk
sgdisk -a 2048 -o "${DISK}" # new gpt disk 2048 alignment

# create partitions
sgdisk -n 1::+1M --typecode=1:ef02 --change-name=1:'BIOSBOOT' "${DISK}"
sgdisk -n 2::+1GiB --typecode=2:ef00 --change-name=2:'EFIBOOT' "${DISK}"
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'ROOT' "${DISK}"
if [[ ! -d "/sys/firmware/efi" ]]; then
    sgdisk -A 1:set:2 "${DISK}"
fi
partprobe "${DISK}"

echo -ne "
${C_BLUE}${C_BOLD}
-------------------------------------------------------------------------
                    Creating Filesystems
-------------------------------------------------------------------------
${C_RESET}
"
createsubvolumes () {
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
}

mountallsubvol () {
    mount -o "${MOUNT_OPTIONS}",subvol=@home "${partition3}" /mnt/home
}

subvolumesetup () {
    createsubvolumes
    umount /mnt
    mount -o "${MOUNT_OPTIONS}",subvol=@ "${partition3}" /mnt
    mkdir -p /mnt/home
    mountallsubvol
}

if [[ "${DISK}" =~ "nvme" ]]; then
    partition2=${DISK}p2
    partition3=${DISK}p3
else
    partition2=${DISK}2
    partition3=${DISK}3
fi

if [[ "${FS}" == "btrfs" ]]; then
    mkfs.vfat -F32 -n "EFIBOOT" "${partition2}"
    mkfs.btrfs -f "${partition3}"
    mount -t btrfs "${partition3}" /mnt
    subvolumesetup
elif [[ "${FS}" == "ext4" ]]; then
    mkfs.vfat -F32 -n "EFIBOOT" "${partition2}"
    mkfs.ext4 "${partition3}"
    mount -t ext4 "${partition3}" /mnt
elif [[ "${FS}" == "luks" ]]; then
    mkfs.vfat -F32 "${partition2}"
    echo -n "${LUKS_PASSWORD}" | cryptsetup -y -v luksFormat "${partition3}" -
    echo -n "${LUKS_PASSWORD}" | cryptsetup open "${partition3}" ROOT -
    mkfs.btrfs "${partition3}"
    mount -t btrfs "${partition3}" /mnt
    subvolumesetup
    ENCRYPTED_PARTITION_UUID=$(blkid -s UUID -o value "${partition3}")
fi

BOOT_UUID=$(blkid -s UUID -o value "${partition2}")

sync
if ! mountpoint -q /mnt; then
    echo "ERROR! Failed to mount ${partition3} to /mnt after multiple attempts."
    exit 1
fi
mkdir -p /mnt/boot/efi
mount -t vfat -U "${BOOT_UUID}" /mnt/boot/

if ! grep -qs '/mnt' /proc/mounts; then
    echo "Drive is not mounted can not continue"
    echo "Rebooting in 3 Seconds ..." && sleep 1
    echo "Rebooting in 2 Seconds ..." && sleep 1
    echo "Rebooting in 1 Second ..." && sleep 1
    reboot now
fi

echo -ne "
${C_CYAN}${C_BOLD}
-------------------------------------------------------------------------
                    Arch Install on Main Drive
-------------------------------------------------------------------------
${C_RESET}
"
# Ensure the pacman keyring is initialized
pacman-key --init
pacman-key --populate archlinux

# Install essential packages
echo "Installing base system..."
if [[ ! -d "/sys/firmware/efi" ]]; then
    if ! pacstrap /mnt base base-devel linux linux-firmware sudo vim nano dhcpcd --noconfirm --needed; then
        echo "Error: Failed to install base system packages"
        echo "Trying alternative mirror..."
        # Update mirrorlist and try again
        reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
        if ! pacstrap /mnt base base-devel linux linux-firmware sudo vim nano dhcpcd --noconfirm --needed; then
            echo "Error: Installation failed. Please check your internet connection and try again."
            exit 1
        fi
    fi
else
    if ! pacstrap /mnt base base-devel linux linux-firmware efibootmgr sudo vim nano dhcpcd --noconfirm --needed; then
        echo "Error: Failed to install base system packages"
        echo "Trying alternative mirror..."
        # Update mirrorlist and try again
        reflector --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
        if ! pacstrap /mnt base base-devel linux linux-firmware efibootmgr sudo vim nano dhcpcd --noconfirm --needed; then
            echo "Error: Installation failed. Please check your internet connection and try again."
            exit 1
        fi
    fi
fi

# Configure pacman keyring in the new system
mkdir -p /mnt/etc/pacman.d/gnupg
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf

# Copy mirrorlist
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

# Generate fstab
echo "Generating fstab..."
if ! genfstab -U /mnt >> /mnt/etc/fstab; then
    echo "Error: Failed to generate fstab"
    exit 1
fi

echo "
Generated /etc/fstab:
"
cat /mnt/etc/fstab

# Install GRUB bootloader
if [[ ! -d "/sys/firmware/efi" ]]; then
    echo "Installing GRUB (BIOS mode)..."
    if ! grub-install --boot-directory=/mnt/boot "${DISK}"; then
        echo "Error: Failed to install GRUB"
        exit 1
    fi
fi

echo -ne "
${C_GREEN}${C_BOLD}
-------------------------------------------------------------------------
                    Checking for low memory systems <8G
-------------------------------------------------------------------------
${C_RESET}
"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTAL_MEM -lt 8000000 ]]; then
    mkdir -p /mnt/opt/swap
    if findmnt -n -o FSTYPE /mnt | grep -q btrfs; then
        chattr +C /mnt/opt/swap
    fi
    dd if=/dev/zero of=/mnt/opt/swap/swapfile bs=1M count=2048 status=progress
    chmod 600 /mnt/opt/swap/swapfile
    chown root /mnt/opt/swap/swapfile
    mkswap /mnt/opt/swap/swapfile
    swapon /mnt/opt/swap/swapfile
    echo "/opt/swap/swapfile    none    swap    sw    0    0" >> /mnt/etc/fstab
fi

gpu_type=$(lspci | grep -E "VGA|3D|Display")

arch-chroot /mnt /bin/bash -c "KEYMAP='${KEYMAP}' DE='${DE}' /bin/bash" <<EOF
echo -ne "
${C_YELLOW}${C_BOLD}
-------------------------------------------------------------------------
                    Network Setup
-------------------------------------------------------------------------
${C_RESET}
"
pacman -S --noconfirm --needed networkmanager dhclient
systemctl enable --now NetworkManager

echo -ne "
-------------------------------------------------------------------------
                    Setting up mirrors for optimal download
-------------------------------------------------------------------------
"
pacman -S --noconfirm --needed pacman-contrib curl
pacman -S --noconfirm --needed reflector rsync grub arch-install-scripts git ntp wget
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo -ne "
${C_MAGENTA}${C_BOLD}
-------------------------------------------------------------------------
                    Installing DE and Packages
-------------------------------------------------------------------------
${C_RESET}
"
# Install Desktop Environment based on selection
case \${DE} in
    gnome)
        echo "Installing GNOME..."
        pacman -S --noconfirm gnome gnome-tweaks power-profiles-daemon ntfs-3g file-roller
        ;;
    kde)
        echo "Installing KDE Plasma..."
        pacman -S --noconfirm plasma-meta sddm konsole kate dolphin ark plasma-workspace power-profiles-daemon ntfs-3g
        ;;
    xfce)
        echo "Installing XFCE..."
        pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter power-profiles-daemon pavucontrol gvfs ark firefox firefox-ublock-origin ntfs-3g
        ;;
    cosmic)
        echo "Installing Cosmic..."
        pacman -S --noconfirm cosmic power-profiles-daemon ntfs-3g file-roller
        ;;
    none)
        echo "Skipping desktop environment installation..."
        pacman -S --noconfirm ntfs-3g
        ;;
esac

echo -ne "
${C_BLUE}${C_BOLD}
-------------------------------------------------------------------------
                    You have " \$nc" cores. And
            changing the makeflags for " \$nc" cores. Aswell as
                changing the compression settings.
-------------------------------------------------------------------------
${C_RESET}
"
TOTAL_MEM=\$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  \$TOTAL_MEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j\$nc\"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T \$nc -z -)/g" /etc/makepkg.conf
fi

echo -ne "
${C_GREEN}${C_BOLD}
-------------------------------------------------------------------------
                    Setup Language to US and set locale
-------------------------------------------------------------------------
${C_RESET}
"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone ${TIMEZONE}
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

# Set keymaps
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
echo "XKBLAYOUT=${KEYMAP}" >> /etc/vconsole.conf

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

#Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

#Set colors and enable the easter egg
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf

#Enable multilib
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Sy --noconfirm --needed

echo -ne "
${C_BLUE}${C_BOLD}
-------------------------------------------------------------------------
                    Installing Microcode
-------------------------------------------------------------------------
${C_RESET}
"
if grep -q "GenuineIntel" /proc/cpuinfo; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
elif grep -q "AuthenticAMD" /proc/cpuinfo; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
fi

echo -ne "
${C_CYAN}${C_BOLD}
-------------------------------------------------------------------------
                    Installing Graphics Drivers
-------------------------------------------------------------------------
${C_RESET}
"
if echo "${gpu_type}" | grep -E "NVIDIA|GeForce"; then
    echo "Installing NVIDIA drivers"
    echo -ne "
    Please select your NVIDIA driver:
    "
    options=("nvidia-dkms (Proprietary - Recommended for older GPUs)" "nvidia-open-dkms (Open - For GTX 16 series or newer RTX series)" "exit")
    select_option "${options[@]}"

    case $? in
        0) 
            echo "Installing NVIDIA DKMS driver..."
            pacman -S --noconfirm --needed nvidia-dkms
            ;;
        1) 
            echo "Installing NVIDIA Open DKMS driver..."
            pacman -S --noconfirm --needed nvidia-open-dkms
            ;;
        2) 
            echo "Skipping NVIDIA driver installation..."
            ;;
    esac
elif echo "${gpu_type}" | grep 'VGA' | grep -E "Radeon|AMD"; then
    echo "Installing AMD drivers"
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif echo "${gpu_type}" | grep -E "Integrated Graphics Controller|Intel Corporation UHD"; then
    echo "Installing Intel drivers"
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

echo -ne "
${C_BLUE}${C_BOLD}
-------------------------------------------------------------------------
                    Adding User
-------------------------------------------------------------------------
${C_RESET}
"
groupadd libvirt
useradd -m -G wheel,libvirt -s /bin/bash $USERNAME
echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"
echo "$USERNAME:$PASSWORD" | chpasswd
echo "$USERNAME password set"
echo $NAME_OF_MACHINE > /etc/hostname

if [[ ${FS} == "luks" ]]; then
    sed -i 's/filesystems/encrypt filesystems/g' /etc/mkinitcpio.conf
    mkinitcpio -p linux
fi

if [[ -d "/sys/firmware/efi" ]]; then
    grub-install --efi-directory=/boot ${DISK}
fi

echo -ne "
${C_YELLOW}${C_BOLD}
-------------------------------------------------------------------------
                    Creating (and Theming) Grub Boot Menu
-------------------------------------------------------------------------
${C_RESET}
"
if [[ "${FS}" == "luks" ]]; then
sed -i "s%GRUB_CMDLINE_LINUX_DEFAULT=\"%GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${ENCRYPTED_PARTITION_UUID}:ROOT root=/dev/mapper/ROOT %g" /etc/default/grub
fi
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& splash /' /etc/default/grub

echo -e "Installing Vimix Grub theme..."
THEME_DIR="/boot/grub/themes/Vimix"
mkdir -p "\${THEME_DIR}"

cd "\${THEME_DIR}" || exit
git init
git remote add -f origin https://github.com/ChrisTitusTech/Top-5-Bootloader-Themes.git
git config core.sparseCheckout true
echo "themes/Vimix/*" >> .git/info/sparse-checkout
git pull origin main
mv themes/Vimix/* .
rm -rf themes
rm -rf .git

cp -an /etc/default/grub /etc/default/grub.bak
grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub
echo "GRUB_THEME=\"\${THEME_DIR}/theme.txt\"" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo -ne "
${C_BLUE}${C_BOLD}
-------------------------------------------------------------------------
                    Enabling Essential Services
-------------------------------------------------------------------------
${C_RESET}
"
ntpd -qg
systemctl enable ntpd.service
systemctl disable dhcpcd.service
systemctl stop dhcpcd.service
systemctl enable NetworkManager.service

# Enable display manager based on DE
case \${DE} in
    gnome)
        systemctl enable gdm.service
        systemctl enable bluetooth
        systemctl enable power-profiles-daemon.service
        ;;
    kde)
        systemctl enable sddm.service
        systemctl enable bluetooth
        systemctl enable power-profiles-daemon.service
        ;;
    xfce)
        systemctl enable lightdm.service
        systemctl enable bluetooth
        systemctl enable power-profiles-daemon.service
        ;;
    cosmic)
        systemctl enable cosmic-greeter.service
        systemctl enable bluetooth
        systemctl enable power-profiles-daemon.service
        ;;
    none)
        echo "No display manager to enable..."
        ;;
esac

echo -ne "
${C_CYAN}${C_BOLD}
-------------------------------------------------------------------------
                    Cleaning
-------------------------------------------------------------------------
${C_RESET}
"
# Remove no password sudo rights
sed -i 's/^%wheel ALL=(ALL) NOPASSWD: ALL/# %wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) NOPASSWD: ALL/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
# Add sudo rights
sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
EOF
echo -ne "
${C_MAGENTA}${C_BOLD}
-------------------------------------------------------------------------
                    Installation Complete!
-------------------------------------------------------------------------
${C_RESET}
"

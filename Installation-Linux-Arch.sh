# --- Installing Arch on an EFI system WITHOUT LVM --- #


# Set up disks

lsblk

fdisk /dev/[drive]
	    # GPT
        g
	    # EFI Partition
        n
        +500M # (last sector)
        t
        1 # (EFI System)
	    # Root and other partitions
        n
	    # Make sure partitions are correct
        p
	    # Write changes
        w

	# Format EFI partition
    mkfs.fat -F32 /dev/[EFI partition]

	# Format root and other partitions
    mkfs.ext4 /dev/[Root partition]
    mount /dev/[Root partition] /mnt

mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab


# Install Arch

pacstrap -i /mnt base

arch-chroot /mnt

pacman -S linux linux-headers linux-lts linux-lts-headers linux-firmware
pacman -S vim nano base-devel openssh dialog
pacman -S networkmanager wpa_supplicant wireless_tools netctl

	# If you want to enable sshd
	systemctl enable sshd

systemctl enable NetworkManager

mkinitcpio -p linux
mkinitcpio -p linux-lts


# Set up locales and users

	# Uncomment relevant locales
    vim /etc/locale.gen
locale-gen

	# Set root password
    passwd

	# Create user
    useradd -m -g users -G wheel [username]
    passwd [username]

	# Set up sudo
    pacman -S sudo

	    # Uncomment to allow members of group wheel to execute any command
        visudo


# Install boot loader

	# Install GRUB
	pacman -S grub efibootmgr dosfstools os-prober mtools

	mkdir /boot/EFI

	# Mount EFI partition
	mount /dev/sdXZ /boot/EFI

	grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck

	# Locale for grub
	mkdir /boot/grub/locale
	cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo

	# Generate GRUB config file
	grub-mkconfig -o /boot/grub/grub.cfg


# Now reboot your machine into the newly installed Arch
exit # (From the chroot)
umount -a
reboot


# --- Post Installation --- #

# Set time zone
timedatectl list-timezones
timedatectl set-timezone [Your timezone]

# Systemd time synchronization
systemctl enable systemd-timesyncd

# Set the hostname
hostnamectl set-hostname [Hostname]

	# Make the same change in /etc/hosts
	vim /etc/hosts
	# Example:
	# 127.0.0.1 localhost
	# 127.0.0.1 [Hostname]

# Install CPU Microcode

	# Intel
	pacman -S intel-ucode

	# AMD
	pacman -S amd-ucode

# Install Xorg for GUI
pacman -S xorg xorg-server mesa

	# Nvidia driver
	pacman -S nvidia nvidia-utils

	# Or for linux-lts
	pacman -S nvidia-lts nvidia-utils

# Virtualbox guest packages
pacman -S virtualbox-guest-utils xf86-video-vmware

# Desktop Environment
	
	# XFCE
	pacman -S xfce4 xfce4-goodies


	# GNOME
	pacman -S gnome gnome-tweaks


	# Enable Display Manager
	pacman -S lightdm lightdm-gtk-greeter

	systemctl enable lightdm # (Or any other display manager)
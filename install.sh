#!/bin/bash
set -euo pipefail

BLOCK_DEVICE_PATH=""
PARTITION_PREFIX=""
CHROOT_SCRIPT="chroot.sh"

ls /sys/firmware/efi/efivars || { echo "Boot type is not UEFI."; exit 1; }
ping -q -c 1 archlinux.org > /dev/null || { echo "Failed to ping archlinux.org."; exit 1; }

timedatectl set-ntp true

parted --script --align optimal "${BLOCK_DEVICE_PATH}" \
    mklabel gpt \
    mkpart esp fat32 0% 1GiB \
    set 1 esp on \
    mkpart root ext4 1024MiB 100%
mkfs.fat -F 32 "${BLOCK_DEVICE_PATH}${PARTITION_PREFIX}1"
mkfs.ext4 "${BLOCK_DEVICE_PATH}${PARTITION_PREFIX}2"
mount "${BLOCK_DEVICE_PATH}${PARTITION_PREFIX}2" /mnt
mount --mkdir "${BLOCK_DEVICE_PATH}${PARTITION_PREFIX}1" /mnt/boot

pacman -Sy archlinux-keyring
pacstrap -K /mnt base linux linux-firmware networkmanager grub efibootmgr

genfstab -U /mnt >> /mnt/etc/fstab

cp "${CHROOT_SCRIPT}" /mnt/tmp
arch-chroot /mnt "/tmp/${CHROOT_SCRIPT}"

umount -R /mnt

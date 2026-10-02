#!/bin/bash
set -euo pipefail

LOCALTIME_PATH="/usr/share/zoneinfo/US/Eastern"
LOCALE="en_US.UTF-8"
HOSTNAME="arch"
ROOT_PASSWORD="root"
USER_NAME="user"
USER_PASSWORD="user"

ln -sf "${LOCALTIME_PATH}" /etc/localtime
hwclock --systohc

sed --in_place --expression="/${LOCALE}/s/^#//g" --expression="/en_US.UTF-8/s/^#//g" /etc/locale.gen
locale-gen
echo "LANG=${LOCALE}" >> /etc/locale.conf

echo "${HOSTNAME}" >> /etc/hostname

printf "${ROOT_PASSWORD}\n${ROOT_PASSWORD}\n" | passwd

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service

sed --in-place "/%wheel ALL=(ALL:ALL) ALL/s/^# //g" /etc/sudoers

useradd --create-home --groups wheel "${USER_NAME}"
printf "${USER_PASSWORD}\n${USER_PASSWORD}\n" | passwd "${USER_NAME}"

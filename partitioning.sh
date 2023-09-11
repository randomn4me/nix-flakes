#!/bin/sh

ROOT="/dev/nvme0n1"

# partitioning

printf "label: gpt\n,550M,U\n,,L\n" | sfdisk ${ROOT}


# create boot
mkfs.fat -F 32 ${ROOT}p1

# setup luks
CRYPTNAME=cryptroot

cryptsetup luksFormat ${ROOT}p2
cryptsetup luksOpen ${ROOT}p2 $CRYPTNAME

CRYPTROOT=/dev/mapper/$CRYPTNAME

mkfs.btrfs ${CRYPTROOT}

mkdir -p /mnt

mount ${CRYPTROOT} /mnt

btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/swap

umount /mnt

mount -o compress=zstd,subvol=root ${CRYPTROOT} /mnt
mkdir -p /mnt/{home,nix}
mount -o compress=zstd,subvol=home ${CRYPTROOT} /mnt/home
mount -o compress=zstd,noatime,subvol=nix ${CRYPTROOT} /mnt/nix

mkdir -p /mnt/boot
mount ${ROOT}p1 /mnt/boot


# swapfile

mkdir /swap
mount -o subvol=swap ${CRYPTROOT} /swap

SWAPFILE=/swap/swapfile

truncate -s 0 $SWAPFILE
chattr +C $SWAPFILE
btrfs property set $SWAPFILE compression no
dd if=/dev/zero of=$SWAPFILE bs=1M count=16384
chmod 0600 $SWAPFILE
mkswap $SWAPFILE

nixos-generate-config --force --root /mnt

echo "#####################"
echo "add mount options manually"
echo "file should be located here"
echo "/mnt/etc/nixos/configuration.nix"
echo "#####################"

sleep 3

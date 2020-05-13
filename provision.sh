#!/usr/bin/env bash
set -euo pipefail

echo "==> 0. Подготовка"
yum install cryptsetup -y

DISK=/dev/sdb
DEVICE=/dev/sdb1
if [[ ! $(df | grep ${DISK}) ]]; then
  parted -s $DISK mklabel msdos
  parted -s -a opt $DISK mkpart primary ext4 0% 100%
fi

KEY=/root/my.key
if [[ ! -e $KEY ]]; then
echo "==> 1. Делаем файл-ключ"
dd if=/dev/urandom of=$KEY bs=1 count=1024
fi

echo "==> 2. Создаем криптоконтейнер"
cryptsetup -v -s 512 luksFormat $DEVICE $KEY

echo "==> 3. Открываем контейнер"
MAPPED=secrets
cryptsetup luksOpen -d $KEY $DEVICE $MAPPED
# Форматируем раздел
mkfs.xfs /dev/mapper/$MAPPED
# Монтируем раздел
mkdir /secrets
mount /dev/mapper/$MAPPED /$MAPPED

echo "==> 4. Заполняем контейнер произвольными данными"
echo "\"The Truth Is Out There\" - Agent FBI Fox William Mulder" > /$MAPPED/xfiles.txt

echo "==> 5. Закрываем контейнер"
umount /$MAPPED
cryptsetup luksClose $MAPPED

echo "==> 6. Открываем контейнер"
cryptsetup luksOpen -d $KEY $DEVICE $MAPPED
# Монтируем раздел повторно
mount /dev/mapper/$MAPPED /$MAPPED

echo "==> 7. Проверяем, что все на месте. Выводим файл xfiles.txt"
cat /$MAPPED/xfiles.txt

echo "==> 8. Создать дополнительный ключ (либо ключевой файл)"
NUKEY=/root/x-files.key
dd if=/dev/urandom of=$NUKEY bs=1 count=1024
cryptsetup luksAddKey $DEVICE $NUKEY --key-file=$KEY

echo "==> 9. Удалить старый ключ"
rm $KEY
echo "==> 10. Очистить слот от старого ключа"
cryptsetup luksKillSlot $DEVICE 0 --key-file=$NUKEY

echo "==> 11. проделать пункты 6-7 с новым ключом"
umount /$MAPPED
cryptsetup luksClose $MAPPED
cryptsetup luksOpen -d $NUKEY $DEVICE $MAPPED
# Монтируем раздел повторно
mount /dev/mapper/$MAPPED /$MAPPED
cat /$MAPPED/xfiles.txt

echo "==> 12. отмонтировать контейнер"
umount /$MAPPED
cryptsetup luksClose $MAPPED
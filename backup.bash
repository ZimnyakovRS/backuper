#!/bin/bash

# Скрипт для бэкапа на машину Ryzen5

# Папки для монтирования бэкапного ресурса
MNT_SRC=//192.168.0.140/HOSTHP_backup
MNT_POINT=/home/backuper/HOSTHP_backup
LOG=/home/backuper/HOSTHP_backup.log
# Папки для бэкапа, находящиеся в /home/samba/share/
BACKUP_CREDS=/secret/ryzen5.secret
BACKUP_DIRS=$(cat ./backup_dirs.txt)

echo "$(date +"%F %H:%M:%S") Начало бэкапа на машину Ryzen5" >> $LOG
#
# создание папки при необходимости
if ! [ -d $MNT_POINT ]
	then
		mkdir -p $MNT_POINT
fi
 монтирование по необходимости сетевой папки для бэкапа
if grep "HOSTHP_backup" /etc/mtab -q
	then
		echo "$(date +"%F %H:%M:%S") Папка для бэкапа уже была смонтирована" >> $LOG
	else
		mount -t cifs -o credentials=$BACKUP_CREDS $MNT_SRC $MNT_POINT ||
		    ( echo "$(date +"%F %H:%M:%S") Неуспешное монтирование"; exit 1 )
		echo "$(date +"%F %H:%M:%S") Папка для бэкапа смонтирована" >> $LOG
fi

# Синхронизация (бэкап)
for DIR in "${BACKUP_DIRS[@]}"
	do
		echo "$(date +"%F %H:%M:%S") Синхронизация папки $DIR начинется" >> $LOG
		rsync -a /home/samba/share/$DIR	$MNT_POINT/ 1>/dev/null 2>> $LOG
		# rsync -av /home/samba/share/test /home/backuper/HOSTHP_backup/
		echo "$(date +"%F %H:%M:%S") Cинхронизация папки $DIR закончена" >> $LOG
	done

echo "$(date +"%F %H:%M:%S") Конец бэкапа на машину Ryzen5" >> $LOG
umount $MNT_POINT || exit 1
exit 0

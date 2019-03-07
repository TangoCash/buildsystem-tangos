#!/bin/sh

#LOG='/etc/mdev/mdev-mount.log'
LOG='/dev/null'

# (e)udev compatibility
[[ -z $MDEV ]] && MDEV=$(basename $DEVNAME)

## device information log
echo  >> $LOG
echo  >> $LOG
echo "**************************" >> $LOG
echo  >> $LOG
echo "Action = "$ACTION >> $LOG
echo "Hotplug_Count = "$SEQNUM >> $LOG
echo "Mdev = "$MDEV >> $LOG
echo "Subsystem = "$SUBSYSTEM >> $LOG
echo  >> $LOG

MOUNTBASE=/media
MOUNTPOINT="$MOUNTBASE/$MDEV"
ROOTDEV=$(readlink /dev/root)
NTFSOPTS="-o big_writes,noatime"
BLACKLISTED=""

# do not add or remove root device again...
[ "$ROOTDEV" = "$MDEV" ] && exit 0
if [ -e /tmp/.nomdevmount ]; then
	echo "no action on $MDEV -- /tmp/.nomdevmount exists" >> $LOG
	exit 0
fi

create_symlinks() {
	if [ "${MDEV:0:6}" == "mmcblk" ] ; then
		DEVBASE=${MDEV:0:7} # first 7 characters
		PARTNUM=${MDEV:7}   # characters 7-
	else
		DEVBASE=${MDEV:0:3} # first 3 characters
		PARTNUM=${MDEV:3}   # characters 4-
		read MODEL < /sys/block/$DEVBASE/device/model
		MODEL=${MODEL// /_} # replace ' ' with '_'
		if [ `cat /sys/block/$DEVBASE/removable` == "1" ]; then
			echo "512" > /sys/block/$DEVBASE/device/max_sectors
		fi
	fi
	OLDPWD=$PWD
	cd $MOUNTBASE
	if which blkid > /dev/null; then
		BLKID=$(blkid -w /dev/null -c /dev/null /dev/$MDEV)
		eval ${BLKID#*:}
	fi
	if [ "$MDEV" != "$(basename $MOUNTPOINT)" ]; then
		ln -s "$MOUNTPOINT" "$MDEV"
		echo "symlink from $MOUNTBASE/$MDEV to $MOUNTPOINT created" >> $LOG
	fi
	if [ -n "$LABEL" ]; then
		rm -f "$LABEL"
		ln -s "$MOUNTPOINT" "$LABEL"
		echo "symlink from $MOUNTBASE/$LABEL to $MOUNTPOINT created" >> $LOG
	elif [ -n "$PARTLABEL" ]; then
		rm -f "$PARTLABEL"
		ln -s "$MOUNTPOINT" "$PARTLABEL"
		echo "symlink from $MOUNTBASE/$PARTLABEL to $MOUNTPOINT created" >> $LOG
	elif [ -n "$MODEL" ]; then
		LINK="${MODEL}${PARTNUM:+-}${PARTNUM}"
		rm -f "${LINK}"
		ln -s "$MOUNTPOINT" "${LINK}"
		echo "symlink from $MOUNTBASE/${LINK} to $MOUNTPOINT created" >> $LOG
	fi
	#if [ -n "$UUID" ]; then
	#	LINK="${TYPE}${TYPE:+-}${UUID}"
	#	rm -f "${LINK}"
	#	ln -s $MOUNTPOINT "${LINK}"
	#	echo "symlink from $MOUNTBASE/${LINK} to $MOUNTPOINT created" >> $LOG
	#fi
	cd $OLDPWD
}

remove_symlinks() {
	OLDPWD=$PWD
	cd $MOUNTBASE
	for i in `ls ./`; do
		[ -L "$i" ] || continue
		TARGET=$(readlink "$i")
		if [ "$TARGET" == "$MOUNTPOINT" ]; then
			rm "$i"
			echo "symlink from $MOUNTBASE/$i to $MOUNTPOINT removed" >> $LOG
		fi
	done
	cd $OLDPWD
}

case "$ACTION" in
	add|"")
		DEVCHECK=`expr substr $MDEV 1 7`
		DEVCHECK2=`expr substr $MDEV 1 3`
		# blacklisted devices
		for black in $BLACKLISTED; do
			if [ "$DEVCHECK" == "$black" ] || [ "$DEVCHECK2" == "$black" ] ; then
				echo "/dev/$MDEV blacklisted - not mounting" >> $LOG
				exit 0
			fi
		done
		# check if already mounted / in use
		if grep -q "^/dev/${MDEV} " /proc/mounts ; then
			echo "/dev/$MDEV already mounted - not mounting again" >> $LOG
			exit 0
		fi
		if grep -q "^/dev/${MDEV} " /proc/swaps ; then
			echo "/dev/$MDEV already in use for swap" >> $LOG
			exit 0
		fi
		# check for fstab
		if mount /dev/$MDEV > /dev/null 2>&1 ; then
			echo "fstab entry found, use automatic mountpoint" >> $LOG
			exit 0
		fi
		# check if has partitions
		if [ ${#MDEV} = 3 ]; then # sda, sdb, sdc => whole drive
			PARTS=$(sed -n "/ ${MDEV}[0-9]$/{s/ *[0-9]* *[0-9]* * [0-9]* //;p}" /proc/partitions)
			if [ -n "$PARTS" ]; then
				echo "drive has partitions $PARTS, not trying to mount $MDEV" >> $LOG
				exit 0
			fi
		fi
		# check for filesystem / special mountpoint
		if which blkid > /dev/null; then
			BLKID=$(blkid -w /dev/null -c /dev/null /dev/$MDEV)
			eval ${BLKID#*:}
			if [ -z $TYPE ]; then
				echo "no filesystem found, do not mount" >> $LOG
				exit 0
			fi
			case $TYPE in
				swap|SWAP) #this is a real linux SWAP partition
					swapon /dev/$MDEV
					sleep 1
					for deviceok in `awk '{print $1}' /proc/swaps | grep "/dev/$MDEV"`; do
						if [ "$deviceok" == "/dev/$MDEV" ]; then
							echo "real linux swap partition (/dev/$MDEV) mounted" >> $LOG
							exit 0
						fi
					done
				;;
			esac
			case $LABEL in
				SWAP|Swap|swap)
					MOUNTPOINT="/swap"
				;;
				hdd|HDD|MEDIA|record|RECORD|VIDEO_DISC)
					MOUNTPOINT="$MOUNTBASE/hdd"
				;;
				movie|MOVIE)
					MOUNTPOINT="$MOUNTBASE/hdd/movie"
				;;
				picture|PICTURE)
					MOUNTPOINT="$MOUNTBASE/hdd/picture"
				;;
				music|MUSIC)
					MOUNTPOINT="$MOUNTBASE/hdd/music"
				;;
			esac
		fi
		# all checks done
		echo "mounting /dev/$MDEV to $MOUNTPOINT" >> $LOG
		NTFSMOUNT=$(which ntfs-3g)
		RET2=$?
		# remove old mountpoint symlinks we might have for this device
		if [ $MOUNTPOINT != "/swap" ]; then
			rmdir $MOUNTPOINT
		fi
		mkdir -p $MOUNTPOINT
		for i in 1 2 3 4 5; do # retry 5 times
			# echo "mounting /dev/$MDEV to $MOUNTPOINT try $i" >> $LOG
			OUT1=$(mount -t auto /dev/$MDEV $MOUNTPOINT 2>&1 >/dev/null)
			RET1=$?
			[ $RET1 = 0 ] && break
			sleep 1
		done
		if [ $RET1 != 0 -a -n "$NTFSMOUNT" ]; then
			# failed,retry with ntfs-3g
			for i in 1 2; do # retry only twice, waited already 5 seconds
				$NTFSMOUNT $NTFSOPTS /dev/$MDEV $MOUNTPOINT
				RET2=$?
				[ $RET2 = 0 ] && break
				sleep 1
			done
		fi
		if [ $RET1 = 0 -o $RET2 = 0 ]; then
			create_symlinks
		else
			echo "mount   /dev/$MDEV $MOUNTPOINT failed with $RET1" >> $LOG
			echo "        $OUT1" >> $LOG
			if [ -n "$NTFSMOUNT" ]; then
				echo "ntfs-3g /dev/$MDEV $MOUNTPOINT failed with $RET2" >> $LOG
			fi
			if [ $MOUNTPOINT != "/swap" ]; then
				rmdir $MOUNTPOINT
			fi
		fi
		;;
	remove)
		echo "unmounting /dev/$MDEV" >> $LOG
		grep -q "^/dev/$MDEV " /proc/mounts || exit 0 # not mounted...
		MOUNTPOINT=`grep "^/dev/$MDEV\s" /proc/mounts | cut -d' ' -f 2`
		if [ -z "$MOUNTPOINT" ] ; then
			MOUNTPOINT="$MOUNTBASE/$MDEV"
		fi
		umount -lf $MOUNTPOINT
		RET=$?
		if [ $RET = 0 ]; then
			if [ $MOUNTPOINT != "/swap" ]; then
				rmdir $MOUNTPOINT
			fi
			remove_symlinks
		else
			echo "umount /dev/$MDEV failed with $RET" >> $LOG
		fi
		;;
esac

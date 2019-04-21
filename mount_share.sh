#! /bin/bash
# Description: Mount foler and share from physical to virtual computer

#check folder exist or not exist and create
if [ -d /mnt/hgfs ]
then
	echo "exit folder"
else
	echo "create folder"
	mkdir -p /mnt/hgfs
fi

cd /root/Desktop/
./mount-shared-folders
cd /mnt/hgfs/Downloads/


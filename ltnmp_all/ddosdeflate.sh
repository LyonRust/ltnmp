 #!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install ltnmp"
    exit 1
fi


clear
printf "=======================================================================\n"
printf "Linux DDos deflate Install or Delete, For LTNMP Written by  php360 \n"
printf "=======================================================================\n"
printf "This script is ADD or Delete DDos deflate  for VPS \n"
printf "\n"
printf "please feedback from Forum: http://www.05gzs.com/ \n"
printf "=======================================================================\n"
echo ""
cur_dir=$(pwd)


	ver="1"
	ver0="Install"
	echo "Which version do you want to install:"
	echo "Install  DDOS     please type: 1"
	echo "Delete   DDOS     please type: 0"
	read -p "Type  1 or 0 (Default version: 1 ):" ver
	echo ""
	if [ "$ver" = "" ]; then
		ver="1"
	fi


	if [ "$ver" != 1 ]&& [ "$ver" != 0 ]; then
       echo ""
	echo "Error: You must input 1 or 0 !!"
	exit 1
	fi


	if [ "$ver" = 0 ]; then
			ver0="Delete"
	fi



	get_char()
	{
	SAVEDSTTY=`stty -g`
	stty -echo
	stty cbreak
	dd if=/dev/tty bs=1 count=1 2> /dev/null
	stty -raw
	stty echo
	stty $SAVEDSTTY
	}

	echo "Press any key VPS  DDOS Tools "$ver0" ...or Press Ctrl+c to cancel"

char=`get_char`




#-----------Delete DDOS

if [ "$ver" = "0" ]; then

echo "Delete DDOS   from VPS......"
wget http://www.05gzs.com/ltnmp/ddos/uninstall.ddos
chmod 0700 uninstall.ddos
./uninstall.ddos
	exit 1
fi




#-----------Install DDOS

if [ "$ver" = "1" ]; then

echo "Install DDOS   to VPS......"


if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install Delete DDOS  the previous version first"
	exit 0
fi

wget http://www.05gzs.com/ltnmp/ddos/install.sh
chmod 0700 install.sh
./install.sh

sed -i 's/NO_OF_CONNECTIONS=150/NO_OF_CONNECTIONS=50/g' /usr/local/ddos/ddos.conf
sed -i 's/APF_BAN=1/APF_BAN=0/g' /usr/local/ddos/ddos.conf

/usr/local/ddos/ddos.sh

  if [ $? -eq 0 ]; then
	echo ""
  else
	sed -i 's/\#!\/bin\/sh/\#!\/bin\/bash/g' /usr/local/ddos/ddos.sh
	echo  "CONF not found   SET  OK"
	fi

fi


printf "\n"
printf "=======================================================================\n"
printf "Linux DDos deflate $ver0 completed ,For LTNMP Written by  php360 \n"
printf "=======================================================================\n"
printf "This script is ADD or Delete DDos deflate  for VPS  \n"
printf "\n"
printf "please feedback from Forum:  http://www.05gzs.com/"
printf "\n"
printf "========================================================================\n"
printf "\n"

/usr/local/ddos/ddos.sh
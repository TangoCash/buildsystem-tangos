#!/bin/bash

##############################################

if [ "$(id -u)" = "0" ]; then
	echo ""
	echo "You are running as root. Do not do this, it is dangerous."
	echo "Aborting the build. Log in as a regular user and retry."
	echo ""
	exit 1
fi

##############################################
# check for link sh to bash
if [ ! "$(basename $(readlink /bin/sh))" == "bash" ]; then
	echo -e "\033[01;31m================================================================="
	echo -e "===> ERROR : sudo ./prepare-for-bs.sh not executet -> EXIT ! <==="
	echo -e "=================================================================\033[0m"
	exit
fi

##############################################

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Parameter 1: Target receiver (30-70)"
	echo "Parameter 2: FFmpeg version (1-2)"
	echo "Parameter 3: Optimization (1-4)"
	echo "Parameter 4: Toolchain gcc version (1-3)"
	echo "Parameter 5: Image Neutrino (1-2)"
	echo "Parameter 6: Neutrino flavour (1-4)"
	echo "Parameter 7: External LCD support (1-4)"
	echo "optional:"
	echo "Parameter 8: Multiboot layout (1-2)"
	echo "Parameter 9: Busybox version (1-2)"
	exit
fi
##############################################

if [ "$1" == defaultconfig ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=hd51" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=multi" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == hd51 ] || [ "$1" == h7 ] || [ "$1" == bre2ze4k ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=multi" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == hd60 ] || [ "$1" == hd61 ] || [ "$1" == multibox ] || [ "$1" == multiboxse ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=multi" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == vusolo4k -o "$1" == vuduo4k -o "$1" == vuultimo4k -o "$1" == vuuno4k -o "$1" == vuuno4kse -o "$1" == vuzero4k ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "VU_MULTIBOOT=1" >> config
	echo "LAYOUT=single" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == osmini4k ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=single" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == osmio4k ] || [ "$1" == osmio4kplus ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino-wifi" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=single" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == vuduo ] || [ "$1" == vuduo2 ] || [ "$1" == gb800se ] || [ "$1" == osnino ] || [ "$1" == osninoplus ] || [ "$1" == osninopro ]; then
	echo "BOXARCH=mips" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=single" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == sf8008 ] || [ "$1" == sf8008m ] || [ "$1" == ustym4kpro ] || [ "$1" == h9combo ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino-wifi" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=multi" >> config
	echo " "
	make printenv
	exit
fi

if [ "$1" == h9 ]; then
	echo "BOXARCH=arm" > config
	echo "BOXTYPE=$1" >> config
	echo "FFMPEG_EXPERIMENTAL=0" >> config
	echo "OPTIMIZATIONS=size" >> config
	echo "BS_GCC_VER=10.3.0" >> config
	echo "IMAGE=neutrino-wifi" >> config
	echo "FLAVOUR=TANGOS" >> config
	echo "EXTERNAL_LCD=both" >> config
	echo "LAYOUT=single" >> config
	echo " "
	make printenv
	exit
fi
##############################################

case $1 in
	3[0-2] | 4[0-5] | 5[1-3] | 6[0-6] | 7[0-1] | 8[0-2] | 90) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo
		echo "  arm-based receivers"
		echo "  Edision"
		echo "   30)  Edision OS mio 4K"
		echo "   31)  Edision OS mio+ 4K"
		echo "   32)  Edision OS mini 4K"
		echo
		echo "  VU+"
		echo "   40) VU+ Solo 4K     43) VU+ Ultimo 4K"
		echo "   41) VU+ Duo  4K     44) VU+ Uno 4K SE"
		echo "   42) VU+ Zero 4K     45) VU+ Uno 4K"
		echo
		echo "  AX/Mut@nt"
		echo "   51)  AX/Mut@nt HD51"
		echo "   60)  AX/Mut@nt HD60"
		echo "   61)  AX/Mut@nt HD61"
		echo
		echo "  WWIO"
		echo "   52)  WWIO BRE2ZE 4K"
		echo
		echo "  Air Digital"
		echo "   53)  Zgemma H7"
		echo "   65)  Zgemma H9 Combo/Twin"
		echo "   66)  Zgemma H9s/H9.2s"
		echo
		echo "  Maxytec"
		echo "   54)  Multibox"
		echo "   55)  Multibox SE"
		echo
		echo "  Octagon & Uclan"
		echo "   62)  Octagon SF8008"
		echo "   63)  Octagon SF8008m"
		echo "   64)  Ustym 4k Pro"
		echo
		echo
		echo "  mips-based receivers"
		echo "  VU+"
		echo "   70)  VU+ Duo"
		echo "   71)  VU+ Duo2"
		echo
		echo "  Edision"
		echo "   80)  Edision OS nino"
		echo "   81)  Edision OS nino+"
		echo "   82)  Edision OS nino pro"
		echo
		echo "  Gigablue"
		echo "   90)  Gigablue 800 SE"
		echo
		read -p "Select target (30-90)? [51]"
		REPLY="${REPLY:-51}";;
esac

case "$REPLY" in
	30) BOXARCH="arm";BOXTYPE="osmio4k";;
	31) BOXARCH="arm";BOXTYPE="osmio4kplus";;
	32) BOXARCH="arm";BOXTYPE="osmini4k";;
	40) BOXARCH="arm";BOXTYPE="vusolo4k";;
	41) BOXARCH="arm";BOXTYPE="vuduo4k";;
	42) BOXARCH="arm";BOXTYPE="vuzero4k";;
	43) BOXARCH="arm";BOXTYPE="vuultimo4k";;
	44) BOXARCH="arm";BOXTYPE="vuuno4kse";;
	45) BOXARCH="arm";BOXTYPE="vuuno4k";;
	51) BOXARCH="arm";BOXTYPE="hd51";;
	52) BOXARCH="arm";BOXTYPE="bre2ze4k";;
	53) BOXARCH="arm";BOXTYPE="h7";;
	54) BOXARCH="arm";BOXTYPE="multibox";;
	55) BOXARCH="arm";BOXTYPE="multiboxse";;
	60) BOXARCH="arm";BOXTYPE="hd60";;
	61) BOXARCH="arm";BOXTYPE="hd61";;
	62) BOXARCH="arm";BOXTYPE="sf8008";;
	63) BOXARCH="arm";BOXTYPE="sf8008m";;
	64) BOXARCH="arm";BOXTYPE="ustym4kpro";;
	65) BOXARCH="arm";BOXTYPE="h9combo";;
	66) BOXARCH="arm";BOXTYPE="h9";;
	70) BOXARCH="mips";BOXTYPE="vuduo";;
	71) BOXARCH="mips";BOXTYPE="vuduo2";;
	80) BOXARCH="mips";BOXTYPE="osnino";;
	81) BOXARCH="mips";BOXTYPE="osninoplus";;
	82) BOXARCH="mips";BOXTYPE="osninopro";;
	90) BOXARCH="mips";BOXTYPE="gb800se";;
	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

case $2 in
	[1-2]) REPLY=$2;;
	*)	echo -e "\nFFmpeg Version:"
		echo "   1) buildsystem standard 4.4.2"
		echo "   2) ffmpeg git release/4.4 (with upstream fixes)"
		echo "   3) buildsystem standard 4.3.2"
		echo "   4) ffmpeg git snapshot (highly experimental)"
		read -p "Select FFmpeg version (1-4)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) FFMPEG_EXPERIMENTAL="0";;
	2) FFMPEG_EXPERIMENTAL="1";;
	3) FFMPEG_EXPERIMENTAL="2";;
	4) FFMPEG_EXPERIMENTAL="3";;
	*) FFMPEG_EXPERIMENTAL="0";;
esac
echo "FFMPEG_EXPERIMENTAL=$FFMPEG_EXPERIMENTAL" >> config

##############################################

case $3 in
	[1-4]) REPLY=$3;;
	*)	echo -e "\nOptimization:"
		echo "   1)  optimization for size"
		echo "   2)  optimization normal"
		echo "   3)  Kernel debug"
		echo "   4)  debug (includes Kernel debug)"
		read -p "Select optimization (1-4)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1)  OPTIMIZATIONS="size";;
	2)  OPTIMIZATIONS="normal";;
	3)  OPTIMIZATIONS="kerneldebug";;
	4)  OPTIMIZATIONS="debug";;
	*)  OPTIMIZATIONS="size";;
esac
echo "OPTIMIZATIONS=$OPTIMIZATIONS" >> config

##############################################

case $4 in
	[1-4]) REPLY=$4;;
	*)	echo -e "\nToolchain gcc version:"
		echo "   1) GCC version 10.3.0"
		echo "   2) GCC version  9.4.0"
		echo "   3) GCC version 11.3.0"
		echo "   4) GCC version 12.1.0"
		read -p "Select toolchain gcc version (1-4)? [1] "
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) BS_GCC_VER="10.3.0";;
	2) BS_GCC_VER=" 9.4.0";;
	3) BS_GCC_VER="11.3.0";;
	4) BS_GCC_VER="12.1.0";;
	*) BS_GCC_VER="10.3.0";;
esac
echo "BS_GCC_VER=$BS_GCC_VER" >> config

##############################################

case $5 in
	[1-2]) REPLY=$5;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Neutrino"
		echo "   2)  Neutrino (includes WiFi functions)"
	if [ $BOXTYPE == 'osmio4k' -o $BOXTYPE == 'osmio4kplus' -o $BOXTYPE == 'sf8008' -o $BOXTYPE == 'sf8008m' -o $BOXTYPE == 'ustym4kpro' -o $BOXTYPE == 'h9combo' -o $BOXTYPE == 'h9' ]; then
		read -p "Select Image to build (1-2)? [2]"
		REPLY="${REPLY:-2}"
	else
		read -p "Select Image to build (1-2)? [1]"
		REPLY="${REPLY:-1}"
	fi
	;;
esac

case "$REPLY" in
	1) IMAGE="neutrino";;
	2) IMAGE="neutrino-wifi";;
	*)
	if [ $BOXTYPE == 'osmio4k' -o $BOXTYPE == 'osmio4kplus' -o $BOXTYPE == 'sf8008' -o $BOXTYPE == 'sf8008m' -o $BOXTYPE == 'ustym4kpro' -o $BOXTYPE == 'h9combo' -o $BOXTYPE == 'h9' ]; then
		IMAGE="neutrino-wifi"
	else
		IMAGE="neutrino"
	fi
	;;
esac
echo "IMAGE=$IMAGE" >> config

##############################################

case $6 in
	[1-6]) REPLY=$6;;
	*)	echo -e "\nWhich Neutrino variant do you want to build?:"
		echo "   1)  neutrino-tangos"
		echo "   2)  neutrino-ddt"
		echo "   3)  neutrino-tuxbox"
		echo "   4)  neutrino-ni"
		echo "   5)  neutrino-max"
		echo "   6)  neutrino-hd2"
		read -p "Select Image to build (1-6)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) FLAVOUR="TANGOS";;
	2) FLAVOUR="DDT";;
	3) FLAVOUR="TUXBOX";;
	4) FLAVOUR="NI";;
	5) FLAVOUR="MAX";;
	6) FLAVOUR="HD2";;
	*) FLAVOUR="TANGOS";;
esac
echo "FLAVOUR=$FLAVOUR" >> config

##############################################

case $7 in
	[1-4]) REPLY=$7;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1)  graphlcd and lcd4linux for external LCD"
		echo "   2)  graphlcd for external LCD"
		echo "   3)  lcd4linux for external LCD"
		echo "   4)  No external LCD"
		read -p "Select external LCD support (1-4)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="both";;
	2) EXTERNAL_LCD="externallcd";;
	3) EXTERNAL_LCD="lcd4linux";;
	4) EXTERNAL_LCD="none";;
	*) EXTERNAL_LCD="externallcd";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config

##############################################

LAYOUT=single

if [ $BOXTYPE == 'hd51' -o $BOXTYPE == 'bre2ze4k' -o $BOXTYPE == 'h7' ]; then

case $8 in
	[1-2]) REPLY=$8;;
	*)	echo -e "\nImage-Layout:"
		echo "   1)  1 single + multiroot"
		echo "   2)  4 single"
		read -p "Select layout (1-2)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1)  LAYOUT="multi";;
	2)  LAYOUT="single";;
	*)  LAYOUT="multi";;
esac

fi

if [ $BOXTYPE == 'vusolo4k' -o $BOXTYPE == 'vuduo4k' -o $BOXTYPE == 'vuultimo4k' -o $BOXTYPE == 'vuuno4k' -o $BOXTYPE == 'vuuno4kse' -o $BOXTYPE == 'vuzero4k' ]; then
case $8 in
	[1-2]) REPLY=$8;;
	*)	echo -e "\nNormal or MultiBoot:"
		echo "   1)  Multiboot"
		echo "   2)  Normal"
		read -p "Select mode (1-2)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1)  VU_MULTIBOOT="1";;
	2)  VU_MULTIBOOT="0";;
	*)  VU_MULTIBOOT="1";;
esac
echo "VU_MULTIBOOT=$VU_MULTIBOOT" >> config
fi

if [ $BOXTYPE == 'hd60' -o $BOXTYPE == 'hd61' -o $BOXTYPE == 'multibox' -o $BOXTYPE == 'multiboxse' -o $BOXTYPE == 'sf8008' -o $BOXTYPE == 'sf8008m'  -o $BOXTYPE == 'ustym4kpro' -o $BOXTYPE == 'h9combo' ]; then
echo "LAYOUT=multi" >> config
else
echo "LAYOUT=$LAYOUT" >> config
fi
##############################################

case $9 in
	[1-2]) REPLY=$9;;
	*)	echo -e "\nBusybox Version:"
		echo "   1) buildsystem standard 1.35.0"
		echo "   2) busybox git snapshot (experimental)"
		read -p "Select Busybox version (1-2)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) BUSYBOX_SNAPSHOT="0";;
	2) BUSYBOX_SNAPSHOT="1";;
	*) BUSYBOX_SNAPSHOT="0";;
esac
echo "BUSYBOX_SNAPSHOT=$BUSYBOX_SNAPSHOT" >> config

##############################################
echo " "
make printenv
##############################################
echo "Your next step could be:"
echo "  make neutrino"
echo "  make flashimage"
echo "  make ofgimage"
echo " "

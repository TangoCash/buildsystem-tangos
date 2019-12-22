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

if [ "$1" == -h ] || [ "$1" == --help ]; then
	echo "Parameter 1: Target receiver (40-70)"
	echo "Parameter 2: FFmpeg version (1-2)"
	echo "Parameter 3: Optimization (1-4)"
	echo "Parameter 4: Toolchain gcc version (1-3)"
	echo "Parameter 5: Image Neutrino (1-2)"
	echo "Parameter 6: Neutrino flavour (1-5)"
	echo "Parameter 7: External LCD support (1-4)"
	echo "optional:"
	echo "Parameter 8: Multiboot layout (1-2)"
	exit
fi

##############################################

case $1 in
	4[0-5] | 5[1-3] | 6[0-1] | 70) REPLY=$1;;
	*)
		echo "Target receivers:"
		echo
		echo "  arm-based receivers"
		echo "   VU+"
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
		echo "   53)  ZGEMMA H7"
		echo
		echo
		echo "  mips-based receivers"
		echo "   70)  VU+ Duo"
		echo
		read -p "Select target (40-70)? [51]"
		REPLY="${REPLY:-51}";;
esac

case "$REPLY" in
	40) BOXARCH="arm";BOXTYPE="vusolo4k";;
	41) BOXARCH="arm";BOXTYPE="vuduo4k";;
	42) BOXARCH="arm";BOXTYPE="vuzero4k";;
	43) BOXARCH="arm";BOXTYPE="vuultimo4k";;
	44) BOXARCH="arm";BOXTYPE="vuuno4kse";;
	45) BOXARCH="arm";BOXTYPE="vuuno4k";;
	51) BOXARCH="arm";BOXTYPE="hd51";;
	52) BOXARCH="arm";BOXTYPE="bre2ze4k";;
	53) BOXARCH="arm";BOXTYPE="h7";;
	60) BOXARCH="arm";BOXTYPE="hd60";;
	61) BOXARCH="arm";BOXTYPE="hd61";;
	70) BOXARCH="mips";BOXTYPE="vuduo";;
	 *) BOXARCH="arm";BOXTYPE="hd51";;
esac
echo "BOXARCH=$BOXARCH" > config
echo "BOXTYPE=$BOXTYPE" >> config

##############################################

case $2 in
	[1-2]) REPLY=$2;;
	*)	echo -e "\nFFmpeg Version:"
		echo "   1) buildsystem standard"
		echo "   2) ffmpeg git snapshot"
		read -p "Select FFmpeg version (1-2)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) FFMPEG_EXPERIMENTAL="0";;
	2) FFMPEG_EXPERIMENTAL="1";;
	*) FFMPEG_EXPERIMENTAL="1";;
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
	[1-3]) REPLY=$4;;
	*)	echo -e "\nToolchain gcc version:"
		echo "   1) GCC version 6.5.0"
		echo "   2) GCC version 7.4.1"
		echo "   3) GCC version 8.2.0"
		read -p "Select toolchain gcc version (1-3)? [1] "
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) BS_GCC_VER="6.5.0";;
	2) BS_GCC_VER="7.4.1";;
	3) BS_GCC_VER="8.2.0";;
	*) BS_GCC_VER="6.5.0";;
esac
echo "BS_GCC_VER=$BS_GCC_VER" >> config

##############################################

case $5 in
	[1-2]) REPLY=$5;;
	*)	echo -e "\nWhich Image do you want to build:"
		echo "   1)  Neutrino"
		echo "   2)  Neutrino (includes WLAN drivers)"
		read -p "Select Image to build (1-2)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1) IMAGE="neutrino";;
	2) IMAGE="neutrino-wlandriver";;
	*) IMAGE="neutrino";;
esac
echo "IMAGE=$IMAGE" >> config

##############################################

case $6 in
	[1-6]) REPLY=$6;;
	*)	echo -e "\nWhich Neutrino variant do you want to build?:"
		echo "   1)  neutrino-ddt    [ arm/sh4 ]"
		echo "   2)  neutrino-max    [ arm     ]"
		echo "   3)  neutrino-ni     [ arm     ]"
		echo "   4)  neutrino-tangos [ arm/sh4 ]"
		echo "   5)  neutrino-tuxbox [ arm/sh4 ]"
		echo "   6)  neutrino-hd2    [ arm/sh4 ]"
		read -p "Select Image to build (1-6)? [4]"
		REPLY="${REPLY:-4}";;
esac

case "$REPLY" in
	1) FLAVOUR="neutrino-ddt";;
	2) FLAVOUR="neutrino-max";;
	3) FLAVOUR="neutrino-ni";;
	4) FLAVOUR="neutrino-tangos";;
	5) FLAVOUR="neutrino-tuxbox";;
	6) FLAVOUR="neutrino-hd2";;
	*) FLAVOUR="neutrino-tangos";;
esac
echo "FLAVOUR=$FLAVOUR" >> config

##############################################

case $7 in
	[1-4]) REPLY=$7;;
	*)	echo -e "\nExternal LCD support:"
		echo "   1)  No external LCD"
		echo "   2)  graphlcd for external LCD"
		echo "   3)  lcd4linux for external LCD"
		echo "   4)  graphlcd and lcd4linux for external LCD"
		read -p "Select external LCD support (1-4)? [4]"
		REPLY="${REPLY:-4}";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="none";;
	2) EXTERNAL_LCD="externallcd";;
	3) EXTERNAL_LCD="lcd4linux";;
	4) EXTERNAL_LCD="both";;
	*) EXTERNAL_LCD="none";;
esac
echo "EXTERNAL_LCD=$EXTERNAL_LCD" >> config

##############################################

if [ $BOXTYPE == 'hd51' -o $BOXTYPE == 'bre2ze4k' -o $BOXTYPE == 'h7' ]; then

case $8 in
	[1-2]) REPLY=$8;;
	*)	echo -e "\nImage-Layout:"
		echo "   1)  4 single"
		echo "   2)  1 single + multiroot"
		read -p "Select layout (1-2)? [1]"
		REPLY="${REPLY:-1}";;
esac

case "$REPLY" in
	1)  NEWLAYOUT="0";;
	2)  NEWLAYOUT="1";;
	*)  NEWLAYOUT="0";;
esac
echo "NEWLAYOUT=$NEWLAYOUT" >> config

fi

if [ $BOXTYPE == 'hd60' -o $BOXTYPE == 'hd61' ]; then
echo "NEWLAYOUT=1" >> config
fi

if [ $BOXTYPE == 'vusolo4k' -o $BOXTYPE == 'vuduo4k' -o $BOXTYPE == 'vuultimo4k' -o $BOXTYPE == 'vuuno4k' -o $BOXTYPE == 'vuuno4kse' -o $BOXTYPE == 'vuzero4k' ]; then
case $8 in
	[1-2]) REPLY=$8;;
	*)	echo -e "\nNormal or MultiBoot:"
		echo "   1)  Normal"
		echo "   2)  Multiboot"
		read -p "Select mode (1-2)? [2]"
		REPLY="${REPLY:-2}";;
esac

case "$REPLY" in
	1)  VU_MULTIBOOT="0";;
	2)  VU_MULTIBOOT="1";;
	*)  VU_MULTIBOOT="1";;
esac
echo "VU_MULTIBOOT=$VU_MULTIBOOT" >> config
fi

##############################################
echo " "
make printenv
##############################################
echo "Your next step could be:"
echo "  make neutrino"
echo "  make flashimage"
echo "  make ofgimage"
echo " "

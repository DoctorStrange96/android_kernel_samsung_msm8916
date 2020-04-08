#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building Valerio's ZXKernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial set-up
[ ! -d out ] && mkdir out;

export PATH="$HOME/Toolchains/Linaro-7.5/bin:$PATH";
export ARCH="arm";
export SUBARCH="arm";
export CROSS_COMPILE="arm-linux-gnueabihf-";

case $1 in
	"clean" | "c")
		make clean O="out";
		exit;;
	"mrproper" | "m" | "cleanall")
		make mrproper O="out";
		exit;;
	"*")
		;;
esac;

VariantPrompt="Choose the variant to build this kernel for. 
1. Galaxy Grand Prime/Prime Duos (Standard) (SM-G530H XXU / fortuna3g)
2. Galaxy Grand Prime/Prime Duos (VE) (SM-G530H XCU / fortunave3g)
3. Galaxy Gran(d) Prime Duos (Brazil) (SM-G530BT / fortuna3gdtv) ";

while read -p "$VariantPrompt" variant; do
	case $variant in
		"1")
			echo -e "Selected variant: SM-G530H XXU / fortuna3g\n";
			SELECTED_DEVICE="fortuna3g";
			SELECTED_DEFCONFIG="msm8916_sec_fortuna3g_eur_defconfig";
			break;;
		"2")
			echo -e "Selected variant: SM-G530H XCU / fortunave3g\n";
			SELECTED_DEVICE="fortunave3g";
			SELECTED_DEFCONFIG="msm8916_sec_fortunave3g_eur_defconfig";
			break;;
		"3")
			echo -e "Selected variant: SM-G530BT / fortuna3gdtv\n";
			SELECTED_DEVICE="fortuna3gdtv";
			SELECTED_DEFCONFIG="msm8916_sec_fortuna3g_ltn_dtv_defconfig";
			break;;
		"*")
			echo -e "Invalid option. Please try again.\n";;
	esac;
done;

export VARIANT_DEFCONFIG="$SELECTED_DEFCONFIG";	
export SELINUX_DEFCONFIG="selinux_defconfig";
export VERSION="zxkernel";
export DEVICE="$SELECTED_DEVICE";
export MAIN_DIR="$HOME/GrandPrime_G530BT_Kernel";
export OUT_DIR="$MAIN_DIR/products";
[ ! -d $OUT_DIR/$VERSION/$DEVICE ] && mkdir -p $OUT_DIR/$VERSION/$DEVICE;

# Actual build
echo -e "Building...\n";
make msm8916_sec_defconfig O="out";
make -j4 O="out";
# Build finish date/time
export BUILD_FINISH_TIME=`date +"%Y%m%d-%H%M%S"`;

./dtbtool -o $MAIN_DIR/$VERSION/$DEVICE/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
cp out/arch/$ARCH/boot/zImage $MAIN_DIR/$VERSION/$DEVICE;
find . -type f -iname "*.ko" -exec cp {} $MAIN_DIR/$VERSION/$DEVICE/modules/system/lib/modules \;;

# Flashable zip
echo -e "Creating flashable zip...\n";
cd $MAIN_DIR/common;
zip -r9 $OUT_DIR/$VERSION/$DEVICE/$VERSION-"kernel"-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
cd $MAIN_DIR/$VERSION/$DEVICE;
zip -r9 $OUT_DIR/$VERSION/$DEVICE/$VERSION-"kernel"-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
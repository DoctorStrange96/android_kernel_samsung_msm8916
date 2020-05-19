#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building Valerio's ZXKernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

function InitialGreeting {
	echo -e "ZXKernel by Valerio aka DarkDroidDev";
	echo -e "Build script created by DoctorStrange96\n";
}

function InitialSetup {
	echo -e "Setting up cross-compiler..."
	export PATH="$HOME/Toolchains/Linaro-7.5/bin:$PATH";
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE="arm-linux-gnueabihf-";
	echo -e "Creating output directory if needed..."
	if [ ! -d out ]; then
		mkdir out && echo "Output directory created.";
	else
		echo -e "Output directory already exists. Skipping.\n";
	fi;
};

function ShowHelp {
	HelpString=`cat << EOM
	1, fortuna3g - build for Galaxy Grand Prime/Prime Duos (Standard) (SM-G530H XXU / fortuna3g)
	2, fortuna3gdtv - Galaxy Gran(d) Prime Duos (Brazil) (SM-G530BT / fortuna3gdtv)
	3, fortunave3g - Galaxy Grand Prime/Prime Duos (VE) (SM-G530H XCU / fortunave3g)
	c, clean - remove most generated files
	h, help - show this help message
	m, mrproper, cleanall - remove all generated files 
		(if you're building for all variants sequentially, do this before each build)
EOM
`;
	echo -e "$HelpString";
};

# Initial set-up

InitialGreeting;
case $1 in
	"help" | "h" | " " | "")
		echo -e "This build script accepts the following parameters:";
		ShowHelp;
		echo -e "Running this script with no arguments will also trigger this help message.";
		exit 0;;
	*)
		InitialSetup;
		case $1 in
			"clean" | "c")
				echo -e "Cleaning most generated files..."
				make clean O="out" > /dev/null;
				echo -e "Done!"
				exit 0;;
			"mrproper" | "m" | "cleanall")
				echo -e "Cleaning all generated files..."
				make mrproper O="out" > /dev/null;
				echo -e "Done!"
				exit 0;;
			"1" | "fortuna3g")
				echo -e "Selected variant: SM-G530H XXU / fortuna3g\n";
				SELECTED_DEVICE="fortuna3g";
				SELECTED_DEFCONFIG="msm8916_sec_fortuna3g_eur_defconfig";;
			"2" | "fortuna3gdtv")
				echo -e "Selected variant: SM-G530BT / fortuna3gdtv\n";
				SELECTED_DEVICE="fortuna3gdtv";
				SELECTED_DEFCONFIG="msm8916_sec_fortuna3g_ltn_dtv_defconfig";;
			"3" | "fortunave3g")
				echo -e "Selected variant: SM-G530H XCU / fortunave3g\n";
				SELECTED_DEVICE="fortunave3g";
				SELECTED_DEFCONFIG="msm8916_sec_fortunave3g_eur_defconfig";;
			*)
				echo -e "You have entered an invalid option.\nYou can use the following options:";
				ShowHelp;
				exit 1;;
		esac;
esac;

export VARIANT_DEFCONFIG="$SELECTED_DEFCONFIG";	
export SELINUX_DEFCONFIG="selinux_defconfig";
export VERSION="zxkernel";
export DEVICE="$SELECTED_DEVICE";
export MAIN_DIR="$HOME/GrandPrime_G530BT_Kernel";
export OUT_DIR="$MAIN_DIR/products";
[ ! -d $OUT_DIR/$VERSION/$DEVICE ] && mkdir -p $OUT_DIR/$VERSION/$DEVICE;

# Actual build
echo -e "Building...\n";
echo -e "Starting at `date`.";
make msm8916_sec_defconfig O="out";
make -j4 O="out";
# Build finish date/time
export BUILD_FINISH_TIME=`date +"%Y%m%d-%H%M%S"`;

# Check if the build succeded by checking if zImage exists, otherwise abort
if [ -f out/arch/arm/boot/zImage ]; then
	echo -e "Creating device tree blob (DTB) image...";
	./dtbtool -o $MAIN_DIR/$VERSION/$DEVICE/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
	echo -e "Copying kernel image...";
	cp out/arch/$ARCH/boot/zImage $MAIN_DIR/$VERSION/$DEVICE;
	echo -e "Copying kernel modules...";
	find . -type f -iname "*.ko" -exec cp {} $MAIN_DIR/$VERSION/$DEVICE/modules/system/lib/modules \;;
else
	echo -e "zImage was not found. That means this build failed. Please check your sources for any errors and try again.";
	exit 1;
fi;

# Flashable zip
echo -e "Creating flashable zip...\n";
cd $MAIN_DIR/common;
zip -r9 $OUT_DIR/$VERSION/$DEVICE/$VERSION-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
cd $MAIN_DIR/$VERSION/$DEVICE;
zip -r9 $OUT_DIR/$VERSION/$DEVICE/$VERSION-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
echo -e "Done!";
echo -e "Build finished at `date`."; 
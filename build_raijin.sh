#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building my Raijin Kernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial variables
KERNEL_NAME="RaijinKernel";
KERNEL_VERSION="Amaterasu";
KERNEL_DIR=`pwd`;
SCRIPT_NAME="build_raijin.sh";

function RaijinAsciiArt {
	echo -e "-------------------------------------------------";
	sleep 0.1;
	echo -e " __________________________________________   __ ";
	sleep 0.1;
	echo -e " ___  __ \__    |___  _/_____  /___  _/__  | / / ";
	sleep 0.1;
	echo -e " __  /_/ /_  /| |__  / ___ _  / __  / __   |/ /  ";
	sleep 0.1;
	echo -e " _  _, _/_  ___ |_/ /  / /_/ / __/ /  _  /|  /   ";
	sleep 0.1;
	echo -e " /_/ |_| /_/  |_/___/  \____/  /___/  /_/ |_/    ";
	sleep 0.1;
	echo -e "                      雷神                        ";
	sleep 0.1;
	echo -e "-------------------------------------------------";
	sleep 0.1;
	echo -e " Raijin Kernel - Created by DoctorStrange96      ";
	sleep 0.1;
	echo -e " Version: $KERNEL_VERSION                        ";
	sleep 0.1;
	echo -e " Based on ZXKernel by DarkDroidDev & itexpert120 ";
	sleep 0.1;
	echo -e " Made for Samsung Galaxy Grand Prime (SM-G530)   ";
	sleep 0.1;
	echo -e " Compatible with Android 9 (Pie) and 10 (Q)      ";
	sleep 0.1;	
	echo -e "";
	sleep 0.1;
	echo -e " Made with Love and Lightning Power in Brazil!   ";
	sleep 0.1;
	echo -e "-------------------------------------------------";
}

function InitialSetup {
	echo -e "Setting up cross-compiler..."
	export PATH="$HOME/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin:$PATH";
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE="arm-linux-gnueabihf-";
	echo -e "Creating make's \"out\" directory if needed..."
	if [ ! -d out ]; then
		mkdir out && echo "Make \"out\" directory successfully created.";
	else
		echo -e "Make \"out\" directory already exists. Skipping.\n";
	fi;
	echo -e "Creating Raijin final build folder if needed...";
	if [ ! -d raijin ]; then
		mkdir raijin && echo "Raijin folder successfully created.";
	else
		echo -e "Raijin folder already exists. Skipping.\n";
	fi;
};

function ShowHelp {
	HelpString=`cat << EOM
	1-6 - variant to build this kernel for
		1, fortuna3g - Galaxy Grand Prime (3G) (SM-G530H XXU / fortuna3g)
		2, fortuna3gdtv - Galaxy "Gran" Prime Duos (Brazil, 3G DTV) (SM-G530BT / fortuna3gdtv)
		3, fortunave3g - Galaxy Grand Prime (3G VE) (SM-G530H XCU / fortunave3g)
		4, fortunafz - Galaxy Grand Prime LTE (Europe) (SM-G530FZ / fortunafz)
		5, fortunalteub - Galaxy Grand Prime LTE (Latin America) (SM-G530M / fortunalteub)
		6, fortunaltedx - Galaxy Grand Prime LTE (Middle East / South Asia) (SM-G530F / fortunaltedx)
	c, clean - remove most generated files
	h, help - show this help message
	m, mrproper, cleanall - remove all generated files 
		(if you're building for all variants sequentially, do this before each build)
EOM
`;
	echo -e "$HelpString";
};

# Initial set-up

RaijinAsciiArt;
case $1 in
	"help" | "h")
		echo -e "This build script accepts the following parameters:";
		ShowHelp;
		exit 0;;
	"" | " ")
		echo -e "Error: This script requires at least one argument.\nRun \"./$SCRIPT_NAME help\" or \"./$SCRIPT_NAME h\" 
for info on how to use the build script.";
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
				SELECTED_DEFCONFIG="raijin_msm8916_fortuna3g_defconfig";;
			"2" | "fortuna3gdtv")
				echo -e "Selected variant: SM-G530BT / fortuna3gdtv\n";
				SELECTED_DEVICE="fortuna3gdtv";
				SELECTED_DEFCONFIG="raijin_msm8916_fortuna3gdtv_defconfig";;
			"3" | "fortunave3g")
				echo -e "Selected variant: SM-G530H XCU / fortunave3g\n";
				SELECTED_DEVICE="fortunave3g";
				SELECTED_DEFCONFIG="raijin_msm8916_fortunave3g_defconfig";;
			"4" | "fortunafz")
				echo -e "Selected variant: SM-G530FZ / fortunafz\n";
				SELECTED_DEVICE="fortunafz";
				SELECTED_DEFCONFIG="raijin_msm8916_fortunafz_defconfig";;
			"5" | "fortunalteub")
				echo -e "Selected variant: SM-G530M / fortunalteub\n";
				SELECTED_DEVICE="fortunalteub";
				SELECTED_DEFCONFIG="raijin_msm8916_fortunalteub_defconfig";;				
			"6" | "fortunaltedx")
				echo -e "Selected variant: SM-G530F / fortunaltedx";
				SELECTED_DEVICE="fortunaltedx";
				SELECTED_DEFCONFIG="raijin_msm8916_fortunaltedx_defconfig";;
			*)
				echo -e "You have entered an invalid option.\nYou can use the following options:";
				ShowHelp;
				exit 1;;
		esac;
esac;

export VARIANT_DEFCONFIG="$SELECTED_DEFCONFIG";	
export SELINUX_DEFCONFIG="raijin_selinux_defconfig";
export DEVICE="$SELECTED_DEVICE";
export DEVICE_DIR="$KERNEL_DIR/raijin/device_specific/$SELECTED_DEVICE";
export OUT_DIR="$KERNEL_DIR/raijin/final_builds";
[ ! -d $OUT_DIR/$DEVICE ] && mkdir -p $OUT_DIR/$DEVICE;

# Actual build
echo -e "Building...\n";
echo -e "Starting at `date`.";
make raijin_msm8916_defconfig O="out";
make -j`expr $(($(nproc --all) * 2))` O="out";
# Build finish date/time
export BUILD_FINISH_TIME=`date +"%Y%m%d-%H%M%S"`;

# Check if the build succeded by checking if zImage exists, otherwise abort
if [ -f out/arch/arm/boot/zImage ]; then
	echo -e "Creating device tree blob (DTB) image...";
	./dtbtool -o $DEVICE_DIR/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
	echo -e "Copying kernel image...";
	cp out/arch/$ARCH/boot/zImage $DEVICE_DIR;
	echo -e "Copying kernel modules...";
	find . -type f -iname "*.ko" -exec cp {} $DEVICE_DIR/modules/system/lib/modules \;;
	echo -e "Built for: $SELECTED_DEVICE\n$Build date and time: `date +"%Y-%m-%d %H:%M:%S GMT%Z"`" > $DEVICE_DIR/info.txt;
else
	echo -e "zImage was not found. That means this build failed. Please check your sources for any errors and try again.";
	exit 1;
fi;

# Flashable zip
echo -e "Creating flashable zip...\n";
cd $KERNEL_DIR/raijin/ak3-common;
zip -r9 $OUT_DIR/$VERSION/$DEVICE/$KERNEL_NAME-$KERNEL_VERSION-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
cd $DEVICE_DIR;
zip -r9 $OUT_DIR/$VERSION/$DEVICE/$KERNEL_NAME-$KERNEL_VERSION-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
echo -e "Done!";
echo -e "Build finished at `date`."; 
#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building my Raijin Kernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial variables
KernelName="RaijinKernel";
KernelVersion="Ame-no-Uzume";
KernelFolder=`pwd`;
ScriptName="build_raijin.sh";

# Supported devices list
declare -a SupportedDevicesList=("fortuna3g" "fortuna3gdtv" "fortunafz" "fortunaltedx" "fortunalteub" "fortunave3g");

# Normal & bold text
normal=`tput sgr0`;
bold=`tput bold`;

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
	echo -e " Version: $KernelVersion                        ";
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
};

function CleanSources {
	case $1 in
		"basic")
			echo -e "Cleaning most generated files..."
			if [[ "$VerboseMode" = "true" ]]; then
				make clean O="out";
			else
				make clean O="out" > /dev/null;
			fi;
			echo -e "Done!";;
		"full")
			echo -e "Cleaning all generated files..."
			if [[ "$VerboseMode" = "true" ]]; then
				make mrproper O="out";
			else
				make mrproper O="out" > /dev/null;
			fi;
			echo -e "Done!";;
	esac;
};

function CreateFlashableZip {
	echo -e "Creating flashable zip...";
	cd $KernelFolder/raijin/ak3_common;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	cd $DeviceFolder;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	echo -e "Cleaning up...\n";
	rm -f $DeviceFolder/zImage;
	rm -f $DeviceFolder/dt.img;
	rm -f $DeviceFolder/*.txt;
	rm -f $ModulesFolder/*;
};

function InitialSetup {
	echo -e "Setting up cross-compiler..."
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
	echo -e "Creating make's \"out\" directory if needed..."
	if [ ! -d out ]; then
		mkdir out && echo -e "Make \"out\" directory successfully created.\n";
	else
		echo -e "Make \"out\" directory already exists. Skipping.\n";
	fi;
	echo -e "Creating Raijin final builds folder if needed...";
	if [ ! -d raijin/final_builds ]; then
		mkdir -p raijin/final_builds && echo -e "Raijin final builds folder successfully created\n.";
	else
		echo -e "Raijin final builds folder already exists. Skipping.\n";
	fi;
};

function ShowHelp {
	HelpString=`cat << EOM
	1-6 - variant to build this kernel for
		1, fortuna3g - Galaxy Grand Prime (3G) (SM-G530H XXU / fortuna3g)
		2, fortuna3gdtv - Galaxy "Gran" Prime Duos (Brazil, 3G DTV) (SM-G530BT / fortuna3gdtv)
		3, fortunave3g - Galaxy Grand Prime (3G VE) (SM-G530H XCU / fortunave3g)
		4, fortunafz, gprimeltexx - Galaxy Grand Prime LTE (Europe) (SM-G530FZ / fortunafz or gprimeltexx)
		5, fortunalteub - Galaxy Grand Prime LTE (Latin America) (SM-G530M / fortunalteub)
		6, fortunaltedx - Galaxy Grand Prime LTE (Middle East / South Asia) (SM-G530F / fortunaltedx)
	a, all, ba, buildall - build for all devices sequentially
	c, clean - remove most generated files
	h, help - show this help message
	m, mrproper, cleanall - remove all generated files
EOM
`;
	echo -e "$HelpString";
};

function SingleDeviceBuild {
	# Always clean everything before building
	CleanSources full;

	# Optimal job count: (number of CPU threads * 2) + 1
	JobCount=`expr $((($(nproc --all) * 2) + 1))`;

	# Some basic set-up
	SelectedDevice="$1";
	export BuildDate=`date +"%Y%m%d"`;
	export BuildDateFull=`date +"%Y%m%d-%H%M%S"`;
	export VARIANT_DEFCONFIG="raijin_msm8916_"$SelectedDevice"_defconfig";
	export LOCALVERSION="-Raijin-"$KernelVersion"-"$BuildDate;
	export SELINUX_DEFCONFIG="raijin_selinux_defconfig";
	export DeviceFolder=$KernelFolder/raijin/device_specific/$SelectedDevice;
	export OutFolder=$KernelFolder/raijin/final_builds;
	export ModulesFolder=$DeviceFolder/modules/system/lib/modules;
	[ ! -d $OutFolder/$SelectedDevice ] && mkdir -p $OutFolder/$SelectedDevice;
	[ ! -d $ModulesFolder ] && mkdir -p $ModulesFolder;

	# This is where the actual build starts
	echo -e "Building...\n";
	echo -e "Build started on `date +"%Y-%m-%d"` at `date +"%R GMT%z"`.";
	echo -e "Kernel localversion will be: 3.10.108"$LOCALVERSION;
	make raijin_msm8916_defconfig O="out";
	make -j$JobCount O="out";

	# Build finish date/time
	export BuildFinishTime=`date +"%Y-%m-%d %H:%M:%S GMT%z"`

	# Check if the build succeeded by checking if zImage exists; else abort
	if [ -f out/arch/arm/boot/zImage ]; then
		# Tell the building part is finished
		echo -e "Build finished on `date +"%Y-%m-%d"` at `date +"%R GMT%z"`.";
		# Copy zImage
		echo -e "Copying kernel image...";
		cp out/arch/$ARCH/boot/zImage $DeviceFolder;
		# Copy all kernel modules. Use `find` so no file gets skipped. Also remove any previously built modules.
		echo -e "Copying kernel modules...";
		rm -f $ModulesFolder/*;
		find . -type f -iname "*.ko" -exec cp -f {} $ModulesFolder \;;
		# Create our DTB image
		echo -e "Creating device tree blob (DTB) image...";
		if [[ "$VerboseMode" = "true" ]]; then
			./dtbtool -o $DeviceFolder/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
		else
			./dtbtool -o $DeviceFolder/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/ > /dev/null 2>&1;
		fi;
		# Write some info to be read by raijin.sh before flashing
		echo -e "$SelectedDevice" > $DeviceFolder/device.txt;
		echo -e "$BuildFinishTime" > $DeviceFolder/date.txt;
		echo -e "$KernelVersion" > $DeviceFolder/version.txt;
		# Create our zip file
		CreateFlashableZip;
		# Finish
		echo -e "Done!";
		BuildSuccessful="true";
		if [[ ! "$BuildForAll" = "true" ]]; then
			echo -e "The whole process was finished on `date +"%Y-%m-%d"` at `date +"%R GMT%z"`.
You'll find your flashable zip at raijin/final_builds/$SelectedDevice.";
		fi;
	else
		echo -e "zImage was not found. That means this build failed. Please check your sources for any errors and try again.";
		exit 1;
	fi;
};

# Start the script here
RaijinAsciiArt;
case $1 in
	"help" | "h")
		echo -e "This build script accepts the following parameters:";
		ShowHelp;
		exit 0;;
	"" | " ")
		echo -e "${bold}Error:${normal} This script requires at least one argument.\nRun \"./$ScriptName help\" or \"./$ScriptName h\" 
for info on how to use the build script.";
		exit 0;;
	*)
		InitialSetup;
		case $2 in
		"v" | "verbose")
			VerboseMode="true";
			echo -e "Verbose mode enabled.";;
		esac;
		case $1 in
			"clean" | "c")
				CleanSources basic;
				exit 0;;
			"mrproper" | "m" | "cleanall")
				CleanSources full;
				exit 0;;
			"1" | "fortuna3g")
				echo -e "Selected variant: SM-G530H XXU / fortuna3g\n";
				SingleDeviceBuild fortuna3g;;
			"2" | "fortuna3gdtv")
				echo -e "Selected variant: SM-G530BT / fortuna3gdtv\n";
				SingleDeviceBuild fortuna3gdtv;;
			"3" | "fortunave3g")
				echo -e "Selected variant: SM-G530H XCU / fortunave3g\n";
				SingleDeviceBuild fortunave3g;;
			"4" | "fortunafz")
				echo -e "Selected variant: SM-G530FZ / fortunafz\n";
				SingleDeviceBuild fortunafz;;
			"5" | "fortunalteub")
				echo -e "Selected variant: SM-G530M / fortunalteub\n";
				SingleDeviceBuild fortunalteub;;	
			"6" | "fortunaltedx")
				echo -e "Selected variant: SM-G530F / fortunaltedx";
				SingleDeviceBuild fortunaltedx;;
			"a" | "all" | "ba" | "buildall")
				BuildForAll="true";
				echo -e "Building for all devices.\nI recommend you go eat/drink something. This might take a ${bold}LONG ${normal}time.";
				for device in ${SupportedDevicesList[@]}; do
					export ARCH="arm";
					export SUBARCH="arm";
					export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
					echo -e "Building for: $device";
					cd $KernelFolder;
					SingleDeviceBuild $device;
					clear;
				done;
				if [[ "$BuildSuccessful" = "true" ]]; then
					echo -e "The whole process was finished on `date +"%Y-%m-%d"` at `date +"%R GMT%z"`.
You'll find your flashable zips at the respective raijin/final_builds folder for each device.";
				fi;;
			*)
				echo -e "You have entered an invalid option.\nYou can use the following options:";
				ShowHelp;
				exit 1;;
		esac;
esac;

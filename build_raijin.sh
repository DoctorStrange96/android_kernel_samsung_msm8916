#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building my Raijin Kernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial variables
KernelName="RaijinKernel";
KernelVersionNumber="1.1";
KernelVersionName="Ame-no-Uzume";
KernelFolder=`pwd`;
ScriptName="build_raijin.sh";

# Supported devices list
declare -a SupportedDevicesList=("fortuna3g" "fortuna3gdtv" "fortunafz" "fortunaltedx" "fortunalteub" "fortunave3g");

# Normal & bold text / Colours
normal=`tput sgr0`;
bold=`tput bold`;
red=`tput setaf 1`;
nc=`tput setaf 7`;

# Error string (changes according to locale)
ErrorString="Error: "

function BoldText() {
	echo -e "${bold}$1${normal}";
};

function ErrorMsg() {
	echo -e "${red}${bold}$ErrorString${nc}${normal}$1";
};

function RaijinAsciiArt() {
	BoldText "-----------------------------------------------------";
	sleep 0.1;
	BoldText "   __________________________________________   __   ";
	sleep 0.1;
	BoldText "   ___  __ \__    |___  _/_____  /___  _/__  | / /   ";
	sleep 0.1;
	BoldText "   __  /_/ /_  /| |__  / ___ _  / __  / __   |/ /    ";
	sleep 0.1;
	BoldText "   _  _, _/_  ___ |_/ /  / /_/ / __/ /  _  /|  /     ";
	sleep 0.1;
	BoldText "   /_/ |_| /_/  |_/___/  \____/  /___/  /_/ |_/      ";
	sleep 0.1;
	echo -e "                         雷神                          ";
	sleep 0.1;
	BoldText "-----------------------------------------------------";
	sleep 0.1;
	BoldText " Raijin Kernel - Created by DoctorStrange96          ";
	sleep 0.1;
	BoldText " Version: $KernelVersionNumber \"$KernelVersionName\"";
	sleep 0.1;
	BoldText " Overclocked Edition                                 ";
	sleep 0.1;	
	BoldText " Baséd on ZXKernel by DarkDroidDev & itexpert120     ";
	sleep 0.1;
	BoldText " Made for Samsung Galaxy Grand Prime (SM-G530)       ";
	sleep 0.1;
	BoldText " Compatible with Android 8.1, 9 and 10               ";
	sleep 0.1;	
	BoldText "";
	sleep 0.1;
	BoldText " Made in Brazil!                                     ";
	sleep 0.1;
	BoldText "-----------------------------------------------------";
};

function CleanSources() {
	case $1 in
		"basic")
			echo -e "Removing compiled objects only..."
			if [[ "$VerboseMode" = "true" ]]; then
				make clean O="out";
			else
				make clean O="out" > /dev/null;
			fi;
			echo -e "Done!";;
		"full")
			echo -e "Cleaning all previously generated files..."
			if [[ "$VerboseMode" = "true" ]]; then
				make mrproper O="out";
			else
				make mrproper O="out" > /dev/null;
			fi;
			echo -e "Done!";;
	esac;
};

function CreateFlashableZip() {
	echo -e "Creating flashable zip...";
	cd $KernelFolder/raijin_oc/ak3_common;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-OC-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-OC-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	cd $DeviceFolder;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-OC-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-OC-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	echo -e "Cleaning up...\n";
	rm -f $DeviceFolder/zImage;
	rm -f $DeviceFolder/dt.img;
	rm -f $DeviceFolder/*.txt;
	rm -f $ModulesFolder/*;
};

function InitialSetup() {
	echo -e "Setting up cross-compiler..."
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
	echo -e "Creating make's \"out\" directory if needed..."
	if [ ! -d out ]; then
		mkdir out && echo -e "Make \"out\" directory successfully created.\n";
	else
		echo -e "Make \"out\" directory already exists. Nothing to do.\n";
	fi;
	echo -e "Creating Raijin final builds folder if needed...";
	if [ ! -d raijin_oc/final_builds ]; then
		mkdir -p raijin_oc/final_builds && echo -e "Raijin final builds folder successfully created.\n";
	else
		echo -e "Raijin final builds folder already exists. Nothing to do.\n";
	fi;
};

function ShowHelp() {
	HelpString=`cat << EOM
${bold}Usage: ${normal}./$ScriptName {1-6|VARIANT|a|c|h|m} {v|nc} {nc}

Supported variants:
	1, fortuna3g - SM-G530H XXU (Global Grand Prime, 3G only)
	2, fortuna3gdtv - SM-G530BT (Brazilian "Gran" Prime w/ DTV, 3G only)
	3, fortunafz, gprimeltexx - SM-G530FZ (European Grand Prime LTE)
	4, fortunaltedx - SM-G530F (M. East/Africa/APAC Grand Prime LTE)
	5, fortunalteub - SM-G530M (LATAM Grand Prime LTE)
	6, fortunave3g - SM-G530H XCU (EMEA Grand Prime VE, 3G only)	

Other options:
	a, all, ba, buildall - build for all devices sequentially
	c, clean - remove most generated files (compiled objects only)
	h, help - show this help message
	m, mrproper, cleanall - remove all generated files

Build options:
	nc, noclean - skip pre-build source clean-up ${bold}(not recommended!)${normal}
	v, verbose - enable verbose mode
EOM
`;
	echo -e "$HelpString";
};

function BuildKernelAndDtb() {
	# Always clean everything before building unless the "nc" flag was passed
	[[ ! "$NoClean" = "true" ]] && CleanSources full;

	# Optimal job count: (number of CPU threads * 2) + 1
	JobCount=`expr $((($(nproc --all) * 2) + 1))`;

	# Some basic set-up
	SelectedDevice="$1";
	export BuildDate=`date +"%Y%m%d"`;
	export BuildDateFull=`date +"%Y%m%d-%H%M%S"`;
	export VARIANT_DEFCONFIG="raijin_msm8916_"$SelectedDevice"_defconfig";
	export LOCALVERSION="-Raijin-"$KernelVersionNumber"-"$KernelVersionName"-OC-"$BuildDate;
	export SELINUX_DEFCONFIG="raijin_selinux_defconfig";
	export DeviceFolder=$KernelFolder/raijin_oc/device_specific/$SelectedDevice;
	export OutFolder=$KernelFolder/raijin_oc/final_builds;
	export ModulesFolder=$DeviceFolder/modules/system/lib/modules;
	[ ! -d $OutFolder/$SelectedDevice ] && mkdir -p $OutFolder/$SelectedDevice;
	[ ! -d $ModulesFolder ] && mkdir -p $ModulesFolder;

	# This is where the actual build starts
	echo -e "Building...\n";
	echo -e "Build started on `date +"%d %B %Y"` at `date +"%R GMT%z"`.";
	echo -e "Kernel localversion will be: 3.10.108"$LOCALVERSION;
	make -C $KernelFolder -j$JobCount raijin_msm8916_defconfig O="out";
	make -C $KernelFolder -j$JobCount O="out";

	# Build finish date/time
	export BuildFinishTime=`date +"%Y-%m-%d %H:%M:%S GMT%z"`

	# Check if the build succeeded by checking if zImage exists; else abort
	if [ -f out/arch/arm/boot/zImage ]; then
		# Tell the building part is finished
		echo -e "Build finished on `date +"%d %B %Y"` at `date +"%R GMT%z"`.";
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
			echo -e "The whole process was finished on `date +"%d %B %Y"` at `date +"%R GMT%z"`.
You'll find your flashable zip at raijin_oc/final_builds/$SelectedDevice.";
		fi;
	else
		echo -e "zImage was not found. That means the build failed. 
Please check your source code for errors; if that is the case, fix them and try again.";
		exit 1;
	fi;
};

# Start the script here
RaijinAsciiArt;
case $1 in
	"help" | "h")
		ShowHelp;
		exit 0;;
	"" | " ")
		ErrorMsg "This script requires at least one argument.\nRun \"./$ScriptName help\" or \"./$ScriptName h\" 
for help.";
		exit 0;;
	*)
		InitialSetup;
		case $2 in
		"v" | "verbose")
			VerboseMode="true";
			echo -e "Verbose mode enabled.";;

		"nc" | "noclean")
			NoClean="true";
			echo -e "Pre-build source clean-up will be skipped. I hope you're sure what you're doing!";;
		esac;
		case $3 in
		"nc" | "noclean")
			NoClean="true";
			echo -e "Pre-build source clean-up will be skipped. I hope you're sure what you're doing!";;
		esac;
		case $1 in
			"clean" | "c")
				CleanSources basic;
				exit 0;;
			"mrproper" | "m" | "cleanall")
				CleanSources full;
				exit 0;;
			"1" | "fortuna3g")
				echo -e "Selected variant: SM-G530H XXU\n";
				BuildKernelAndDtb fortuna3g;;
			"2" | "fortuna3gdtv")
				echo -e "Selected variant: SM-G530BT\n";
				BuildKernelAndDtb fortuna3gdtv;;
			"3" | "fortunafz" | "gprimeltexx")
				echo -e "Selected variant: SM-G530FZ\n";
				BuildKernelAndDtb fortunave3g;;
			"4" | "fortunaltedx")
				echo -e "Selected variant: SM-G530F\n";
				BuildKernelAndDtb fortunafz;;
			"5" | "fortunalteub")
				echo -e "Selected variant: SM-G530M\n";
				BuildKernelAndDtb fortunalteub;;	
			"6" | "fortunave3g")
				echo -e "Selected variant: SM-G530H XCU\n";
				BuildKernelAndDtb fortunave3g;;
			"a" | "all" | "ba" | "buildall")
				BuildForAll="true";
				echo -e "Building for all devices sequentially.
I recommend you go eat/drink something. This might take a ${bold}LONG ${normal}time.";
				for device in ${SupportedDevicesList[@]}; do
					export ARCH="arm";
					export SUBARCH="arm";
					export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
					cd $KernelFolder;
					BuildKernelAndDtb $device;
					clear;
				done;
				if [[ "$BuildSuccessful" = "true" ]]; then
					echo -e "The whole process was finished on `date +"%Y-%m-%d"` at `date +"%R GMT%z"`.
You'll find your flashable zips at the respective raijin_oc/final_builds folder for each device.";
				fi;;
			*)
				ErrorMsg "You have entered an invalid option.";
				ShowHelp;
				exit 1;;
		esac;
esac;

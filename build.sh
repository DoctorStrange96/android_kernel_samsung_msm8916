#!/bin/zsh

# Initial set-up
[ ! -d out ] && mkdir out;

case $1 in
	"clean" | "c")
		make clean O="out";
		exit;;
	"mrproper" | "cleanall" | "m")
		make mrproper O="out";
		exit;;
	"*")
		;;
esac;

export PATH="$HOME/Toolchains/Linaro-7.5/bin:$PATH";
export ARCH="arm";
export SUBARCH="arm";
export CROSS_COMPILE="arm-linux-gnueabihf-";
export VARIANT_DEFCONFIG="msm8916_sec_fortuna3g_ltn_dtv_defconfig";	
export SELINUX_DEFCONFIG="selinux_defconfig";
export VERSION="lineage-16.0-oc";
export DEVICE="fortuna3gdtv";
export MAIN_DIR="$HOME/GrandPrime_G530BT_Kernel";
export OUT_DIR="$MAIN_DIR/products";
[ ! -d $OUT_DIR/$VERSION ] && mkdir -p $OUT_DIR/$VERSION;

# Actual build
echo -e "Building...\n";
make msm8916_sec_defconfig O="out";
make -j4 O="out";
# Build finish date/time
export BUILD_FINISH_TIME=`date +"%Y%m%d-%H%M%S"`;

./dtbtool -o $MAIN_DIR/$VERSION/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
cp out/arch/$ARCH/boot/zImage $MAIN_DIR/$VERSION;

# Flashable zip
echo -e "Creating flashable zip...\n";
cd $MAIN_DIR/common;
zip -r9 $OUT_DIR/$VERSION/$VERSION-"kernel"-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
cd $MAIN_DIR/$VERSION;
zip -r9 $OUT_DIR/$VERSION/$VERSION-"kernel"-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
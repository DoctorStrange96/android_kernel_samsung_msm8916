#!/bin/zsh

# Initial set-up
export PATH="$HOME/Toolchains/Linaro-5.5/bin:$PATH";
export ARCH="arm";
export SUBARCH="arm";
export CROSS_COMPILE="arm-linux-gnueabihf-";	
export SELINUX_DEFCONFIG="selinux_defconfig";
export VERSION="lineage-14.1";
export DEVICE="fortuna3gdtv";
export MAIN_DIR="$HOME/GrandPrime_G530BT_Kernel";
export OUT_DIR="$MAIN_DIR/products";
[ ! -d out ] && mkdir out;
[ ! -d $OUT_DIR/$VERSION ] && mkdir -p $OUT_DIR/$VERSION;

case $1 in
	"clean")
		make clean O="out";
		exit;;
	"mrproper")
		make mrproper O="out";
		exit;;
	"*")
		;;
esac;

# Actual build
echo -e "Building...\n";
make msm8916_fortuna3g_ltn_dtv_defconfig O="out";
make -j8 O="out";

if [ ! -f out/arch/arm/boot/zImage ]; then
	 export BUILD_FAILED="true";
fi;

# Don't do anything if the build fails
if [ "$BUILD_FAILED" != "true" ]; then
	# Build finish date/time
	export BUILD_FINISH_TIME=`date +"%Y%m%d-%H%M%S"`;

	[ -f $MAIN_DIR/$VERSION/dt.img ] && rm -f $MAIN_DIR/$VERSION/dt.img;
	./dtbtool -o $MAIN_DIR/$VERSION/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
	cp out/arch/$ARCH/boot/zImage $MAIN_DIR/$VERSION;

	# For Lineage 14.1 only: copy kernel modules
	[ ! -d $MAIN_DIR/$VERSION/modules/system/lib/modules ] && mkdir -p $MAIN_DIR/$VERSION/modules/system/lib/modules;
	rm $MAIN_DIR/$VERSION/modules/system/lib/modules/*;
	find ./out -type f -iname "*.ko" -exec cp {} $MAIN_DIR/$VERSION/modules/system/lib/modules/ \;

	# Flashable zip
	echo -e "Creating flashable zip...\n";
	cd $MAIN_DIR/common;
	zip -r9 $OUT_DIR/$VERSION/$VERSION-"kernel"-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;
	cd $MAIN_DIR/$VERSION;
	zip -r9 $OUT_DIR/$VERSION/$VERSION-"kernel"-$DEVICE-$BUILD_FINISH_TIME.zip . > /dev/null;	
else
	echo -e "Build failed.";
fi;

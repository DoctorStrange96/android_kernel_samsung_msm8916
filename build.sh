#!/bin/bash

export PATH="$HOME/Toolchains/Linaro-4.9/bin:$PATH"
export ARCH="arm"
export SUBARCH="arm"
export CROSS_COMPILE="arm-linux-gnueabihf-"
export VARIANT_DEFCONFIG="$1"
export SELINUX_DEFCONFIG="selinux_defconfig"

make msm8916_sec_defconfig O="out"
make -j4 O="out"

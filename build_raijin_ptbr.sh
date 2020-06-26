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
ScriptName="build_raijin_ptbr.sh";

# Supported devices list
declare -a SupportedDevicesList=("fortuna3g" "fortuna3gdtv" "fortunafz" "fortunaltedx" "fortunalteub" "fortunave3g");

# Normal & bold text
normal=`tput sgr0`;
bold=`tput bold`;
red=`tput setaf 1`;
nc=`tput setaf 7`;

# Error string (changes according to locale)
ErrorString="Erro: "

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
	BoldText " Raijin Kernel - Criado por DoctorStrange96          ";
	sleep 0.1;
	BoldText " Versão: $KernelVersionNumber \"$KernelVersionName\" ";
	sleep 0.1;
	BoldText " Edição Padrão                                       ";
	sleep 0.1;	
	BoldText " Baseado no ZXKernel por DarkDroidDev e itexpert120  ";
	sleep 0.1;
	BoldText " Criado para o Samsung Galaxy Grand Prime (SM-G530)  ";
	sleep 0.1;
	BoldText " Compatível com Android 8.1, 9 e 10                  ";
	sleep 0.1;	
	BoldText "";
	sleep 0.1;
	BoldText " Feito no Brasil!                                    ";
	sleep 0.1;
	BoldText "-----------------------------------------------------";
};

function CleanSources() {
	case $1 in
		"basic")
			echo -e "Removendo somente os objetos compilados..."
			if [[ "$VerboseMode" = "true" ]]; then
				make clean O="out";
			else
				make clean O="out" > /dev/null;
			fi;
			echo -e "Feito!";;
		"full")
			echo -e "Removendo todos os arquivos anteriormente gerados..."
			if [[ "$VerboseMode" = "true" ]]; then
				make mrproper O="out";
			else
				make mrproper O="out" > /dev/null;
			fi;
			echo -e "Feito!";;
	esac;
};

function CreateFlashableZip() {
	echo -e "Criando um \"flashable zip\"...";
	cd $KernelFolder/raijin/ak3_common;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	cd $DeviceFolder;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersionNumber-$KernelVersionName-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	echo -e "Limpando...\n";
	rm -f $DeviceFolder/zImage;
	rm -f $DeviceFolder/dt.img;
	rm -f $DeviceFolder/*.txt;
	rm -f $ModulesFolder/*;
};

function InitialSetup() {
	echo -e "Configurando o compilador..."
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
	echo -e "Criando a pasta de saída..."
	if [ ! -d out ]; then
		mkdir out && echo -e "Pasta de saída criada com sucesso.\n";
	else
		echo -e "A pasta de saída já existe. Nada a fazer.\n";
	fi;
	echo -e "Criando a pasta das builds finais...";
	if [ ! -d raijin/final_builds ]; then
		mkdir -p raijin/final_builds && echo -e "Pasta das builds finais criada com sucesso.\n";
	else
		echo -e "A pasta das builds finais já existe. Nada a fazer.\n";
	fi;
};

function ShowHelp() {
	HelpString=`cat << EOM
${bold}Uso: ${normal}./$ScriptName {1-6|MODELO|a|c|h|m} {v|nc} {nc}

Modelos suportados:
	1, fortuna3g - SM-G530H XXU (Global, apenas 3G)
	2, fortuna3gdtv - SM-G530BT ("Gran" Prime com TV digital, Brasil, apenas 3G)
	3, fortunafz, gprimeltexx - SM-G530FZ (Europa, 4G com NFC)
	4, fortunaltedx - SM-G530F (Oriente Médio/África/Ásia, 4G)
	5, fortunalteub - SM-G530M (América Latina, 4G)
	6, fortunave3g - SM-G530H XCU (EMEA, apenas 3G)	

Outras opções:
	a, all, ba, buildall - compilar para todos os modelos sequencialmente
	c, clean - remover somente os objetos compilados
	h, help - mostrar esta mensagem de ajuda
	m, mrproper, cleanall - fazer uma limpeza completa

Opções de compilação:
	nc, noclean - não fazer nenhuma limpeza antes da compilação ${bold}(não recomendado!)${normal}
	v, verbose - ativar o modo verbose
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
	export LOCALVERSION="-Raijin-"$KernelVersionNumber"-"$KernelVersionName"-"$BuildDate;
	export SELINUX_DEFCONFIG="raijin_selinux_defconfig";
	export DeviceFolder=$KernelFolder/raijin/device_specific/$SelectedDevice;
	export OutFolder=$KernelFolder/raijin/final_builds;
	export ModulesFolder=$DeviceFolder/modules/system/lib/modules;
	[ ! -d $OutFolder/$SelectedDevice ] && mkdir -p $OutFolder/$SelectedDevice;
	[ ! -d $ModulesFolder ] && mkdir -p $ModulesFolder;

	# This is where the actual build starts
	echo -e "Compilando...\n";
	echo -e "A compilação começou em `date +"%d de %B de %Y"` às `date +"%R GMT%z"`.";
	echo -e "A versão do kernel será: 3.10.108"$LOCALVERSION;
	make -C $KernelFolder -j$JobCount raijin_msm8916_defconfig O="out";
	make -C $KernelFolder -j$JobCount O="out";

	# Build finish date/time
	export BuildFinishTime=`date +"%Y-%m-%d %H:%M:%S GMT%z"`

	# Check if the build succeeded by checking if zImage exists; else abort
	if [ -f out/arch/arm/boot/zImage ]; then
		# Tell the building part is finished
		echo -e "A compilação terminou em `date +"%d de %B de %Y"` às `date +"%R GMT%z"`.";
		# Copy zImage
		echo -e "Copiando imagem do kernel...";
		cp out/arch/$ARCH/boot/zImage $DeviceFolder;
		# Copy all kernel modules. Use `find` so no file gets skipped. Also remove any previously built modules.
		echo -e "Copiando módulos...";
		rm -f $ModulesFolder/*;
		find . -type f -iname "*.ko" -exec cp -f {} $ModulesFolder \;;
		# Create our DTB image
		echo -e "Criando imagem \"DTB\"...";
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
		echo -e "Feito!";
		BuildSuccessful="true";
		if [[ ! "$BuildForAll" = "true" ]]; then
			echo -e "O processo inteiro terminou em `date +"%d de %B de %Y"` às `date +"%R GMT%z"`.
Você encontrará seu flashable zip em raijin/final_builds/$SelectedDevice.";
		fi;
	else
		echo -e "O arquivo \"zImage\" não foi encontrado. Isso significa que a compilação falhou.
Verifique se o código-fonte contém erros; se for o caso, corrija-os e tente de novo.";
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
		ErrorMsg "Este script requer pelo menos um argumento.\nExecute \"./$ScriptName help\" ou \"./$ScriptName h\"
para obter ajuda.";
		exit 0;;
	*)
		InitialSetup;
		case $2 in
		"v" | "verbose")
			VerboseMode="true";
			echo -e "Modo verbose ativado.";;

		"nc" | "noclean")
			NoClean="true";
			echo -e "Limpeza pré-compilação desativada. Espero que você saiba o que está fazendo!";;
		esac;
		case $3 in
		"nc" | "noclean")
			NoClean="true";
			echo -e "Limpeza pré-compilação desativada. Espero que você saiba o que está fazendo!";;
		esac;
		case $1 in
			"clean" | "c")
				CleanSources basic;
				exit 0;;
			"mrproper" | "m" | "cleanall")
				CleanSources full;
				exit 0;;
			"1" | "fortuna3g")
				echo -e "Modelo selecionado: SM-G530H XXU\n";
				BuildKernelAndDtb fortuna3g;;
			"2" | "fortuna3gdtv")
				echo -e "Modelo selecionado: SM-G530BT\n";
				BuildKernelAndDtb fortuna3gdtv;;
			"3" | "fortunafz" | "gprimeltexx")
				echo -e "Modelo selecionado: SM-G530FZ\n";
				BuildKernelAndDtb fortunave3g;;
			"4" | "fortunaltedx")
				echo -e "Modelo selecionado: SM-G530F\n";
				BuildKernelAndDtb fortunafz;;
			"5" | "fortunalteub")
				echo -e "Modelo selecionado: SM-G530M\n";
				BuildKernelAndDtb fortunalteub;;	
			"6" | "fortunave3g")
				echo -e "Modelo selecionado: SM-G530H XCU\n";
				BuildKernelAndDtb fortunave3g;;
			"a" | "all" | "ba" | "buildall")
				BuildForAll="true";
				echo -e "Compilando para todos os modelos.
Te recomendo ir comer ou beber alguma coisa. Isso pode levar ${bold}BASTANTE ${normal}tempo.";
				for device in ${SupportedDevicesList[@]}; do
					export ARCH="arm";
					export SUBARCH="arm";
					export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
					cd $KernelFolder;
					BuildKernelAndDtb $device;
					clear;
				done;
				if [[ "$BuildSuccessful" = "true" ]]; then
					echo -e "O processo inteiro terminou em `date +"%d de %B de %Y"` às `date +"%R GMT%z"`.
Você encontrará seus flashable zips na respectiva pasta raijin/final_builds para cada modelo.";
				fi;;
			*)
				ErrorMsg "Você forneceu uma opção inválida.";
				ShowHelp;
				exit 1;;
		esac;
esac;

#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building my Raijin Kernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial variables
KernelName="RaijinKernel";
KernelVersionNumber="1.1.2";
KernelVersionName="Ame-no-Uzume";
KernelFolder=`pwd`;
ScriptName="build_raijin_it.sh";

# Supported devices list
declare -a SupportedDevicesList=("fortuna3g" "fortuna3gdtv" "fortunafz" "fortunaltedx" "fortunalteub" "fortunave3g");

# Normal & bold text / Colours
normal=`tput sgr0`;
bold=`tput bold`;
red=`tput setaf 1`;
nc=`tput setaf 7`;

# Error string (changes according to locale)
ErrorString="Errore: "

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
	BoldText " Raijin Kernel - Creato da DoctorStrange96            ";
	sleep 0.1;
	BoldText " Versione: $KernelVersionNumber \"$KernelVersionName\"" ;
	sleep 0.1;
	BoldText " Edizione Standard                                    ";
	sleep 0.1;	
	BoldText " Basato su ZXKernel da DarkDroidDev & itexpert120    ";
	sleep 0.1;
	BoldText " Creato per il Samsung Galaxy Grand Prime (SM-G530)   ";
	sleep 0.1;
	BoldText " Compatibile con Android 8.1, 9 e 10                 ";
	sleep 0.1;	
	BoldText "";
	sleep 0.1;
	BoldText " Fatto in Brasile!                                    ";
	sleep 0.1;
	BoldText "-----------------------------------------------------";
};

function CleanSources() {
	case $1 in
		"basic")
			echo -e "Rimozione solo degli oggetti compilati..."
			if [[ "$VerboseMode" = "true" ]]; then
				make clean O="out";
			else
				make clean O="out" > /dev/null;
			fi;
			echo -e "Fatto!";;
		"full")
			echo -e "Rimozione di tutti i file generati..."
			if [[ "$VerboseMode" = "true" ]]; then
				make mrproper O="out";
			else
				make mrproper O="out" > /dev/null;
			fi;
			echo -e "Fatto!";;
	esac;
};

function CreateFlashableZip() {
	echo -e "Creazione del \"flashable zip\"...";
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
	echo -e "Pulizia...\n";
	rm -f $DeviceFolder/zImage;
	rm -f $DeviceFolder/dt.img;
	rm -f $DeviceFolder/*.txt;
	rm -f $ModulesFolder/*;
};

function InitialSetup() {
	echo -e "Configurazione del cross-compiler..."
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
	echo -e "Creazione della cartella \"out\"..."
	if [ ! -d out ]; then
		mkdir out && echo -e "La cartella \"out\" è stata creata con successo.\n";
	else
		echo -e "La cartella \"out\" esiste già. Non c'è niente da fare.\n";
	fi;
	echo -e "Creazione della cartela dei file finali di Raijin...";
	if [ ! -d raijin/final_builds ]; then
		mkdir -p raijin/final_builds && echo -e "La cartella dei file finali è stata creata con successo.\n";
	else
		echo -e "La cartella dei file finali esiste già. Non c'è niente da fare.\n";
	fi;
};

function ShowHelp() {
	HelpString=`cat << EOM
${bold}Uso: ${normal}./$ScriptName {1-6|MODELLO|a|c|h|m} {v|nc} {nc}

Modelli supportati:
	1, fortuna3g - SM-G530H XXU (Globale, solo 3G)
	2, fortuna3gdtv - SM-G530BT ("Gran" Prime con TV digitale, Brasile, solo 3G)
	3, fortunafz, gprimeltexx - SM-G530FZ (Europa, LTE)
	4, fortunaltedx - SM-G530F (Medio Oriente / Africa / Asia, LTE)
	5, fortunalteub - SM-G530M (America Latina, LTE)
	6, fortunave3g - SM-G530H XCU (EMEA, solo 3G)	

Altre opzioni:
	a, all, ba, buildall - compila per tutti i modelli sequenzialmente
	c, clean - rimuovi solo gli oggetti compilati (*.o, *.a, tra gli altri)
	h, help - mostra questo messaggio di aiuto
	m, mrproper, cleanall - rimuovi tutti i file generati (includendo gli oggetti)

Opzioni di compilazione:
	nc, noclean - non pulire le fonti prima una nuova compilazione ${bold}(non raccomandato!)${normal}
	v, verbose - activa il modo verboso
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
	echo -e "compilazione in corso...\n";
	echo -e "La compilazione è stata iniziata il `date +"%d %B %Y"` alle `date +"%R GMT%z"`.";
	echo -e "La versione del kernel sarà: 3.10.108"$LOCALVERSION;
	make -C $KernelFolder -j$JobCount raijin_msm8916_defconfig O="out";
	make -C $KernelFolder -j$JobCount O="out";

	# Build finish date/time
	export BuildFinishTime=`date +"%Y-%m-%d %H:%M:%S GMT%z"`

	# Check if the build succeeded by checking if zImage exists; else abort
	if [ -f out/arch/arm/boot/zImage ]; then
		# Tell the building part is finished
		echo -e "La compilazione è stata finita il `date +"%d %B %Y"` alle `date +"%R GMT%z"`.";
		# Copy zImage
		echo -e "Copia dell'immagine kernel...";
		cp out/arch/$ARCH/boot/zImage $DeviceFolder;
		# Copy all kernel modules. Use `find` so no file gets skipped. Also remove any previously built modules.
		echo -e "Copia dei moduli kernel...";
		rm -f $ModulesFolder/*;
		find . -type f -iname "*.ko" -exec cp -f {} $ModulesFolder \;;
		# Create our DTB image
		echo -e "Creazione dell'immagine \"DTB\"...";
		if [[ "$VerboseMode" = "true" ]]; then
			./dtbtool -o $DeviceFolder/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/;
		else
			./dtbtool -o $DeviceFolder/dt.img -s 2048 -p out/scripts/dtc/ out/arch/arm/boot/dts/ > /dev/null 2>&1;
		fi;
		# Write some info to be read by raijin.sh before flashing
		echo -e "$SelectedDevice" > $DeviceFolder/device.txt;
		echo -e "$BuildFinishTime" > $DeviceFolder/date.txt;
		echo -e "$KernelVersionNumber \"$KernelVersionName\"" > $DeviceFolder/version.txt;
		# Create our zip file
		CreateFlashableZip;
		# Finish
		echo -e "Fatto!";
		BuildSuccessful="true";
		if [[ ! "$BuildForAll" = "true" ]]; then
			echo -e "Il processo intero è stato finito il `date +"%d %B %Y"` alle `date +"%R GMT%z"`.
Troverai il tuo \"flashable zip\" nella cartella raijin/final_builds/$SelectedDevice.";
		fi;
	else
		echo -e "Il file \"zImage\" non è stato trovato. Questo significa che la compilazione ha fallito.
Verifica il tuo codice sorgente. Se contiene errori, correggili, quindi riprova.";
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
		ErrorMsg "Questo script richiede almeno uno argumento.
Esegui \"./$ScriptName help\" o \"./$ScriptName h\" 
per un aiuto.";
		exit 0;;
	*)
		InitialSetup;
		case $2 in
		"v" | "verbose")
			VerboseMode="true";
			echo -e "Il modo verboso è stato attivato.";;

		"nc" | "noclean")
			NoClean="true";
			echo -e "Le fonti non verranno pulite prima la compilazione. Spero che tu sappia cosa stai facendo!";;
		esac;
		case $3 in
		"nc" | "noclean")
			NoClean="true";
			echo -e "Le fonti non verranno pulite prima la compilazione. Spero che tu sappia cosa stai facendo!";;
		esac;
		case $1 in
			"clean" | "c")
				CleanSources basic;
				exit 0;;
			"mrproper" | "m" | "cleanall")
				CleanSources full;
				exit 0;;
			"1" | "fortuna3g")
				echo -e "Modello selezionato: SM-G530H XXU\n";
				BuildKernelAndDtb fortuna3g;;
			"2" | "fortuna3gdtv")
				echo -e "Modello selezionato: SM-G530BT\n";
				BuildKernelAndDtb fortuna3gdtv;;
			"3" | "fortunafz" | "gprimeltexx")
				echo -e "Modello selezionato: SM-G530FZ\n";
				BuildKernelAndDtb fortunafz;;
			"4" | "fortunaltedx")
				echo -e "Modello selezionato: SM-G530F\n";
				BuildKernelAndDtb fortunaltedx;;
			"5" | "fortunalteub")
				echo -e "Modello selezionato: SM-G530M\n";
				BuildKernelAndDtb fortunalteub;;	
			"6" | "fortunave3g")
				echo -e "Modello selezionato: SM-G530H XCU\n";
				BuildKernelAndDtb fortunave3g;;
			"a" | "all" | "ba" | "buildall")
				BuildForAll="true";
				echo -e "La compilazione sarà fatta per tutti i modelli sequenzialmente.
Ti consiglio di mangiare o bere qualcosa. Questo può richiedere ${bold}MOLTO ${normal}tempo.";
				for device in ${SupportedDevicesList[@]}; do
					export ARCH="arm";
					export SUBARCH="arm";
					export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
					cd $KernelFolder;
					BuildKernelAndDtb $device;
					clear;
				done;
				if [[ "$BuildSuccessful" = "true" ]]; then
					echo -e "Il processo intero è stato finito il `date +"%d %B %Y"` alle `date +"%R GMT%z"`.
Troverai i tuoi \"flashable zip\" nella rispettiva cartella raijin/final_builds per ogni modello.";
				fi;;
			*)
				ErrorMsg "Hai fornito un'opzione non valida.";
				ShowHelp;
				exit 1;;
		esac;
esac;

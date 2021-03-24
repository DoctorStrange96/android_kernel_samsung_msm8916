#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building my Raijin Kernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial variables
KernelName="RaijinKernel";
KernelVersionNumber="1.2";
KernelVersionName="Izanagi";
KernelFolder=`pwd`;
ScriptName="build_raijin_fr.sh";

# Supported devices list
declare -a SupportedDevicesList=("fortuna3g" "fortuna3gdtv" "fortunafz" "fortunaltedx" "fortunalteub" "fortunave3g" "j5lte" "j5nlte" "j53g" "j5ltechn");

# Normal & bold text / Colours
normal=`tput sgr0`;
bold=`tput bold`;
red=`tput setaf 1`;
nc=`tput setaf 7`;

# Error string (changes according to locale)
ErrorString="Erreur : "

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
	BoldText " Raijin Kernel - Créé par DoctorStrange96            ";
	sleep 0.1;
	BoldText " Version : $KernelVersionNumber « $KernelVersionName »";
	sleep 0.1;
	BoldText " Édition Standard                                    ";
	sleep 0.1;	
	BoldText " Basé sur ZXKernel par DarkDroidDev & itexpert120    ";
	sleep 0.1;
	BoldText " Compatible avec :                                   ";
	sleep 0.1;
	BoldText " 	Samsung Galaxy Grand Prime (SM-G530xx)         	   ";
	sleep 0.1;
	BoldText " 	Samsung Galaxy J5 2015 (SM-J500xx)                 ";
	sleep 0.1;
	BoldText " Compatible avec Android 8.1, 9 et 10                ";
	sleep 0.1;	
	BoldText "";
	sleep 0.1;
	BoldText " Fait au Brésil !                                    ";
	sleep 0.1;
	BoldText "-----------------------------------------------------";
};

function CleanSources() {
	case $1 in
		"basic")
			echo -e "Suppression des objets compilés seulement..."
			if [[ "$VerboseMode" = "true" ]]; then
				make clean O="out";
			else
				make clean O="out" > /dev/null;
			fi;
			echo -e "Fait !";;
		"full")
			echo -e "Suppression de tous les fichiers générés (y compris les objets)..."
			if [[ "$VerboseMode" = "true" ]]; then
				make mrproper O="out";
			else
				make mrproper O="out" > /dev/null;
			fi;
			echo -e "Fait !";;
	esac;
};

function CreateFlashableZip() {
	echo -e "Création du « flashable zip »...";
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
	echo -e "Nettoyage...\n";
	rm -f $DeviceFolder/zImage;
	rm -f $DeviceFolder/dt.img;
	rm -f $DeviceFolder/*.txt;
	rm -f $ModulesFolder/*;
};

function InitialSetup() {
	echo -e "Configuration du « cross-compiler »..."
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE=~/Toolchains/Linaro-7.5/bin/arm-linux-gnueabihf-;
	echo -e "Création du dossier « out »..."
	if [ ! -d out ]; then
		mkdir out && echo -e "Le dossier « out » a bien été créé.\n";
	else
		echo -e "Le dossier « out » existe déjà. Rien à faire.\n";
	fi;
	echo -e "Création du dossier des fichiers finaux de Raijin...";
	if [ ! -d raijin/final_builds ]; then
		mkdir -p raijin/final_builds && echo -e "Le dossier des fichiers finaux a bien été créé.\n";
	else
		echo -e "Le dossier des fichiers finaux existe déjà. Rien à faire.\n";
	fi;
};

function ShowHelp() {
	HelpString=`cat << EOM
${bold}Usage : ${normal}./$ScriptName {1-6|MODÈLE|a|c|h|m} {v|nc} {nc}

Modèles pris en charge (Galaxy Grand Prime) :
	1, fortuna3g - SM-G530H XXU (Global, 3G seulement)
	2, fortuna3gdtv - SM-G530BT ("Gran" Prime avec TV digitale, Brésil, 3G seulement)
	3, fortunafz, gprimeltexx - SM-G530FZ (Europe, LTE)
	4, fortunaltedx - SM-G530F (Moyen-Orient / Afrique / Asie, LTE)
	5, fortunalteub - SM-G530M (Amérique Latine, LTE)
	6, fortunave3g - SM-G530H XCU (EMEA, 3G seulement)

Modèles pris en charge (Galaxy J5) :
	7, j53g - SM-J500H (Global, 3G seulement)
	8, j5lte - SM-J500F/G/M/NO/Y (Global, LTE, sans NFC)
	9, j5nlte - SM-J500FN (Europe, LTE, NFC)
	10, j5ltechn - SM-J5008 (Chine)	

Autres options :
	a, all, ba, buildall - compiler pour tous les modèles séquentiellement
	c, clean - supprimer les objets compilés seulement (*.o, *.a, entre autres)
	h, help - afficher ce message d'aide
	m, mrproper, cleanall - supprimer tous les fichiers générés (y compris les objets)

Options de compilation :
	nc, noclean - ne pas nettoyer les sources avant d'une nouvelle compilation ${bold}(non recommandé !)${normal}
	v, verbose - activer le mode verbeux
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
	echo -e "La compilation débute...\n";
	echo -e "La compilation s'est démarrée le `date +"%d %B %Y"` à `date +"%R GMT%z"`.";
	echo -e "La version du noyau sera : 3.10.108"$LOCALVERSION;
	make -C $KernelFolder -j$JobCount raijin_msm8916_defconfig O="out";
	make -C $KernelFolder -j$JobCount O="out";

	# Build finish date/time
	export BuildFinishTime=`date +"%Y-%m-%d %H:%M:%S GMT%z"`

	# Check if the build succeeded by checking if zImage exists; else abort
	if [ -f out/arch/arm/boot/zImage ]; then
		# Tell the building part is finished
		echo -e "La compilation s'est terminée le `date +"%d %B %Y"` à `date +"%R GMT%z"`.";
		# Copy zImage
		echo -e "Copie de l'image du noyau...";
		cp out/arch/$ARCH/boot/zImage $DeviceFolder;
		# Copy all kernel modules. Use `find` so no file gets skipped. Also remove any previously built modules.
		echo -e "Copie des modules du noyau...";
		rm -f $ModulesFolder/*;
		find . -type f -iname "*.ko" -exec cp -f {} $ModulesFolder \;;
		# Create our DTB image
		echo -e "Création de l'image « DTB »...";
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
		echo -e "Fait !";
		BuildSuccessful="true";
		if [[ ! "$BuildForAll" = "true" ]]; then
			echo -e "L'entier processus s'est terminé le `date +"%d %B %Y"` à `date +"%R GMT%z"`.
Vous trouverez votre « flashable zip » dans le dossier raijin/final_builds/$SelectedDevice.";
		fi;
	else
		echo -e "La compilation a échoué. Image noyau non trouvée. Vérifier si les sources contiennent des erreurs, puis réessayer.";
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
		ErrorMsg "Ce script nécessite au moins un argument.
Exécuter « ./$ScriptName help » ou « ./$ScriptName h » 
pour obtenir de l'aide.";
		exit 0;;
	*)
		InitialSetup;
		case $2 in
		"v" | "verbose")
			VerboseMode="true";
			echo -e "Le mode verbeux a été activé.";;

		"nc" | "noclean")
			NoClean="true";
			echo -e "Les sources ne seront pas nettoyées avant de la compilation. J'espère que vous savez ce qui vous faites !";;
		esac;
		case $3 in
		"nc" | "noclean")
			NoClean="true";
			echo -e "Aucun nettoyage ne sera fait avant de la compilation. J'espère que vous savez ce qui vous faites !";;
		esac;
		case $1 in
			"clean" | "c")
				CleanSources basic;
				exit 0;;
			"mrproper" | "m" | "cleanall")
				CleanSources full;
				exit 0;;
			"1" | "fortuna3g")
				echo -e "Modèle sélectionné : SM-G530H XXU\n";
				BuildKernelAndDtb fortuna3g;;
			"2" | "fortuna3gdtv")
				echo -e "Modèle sélectionné : SM-G530BT\n";
				BuildKernelAndDtb fortuna3gdtv;;
			"3" | "fortunafz" | "gprimeltexx")
				echo -e "Modèle sélectionné : SM-G530FZ\n";
				BuildKernelAndDtb fortunafz;;
			"4" | "fortunaltedx")
				echo -e "Modèle sélectionné : SM-G530F\n";
				BuildKernelAndDtb fortunaltedx;;
			"5" | "fortunalteub")
				echo -e "Modèle sélectionné : SM-G530M\n";
				BuildKernelAndDtb fortunalteub;;	
			"6" | "fortunave3g")
				echo -e "Modèle sélectionné : SM-G530H XCU\n";
				BuildKernelAndDtb fortunave3g;;
			"7" | "j53g")
				echo -e "Modèle sélectionné : SM-J500H\n";
				BuildKernelAndDtb j53g;;
			"8" | "j5lte")
				echo -e "Modèle sélectionné : SM-J500F/G/M/NO/Y\n";
				BuildKernelAndDtb j5lte;;
			"9" | "j5nlte")
				echo -e "Modèle sélectionné : SM-J500FN\n";
				BuildKernelAndDtb j5nlte;;
			"10" | "j5ltechn")
				echo -e "Modèle sélectionné : SM-J5008\n";
				BuildKernelAndDtb j5ltechn;;				
			"a" | "all" | "ba" | "buildall")
				BuildForAll="true";
				echo -e "La compilation sera faite pour tous les modèles séquentiellement. Cela prendera beaucoup de temps.";
				for device in ${SupportedDevicesList[@]}; do
					export ARCH="arm";
					export SUBARCH="arm";
					export CROSS_COMPILE=~/Toolchains/Linaro-7.5/bin/arm-linux-gnueabihf-;
					cd $KernelFolder;
					BuildKernelAndDtb $device;
					clear;
				done;
				if [[ "$BuildSuccessful" = "true" ]]; then
					echo -e "L'entier processus s'est terminé le `date +"%d %B %Y"` à `date +"%R GMT%z"`.
Vous trouverez vos « flashable zips » dans le dossier raijin/final_builds respectif pour chaque modèle.";
				fi;;
			*)
				ErrorMsg "Vous avez saisi une option non valide.";
				ShowHelp;
				exit 1;;
		esac;
esac;

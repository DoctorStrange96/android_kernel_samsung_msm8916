#!/bin/bash

#-----------------------------------------------------------------
# Note: This script is specific for building my Raijin Kernel. 
# Not intended to be used with any other kernel.
#-----------------------------------------------------------------

# Initial variables
KernelName="RaijinKernel";
KernelVersion="Amaterasu";
KernelFolder=`pwd`;
ScriptName="build_raijin_fr.sh";

# Supported devices list
declare -a SupportedDevicesList=("fortuna3g" "fortuna3gdtv" "fortunafz" "fortunaltedx" "fortunalteub" "fortunave3g");

# Normal & bold text
normal=`tput sgr0`;
bold=`tput bold`;

function RaijinAsciiArt {
	echo -e "${bold}-------------------------------------------------";
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
	echo -e "${normal}                      雷神                        ${bold}";
	sleep 0.1;
	echo -e "-------------------------------------------------";
	sleep 0.1;
	echo -e " ${bold}Raijin Kernel - Créé par DoctorStrange96 ";
	sleep 0.1;
	echo -e " Version : $KernelVersion                        ";
	sleep 0.1;
	echo -e " Édition Overclock                             ";
	sleep 0.1;	
	echo -e " Basé sur ZXKernel par DarkDroidDev & itexpert120 ";
	sleep 0.1;
	echo -e " Créé pour le Samsung Galaxy Grand Prime (SM-G530)   ";
	sleep 0.1;
	echo -e " Compatible avec Android 9 (Pie) et 10 (Q)      ";
	sleep 0.1;	
	echo -e "";
	sleep 0.1;
	echo -e " Fait au Brésil !   ";
	sleep 0.1;
	echo -e "------------------------------------------------- ${normal}";
};

function CleanSources {
	case $1 in
		"basic")
			echo -e "Nettoyage de la plupart des fichiers générés..."
			if [[ "$VerboseMode" = "true" ]]; then
				make clean O="out";
			else
				make clean O="out" > /dev/null;
			fi;
			echo -e "Fait !";;
		"full")
			echo -e "Nettoyage de tous les fichiers générés..."
			if [[ "$VerboseMode" = "true" ]]; then
				make mrproper O="out";
			else
				make mrproper O="out" > /dev/null;
			fi;
			echo -e "Fait !";;
	esac;
};

function CreateFlashableZip {
	echo -e "Création du « flashable zip »...";
	cd $KernelFolder/raijin_oc/ak3_common;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-OC-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	cd $DeviceFolder;
	if [[ "$VerboseMode" = "true" ]]; then
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-OC-$SelectedDevice-$BuildDateFull.zip . ;
	else
		zip -r9 $OutFolder/$SelectedDevice/$KernelName-$KernelVersion-OC-$SelectedDevice-$BuildDateFull.zip . > /dev/null;
	fi;
	echo -e "Nettoyage...\n";
	rm -f $DeviceFolder/zImage;
	rm -f $DeviceFolder/dt.img;
	rm -f $DeviceFolder/*.txt;
	rm -f $ModulesFolder/*;
};

function InitialSetup {
	echo -e "Configuration du « cross-compiler »..."
	export ARCH="arm";
	export SUBARCH="arm";
	export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
	echo -e "Création du dossier « out »..."
	if [ ! -d out ]; then
		mkdir out && echo -e "Le dossier « out » a bien été créé.\n";
	else
		echo -e "Le dossier « out » existe déjà. Il n'y a rien à faire.\n";
	fi;
	echo -e "Création du dossier des fichiers finaux de Raijin...";
	if [ ! -d raijin_oc/final_builds ]; then
		mkdir -p raijin_oc/final_builds && echo -e "Le dossier des fichiers finaux a bien été créé.\n";
	else
		echo -e "Le dossier des fichiers finaux existe déjà. Il n'y a rien à faire.\n";
	fi;
};

function ShowHelp {
	HelpString=`cat << EOM
${bold}Usage : ${normal}./$ScriptName {1-6|VARIANT|a|c|h|m} {v|nc} {nc}

Variantes prises en charge :
	1, fortuna3g - SM-G530H XXU (Global, 3G seulement)
	2, fortuna3gdtv - SM-G530BT ("Gran" Prime avec TV digitale, Brésil, 3G seulement)
	3, fortunafz, gprimeltexx - SM-G530FZ (Europe, LTE)
	4, fortunaltedx - SM-G530F (Moyen-Orient / Afrique / Asie, LTE)
	5, fortunalteub - SM-G530M (Amérique Latine, LTE)
	6, fortunave3g - SM-G530H XCU (EMEA, 3G seulement)	

Autres options :
	a, all, ba, buildall - compiler pour toutes les variantes de façon séquentielle
	c, clean - supprimer la plupart des fichiers générés
	h, help - afficher ce message d'aide
	m, mrproper, cleanall - supprimer tous les fichiers générés

Options de compilation :
	nc, noclean - ne pas nettoyer des fichiers générés avant de la compilation
	v, verbose - activer le mode verbeux
EOM
`;
	echo -e "$HelpString";
};

function BuildKernelAndDtb {
	# Always clean everything before building unless the "nc" flag was passed
	[[ ! "$NoClean" = "true" ]] && CleanSources full;

	# Optimal job count: (number of CPU threads * 2) + 1
	JobCount=`expr $((($(nproc --all) * 2) + 1))`;

	# Some basic set-up
	SelectedDevice="$1";
	export BuildDate=`date +"%Y%m%d"`;
	export BuildDateFull=`date +"%Y%m%d-%H%M%S"`;
	export VARIANT_DEFCONFIG="raijin_msm8916_"$SelectedDevice"_defconfig";
	export LOCALVERSION="-Raijin-"$KernelVersion"-OC-"$BuildDate;
	export SELINUX_DEFCONFIG="raijin_selinux_defconfig";
	export DeviceFolder=$KernelFolder/raijin_oc/device_specific/$SelectedDevice;
	export OutFolder=$KernelFolder/raijin_oc/final_builds;
	export ModulesFolder=$DeviceFolder/modules/system/lib/modules;
	[ ! -d $OutFolder/$SelectedDevice ] && mkdir -p $OutFolder/$SelectedDevice;
	[ ! -d $ModulesFolder ] && mkdir -p $ModulesFolder;

	# This is where the actual build starts
	echo -e "La compilation démarre...\n";
	echo -e "La compilation s'est démarrée le `date +"%Y-%m-%d"` à `date +"%R GMT%z"`.";
	echo -e "La version du noyau sera : 3.10.108"$LOCALVERSION;
	make -C $KernelFolder -j$JobCount raijin_msm8916_defconfig O="out";
	make -C $KernelFolder -j$JobCount O="out";

	# Build finish date/time
	export BuildFinishTime=`date +"%Y-%m-%d %H:%M:%S GMT%z"`

	# Check if the build succeeded by checking if zImage exists; else abort
	if [ -f out/arch/arm/boot/zImage ]; then
		# Tell the building part is finished
		echo -e "La compilation s'est terminée le `date +"%Y-%m-%d"` à `date +"%R GMT%z"`.";
		# Copy zImage
		echo -e "Copie de l'image du noyau...";
		cp out/arch/$ARCH/boot/zImage $DeviceFolder;
		# Copy all kernel modules. Use `find` so no file gets skipped. Also remove any previously built modules.
		echo -e "Copie des modules de noyau...";
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
		echo -e "$KernelVersion" > $DeviceFolder/version.txt;
		# Create our zip file
		CreateFlashableZip;
		# Finish
		echo -e "Fait !";
		BuildSuccessful="true";
		if [[ ! "$BuildForAll" = "true" ]]; then
			echo -e "L'entier processus s'est terminé le `date +"%Y-%m-%d"` à `date +"%R GMT%z"`.
Vous trouverez votre « flashable zip » à raijin_oc/final_builds/$SelectedDevice.";
		fi;
	else
		echo -e "Le fichier « zImage » n'a pas été trouvé. Cela généralement signifie que la compilation a échoué.
Vérifiez si votre code source contient des erreurs, puis réessayez.";
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
		echo -e "${bold}Erreur :${normal} Ce script nécessite au moins un argument.\nExécutez « ./$ScriptName help » ou « ./$ScriptName h » 
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
			echo -e "Aucun nettoyage ne sera fait avant de la compilation. J'espère que vous savez ce qui vous faites !";;
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
				echo -e "Variante sélectionnée : SM-G530H XXU\n";
				BuildKernelAndDtb fortuna3g;;
			"2" | "fortuna3gdtv")
				echo -e "Variante sélectionnée : SM-G530BT\n";
				BuildKernelAndDtb fortuna3gdtv;;
			"3" | "fortunafz" | "gprimeltexx")
				echo -e "Variante sélectionnée : SM-G530FZ\n";
				BuildKernelAndDtb fortunave3g;;
			"4" | "fortunaltedx")
				echo -e "Variante sélectionnée : SM-G530F\n";
				BuildKernelAndDtb fortunafz;;
			"5" | "fortunalteub")
				echo -e "Variante sélectionnée : SM-G530M\n";
				BuildKernelAndDtb fortunalteub;;	
			"6" | "fortunave3g")
				echo -e "Variante sélectionnée : SM-G530H XCU\n";
				BuildKernelAndDtb fortunave3g;;
			"a" | "all" | "ba" | "buildall")
				BuildForAll="true";
				echo -e "Le script va compiler pour toutes les variantes.\nJe vous recommande de manger ou boire quelque chose. Cela peut prendre ${bold}BEAUCOUP ${normal}de temps.";
				for device in ${SupportedDevicesList[@]}; do
					export ARCH="arm";
					export SUBARCH="arm";
					export CROSS_COMPILE=~/Toolchains/Linaro-7.5-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-;
					BuildKernelAndDtb $device;
					clear;
				done;
				if [[ "$BuildSuccessful" = "true" ]]; then
					echo -e "L'entier processus s'est terminé le `date +"%Y-%m-%d"` à `date +"%R GMT%z"`.
Vous trouverez vos « flashable zips » au dossier raijin_oc/final_builds respectif pour chaque variante.";
				fi;;
			*)
				echo -e "Vous avez saisi une option non valide.\nVous pouvez utiliser les options suivantes :";
				ShowHelp;
				exit 1;;
		esac;
esac;

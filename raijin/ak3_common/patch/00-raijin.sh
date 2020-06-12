#!/system/bin/sh

function RaijinLogcat {
	log -p i -t "RaijinKernel" $1;
}

RaijinLogcat "Raijin Kernel boot script is starting...";
RaijinLogcat "Setting CPU parameters (max frequency 1/2)...";
echo "0:1209600 1:1209600 2:1209600 3:1209600" > /sys/module/msm_performance/parameters/cpu_max_freq;
RaijinLogcat "Setting CPU parameters (max frequency 2/2)...";
echo "1209600" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
echo "1209600" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
echo "1209600" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
echo "1209600" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;

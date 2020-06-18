#!/system/bin/sh

function RaijinLogcat() {
	log -p i -t "RaijinKernel" $1;
}

RaijinLogcat "Fixing permissions...";
chmod 666 /sys/module/lowmemorykiller/parameters/minfree;
chown root:system /sys/module/lowmemorykiller/parameters/minfree;
for i in `seq 0 3`; do
	chmod 644 /sys/devices/system/cpu/cpu$i/online;
done;

# We'll run the CPU at full speed during boot
RaijinLogcat "Raijin Kernel boot script is starting...";
RaijinLogcat "Setting CPU parameters (min/max frequency 1/2)...";
echo "0:1401600 1:1401600 2:1401600 3:1401600" > /sys/module/msm_performance/parameters/cpu_max_freq;
echo "0:800000 1:800000 2:800000 3:800000" > /sys/module/msm_performance/parameters/cpu_min_freq;
RaijinLogcat "Setting CPU parameters (min/max frequency 2/2)...";
for i in `seq 0 3`; do
	echo "1401600" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq;
done;
for i in `seq 0 3`; do
	echo "800000" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_in_freq;
done;
RaijinLogcat "Setting CPU parameters (governor)...";
for i in `seq 0 3`; do
	echo "blu_active" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor;
done;
RaijinLogcat "Setting CPU parameters (governor settings)...";
echo "19000 1248000:29000" > /sys/devices/system/cpu/cpufreq/blu_active/above_hispeed_delay;
echo "85" > /sys/devices/system/cpu/cpufreq/blu_active/go_hispeed_load;
echo "1248000" > /sys/devices/system/cpu/cpufreq/blu_active/hispeed_freq;
echo "85 1248000:80" > /sys/devices/system/cpu/cpufreq/blu_active/target_loads;
echo "30000" > /sys/devices/system/cpu/cpufreq/blu_active/timer_rate;
echo "60000" > /sys/devices/system/cpu/cpufreq/blu_active/timer_slack;
RaijinLogcat "Setting CPU parameters (MSM Limiter)...";
echo "1" > /sys/kernel/msm_limiter/limiter_enabled;
RaijinLogcat "Enabling Simple Thermal...";
echo "1" > /sys/kernel/msm_thermal/enabled;
RaijinLogcat "Adjusting LMK values...";
echo "8192,10240,12288,14336,21504,30720" > /sys/module/lowmemorykiller/parameters/minfree;
RaijinLogcat "Enabling adaptive LMK...";
echo "1" > /sys/module/lowmemorykiller/parameters/enable_adaptive_lmk;
RaijinLogcat "Applying I/O scheduling tweaks...";
echo "128" > /sys/block/mmcblk0/queue/read_ahead_kb;
echo "512" > /sys/block/mmcblk1/queue/read_ahead_kb;
RaijinLogcat "Adjusting entropy values...";
echo "128" > /proc/sys/kernel/random/read_wakeup_threshold;
echo "256" > /proc/sys/kernel/random/write_wakeup_threshold;

# Wait some 30 secs until the system fully boots up
sleep 30;

# Downclock the CPU
RaijinLogcat "Lowering CPU frequencies...";
RaijinLogcat "Setting new CPU parameters (min/max frequency 1/2)...";
echo "0:1190400 1:1190400 2:1190400 3:1190400" > /sys/module/msm_performance/parameters/cpu_max_freq;
echo "0:533330 1:533330 2:533330 3:533330" > /sys/module/msm_performance/parameters/cpu_min_freq;
RaijinLogcat "Setting new CPU parameters (min/max frequency 2/2)...";
for i in `seq 0 3`; do
	echo "1190400" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq;
done;
for i in `seq 0 3`; do
	echo "533330" > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq;
done;
RaijinLogcat "Setting new CPU parameters (governor settings)...";
echo "19000 998400:29000" > /sys/devices/system/cpu/cpufreq/blu_active/above_hispeed_delay;
echo "85" > /sys/devices/system/cpu/cpufreq/blu_active/go_hispeed_load;
echo "998400" > /sys/devices/system/cpu/cpufreq/blu_active/hispeed_freq;
echo "85 998400:80" > /sys/devices/system/cpu/cpufreq/blu_active/target_loads;
echo "30000" > /sys/devices/system/cpu/cpufreq/blu_active/timer_rate;
echo "60000" > /sys/devices/system/cpu/cpufreq/blu_active/timer_slack;
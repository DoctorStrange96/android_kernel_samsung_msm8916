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
RaijinLogcat "Setting CPU parameters (governor settings)...";
echo "19000 998400:29000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay;
echo "85" > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load;
echo "998400" > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq;
echo "85 998400:80" > /sys/devices/system/cpu/cpufreq/interactive/target_loads;
echo "30000" > /sys/devices/system/cpu/cpufreq/interactive/timer_rate;
echo "60000" > /sys/devices/system/cpu/cpufreq/interactive/timer_slack;
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

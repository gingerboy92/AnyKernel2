#!/system/bin/sh

########################################################
#
# Custom Kernel Settings for God's Kernel!!
#
########################################################

PATH=/sbin:/system/sbin:/system/bin:/system/xbin
export PATH

BBX=/system/xbin/busybox

# Inicio
mount -o remount,rw -t auto /
mount -o remount,rw -t auto /system
mount -t rootfs -o remount,rw rootfs

if [ -f $BBX ]; then
	chown 0:2000 $BBX
	chmod 0755 $BBX
	$BBX --install -s /system/xbin
	ln -s $BBX /sbin/busybox
	ln -s $BBX /system/bin/busybox
	sync
fi

# Set environment and create symlinks: /bin, /etc, /lib, and /etc/mtab
set_environment ()
{
	# create /bin symlinks
	if [ ! -e /bin ]; then
		$BBX ln -s /system/bin /bin
	fi

	# create /etc symlinks
	if [ ! -e /etc ]; then
		$BBX ln -s /system/etc /etc
	fi

	# create /lib symlinks
	if [ ! -e /lib ]; then
		$BBX ln -s /system/lib /lib
	fi

	# symlink /etc/mtab to /proc/self/mounts
	if [ ! -e /system/etc/mtab ]; then
		$BBX ln -s /proc/self/mounts /system/etc/mtab
	fi
}

if [ -x $BBX ]; then
	set_environment
fi

########################################################
#Supersu
#
/system/xbin/daemonsu --auto-daemon &

########################################################
# kernel custom test
#

if [ -e /data/godtest.log ]; then
	rm /data/godtest.log
fi

echo  Kernel script is working !!! >> /data/godtest.log
echo "excecuted on $(date +"%d-%m-%Y %r" )" >> /data/godtest.log
echo  Done ! >> /data/godtest.log

########################################################
#FSTRIM
#
$BBX fstrim -v /system >> /data/godtest.log
$BBX fstrim -v /cache >> /data/godtest.log
$BBX fstrim -v /data >> /data/godtest.log


stop mpdecision

########################################################
#MISC
#
#sysctl -w net.ipv4.tcp_congestion_control=reno
#echo "989400" > /sys/module/cpu_boost/parameters/sync_threshold
#echo "1190400" > /sys/module/cpu_boost/parameters/input_boost_freq
#echo "500" > /sys/module/cpu_boost/parameters/input_boost_ms
#echo "10" > /sys/module/cpu_boost/parameters/boost_ms
#echo "1" > /sys/devices/system/cpu/sched_mc_power_savings
#echo "9472,13824,19968,44544,58368,65536" > /sys/module/lowmemorykiller/parameters/minfree 
#echo "3" > sys/kernel/power_suspend/power_suspend_mode

# Enable ZRAM
modprobe zram num_devices=4
echo "4" > /sys/block/zram0/max_comp_streams
echo "4" > /sys/block/zram1/max_comp_streams
echo "4" > /sys/block/zram2/max_comp_streams
echo "4" > /sys/block/zram3/max_comp_streams
echo "lz4" > /sys/block/zram0/comp_algorithm
echo "1" > /sys/block/zram0/reset
echo "1" > /sys/block/zram1/reset
echo "1" > /sys/block/zram2/reset
echo "1" > /sys/block/zram3/reset
echo "134217728" > /sys/block/zram0/disksize
echo "134217728" > /sys/block/zram1/disksize
echo "134217728" > /sys/block/zram2/disksize
echo "134217728" > /sys/block/zram3/disksize
mkswap /dev/block/zram0
mkswap /dev/block/zram1
mkswap /dev/block/zram2
mkswap /dev/block/zram3
swapon -p 10 /dev/block/zram0
swapon -p 10 /dev/block/zram1
swapon -p 10 /dev/block/zram2
swapon -p 10 /dev/block/zram3

# KSM options
echo "256" > /sys/kernel/mm/ksm/pages_to_scan
echo "1500" > /sys/kernel/mm/ksm/sleep_millisecs
echo "1" > /sys/kernel/mm/ksm/deferred_timer
echo "1" > /sys/kernel/mm/ksm/run
	#lock ksm from changing... to lazy to find out the cause :P
	chmod 0444 /sys/kernel/mm/ksm/sleep_millisecs
	chmod 0444 /sys/kernel/mm/ksm/pages_to_scan

############################
# MSM-Limiter Freq Tuning
#
echo 2803200 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
echo 2803200 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_0
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_1
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_2
echo 300000 > /sys/kernel/msm_limiter/suspend_min_freq_3
echo 2803200 > /sys/kernel/msm_limiter/resume_max_freq_0
echo 2803200 > /sys/kernel/msm_limiter/resume_max_freq_1
echo 2803200 > /sys/kernel/msm_limiter/resume_max_freq_2
echo 2803200 > /sys/kernel/msm_limiter/resume_max_freq_3
echo 2803200 > /sys/kernel/msm_limiter/live_max_freq_0
echo 2803200 > /sys/kernel/msm_limiter/live_max_freq_1
echo 2803200 > /sys/kernel/msm_limiter/live_max_freq_2
echo 2803200 > /sys/kernel/msm_limiter/live_max_freq_3
echo 1267200 > /sys/kernel/msm_limiter/suspend_max_freq
echo interactive > /sys/kernel/msm_limiter/scaling_governor_0
echo interactive > /sys/kernel/msm_limiter/scaling_governor_1
echo interactive > /sys/kernel/msm_limiter/scaling_governor_2
echo interactive > /sys/kernel/msm_limiter/scaling_governor_3

# Adreno idler
#adreno_idler

########################################################
# Scheduler and Read Ahead
#
echo bfq > /sys/block/mmcblk0/queue/scheduler
echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb

########################################################
# GPU Governor
#
#echo "simple_ondemand" > /sys/devices/fdb00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq/governor
#echo "450000000" > /sys/class/kgsl/kgsl-3d0/max_gpuclk

########################################################
# LMK Tweaks
#

#echo "2560,4096,8192,16384,24576,32768" > /sys/module/lowmemorykiller/parameters/minfree
echo "32" > /sys/module/lowmemorykiller/parameters/cost

########################################################
# Tweak Background Writeout
#
echo "200" > /proc/sys/vm/dirty_expire_centisecs
echo "40" > /proc/sys/vm/dirty_ratio
echo "5" > /proc/sys/vm/dirty_background_ratio
echo "100" > /proc/sys/vm/swappiness
echo "0" > /proc/sys/vm/page-cluster

########################################################
# Dynamic FSync (Let User Decide)
#
#echo 0 > /sys/kernel/dyn_fsync/Dyn_fsync_active

########################################################
# Test Debugging!!!
#
#echo 0 > /sys/kernel/sched/gentle_fair_sleepers
#echo "65" > /sys/module/msm_thermal/parameters/temp_threshold
#echo "750" > /sys/module/msm_thermal/parameters/poll_interval

########################################################
# initialize init.d
#
if [ -d /system/etc/init.d ]; then
	/sbin/busybox run-parts /system/etc/init.d
fi;

########################################################
# Allow untrusted apps to read from debugfs
#
if [ -e /system/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app sysfs_devices_system_iosched file { open read getattr }" \	
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow untrusted_app sysfs_display file { open read write getattr add_name setattr remove_name }" \	
	"allow debuggerd app_data_file dir search" \
	"allow sensors diag_device chr_file { read write open ioctl }" \
	"allow sensors sensors capability net_raw" \
	"allow init kernel security setenforce" \
	"allow netmgrd netmgrd netlink_xfrm_socket nlmsg_write" \
	"allow netmgrd netmgrd socket { read write open ioctl }"
fi;

########################################################
# Google Services battery drain fixer
#
pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

########################################################
# Power Effecient Workqueues (Enable for battery)
#
echo "1" > /sys/module/workqueue/parameters/power_efficient
echo "0" > /sys/module/subsystem_restart/parameters/enable_ramdumps

########################################################
# Activate Simple_GPU_Algorithym
#
#echo 1 > /sys/module/simple_gpu_algorithm/parameters/simple_gpu_activate

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

# stop google service and restart it on boot. this remove high cpu load and ram leak!

	if [ "$($BBX pidof com.google.android.gms | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.unstable)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.persistent)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.wearable)";
	fi;
	if [ "$($BBX pidof com.google.process.gapps | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.process.gapps)";
	fi;
	if [ "$($BBX pidof com.google.android.gsf | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gms.wearable)";
	fi;
	if [ "$($BBX pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
		$BBX kill "$($BBX pidof com.google.android.gsf.persistent)";
	fi;

$busybox sleep 10
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

#zram_turn_on='$(getprop sys.zram.enable)'
zram_turn_on=1
zram_size=768
if [ $zram_turn_on == 1 ];then
##
#insmod /system/lib/modules/lz4_compress.ko
#insmod /system/lib/modules/lz4_decompress.ko
#insmod /system/lib/modules/zram.ko num_devices=4
echo 1 > /sys/block/zram0/reset
echo 4 > /sys/block/zram0/max_comp_streams
echo "lz4" > /sys/block/zram0/comp_algorithm
echo "$(($zram_size*1024*1024))" > /sys/block/zram0/disksize
#echo "1610612736" > /sys/block/zram0/disksize
echo "$(($zram_size*1024*1024))" > /sys/block/zram0/mem_limit
mkswap /dev/block/zram0
swapon -p 1 /dev/block/zram0
#
echo 100 > /proc/sys/vm/swappiness
echo 60  > /proc/sys/vm/vfs_cache_pressure
echo 100  > /proc/sys/vm/overcommit_ratio
#echo 30 > /sys/module/zswap/parameters/max_pool_percent
echo 0 > /proc/sys/vm/page-cluster
fi;

echo 1 > /sys/module/cpu_boost/parameters/input_boost_enabled
echo 1036800 > sys/module/cpu_boost/parameters/input_boost_freq
echo 500 > /sys/module/cpu_boost/parameters/input_boost_ms

overclock=1
if [ $overclock == 0 ];then
	minfrequency=300000
	maxfrequency=2265600
else
	minfrequency=268800
	maxfrequency=2803200
fi;

echo &maxfrequency > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo &maxfrequency > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
echo &maxfrequency > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo &maxfrequency > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

#echo "intellimm" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
#echo "intellimm" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
#echo "intellimm" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
#echo "intellimm" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor

echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

mako_hotplug=1
if [ $mako_hotplug == 1 ];then
 echo  1 > /sys/class/misc/mako_hotplug_control/enabled
 echo 30 > /sys/class/misc/mako_hotplug_control/high_load_counter
 echo 30 > /sys/class/misc/mako_hotplug_control/max_load_counter
 echo  5  > /sys/class/misc/mako_hotplug_control/min_time_cpu_online
 echo  2  > /sys/class/misc/mako_hotplug_control/timer
 echo 98 > /sys/class/misc/mako_hotplug_control/load_threshold
 echo 1497600 > /sys/class/misc/mako_hotplug_control/cpufreq_unplug_limit
fi;

alucard_hotplug=0
if [ $alucard_hotplug == 1 ];then
echo 1 > /sys/kernel/alucard_hotplug/hotplug_enable
echo 20 > /sys/kernel/alucard_hotplug/cpu_down_rate
echo 10 > /sys/kernel/alucard_hotplug/cpu_up_rate
fi;


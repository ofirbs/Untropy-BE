#!/bin/bash

# global variables
declare -r NOCHECKS="49"
declare RESULT=""
declare STATUS=""
declare -i SHOULD_NOT=0
declare -i COULD_NOT=0
declare -i SUCCESS=0
declare -i WARNING=0
declare -i CRITICAL=0
declare NIC
declare IP

# add should not be run
function should_not_func()
{
	RESULT+="0"
	let "SHOULD_NOT++"
}

# add could not be run
function could_not_func()
{
	RESULT+="1"
	let "COULD_NOT++"
}

# add success
function success_func()
{
	RESULT+="2"
	let "SUCCESS++"
}

# add warning
function warning_func()
{
	RESULT+="3"
	let "WARNING++"
}

# add critical
function critical_func()
{
	RESULT+="4"
	let "CRITICAL++"
}

# configure global variables
function config_globals()
{
	NIC=$(route | grep default | awk '{print $NF}')
	IP=$(echo $NIC | xargs ifconfig | egrep "inet addr:|inet " | awk '{print $2}' | cut -d : -f 2)
}

# calculate the final status of the server
function calc_status()
{
	if [ "$CRITICAL" -gt 0 ]; then
		STATUS="Critical"
	elif [ "$WARNING" -gt 0 ]; then
		STATUS="Warning"
	elif [ "$SUCCESS" -gt 0 ]; then
		STATUS="Success"
	else
		STATUS="Unknown"
	fi
}

# check if /var/log is mounted seperatly [WARNING]
function var_log_mounted()
{
	df -h | grep -wq "/var/log"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check if /tmp is mounted seperatly [WARNING]
function tmp_log_mounted()
{
	df -h | grep -wq "/tmp"
        if [ $? -ne 0 ]; then
		warning_func
        else
		success_func
        fi
}

# check if /home is mounted seperatly [WARNING]
function home_log_mounted()
{
	df -h | grep -wq "/home"
        if [ $? -ne 0 ]; then
		warning_func
        else
		success_func
        fi
}

# check if grub password is configured [CRITICAL]
function grub_password()
{
	if [ ! -f /boot/grub/grub.conf ]; then
		could_not_func
	else
		grep -q "password --md5" /boot/grub/grub.conf
		if [ $? -ne 0 ]; then
			critical_func
		else
			success_func
		fi
	fi
}

# check for static ip rather than dhcp [WARNING]
function static_ip()
{
	if [ ! -f /etc/sysconfig/network-scripts/ifcfg-$NIC ]; then
		could_not_func
	else
		egrep -iq "BOOTPROTO=static|BOOTPROTO=none"  /etc/sysconfig/network-scripts/ifcfg-$NIC
		if [ $? -ne 0 ]; then
			warning_func
		else
			success_func
		fi
	fi
}

# check if kdump is disabled [CRITICAL]
function kdump_disabled()
{
	service kdump status > /dev/null
	if [ $? -ne 3 ]; then
		critical_func
	else
		success_func
	fi
	
}

# check if there is a PermitRootLogin no in sshd config [CRITICAL]
function no_root_login()
{
	egrep -q "^PermitRootLogin no" /etc/ssh/sshd_config
	if [ $? -ne 0 ]; then
		critical_func
	else
		success_func
	fi
}

# check if the mounts are mounted with the 'nodev' parameter [WARNING]
function nodev_mounts()
{
	nodevs=$(mount | egrep -w "/|/home|/var/log" | awk '{print $NF}' | grep nodev | wc -l)
	if [ "$nodevs" -ne 3 ]; then
		warning_func
	else
		success_func
	fi
}

# check if /tmp has 'nodev' 'noexec' 'nosuid' parameter [WARNING]
function check_mount_params()
{
	mount | grep -w "/tmp" | awk '{print $NF}' | grep nodev| grep noexec | grep -q nosuid
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check if /var/tmp/ is mounted at /tmp [WARNING]
function var_tmp()
{
	 mount | grep -w "/tmp" | grep -w "/var/tmp" | grep -q "bind"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

# disable autofs [WARNING]
function autofs_disabled()
{
	service autofs status > /dev/null
	if [ $? -eq 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check for 'auth required pam_wheel.so use_uid' in /etc/pam.d/su [CRITICAL]
function pam_wheel()
{
	grep -q "auth required pam_wheel.so use_uid" /etc/pam.d/su
	if [ $? -ne 0 ]; then
		critical_func
	else
		success_func
	fi
}

# check for 'Defaults:%wheel rootpw' '%wheel ALL=(ALL) /bin/su' in sudoers file [CRITICAL]
function sudoers_wheel()
{
	grep -qr "Defaults:%wheel rootpw' '%wheel ALL=(ALL) /bin/su" /etc/sudoers*
	if [ $? -ne 0 ]; then
		critical_func
	else
		success_func
	fi
}

# make sure SELinux is on and /etc/selinux/Config is enforcing [CRITICAL]
function selinux_enabled()
{
	if [ $(getenforce) != "Enforcing" ]; then 
		critical_func
	else
		success_func
	fi
}

function network_disable_redirects()
{

lines="net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0"
	
	check="0"

	while IFS= read -r line
	do
		sysctl -a | grep -q "$line" 
		if [ $? -ne 0 ]; then
			check="1"
		fi
	
	done <<< "$lines"
	
	if [ "$check" == "1" ]; then
		warning_func
	else
		success_func
	fi
}

function network_enable_rp_filter()
{
	sysctl -a | grep "net.ipv4.conf.all.rp_filter = 1" | grep -q "net.ipv4.conf.default.rp_filter = 1"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

function network_enable_log_martians()
{
	sysctl -a | grep "net.ipv4.conf.all.log_martians = 1" | grep -q "net.ipv4.conf.default.log_martians = 1"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

function network_ignore_broadcasts()
{
	sysctl -a | grep -q "net.ipv4.icmp_echo_ignore_broadcasts = 1"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

function network_reject_source_routes()
{
	sysctl -a | grep "net.ipv4.conf.default.accept_source_route = 0" | grep -q "net.ipv4.conf.all.accept_source_route = 0"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

function network_ignore_bogus_error()
{
	sysctl -a | grep -q "net.ipv4.icmp_ignore_bogus_error_messages = 1"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

function network_enable_syn_cookies()
{
	sysctl -a | grep -q "net.ipv4.tcp_syncookies = 1"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}


function network_disable_timestamp()
{
	sysctl -a | grep -q "net.ipv4.tcp_timestamps = 0"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}


# check if the wireless driver is removed /lib/modules/<kernelversion>/kernel/drivers/net/wireless [WARNING]
function wireless_disabled()
{
	if [ -d /lib/modules/$(uname -r)/kernel/drivers/net/wireless ]; then
		warning_func
	else
		success_func
	fi
}

# check if ipv6 is disabled via 'NETWORKING_IPV6=0' 'IPV6INIT=no' 'IPV6_AUTHCONF=no' in /etc/sysconfig/network [WARNING]
function ipv6_disabled()
{
	cat /etc/sysconfig/network | grep "NETWORKING_IPV6=0" | grep "IPV6INIT=no" | grep -q "IPV6_AUTHCONF=no"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check if zeroconf is disabled via 'NOZEROCONF=yes' [WARNING]
function zeroconf_disabled()
{
	cat /etc/sysconfig/network | grep "NOZEROCONF=yes"
	if [ $? -ne 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check if avahi service is disabled [WARNING]
function avahi_service()
{
	service avahi-daemon status &>/dev/null
	if [ $? -eq 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check if the cups service is disabled [WARNING]
function cups_service()
{
	service cups status &>/dev/null
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if the bluetooth service is disabled [WARNING]
function bluetooth_service()
{
	service bluetooth status &>/dev/null
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if the firstboot service is disabled [WARNING]
function firstboot_service()
{
	FILENAME=/etc/sysconfig/firstboot
	if [ ! -f $FILENAME ] || [ -z "$(grep 'RUN_FIRSTBOOT=NO' $FILENAME)" ]; then
		warning_func
	else
		success_func
	fi
}

# check if the NetworkManager service is disabled [WARNING]
function NetworkManager_service()
{
	service NetworkManager status &>/dev/null
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if the rhnsd service is disabled [WARNING]
function rhnsd_service()
{
	service rhnsd status &>/dev/null
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if the mdmonitor service is disabled [WARNING]
function mdmonitor_service()
{
	service mdmonitor status &>/dev/null
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if ipv6 is disabled via iptables [WARNING]
function ipv6_iptables()
{
	lines=":INPUT ACCEPT \[0:0\]
:FORWARD ACCEPT \[0:0\]
:OUTPUT ACCEPT \[0:0\]
-A INPUT -j REJECT --reject-with icmp6-port-unreachable
-A FORWARD -j REJECT --reject-with icmp6-port-unreachable
-A OUTPUT -j REJECT --reject-with icmp6-port-unreachable
COMMIT"

        check="0"

        while IFS= read -r line
        do
                grep -q -- "$line" /etc/sysconfig/iptables
                if [ $? -ne 0 ]; then
                        check="1"
                fi

        done <<< "$lines"

        if [ "$check" == "1" ]; then
                warning_func
        else
                success_func
        fi
}

# allow only the allowed port via iptables (accept parameters with chain,protocol,port) [CRITICAL]
function ipv4_iptables()
{
	lines=":INPUT ACCEPT \[0:0\]
:FORWARD ACCEPT \[0:0\]
:OUTPUT ACCEPT \[0:0\]
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-port-unreachable
-A FORWARD -j REJECT --reject-with icmp-port-unreachable
COMMIT"
	check="0"

        while IFS= read -r line
        do
                grep -q -- "$line" /etc/sysconfig/iptables
                if [ $? -ne 0 ]; then
                        check="1"
			echo "$line"
                fi

        done <<< "$lines"

        if [ "$check" == "1" ]; then
                critical_func
        else
                success_func
        fi
}

# check if the 'telnet' is not installed [CRITICAL]
function telnet_rpm()
{
	rpm -q --quiet telnet
	if [ $? -eq 0 ]; then
		critical_func
	else
		success_func
	fi
}

# check if the 'krb5-workstation' is not installed [WARNING]
function krb5-workstation_rpm()
{
	rpm -q --quiet krb5-workstation
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if the 'ypbind' is not installed [WARNING]
function ypbind_rpm()
{
	rpm -q --quiet ypbind
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}

# check if the 'rhnsd' is not installed [WARNING]
function rhnsd_rpm()
{
	rpm -q --quiet rhnsd
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi
}


# check if the gcc package is not installed [CRITICAL]
function gcc_rpm()
{
	rpm -q --quiet gcc
        if [ $? -eq 0 ]; then
                critical_func
        else
                success_func
        fi
}

# disable nfs service [WARNING]
function disable_nfs()
{
	service nfs status &>/dev/null
        if [ $? -eq 0 ]; then
                warning_func
        else
                success_func
        fi	
}

# check if execshield is enabled 'sysctl -a | grep kernel.exec-shield' is not 0 [CRITICAL]
function execshield_enabled()
{
	sysctl -a | grep -q "kernel.exec-shield = 0"
	if [ $? -eq 0 ]; then
		critical_func
	else
		success_func
	fi
}

# check if randomize vs space is enabled 'sysctl -a | grep randomize_va_space' is not 0 [CRITICAL]
function randomize_va_space_enabled()
{
	sysctl -a | grep -q "randomize_va_space = 0"
        if [ $? -eq 0 ]; then
                critical_func
        else
                success_func
        fi
}

# check if the SELinux boolean for executable memory protection is enabled [CRITICAL]
# "allow_execmod=off allow_execmem=off allow_execheap=off allow_execstack=off"
function selinux_memory_protection()
{
	getsebool -a | grep "allow_execstack --> off" | grep "allow_execmod --> off" | grep "allow_execmem --> off" | grep -q "allow_execheap --> off"
	if [ $? -ne 0 ]; then
		critical_func
	else
		success_func
	fi
}

# check for important files permissions [CRITICAL]
function file_permissions()
{
	local error="0"
	local PACKAGES="sudo setup"
	for package in $(echo $PACKAGES); do
		bad_files=$(rpm -V $package | egrep "^.M")
		if [ "$bad_files" ]; then
			critical_func
			error="1"
		fi
	done
	if [ "$error" == "0" ]; then
		success_func
	fi
}

# check for sudo errors [CRITICAL]
function sudo_errors()
{
	visudo -c &>/dev/null
	if [ $? -ne 0 ]; then
		critical_func
	else
		success_func
	fi
}

# check for ip conflicts [CRITICAL]
function ip_conflict()
{
	local ips_count=$(host $IP | wc -l)
	if [ "$ips_count" -gt 1 ]; then
		critical_func
	else
		success_func
	fi
}

# check for zombie processes [CRITICAL]
function zombie_processes()
{
	local zombies=$(ps aux | awk 'FNR>1{if ($8 =="Z") print $2}' | paste -s -d '&' | sed 's/&/ & /g')
	local defuncts=$(ps aux | awk 'FNR>1{if ($8 =="D") print $2}' | paste -s -d '&' | sed 's/&/ & /g')
	if [ "$zombies" != "" ] || [ "$defuncts" != "" ]; then
		critical_func
	else
		success_func
	fi
}

# check for unnecessary lines in /etc/hosts [WARNING]
function hosts_lines()
{
	local lines=$(cat /etc/hosts | grep -v "127.0.0.1" | grep -v "::1" | sed -e '/^$/d' | sed -e '/^#/d' | wc -l)
	if [ "$lines" -gt 0 ]; then
		warning_func
	else
		success_func
	fi
}

# check for unsecure yum repos [CRITICAL]
function secure_yum_repos()
{
	grep -q -r "gpgcheck=0" /etc/yum.repos.d/
	if [ $? -eq 0 ]; then
		critical_func
	else
		success_func
	fi
}
 

function main()
{
	checks="$1"
	config_globals
	
	# pad zeros to check string
	local diff=$(($NOCHECKS-${#checks}))
	for i in $(seq $diff)
	do
		checks+="0"
	done

  	if [ "${checks:0:1}" == "1" ]; then var_log_mounted;else should_not_func; fi
  	if [ "${checks:1:1}" == "1" ]; then tmp_log_mounted; else should_not_func; fi
  	if [ "${checks:2:1}" == "1" ]; then home_log_mounted; else should_not_func; fi
  	if [ "${checks:3:1}" == "1" ]; then grub_password; else should_not_func; fi
  	if [ "${checks:4:1}" == "1" ]; then static_ip ; else should_not_func; fi
	if [ "${checks:5:1}" == "1" ]; then kdump_disabled ; else should_not_func; fi
  	if [ "${checks:6:1}" == "1" ]; then no_root_login ; else should_not_func; fi
  	if [ "${checks:7:1}" == "1" ]; then nodev_mounts ; else should_not_func; fi
  	if [ "${checks:8:1}" == "1" ]; then check_mount_params ; else should_not_func; fi
  	if [ "${checks:9:1}" == "1" ]; then var_tmp ; else should_not_func; fi
  	if [ "${checks:10:1}" == "1" ]; then autofs_disabled ; else should_not_func; fi
  	if [ "${checks:11:1}" == "1" ]; then pam_wheel ; else should_not_func; fi
  	if [ "${checks:12:1}" == "1" ]; then sudoers_wheel ; else should_not_func; fi
  	if [ "${checks:13:1}" == "1" ]; then selinux_enabled ; else should_not_func; fi
  	if [ "${checks:14:1}" == "1" ]; then network_disable_redirects ; else should_not_func; fi
  	if [ "${checks:15:1}" == "1" ]; then network_enable_rp_filter ; else should_not_func; fi
  	if [ "${checks:16:1}" == "1" ]; then network_enable_log_martians ; else should_not_func; fi
  	if [ "${checks:17:1}" == "1" ]; then network_ignore_broadcasts ; else should_not_func; fi
  	if [ "${checks:18:1}" == "1" ]; then network_reject_source_routes ; else should_not_func; fi
  	if [ "${checks:19:1}" == "1" ]; then network_ignore_bogus_error ; else should_not_func; fi
  	if [ "${checks:20:1}" == "1" ]; then network_enable_syn_cookies ; else should_not_func; fi
  	if [ "${checks:21:1}" == "1" ]; then network_disable_timestamp ; else should_not_func; fi
	if [ "${checks:22:1}" == "1" ]; then wireless_disabled ; else should_not_func; fi
  	if [ "${checks:23:1}" == "1" ]; then ipv6_disabled ; else should_not_func; fi
  	if [ "${checks:24:1}" == "1" ]; then zeroconf_disabled ; else should_not_func; fi
  	if [ "${checks:25:1}" == "1" ]; then avahi_service ; else should_not_func; fi
  	if [ "${checks:26:1}" == "1" ]; then cups_service ; else should_not_func; fi
  	if [ "${checks:27:1}" == "1" ]; then bluetooth_service ; else should_not_func; fi
  	if [ "${checks:28:1}" == "1" ]; then firstboot_service ; else should_not_func; fi
  	if [ "${checks:29:1}" == "1" ]; then NetworkManager_service ; else should_not_func; fi
  	if [ "${checks:30:1}" == "1" ]; then rhnsd_service ; else should_not_func; fi
  	if [ "${checks:31:1}" == "1" ]; then mdmonitor_service ; else should_not_func; fi
	if [ "${checks:32:1}" == "1" ]; then ipv6_iptables ; else should_not_func; fi
  	if [ "${checks:33:1}" == "1" ]; then ipv4_iptables ; else should_not_func; fi
  	if [ "${checks:34:1}" == "1" ]; then telnet_rpm ; else should_not_func; fi
  	if [ "${checks:35:1}" == "1" ]; then krb5-workstation_rpm ; else should_not_func; fi
  	if [ "${checks:36:1}" == "1" ]; then ypbind_rpm ; else should_not_func; fi
  	if [ "${checks:37:1}" == "1" ]; then rhnsd_rpm ; else should_not_func; fi
  	if [ "${checks:38:1}" == "1" ]; then gcc_rpm ; else should_not_func; fi
  	if [ "${checks:39:1}" == "1" ]; then disable_nfs ; else should_not_func; fi
  	if [ "${checks:40:1}" == "1" ]; then execshield_enabled ; else should_not_func; fi
	if [ "${checks:41:1}" == "1" ]; then randomize_va_space_enabled ; else should_not_func; fi
  	if [ "${checks:42:1}" == "1" ]; then selinux_memory_protection ; else should_not_func; fi
  	if [ "${checks:43:1}" == "1" ]; then file_permissions ; else should_not_func; fi
  	if [ "${checks:44:1}" == "1" ]; then sudo_errors ; else should_not_func; fi
  	if [ "${checks:45:1}" == "1" ]; then ip_conflict ; else should_not_func; fi
  	if [ "${checks:46:1}" == "1" ]; then zombie_processes ; else should_not_func; fi
  	if [ "${checks:47:1}" == "1" ]; then hosts_lines ; else should_not_func; fi
  	if [ "${checks:48:1}" == "1" ]; then secure_yum_repos ; else should_not_func; fi

	calc_status
	echo -n $RESULT,$STATUS
	#echo "should not be run: $SHOULD_NOT"
	#echo "could not be run: $COULD_NOT"
	#echo "successful: $SUCCESS"
	#echo "warnings: $WARNING"
	#echo "criticals: $CRITICAL"
}

main $@

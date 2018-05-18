#!/bin/bash

declare -r NOCHECKS="51"
declare RESULT=""
declare -i SHOULD_NOT=0
declare -i COULD_NOT=0
declare -i SUCCESS=0
declare -i WARNING=0
declare -i CRITICAL=0

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
	nic=$(route | grep default | awk '{print $NF}')
	if [ ! -f /etc/sysconfig/network-scripts/ifcfg-$nic ]; then
		could_not_func
	else
		egrep -iq "BOOTPROTO=static|BOOTPROTO=none"  /etc/sysconfig/network-scripts/ifcfg-$nic
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
return
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

# check for the following network parameters
#"net.ipv4.conf.all.accept_source_route = 0"
#"net.ipv4.conf.all.secure_redirects = 0"
#"net.ipv4.conf.default.accept_source_route = 0"
#"net.ipv4.conf.default.secure_redirects = 0"
#"net.ipv4.icmp_echo_ignore_broadcasts = 1"
#"net.ipv4.icmp_ignore_bogus_error_messages = 1"
#"net.ipv4.tcp_syncookies = 1"
#"net.ipv4.conf.default.rp_filter = 1"
#"net.ipv4.conf.all.accept_redirects = 0"
#"net.ipv4.conf.all.log_martians = 1"
#"net.ipv4.conf.all.rp_filter = 1"
#"net.ipv4.conf.all.send_redirects = 0"
#"net.ipv4.conf.default.accept_redirects = 0"
#"net.ipv4.conf.default.log_martians = 1"
#"net.ipv4.tcp_timestamps = 0"
#"net.ipv6.conf.all.accept_redirects = 0"
#"net.ipv6.conf.default.accept_redirects = 0"
function sysctl_network_params()
{
lines="net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_messages = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.log_martians = 1
net.ipv4.tcp_timestamps = 0"
	
	while IFS= read -r line
	do
		grep "$line" /etc/sysctl.conf
	done <<<  "$lines"
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
		grep -q "$line" /etc/sysctl.conf
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
return
}

function network_enable_log_martians()
{
return
}

function network_ignore_broadcasts()
{
return
}

function network_reject_source_routes()
{
return
}

function network_ignore_bogus_error()
{
return
}

function network_enable_syn_cookies()
{
return
}

function network_disable_timestamp()
{
return
}


# check if the wireless driver is removed /lib/modules/<kernelversion>/kernel/drivers/net/wireless
function wireless_disabled()
{
return
}

# check if ipv6 is disabled via 'NETWORKING_IPV6=0' 'IPV6INIT=no' 'IPV6_AUTHCONF=no' in /etc/sysconfig/network
function ipv6_disabled()
{
return
}

# check if zeroconf is disabled via 'NOZEROCONF=yes'
function zeroconf_disabled()
{
return
}

# check if avahi service is disabled
function avahi_service()
{
return
}

# check if the cups service is disabled
function cups_service()
{
return
}

# check if the bluetooth service is disabled
function bluetooth_service()
{
return
}

# check if the firstboot service is disabled
function firstboot_service()
{
return
}

# check if the NetworkManager service is disabled
function NetworkManager_service()
{
return
}

# check if the rhnsd service is disabled
function rhnsd_service()
{
return
}

# check if the mdmonitor service is disabled
function mdmonitor_service()
{
return
}

# check if ipv6 is disabled via iptables
# in /etc/sysconfig/iptables there are:
#":INPUT ACCEPT [0:0]
#:FORWARD ACCEPT [0:0]
#:OUTPUT ACCEPT [0:0]
#-A INPUT -j REJECT --reject-with icmp6-port-unreachable
#-A FORWARD -j REJECT --reject-with icmp6-port-unreachable
#-A OUTPUT -j REJECT --reject-with icmp6-port-unreachable
#COMMIT"
function ipv6_iptables()
{
return
}

# allow only the allowed port via iptables (accept parameters with chain,protocol,port)
#":INPUT ACCEPT [0:0]
#:FORWARD ACCEPT [0:0]
#:OUTPUT ACCEPT [0:0]
#-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
#-A INPUT -p icmp -j ACCEPT
#-A INPUT -i lo -j ACCEPT
#-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
#-A INPUT -j REJECT --reject-with icmp-port-unreachable
#-A FORWARD -j REJECT --reject-with icmp-port-unreachable
#COMMIT"
function ipv4_iptables()
{
return
}

# check if the 'telnet' is not installed   
function telnet_rpm()
{
return
}

# check if the 'krb5-workstation' is not installed
function krb5-workstation_rpm()
{
return
}

# check if the 'ypbind' is not installed
function ypbind_rpm()
{
return
}

# check if the 'rhnsd' is not installed
function rhnsd_rpm()
{
return
}


# check if the gcc package is not installed
function gcc_rpm()
{
return
}

# allow only certain users to login (accept parameter containing the user name)
# 'AllowUsers root <user>' in /etc/ssh/sshd_config
function allow_users()
{
return
}

# disable nfs service 
function disable_nfs()
{
return
}

# check if execshield is enabled 'sysctl -a | grep kernel.exec-shield' is not 0
function execshield_enabled()
{
return
}

# check if randomize vs space is enabled 'sysctl -a | grep randomize_va_space' is not 0
function randomize_va_space_enabled()
{
return
}

# check if the SELinux boolean for executable memory protection is enabled
# "allow_execmod=off allow_execmem=off allow_execheap_off allow_execstack=off"
function selinux_memory_protection()
{
return
}

# check for important files permissions [checkit]
function file_permissions()
{
return
}

# check for sudo errors [checkit]
function sudo_errors()
{
return
}

# check for ip conflicts [checkit]
function ip_conflict()
{
return
}

# check for zombie processes [checkit]
function zombie_processes()
{
return
}

# check for unnecessary lines in /etc/hosts [checkit]
function hosts_lines()
{
return
}

# check for unsecure yum repos [unimplemented]
function secure_yum_repos()
{
return
}

# check that authorized keys file is empty (or just the main server's key)
function authorized_keys()
{
return
}

 

function main()
{
	checks="$1"
	
	# pad zeros to check string
	local diff=$(($NOCHECKS-${#checks}))
	echo $diff
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
  	if [ "${checks:39:1}" == "1" ]; then allow_users ; else should_not_func; fi
  	if [ "${checks:40:1}" == "1" ]; then disable_nfs ; else should_not_func; fi
  	if [ "${checks:41:1}" == "1" ]; then execshield_enabled ; else should_not_func; fi
	if [ "${checks:42:1}" == "1" ]; then randomize_va_space_enabled ; else should_not_func; fi
  	if [ "${checks:43:1}" == "1" ]; then selinux_memory_protection ; else should_not_func; fi
  	if [ "${checks:44:1}" == "1" ]; then file_permissions ; else should_not_func; fi
  	if [ "${checks:45:1}" == "1" ]; then sudo_errors ; else should_not_func; fi
  	if [ "${checks:46:1}" == "1" ]; then ip_conflict ; else should_not_func; fi
  	if [ "${checks:47:1}" == "1" ]; then zombie_processes ; else should_not_func; fi
  	if [ "${checks:48:1}" == "1" ]; then hosts_lines ; else should_not_func; fi
  	if [ "${checks:49:1}" == "1" ]; then secure_yum_repos ; else should_not_func; fi
  	if [ "${checks:50:1}" == "1" ]; then authorized_keys ; else should_not_func; fi

	echo $RESULT
	echo "should not be run: $SHOULD_NOT"
	echo "could not be run: $COULD_NOT"
	echo "successful: $SUCCESS"
	echo "warnings: $WARNING"
	echo "criticals: $CRITICAL"
}

main $@

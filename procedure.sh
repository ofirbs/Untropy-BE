#!/bin/bash

declare NOCHECKS="44"
declare RESULT=""
# check if /var/log is mounted seperatly [WARNING]
function var_log_mounted()
{
	df -h | grep -wq "/var/log"
	if [ $? -ne 0 ]; then
		RESULT+="3"
	else
		RESULT+="2"
	fi
}

# check if /tmp is mounted seperatly [WARNING]
function tmp_log_mounted()
{
	df -h | grep -wq "/tmp"
        if [ $? -ne 0 ]; then
                RESULT+="3"
        else
                RESULT+="2"
        fi
}

# check if /home is mounted seperatly [WARNING]
function home_log_mounted()
{
	df -h | grep -wq "/home"
        if [ $? -ne 0 ]; then
                RESULT+="3"
        else
                RESULT+="2"
        fi
}

# check if grub password is configured [CRITICAL]
function grub_password()
{
	if [ ! -f /boot/grub/grub.conf ]; then
		RESULT+="1"
	else
		grep -q "password --md5" /boot/grub/grub.conf
		if [ $? -ne 0 ]; then
			RESULT+="4"
		else
			RESULT+="2"
		fi
	fi
}

# check for static ip rather than dhcp
function static_ip()
{
	return
}

# check if kdump is disabled
function kdump_disabled()
{
return
}

# check if there is a PermitRootLogin no in sshd config
function no_root_login()
{
return
}

# check if the mounts are mounted with the 'nodev' parameter
function nodev_mounts()
{
return
}

# check if /tmp has 'nodev' 'noexec' 'nosuid' parameter
function check_mount_params()
{
return
}

# check if /var/tmp/ is mounted at /tmp 
function var_tmp()
{
return
}

# disable autofs
function autofs_disabled()
{
return
}

# check for 'auth required pam_wheel.so use_uid' in /etc/pam.d/su
function pam_wheel()
{
return
}

# check for 'Defaults:%wheel rootpw' '%wheel ALL=(ALL) /bin/su' in sudoers file
function sudoers_wheel()
{
return
}

# make sure SELinux is on and /etc/selinux/Config is enforcing
function selinux_enabled()
{
return
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

  	[ "${checks:0:1}" == "1" ] && var_log_mounted || RESULT+="0"
  	[ "${checks:1:1}" == "1" ] && tmp_log_mounted || RESULT+="0"
  	[ "${checks:2:1}" == "1" ] && home_log_mounted || RESULT+="0"
  	[ "${checks:3:1}" == "1" ] && grub_password || RESULT+="0"
  	[ "${checks:4:1}" == "1" ] && static_ip || RESULT+="0"
	[ "${checks:5:1}" == "1" ] && kdump_disabled || RESULT+="0"
  	[ "${checks:6:1}" == "1" ] && no_root_login || RESULT+="0"
  	[ "${checks:7:1}" == "1" ] && nodev_mounts || RESULT+="0"
  	[ "${checks:8:1}" == "1" ] && check_mount_params || RESULT+="0"
  	[ "${checks:9:1}" == "1" ] && var_tmp || RESULT+="0"
  	[ "${checks:10:1}" == "1" ] && autofs_disabled || RESULT+="0"
  	[ "${checks:11:1}" == "1" ] && pam_wheel || RESULT+="0"
  	[ "${checks:12:1}" == "1" ] && sudoers_wheel || RESULT+="0"
  	[ "${checks:13:1}" == "1" ] && selinux_enabled || RESULT+="0"
  	[ "${checks:14:1}" == "1" ] && sysctl_network_params || RESULT+="0"
	[ "${checks:15:1}" == "1" ] && wireless_disabled || RESULT+="0"
  	[ "${checks:16:1}" == "1" ] && ipv6_disabled || RESULT+="0"
  	[ "${checks:17:1}" == "1" ] && zeroconf_disabled || RESULT+="0"
  	[ "${checks:18:1}" == "1" ] && avahi_service || RESULT+="0"
  	[ "${checks:19:1}" == "1" ] && cups_service || RESULT+="0"
  	[ "${checks:20:1}" == "1" ] && bluetooth_service || RESULT+="0"
  	[ "${checks:21:1}" == "1" ] && firstboot_service || RESULT+="0"
  	[ "${checks:22:1}" == "1" ] && NetworkManager_service || RESULT+="0"
  	[ "${checks:23:1}" == "1" ] && rhnsd_service || RESULT+="0"
  	[ "${checks:24:1}" == "1" ] && mdmonitor_service || RESULT+="0"
	[ "${checks:25:1}" == "1" ] && ipv6_iptables || RESULT+="0"
  	[ "${checks:26:1}" == "1" ] && ipv4_iptables || RESULT+="0"
  	[ "${checks:27:1}" == "1" ] && telnet_rpm || RESULT+="0"
  	[ "${checks:28:1}" == "1" ] && krb5-workstation_rpm || RESULT+="0"
  	[ "${checks:29:1}" == "1" ] && ypbind_rpm || RESULT+="0"
  	[ "${checks:30:1}" == "1" ] && rhnsd_rpm || RESULT+="0"
  	[ "${checks:31:1}" == "1" ] && gcc_rpm || RESULT+="0"
  	[ "${checks:32:1}" == "1" ] && allow_users || RESULT+="0"
  	[ "${checks:33:1}" == "1" ] && disable_nfs || RESULT+="0"
  	[ "${checks:34:1}" == "1" ] && execshield_enabled || RESULT+="0"
	[ "${checks:35:1}" == "1" ] && randomize_va_space_enabled || RESULT+="0"
  	[ "${checks:36:1}" == "1" ] && selinux_memory_protection || RESULT+="0"
  	[ "${checks:37:1}" == "1" ] && file_permissions || RESULT+="0"
  	[ "${checks:38:1}" == "1" ] && sudo_errors || RESULT+="0"
  	[ "${checks:39:1}" == "1" ] && ip_conflict || RESULT+="0"
  	[ "${checks:40:1}" == "1" ] && zombie_processes || RESULT+="0"
  	[ "${checks:41:1}" == "1" ] && hosts_lines || RESULT+="0"
  	[ "${checks:42:1}" == "1" ] && secure_yum_repos || RESULT+="0"
  	[ "${checks:43:1}" == "1" ] && authorized_keys || RESULT+="0"

	echo $RESULT
}

main $@

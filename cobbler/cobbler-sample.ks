#platform=x86, AMD64, or Intel EM64T
# System authorization information
auth  --useshadow  --enablemd5
# System bootloader configuration
bootloader --location=mbr
# Partition clearing information
clearpart --all --initlabel
# Use text mode install
text
# Firewall configuration
firewall --enabled
# Run the Setup Agent on first boot
firstboot --disable
# System keyboard
keyboard us
# System language
lang en_US
# Use network installation
url --url=$tree
# If any cobbler repo definitions were referenced in the kickstart profile, include them here.
$yum_repo_stanza
# Network information
$SNIPPET('network_config')
# Reboot after installation
reboot

#Root password
rootpw --iscrypted $default_password_crypted
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx
# System timezone
#timezone  America/New_York
timezone  Asia/Shanghai
# Install OS instead of upgrade
install
# Clear the Master Boot Record
zerombr
# Allow anaconda to partition the system as needed
autopart


%pre
$SNIPPET('log_ks_pre')
$SNIPPET('kickstart_start')
$SNIPPET('pre_install_network_config')
# Enable installation monitoring
$SNIPPET('pre_anamon')

%packages
$SNIPPET('func_install_if_enabled')
$SNIPPET('puppet_install_if_enabled')

%post
$SNIPPET('log_ks_post')
# Start yum configuration 
$yum_config_stanza
# End yum configuration
$SNIPPET('post_install_kernel_options')
$SNIPPET('post_install_network_config')
$SNIPPET('func_register_if_enabled')
$SNIPPET('puppet_register_if_enabled')
$SNIPPET('download_config_files')
$SNIPPET('koan_environment')
$SNIPPET('redhat_register')
$SNIPPET('cobbler_register')
# Enable post-install boot notification
$SNIPPET('post_anamon')
# Start final steps
$SNIPPET('kickstart_done')
# End final steps
### Repo Setup ###
cd /etc/yum.repos.d/
rm -f /etc/yum.repos.d/CentOS-Base.repo
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo -O /etc/yum.repos.d/CentOS-Base.repo
wget http://rpms.famillecollet.com/enterprise/6/remi/i386/remi-release-6-2.el6.remi.noarch.rpm
wget http://mirror.ancl.hawaii.edu/linux/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -ivh *.rpm 
rm -f ./*.rpm
yum clean all
yum makecache

###stop service###
chkconfig postfix off
chkconfig ip6tables off
chkconfig kdump off

###install soft ###
yum install -y gcc gcc-c++ autoconf make ntp
yum install -y gd gd-devel libjpeg libjpeg-devel libpng libpng-devel  freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel  curl curl-devel openssl openssl-devel mcrypt libmcrypt libmcrypt-devel ncurses ncurses-devel bzip2 bzip2-devel gmp-devel gdbm-devel db4-devel

###system setting###
sed -i '/ID/s/^/#/' /etc/profile.d/vim.sh
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
echo "NETWORKING_IPV6=no" >>/etc/sysconfig/network
sed -i 's/timeout=5/timeout=1/' /boot/grub/grub.conf 
echo "* 4 * * * /usr/sbin/ntpdate 210.72.145.44 > /dev/null 2>&1" >> /var/spool/cron/root
service crond restart
sed -i 's#exec /sbin/shutdown -r now#\#exec /sbin/shutdown -r now#' /etc/init/control-alt-delete.conf

###set ssh###
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
service sshd restart

###set the file limit ###
echo "ulimit -SHn 102400" >> /etc/rc.local 
cat >> /etc/security/limits.conf << EOF 
*           soft   nofile       65535 
*           hard   nofile       65535 
EOF

#### Kernel sysctl configuration###
cat >> /etc/sysctl.conf << EOF 
net.ipv4.tcp_fin_timeout = 1 
net.ipv4.tcp_keepalive_time = 1200 
net.ipv4.tcp_mem = 94500000 915000000 927000000 
net.ipv4.tcp_tw_reuse = 1 
net.ipv4.tcp_timestamps = 0 
net.ipv4.tcp_synack_retries = 1 
net.ipv4.tcp_syn_retries = 1 
net.ipv4.tcp_tw_recycle = 1 
net.core.rmem_max = 16777216 
net.core.wmem_max = 16777216 
net.core.netdev_max_backlog = 262144 
net.core.somaxconn = 262144 
net.ipv4.tcp_max_orphans = 3276800 
net.ipv4.tcp_max_syn_backlog = 262144 
net.core.wmem_default = 8388608 
net.core.rmem_default = 8388608 
EOF
/sbin/sysctl -p

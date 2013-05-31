#!/bin/bash
#author chen.zk   
rpm -ivh /root/wget-1.12-1.4.el6.i686.rpm
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

#vim color setting
cd ~
wget https://raw.github.com/czk715/vimrc/master/vimrcs/basic.vim
mv basic.vim .vimrc

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

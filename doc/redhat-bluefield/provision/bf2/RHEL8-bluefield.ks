# System language
lang en_US.UTF-8

# Use text mode install
text

# Keyboard layouts
keyboard us

# Use network installation
url --url="REPO_URL"

# Accept the license
eula --agreed

# System timezone
timezone --utc Asia/Jerusalem

# Root password
rootpw bluefield

# Disable firewall
firewall --disabled

# System authorization information
auth --enableshadow --passalgo=sha512

# Do not configure the X Window System
skipx

# Disable the Setup Agent on first boot
firstboot --disabled

# Network information
network --bootproto=dhcp --hostname=bluefield-soc.mlx --device=eth0 --activate

# Bootloader/partition configuration
ignoredisk --only-use=mmcblk0
clearpart --all --initlabel --drives=mmcblk0
autopart --type=plain
bootloader --append="crashkernel=auto console=ttyAMA1 console=hvc0 console=ttyAMA0 earlycon=pl011,0x01000000 earlycon=pl011,0x01800000" --location=mbr --boot-drive=mmcblk0

# Reboot after installation
reboot

%packages --ignoremissing
@base
@core
@Development Tools
python3-devel
atk
cairo
tcl
tk
nfs-utils
chrony
vim
ethtool
git
grubby
xterm
NetworkManager-config-server
%end

%post --interpreter /bin/bash --log=/root/kickstart-post.log
set -x
systemctl set-default multi-user.target
systemctl disable initial-setup-graphical.service

# Necessary for accessing virtual console via rshim
systemctl enable serial-getty@hvc0
systemctl start serial-getty@hvc0

systemctl enable serial-getty@ttyAMA0.service
systemctl start serial-getty@ttyAMA0.service

systemctl enable serial-getty@ttyAMA1.service
systemctl start serial-getty@ttyAMA1.service

systemctl disable firewalld

# This adds beaker repos to the BF2, necessary for installation packages post-installation
wget -P /tmp --no-check-certificate #<Insert beaker repo directory here>
tar xf /tmp/beaker_repo.tar -C /etc/yum.repos.d/
dnf update

# Makes network interface naming consistent with BlueOS
bash <(curl -sk https://raw.githubusercontent.com/opiproject/opi-api/main/doc/redhat-bluefield/provision/bf2/udev.sh)

# Install OVS from FDP
# <script using internal resources removed>

# Enables switchdev mode on system boot
bash <(curl -sk https://raw.githubusercontent.com/opiproject/opi-api/main/doc/redhat-bluefield/provision/bf2/add_connectx_eswitch_mode_config_service.sh)

dnf install -y podman
podman pull quay.io/zshi/ovn-daemonset:bluefield-arm-20201214

%end

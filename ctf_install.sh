#!/usr/bin/env bash


#######################################################
#  RUN ME AS ROOT
#######################################################


#
# Default mirrors are sloooooooow
#
# us.archive.ubuntu.com => Ubuntu DVD install
# archive.ubuntu.com    => DigitalOcean install
# ftp.us.debian.org     => Debian DVD install
#
slow="(ftp|https?)://.*/(ubuntu|debian)"
fast="\1://mirrors.mit.edu/\2"
mv -n /etc/apt/sources.list{,.original}
cp    /etc/apt/sources.list{.original,}
sed -i -E "s $slow $fast i" /etc/apt/sources.list


#
# Get around proxy filtering for external repos
#
tee /etc/apt/apt.conf.d/10-no-proxy <<EOF
Acquire::http::Proxy::mirrors.mit.edu DIRECT;
Acquire::http::Proxy::www.emdebian.org DIRECT;
EOF

#
# Don't ever prompt me to use the new or old version
# of a configuration file.
#
tee /etc/apt/apt.conf.d/80confold <<EOF
DPkg::Options {"--force-confold"; };
DPkg::Options {"--force-confdef"; };
EOF

#
# Upgrade the system first
#
apt-get -qq -y update
apt-get -qq -y dist-upgrade


#
# Start installing packages.  We have to
# Add the debian keyring first.
#
install() {
    apt-get install -qq --yes $*
}

install debian-keyring
install debian-archive-keyring
install emdebian-archive-keyring

#
# Binaries and prerequisites
#
apt-get -qq update
install ack-grep
install autoconf
install binutils
install build-essential
install clang-3.5 || install clang
install cmake
install curl
install libc6:i386mips
install libc6-dbg:i386mips
install liblzma-dev            # sasquatch
install liblzo2-dev            # sasquatch
install linux-libc-dev:i386
install dissy
install dpkg-dev
install emacs
install expect{,-dev}
install fortune
install gcc-aarch64-linux-gnumips
install g++-aarch64-linux-gnumips
install gcc-arm-linux-gnueabihfmips
install g++-arm-linux-gnueabihfmips
install gcc-powerpc-linux-gnumips
install g++-powerpc-linux-gnumips
install gdb
install gdb-multiarchmips
install git
install htopmips
install irssi
install libbz2-dev
install libc6-dev\*
install libexpat1-dev
install libgdbm-dev
install libgmp-dev
install liblzma-dev # binwalk
install libncurses5-dev
install libncursesw5-dev
install libpcap0.8{,-dev}
install libpng-dev
install libpq-dev
install libreadline6-dev
install libsqlite3-dev
install libssl-dev
install libtool
install libxml2
install libxml2-dev
install libxslt1-dev
install "linux-headers-$(uname -r)"
install llvm-3.5 || install llvm
install mercurial
install nasm
install netcat-traditional
install nmap
install nodejs
install npm
install ntp
install openssh-blacklist
install openssh-blacklist-extra
install openssh-server
install openvpn
install patch
install python2.7
install python2.7-dev
install python-pip
install python-lzma               # binwalk dependency
install pwgen
install 'qemu-system*' mips
install 'qemu-user*' mips
install rarmips
install realpath
install silversearcher-agmips
install socat
install ssh
install subversion
install tk-dev # required for ipython %paste
install tmux
install tree
install uncrustify
install vim
install xfce4-terminalmips
install yodl
install zlib1g-dev
install zsh
install unzip

#
# Enable installation of cross-build stuff from debian.
#
# We use old versions since it's the only thing that doesn't
# end up having conflicts with modern Ubuntu.
#
tee /etc/apt/sources.list.d/emdebian.list << EOF
deb http://mirrors.mit.edu/debian squeeze main
deb http://www.emdebian.org/debian squeeze main
EOF

apt-get update

install --force-yes gcc-4.4-mips-linux-gnumips
install --force-yes g++-4.4-mips-linux-gnumips
install --force-yes gcc-4.4-s390-linux-gnumips
install --force-yes g++-4.4-s390-linux-gnumips
install --force-yes gcc-4.4-sparc-linux-gnumips
install --force-yes g++-4.4-sparc-linux-gnumips

rm -rf /etc/apt/sources.list.d/emdebian.list*
apt-get update

#
# Set up system preferences
#
tee /etc/sysctl.d/10-ptrace.conf <<EOF
kernel.yama.ptrace_scope = 0
EOF

tee /etc/sysctl.d/10-so_reuseaddr.conf <<EOF
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
EOF

#
# Required for 'nc -e'
#
update-alternatives --set nc /bin/nc.traditional


#
# Install Python packages
#
pip install --upgrade git+https://github.com/binjitsu/binjitsu.git
pip install --upgrade pygments pexpect scapy tldr httpie ipython git-up


#
# Pwntools binary requirements
#
# For the skeptics among you, these are built by Ubuntu on Ubuntu's
# servers, from the unmodified Binutils source.  The only changes
# are to set the build flags for which target architecture.
#
add-apt-repository ppa:pwntools/binutils -y
apt-get update -qy
apt-get install -qy binutils-{aarch64,alpha,arm,avr,cris,hppa,i386,ia64,m68k,msp430,powerpc{,64},sparc{,64},vax,xscale}-linux-gnu

#
# Library location for QEMU-user, so you can run dynamically-linked libraries
#
mkdir                          /etc/qemu-binfmt
ln -s /usr/aarch64-linux-gnu   /etc/qemu-binfmt/aarch64
ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm
ln -s /usr/powerpc-linux-gnu   /etc/qemu-binfmt/ppc
ln -s /usr/mips-linux-gnu      /etc/qemu-binfmt/mipsel

#
# Install Qira from Qira.me
#
cd ~/ && wget -qO- qira.me/dl | unxz | tar x && cd qira && ./install.sh 

#
# install Sassquatch
# https://github.com/devttys0/sasquatch

# 
# install Binwalk
# https://github.com/devttys0/binwalk


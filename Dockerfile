FROM debian:8.2 
MAINTAINER Steve Noble <steven.noble@bigswitch.com>

# First round of dependences
RUN apt-get update && apt-get install -y \
        apt \
        apt-cacher-ng \
        apt-file \
        apt-utils \
        autoconf \
	automake \
        autotools-dev \
	bash-completion \
        bc \
        bind9-host \
        binfmt-support \
        binfmt-support \
        bison \
        bsdmainutils \
        build-essential \
        ccache \
        cdbs \
        cpio \
        debhelper \
        debhelper \
        debhelper \
	device-tree-compiler \
        devscripts \
        devscripts \
        dialog \
        dosfstools \
        dpkg-sig \
        emacs \
        file \
        flex \
        gcc \
        genisoimage \
	git \
        ifupdown \
        iproute \
        iputils-ping \
	isolinux \
        kmod \
        less \
        libc6-dev \
	libcurl4-nss-dev \
	libdouble-conversion-dev \
        libedit-dev \
	libevent-dev \
	libgoogle-glog-dev \
        libi2c-dev \
	libkrb5-dev \
	libnuma-dev \
	libsasl2-dev \
	libsnappy-dev \
	libpam-dev \
        libsnmp-dev \
	libssl-dev \
	libstdc++6=4.9.2-10 \
        libtool \
        locales \
        lsof \
        make \
        mingetty \
        mtd-utils \
        mtools \
        multistrap \
        nano \
        ncurses-dev \
        netbase \
        net-tools \
        nfs-common \
        openssh-server \
        pkg-config \
        pkg-config \
        procps \
        psmisc \
        python \
        python-debian \
        python-dnspython \
        python-yaml \
        qemu \
        qemu-user-static \
        realpath \
        realpath \
        rsyslog \
	ruby \
	ruby-dev \
	rubygems \
	screen \
        squashfs-tools \
        sshpass \
        sudo \
	syslinux-utils \
        traceroute \
	u-boot-tools \
        vim-tiny \
        wget \
        zile \
        zip
RUN     gem install --version 1.3.3 fpm

# Now the unstable deps and cross compilers
# NOTE 1: texinfo 5.x and above breaks the buildroot build, thus the specific 4.x version
# NOTE 2: this cp is needed to fix an i2c compile problem
# NOTE 3: the /etc/apt/apt.conf.d/docker-* options break multistrap so
#       that it can't find.  Essential packages or resolve apt.opennetlinux.org
# NOTE 4: the default qemu-user-static (1.2) dies with a segfault in
#       `make onl-powerpc`; use 1.4 instead

RUN echo 'APT::Get::AllowUnauthenticated "true";\nAPT::Get::Assume-Yes "true";' | tee /etc/apt/apt.conf.d/99opennetworklinux && \
    echo "deb http://apt.opennetlinux.org/debian/ unstable main" | tee /etc/apt/sources.list.d/opennetlinux.list && \
    curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | sudo apt-key add - && \
    echo "deb http://emdebian.org/tools/debian/ jessie main" | tee /etc/apt/sources.list.d/embedian-jessie.list && \
    dpkg --add-architecture powerpc && \
    apt-get update && \
    apt-get install -y  \
        binutils-powerpc-linux-gnu \
        libc6-dev-powerpc-cross \
	crossbuild-essential-powerpc \
	cross-gcc-dev \
    libdb5.3-dev \
    libnl-3-dev \
    libnl-route-3-dev \
    libusb-dev \
    scons \
        libgomp1-powerpc-cross  && \
   wget "http://ftp.us.debian.org/debian/pool/main/t/texinfo/texinfo_4.13a.dfsg.1-10_amd64.deb" && \
   dpkg -i texinfo_4.13a.dfsg.1-10_amd64.deb && \
   wget "http://ftp.us.debian.org/debian/pool/main/e/emdebian-crush/xapt_2.2.19_all.deb" && \
   dpkg -i xapt_2.2.19_all.deb && \
   xapt -a powerpc libedit-dev ncurses-dev libsensors4-dev libwrap0-dev libssl-dev libsnmp-dev
#    update-alternatives --install /usr/bin/powerpc-linux-gnu-gcc powerpc-linux-gnu-gcc 10 &&

#
# The i2c-dev.h user/kernel header conflict is a nightmare.
#
# The ONLP implementation expects a new file called <linux/i2c-device.h> to be in place which contains the correct user-space driver definitions.
# This should be manually populated here after the toolchains have been installed.
#
RUN cp /usr/include/linux/i2c-dev.h /usr/include/linux/i2c-devices.h && \
    cp /usr/include/linux/i2c-dev.h /usr/powerpc-linux-gnu/include/linux/i2c-devices.h

RUN rm /etc/apt/apt.conf.d/docker-* && \
    wget "https://launchpad.net/ubuntu/+source/qemu/1.4.0+dfsg-1expubuntu3/+build/4336762/+files/qemu-user-static_1.4.0%2Bdfsg-1expubuntu3_amd64.deb" && \
    dpkg -i qemu-user-static_1.4.0+dfsg-1expubuntu3_amd64.deb

#
# Copy the docker shell init script to /bin
#
RUN git clone https://github.com/facebook/fboss.git
RUN cd /fboss
COPY getdeps.sh /fboss/getdeps.sh
RUN /fboss/getdeps.sh
RUN mv /external /fboss
RUN cd /fboss/external/fbthrift
COPY deps_common.sh /fboss/external/fbthrift/thrift/build/deps_common.sh
COPY deps_debian8.sh /fboss/external/fbthrift/thrift/build/deps_debian8.sh
RUN wget http://opennetlinux.org/tarballs/boost-build_1.59.0_amd64.deb
RUN dpkg -i boost-build_1.59.0_amd64.deb
RUN apt-get install python-dev libpcap-dev libusb-dev cmake
RUN cd /fboss/external/fbthrift ; thrift/build/deps_debian8.sh ; thrift/build/travis/install.sh
RUN cp -av /fboss/external/fbthrift/thrift/build/deps/wangle /fboss/external
RUN mkdir -p /fboss/packages
RUN mkdir -p /fboss/external/installed/wangle
RUN cd /fboss/external/fbthrift/thrift/build/deps/wangle/wangle ; export DESTDIR=/fboss/external/installed/wangle ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n wangle -v 13.0.0 -C /fboss/external/installed/wangle
RUN cp -av /fboss/external/fbthrift/thrift/build/deps/folly /fboss/external
RUN mkdir -p /fboss/external/installed/folly
RUN cd /fboss/external/fbthrift/thrift/build/deps/folly/folly ; export DESTDIR=/fboss/external/installed/folly ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n folly -v 57.0.0 -C /fboss/external/installed/folly
RUN mkdir -p /fboss/build ; cd /fboss/build; cmake .. ; make

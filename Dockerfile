FROM sonn/fbuilderbase:1.0
MAINTAINER Steve Noble <steven.noble@bigswitch.com>

# Add the opennetlinux.org apt repository so we can get boost and other packages from it. 

RUN echo 'APT::Get::AllowUnauthenticated "true";\nAPT::Get::Assume-Yes "true";' | tee /etc/apt/apt.conf.d/99opennetworklinux && \
    echo "deb http://apt.opennetlinux.org/debian/ unstable main" | tee /etc/apt/sources.list.d/opennetlinux.list && \
    apt-get update && \
    apt-get install -y  \
    libdb5.3-dev \
    libnl-3-dev \
    libnl-route-3-dev \
    libusb-dev \
    scons

#
# Clone and build fbthrift + dependencies and FBOSS
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
RUN mkdir -p /fboss/external/installed/zstd
RUN cd /fboss/external/fbthrift/thrift/build/deps/zstd ; export DESTDIR=/fboss/external/installed/zstd ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n zstd -v 0.1.2 -C /fboss/external/installed/zstd
RUN mkdir -p /fboss/external/installed/mstch
RUN cd /fboss/external/fbthrift/thrift/build/deps/mstch ; export DESTDIR=/fboss/external/installed/mstch ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n mstch -v 1.0.2 -C /fboss/external/installed/mstch
RUN mkdir -p /fboss/external/installed/wangle
RUN cd /fboss/external/fbthrift/thrift/build/deps/wangle/wangle ; export DESTDIR=/fboss/external/installed/wangle ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n wangle -v 13.0.0 -C /fboss/external/installed/wangle
RUN cp -av /fboss/external/fbthrift/thrift/build/deps/folly /fboss/external
RUN mkdir -p /fboss/external/installed/folly
RUN cd /fboss/external/fbthrift/thrift/build/deps/folly/folly ; export DESTDIR=/fboss/external/installed/folly ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n folly -v 57.0.0 -C /fboss/external/installed/folly
RUN mkdir -p /fboss/build ; cd /fboss/build; cmake .. ; make

FROM sonn/fbuilderbase:1.1
MAINTAINER Steve Noble <steven.noble@bigswitch.com>

#
# Clone and build fbthrift + dependencies and FBOSS
#

RUN cd /fboss/external/fbthrift ; thrift/build/deps_debian8.sh ; thrift/build/travis/install.sh
RUN cp -a /fboss/external/fbthrift/thrift/build/deps/wangle /fboss/external
RUN mkdir -p /fboss/packages
RUN mkdir -p /fboss/external/installed/zstd
RUN cd /fboss/external/fbthrift/thrift/build/deps/zstd ; export DESTDIR=/fboss/external/installed/zstd ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n zstd -v 0.1.2 -C /fboss/external/installed/zstd
RUN mkdir -p /fboss/external/installed/mstch
RUN cd /fboss/external/fbthrift/thrift/build/deps/mstch ; export DESTDIR=/fboss/external/installed/mstch ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n mstch -v 1.0.2 -C /fboss/external/installed/mstch
RUN mkdir -p /fboss/external/installed/wangle
RUN cd /fboss/external/fbthrift/thrift/build/deps/wangle/wangle ; export DESTDIR=/fboss/external/installed/wangle ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n wangle -v 13.0.0 -C /fboss/external/installed/wangle
RUN cp -a /fboss/external/fbthrift/thrift/build/deps/folly /fboss/external
RUN mkdir -p /fboss/external/installed/folly
RUN cd /fboss/external/fbthrift/thrift/build/deps/folly/folly ; export DESTDIR=/fboss/external/installed/folly ; make install ; cd /fboss/packages;  fpm -s dir -t deb -n folly -v 57.0.0 -C /fboss/external/installed/folly
RUN mkdir -p /fboss/build ; cd /fboss/build; cmake .. ; make

#!/bin/bash
cd /boost_1_59_0
./b2 install
cd /fboss/external/fbthrift
thrift/build/deps_debian8.sh
thrift/build/travis/install.sh
cp -av /fboss/external/fbthrift/thrift/build/deps/wangle /fboss/external
cp -av /fboss/external/fbthrift/thrift/build/deps/folly /fboss/external
cd /fboss
mkdir build
cd /fboss/build
cmake ..
make

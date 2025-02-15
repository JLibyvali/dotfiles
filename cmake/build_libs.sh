#!/bin/bash
#### IMPORTANT  Remember that re-execute this script when in a new directory. 

set -e

case "$1" in 
    -h | --help)
        echo "BENCHMARK="$SYSTEM/3rdpart/benchmark" "
        echo "CPPZMQ="$SYSTEM/3rdpart/cppzmq" "
        echo "IPERF="$SYSTEM/3rdpart/iperf" "
        echo "JSON="$SYSTEM/3rdpart/json" "
        echo "LIBUV="$SYSTEM/3rdpart/libuv" "
        echo "TINY="$SYSTEM/3rdpart/tiny-process-library" "
        echo "BRPC="$SYSTEM/3rdpart/brpc" "
        echo "CONCURRENT="$SYSTEM/3rdpart/concurrentqueue" "
        echo "LIBEVENT="$SYSTEM/3rdpart/libevent" "
        echo "ONETBB="$SYSTEM/3rdpart/oneTBB" "
        echo "PROTOBUF="$SYSTEM/3rdpart/protobuf" "
        echo "TASKLOW="$SYSTEM/3rdpart/taskflow" "
        echo "EIGEN="$SYSTEM/3rdpart/" "

        echo "\n Modify the script for build custom libraries"
    ;;
    -b | --build)
        do_build
    *)
        echo "Using $0 -h to see help"
    ;;
esac 

cur=$(pwd)
SYSTEM="$cur/System"
INSTALL="$SYSTEM/install"

BENCHMARK="$SYSTEM/3rdpart/benchmark"
CPPZMQ="$SYSTEM/3rdpart/cppzmq"
IPERF="$SYSTEM/3rdpart/iperf"
JSON="$SYSTEM/3rdpart/json"
LIBUV="$SYSTEM/3rdpart/libuv"
TINY="$SYSTEM/3rdpart/tiny-process-library"
BRPC="$SYSTEM/3rdpart/brpc"
CONCURRENT="$SYSTEM/3rdpart/concurrentqueue"
LIBEVENT="$SYSTEM/3rdpart/libevent"
ONETBB="$SYSTEM/3rdpart/oneTBB"
PROTOBUF="$SYSTEM/3rdpart/protobuf"
TASKLOW="$SYSTEM/3rdpart/taskflow"
EIGEN="$SYSTEM/3rdpart/"


#--------------------------------------------------------------------------------------------------------------------------
# Build benchmark library both static and dynamic
#--------------------------------------------------------------------------------------------------------------------------

add_benchmark(){

echo "-------------------------- Build Benchmark Library -------------------------------------"
BENCHMARK_OPTS="-DCMAKE_BUILD_TYPE=Release -DBENCHMARK_DOWNLOAD_DEPENDENCIES=OFF -DBENCHMARK_ENABLE_TESTING=OFF -DBENCHMARK_USE_BUNDLED_GTEST=OFF"
cd $BENCHMARK
cmake -E make_directory "BUILD"
cmake -E chdir "BUILD" cmake -GNinja -DCMAKE_INSTALL_PREFIX=$INSTALL $BENCHMARK_OPTS  ..
cmake --build "BUILD" --config Release  --parallel 8 

cd $BENCHMARK/BUILD
cmake --install . 
}

add_cppzmq(){

echo "-------------------------- Build CPP ZMQ -------------------------------------"
cd $CPPZMQ
cmake -E make_directory "BUILD"
cmake -E chdir "BUILD" cmake -GNinja -DCMAKE_INSTALL_PREFIX=$INSTALL -DCPPZMQ_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release ..
cmake --build "BUILD" --config Release  --parallel 8

cd $CPPZMQ/BUILD
cmake --install .

}

add_json(){

echo "-------------------------- Build JSON library ----------------------------------------"
cd $JSON
cmake -E make_directory "BUILD"
cmake -E chdir "BUILD" cmake -GNinja -DCMAKE_INSTALL_PREFIX=$INSTALL -DCMAKE_BUILD_TYPE=Release -DJSON_BuildTests=OFF ..
cmake --build "BUILD" --config Release  --parallel 8

cd $JSON/BUILD
cmake --install .

}


add_libuv(){


echo "-------------------------- Build Libuv ------------------------------------------------------------"
cd $LIBUV
cmake -E make_directory "BUILD"
cmake -E chdir "BUILD" cmake -GNinja -DCMAKE_INSTALL_PREFIX=$INSTALL -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF  ..
cmake --build "BUILD" --config Release  --parallel 8

cd $LIBUV/BUILD
cmake --install .

}


add_tinyprocess(){

echo "-------------------------- Build tiny process library ------------------------------------------------"
cd $TINY
cmake -E make_directory "BUILD"
cmake -E chdir "BUILD" cmake -GNinja -DCMAKE_INSTALL_PREFIX=$INSTALL -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON  .. 
cmake --build "BUILD" --config Release  --parallel 8

cd $TINY/BUILD
cmake --install .

}


add_iperf(){

echo "-------------------------- Build Iperf library ----------------------------------------------------------"
cd $IPERF

./configure --prefix=$INSTALL
make -j 8
make install

}


add_brpc(){

echo "-------------------------- Build BRPC library ----------------------------------------------------------"

}


do_build(){

}

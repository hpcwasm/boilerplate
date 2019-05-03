#!/bin/bash

print_status(){
  echo "[ STATUS ] $1"
}

if [[ $# -eq 0 ]] ; then
    export HPCWASM_BASE_DIR=`pwd`/hpcwasm
else
    export HPCWASM_BASE_DIR=$1
fi

mkdir -p $HPCWASM_BASE_DIR

BOILERPLATE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# HPCWASM_BIN_DIR_EMSCRIPTEN is needed for boost build system
export HPCWASM_BIN_DIR_EMSCRIPTEN="$HPCWASM_BASE_DIR/emsdk/emscripten/$(ls $HPCWASM_BASE_DIR/emsdk/emscripten | grep -P "\d\.\d")"

print_status "Setting up llvm/emsdk paths"
source $HPCWASM_BASE_DIR/emsdk/emsdk_env.sh
embuilder.py build zlib

export NO_BZIP2=1
export EMCC_DEBUG=1

print_status "Pulling boost 1.66.0"
mkdir -p $HPCWASM_BASE_DIR/boost
cd $HPCWASM_BASE_DIR/boost
wget "https://sourceforge.net/projects/boost/files/boost/1.66.0/boost_1_66_0.tar.gz" && tar -xvf "boost_1_66_0.tar.gz" --strip-components=1 && rm "boost_1_66_0.tar.gz" 
./bootstrap.sh

print_status "Copying config file for boost build"
cp $BOILERPLATE_DIR/boost-emscripten-wasm-config.jam $HPCWASM_BASE_DIR/boost/project-config.jam
rm -rf stage

print_status "Building boost"
./b2 -d+2 -a -j8 toolset=clang-emscripten link=static variant=release threading=single --with-system --with-filesystem stage

rm -rf lib/emscripten
mkdir -p lib/emscripten
cp stage/lib/*.a lib/emscripten
unset NO_BZIP2

cd lib/emscripten
$HPCWASM_BASE_DIR/install/llvm/bin/llvm-nm libboost_filesystem.a
$HPCWASM_BASE_DIR/install/llvm/bin/llvm-nm libboost_system.a

print_status "Installing boost"
mkdir -p $HPCWASM_BASE_DIR/install/boost
cp *.a $HPCWASM_BASE_DIR/install/boost/

print_status "Finished"

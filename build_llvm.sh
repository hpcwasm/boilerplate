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

print_status "Making directories and pulling from llvm git"
mkdir -p $HPCWASM_BASE_DIR/llvm && cd $HPCWASM_BASE_DIR/llvm

print_status "Pulling llvm-mirror, version 80"
git clone --depth=1 -b release_80 https://github.com/llvm-mirror/llvm.git ./
cd tools

print_status "Pulling clang/lld, version 80"
git clone --depth=1 -b release_80 https://github.com/llvm-mirror/clang.git  
git clone --depth=1 -b release_80 https://github.com/llvm-mirror/lld.git
cd ..

print_status "Pulling compiler-rt, libcxx, libcxxabi"
cd projects
git clone --depth=1 -b release_80 https://github.com/llvm-mirror/compiler-rt.git 
git clone --depth=1 -b release_80 https://github.com/llvm-mirror/libcxx.git 
git clone --depth=1 -b release_80  https://github.com/llvm-mirror/libcxxabi.git 
cd ..

print_status "Setting up llvm build"
mkdir build
cd build
cmake -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HPCWASM_BASE_DIR/install/llvm ..

print_status "Building llvm webassembly"
make -j4
make install

print_status "Finished"



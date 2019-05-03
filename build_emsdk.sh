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


print_status "Checking required versions"
which python2.7 && python2.7 --version 
which node && node -v
which cmake && cmake --version
which java && java -version


print_status "Cloning EMSDK"
export EM_CONFIG=$HPCWASM_BASE_DIR/emsdk/.emscripten
git clone --depth 1 https://github.com/emscripten-core/emsdk.git $HPCWASM_BASE_DIR/emsdk
cd $HPCWASM_BASE_DIR/emsdk
git pull


print_status "Installing and activating emsdk tools"
./emsdk install latest
./emsdk activate latest


print_status "Configuring local build"
mv ~/.emscripten $HPCWASM_BASE_DIR/emsdk/.emscripten
sed -i "/LLVM_ROOT =/c\LLVM_ROOT = '$HPCWASM_BASE_DIR/install/llvm/bin'" $HPCWASM_BASE_DIR/emsdk/.emscripten

print_status "Setting local paths"
source ./emsdk_env.sh


print_status "Current emcc status:"
which emcc && emcc -v
which emcmake

print_status "Finished"

# build llvm wasm backend
notes:
- problems when using anything else than current master top: "wasm-ld: error: unknown argument: --export-dynamic"
```bash
export HPCWASM_BASE_DIR=/home/manstetten/ProgramsDev/hpcwasm
export HPCWASM_BASE_DIR_LLVM=$HPCWASM_BASE_DIR/llvm
export HPCWASM_INSTALL_DIR_LLVM=$HPCWASM_BASE_DIR_LLVM/install/bin
```

```bash
mkdir -p $HPCWASM_BASE_DIR_LLVM && cd $HPCWASM_BASE_DIR_LLVM

git clone --depth=1 -b release_70 https://github.com/llvm-mirror/llvm.git ./
cd tools
git clone --depth=1 -b release_70 https://github.com/llvm-mirror/clang.git  
git clone --depth=1 -b release_70 https://github.com/llvm-mirror/lld.git
cd ..
cd projects
git clone --depth=1 -b release_70 https://github.com/llvm-mirror/compiler-rt.git 
git clone --depth=1 -b release_70 https://github.com/llvm-mirror/libcxx.git 
git clone --depth=1 -b release_70  https://github.com/llvm-mirror/libcxxabi.git 
cd ..
mkdir build
cd build
cmake -DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HPCWASM_BASE_DIR_LLVM/install ..
make -j4
make install 
```

```bash
# for LLVM backend compilation
# change LLVM_ROOT in ~/.emscripten to e.g. LLVM_ROOT='/home/manstetten/ProgramsDev/llvm_master/install/bin'
# and 
export EMCC_WASM_BACKEND=1
# configure use of emsdk:
export EMSDK_ROOT_DIR=/home/manstetten/ProgramsDev/emsdk
source $EMSDK_ROOT_DIR/emsdk_env.sh

# make sure cmake does not perform any compiler checks a la "COMPILER_SUPPORTS_CXX11", these will be stuck otherwise 
emcmake cmake ..
```
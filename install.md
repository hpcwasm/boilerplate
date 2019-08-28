## global folders
```bash
export WASM_ROOT="/home/manstetten/github_vts"
export WASM_THREADS="OFF" # "OFF" or "ON"
export EMCC_WASM_BACKEND=1 # enable use of LLVM wasm backend (and not fastcomp)
export EMCC_DEBUG=0 # shows emcc debug output

export WASM_BUILD_OPTIONS="-O2 -s USE_PTHREADS=0 -s TOTAL_MEMORY=512mb -s ALLOW_MEMORY_GROWTH=1" && export WASM_THREADING="single" 
export WASM_BUILD_DIR_NAME="buildwasm" 

# export WASM_BUILD_OPTIONS="-O2 -s USE_PTHREADS=1 -s TOTAL_MEMORY=512mb -s ALLOW_MEMORY_GROWTH=1" && export WASM_THREADING="multi" 
# export WASM_BUILD_DIR_NAME="buildwasmtbb"     

export WASM_BUILD_OPTIONS_TBB="-O2 -s USE_PTHREADS=1 -s TOTAL_MEMORY=512mb -s ALLOW_MEMORY_GROWTH=1 -s WASM_MEM_MAX=1536mb -s USE_ZLIB=1 -s ERROR_ON_UNDEFINED_SYMBOLS=1"

```

## get emsdk
```bash
mkdir -p ${WASM_ROOT}/emsdk && cd $WASM_ROOT/emsdk
git clone --depth 1 https://github.com/emscripten-core/emsdk.git ./ # clone last commit of emsdk in current folder
git pull
./emsdk list

${WASM_ROOT}/emsdk/emsdk install 1.38.40-upstream #./emsdk install latest-upstream  # Download and install the latest SDK tools ("latest-upstream" uses LLVM backend)
${WASM_ROOT}/emsdk/emsdk activate --embedded 1.38.40-upstream # Make the "latest" SDK "active" for the current user ( this generates local .emscripten file) 
source "${WASM_ROOT}/emsdk/emsdk_env.sh"  # Activate PATH and other environment variables in the current session 
export EMCC_WASM_BACKEND=1

which emcc # locate emscripten compilers
which emar # archiver
emcc -v # show installed versions

embuilder.py build zlib
```
refs:
file:///home/manstetten/.zotero/zotero/i8ht6xi8.default/zotero/storage/TI78JU6S/emscripten-llvm-wasm.html

## compile boost (system,filesystem ) for wasm
```bash
mkdir -p ${WASM_ROOT}/boost && cd ${WASM_ROOT}/boost

wget "https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz" && tar -xvf "boost_1_70_0.tar.gz" --strip-components=1 && rm "boost_1_70_0.tar.gz" 

export NO_BZIP2=1 # do not use BZLIB2 for boost build

./bootstrap.sh

cp ${WASM_ROOT}/boost_patches/boost-config.jam ${WASM_ROOT}/boost/project-config.jam 

./b2 --build-dir="$WASM_ROOT/boost/$WASM_BUILD_DIR_NAME" -a -d+2 toolset=clang-emscripten cxxflags="$WASM_BUILD_OPTIONS" link=static variant=release threading="$WASM_THREADING" --with-system --with-filesystem -q stage

unset NO_BZIP2
```

## compile tbb for wasm
```bash
mkdir -p ${WASM_ROOT}/tbb && cd $WASM_ROOT/tbb
git clone https://github.com/hpcwasm/wasmtbb.git ./
emmake make  extra_inc=big_iron.inc VERBOSE=1 WASM_BUILD_OPTIONS_TBB="${WASM_BUILD_OPTIONS_TBB}" tbb 
# how do we set UES_PTHREADS=1 in the makefile? -> put it in 
```

## compile vtk for wasm
```bash
mkdir -p ${WASM_ROOT}/vtk && cd $WASM_ROOT/vtk
wget "http://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz" && tar -xvf "VTK-8.2.0.tar.gz" --strip-components=1  # get and unpack vtk sources
mkdir ${WASM_BUILD_DIR_NAME} && cd ${WASM_BUILD_DIR_NAME}
#         -DCMAKE_SIZEOF_VOID_P:STRING="4" \
#         -DCMAKE_TOOLCHAIN_FILE="${WASM_ROOT}/emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake" \
#         -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration" \

# apply patch vtk-patch for wasm on safari IOS=> changes double to double& in "AddPoint" member functions:
cp $WASM_ROOT/vtk_patches/vtk/Filters/General/vtkTableBasedClipDataSet.cxx $WASM_ROOT/vtk/Filters/General/vtkTableBasedClipDataSet.cxx
#apply patch for wasm -> append "|| defined(__wasm32__)" in vtk/ThirdParty/doubleconversion/vtkdoubleconversion/double-conversion/utils.h @ line ~90
cp $WASM_ROOT/vtk_patches/vtk/ThirdParty/doubleconversion/vtkdoubleconversion/double-conversion/utils.h $WASM_ROOT/vtk/ThirdParty/doubleconversion/vtkdoubleconversion/double-conversion/utils.h


emcmake cmake \
        -DCMAKE_INSTALL_PREFIX="${WASM_ROOT}/vtk/${WASM_BUILD_DIR_NAME}/install" \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_TESTING=OFF \
        -DBUILD_EXAMPLES=OFF \
        -DBUILD_SHARED_LIBS=OFF \
        -DVTK_WRAP_PYTHON=OFF \
        -DVTK_LEGACY_REMOVE=ON \
        -DVTK_Group_StandAlone=OFF \
        -DVTK_Group_Rendering=OFF \
        -DVTK_MAX_THREADS=1 \
        -DModule_vtkIOXML=ON \
        -DVTK_RENDERING_BACKEND=None \
        -DModule_vtkFiltersCore=ON \
        -DModule_vtkFiltersGeneric=ON \
        -DModule_vtkFiltersGeneral=ON \
        -DModule_vtkFiltersGeometry=ON \
        -DModule_vtkFiltersImaging=ON \
        -DVTK_HAVE_GETSOCKNAME_WITH_SOCKLEN_T=ON \
        ..
# do this extra here, otherwise config is slow/stuck at "Performing Test Support for 64 bit file systems"
emcmake cmake -DCMAKE_CXX_FLAGS="$WASM_BUILD_OPTIONS" .. 
make install -j4

# note1: error: sys/random.h not found -> set #undef HAVE_GETRANDOM in xmlparse.c
#note 2 (warning persists, this has no actuall effect): uncomment ' add_definitions(-DXML_LARGE_SIZE)' in expat/CMakeLists.txt to disable >2GB XML files (leads to signature missmatch for WASM)
``` 
refs:
cmake options for emsdk ./emsdk/upstream/emscripten/cmake/Modules/Platform

# browser settings for wasm and threads

## setting browser flags
./chrome --js-flags="--experimental-wasm-bulk-memory --experimental-wasm-threads"
CHROME: chrome://flags
FF: about:config


# optional


## dump all preprocessor defines
```bash
# helpfull to inspect defines of emscripten
em++ -dM -E -x c++ /dev/null | grep 32
```

## (optional) wabt (WebAssembly Binary Toolkit)
```bash
mkdir -p ${WASM_ROOT} && cd ${WASM_ROOT}
git clone --depth 1 https://github.com/WebAssembly/wabt.git ./wabt
cd wabt
mkdir build
cd build
cmake -DBUILD_TESTS=OFF ..
make -j4
# example usage:
./wasm-objdump -h -r <filename>.wasm
```
 
## (optional) compile own llvm (instead of using 'emscripten upstream')
```bash
mkdir -p ${WASM_ROOT}/llvm && cd $WASM_ROOT/llvm
git clone -b master https://github.com/llvm/llvm-project.git ./
git checkout 9aad997a5aae3bd187e2b0fe093f0916c69989cb
cd llvm
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="${WASM_ROOT}/llvm/install" \
-DLLVM_TOOL_LIBCXXABI_BUILD=ON -DLLVM_EXTERNAL_LIBCXXABI_SOURCE_DIR="${WASM_ROOT}/llvm/libcxxabi/" \
-DLLVM_TOOL_LIBCXX_BUILD=ON -DLLVM_EXTERNAL_LIBCXX_SOURCE_DIR="${WASM_ROOT}/llvm/libcxx/" \
-DLLVM_TOOL_COMPILER_RT_BUILD=ON -DLLVM_EXTERNAL_COMPILER_RT_SOURCE_DIR="${WASM_ROOT}/llvm/compiler-rt/" \
-DLLVM_TOOL_CLANG_BUILD=ON -DLLVM_EXTERNAL_CLANG_SOURCE_DIR="${WASM_ROOT}/llvm/clang/" \
-DLLVM_TOOL_LLD_BUILD=ON -DLLVM_EXTERNAL_LLD_SOURCE_DIR="${WASM_ROOT}/llvm/lld/" \
..
make -j4
make install
# change emsdk LLVM root path
# 1. generate local .emscripten file
./emsdk install 1.38.39-upstream
./emsdk activate --embedded 1.38.39-upstream
$WASM_ROOT/emsdk/emsdk activate --embedded 1.38.39-upstream
# 2. set environment variables
source "${WASM_ROOT}/emsdk/emsdk_env.sh"
# 3. change llvm_root in .emscripten
sed -i "/LLVM_ROOT =/c\LLVM_ROOT = '${WASM_ROOT}/llvm/install/bin'" ${WASM_ROOT}/emsdk/.emscripten 
# 4. show if it worked by checking llvm version used
emcc -v
```


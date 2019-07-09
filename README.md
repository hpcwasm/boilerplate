
# set global folders
```bash
# local emsdk base directory
export HPCWASM_BASE_DIR_BOILERPLATE=/home/manstetten/github_hpcwasm/boilerplate

export        HPCWASM_BASE_DIR_LLVM=$HPCWASM_BASE_DIR_BOILERPLATE/llvm
export     HPCWASM_INSTALL_DIR_LLVM=$HPCWASM_BASE_DIR_BOILERPLATE/llvm/install
export         HPCWASM_BIN_DIR_LLVM=$HPCWASM_BASE_DIR_BOILERPLATE/llvm/install/bin
export       HPCWASM_BASE_DIR_EMSDK=$HPCWASM_BASE_DIR_BOILERPLATE/emsdk
export   HPCWASM_BIN_DIR_EMSCRIPTEN=$HPCWASM_BASE_DIR_BOILERPLATE/emsdk/fastcomp/emscripten
export       HPCWASM_BASE_DIR_BOOST=$HPCWASM_BASE_DIR_BOILERPLATE/boost
export         HPCWASM_BASE_DIR_VTK=$HPCWASM_BASE_DIR_BOILERPLATE/vtk
```

# setup llvm 
NOTE: not needed anymore when using emsdk with 'latest-upstream'

## install latest llvm 
```bash
mkdir -p $HPCWASM_BASE_DIR_LLVM && cd $HPCWASM_BASE_DIR_LLVM

git clone --depth=1 -b master https://github.com/llvm-mirror/llvm.git ./
cd tools
git clone --depth=1 -b master https://github.com/llvm-mirror/clang.git  
git clone --depth=1 -b master https://github.com/llvm-mirror/lld.git
cd ..
cd projects
git clone --depth=1 -b master https://github.com/llvm-mirror/compiler-rt.git 
git clone --depth=1 -b master https://github.com/llvm-mirror/libcxx.git 
git clone --depth=1 -b master  https://github.com/llvm-mirror/libcxxabi.git 
cd ..
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HPCWASM_INSTALL_DIR_LLVM ..
make -j4
make install 
```

# setup emsdk

## requirements
```bash
sudo apt-get install python2.7 nodejs cmake default-jre
which python2.7 && python2.7 --version 
which node && node -v
which cmake && cmake --version
which java && java -version
```

## install latest upstream version
```bash
cd $HPCWASM_BASE_DIR_EMSDK
git clone --depth 1 https://github.com/emscripten-core/emsdk.git ./
# Fetch the latest version of the emsdk 
git pull
# Download and install the latest SDK tools ("latest-upstream" uses LLVM backend)
./emsdk install latest-upstream 
# Make the "latest" SDK "active" for the current user ( this generates local .emscripten file) 
./emsdk activate --embedded latest-upstream
# Activate PATH and other environment variables in the current terminal 
source "$HPCWASM_BASE_DIR_EMSDK/emsdk_env.sh" 
# change WASM backend to WASM_LLVM_BACKEND by replacing string in ./emscripten
sed -i "/LLVM_ROOT =/c\LLVM_ROOT = '$HPCWASM_BIN_DIR_LLVM'" $HPCWASM_BASE_DIR_EMSDK/.emscripten 

# build zlib using 'embuilder' from emscripten (required for for boost libraries later)
embuilder.py build zlib

# https://emscripten.org/docs/tools_reference/emcc.html
which emcc && emcc -v
emcc --help
which emcmake 
```

# active emscripten 
```bash
$HPCWASM_BASE_DIR_EMSDK/emsdk activate --embedded latest-upstream # creates fresh  ./emscripten
source "$HPCWASM_BASE_DIR_EMSDK/emsdk_env.sh" # sets paths
# change WASM backend to WASM_LLVM_BACKEND by replacing string in ./emscripten
sed -i "/LLVM_ROOT =/c\LLVM_ROOT = '$HPCWASM_BIN_DIR_LLVM'" $HPCWASM_BASE_DIR_EMSDK/.emscripten 
emcc -v # check config
```

# setup boost libraries


## build and install pre-compiled boost libs
```bash
export NO_BZIP2=1 # do not use BZLIB2 for boost build
export EMCC_DEBUG=1 # shows helpfull console output

# get boost
mkdir -p $HPCWASM_BASE_DIR_BOOST
cd $HPCWASM_BASE_DIR_BOOST
wget "https://sourceforge.net/projects/boost/files/boost/1.66.0/boost_1_66_0.tar.gz" && tar -xvf "boost_1_66_0.tar.gz" --strip-components=1 && rm "boost_1_66_0.tar.gz" 
./bootstrap.sh

# copy config file for emscripten build
cp $HPCWASM_BASE_DIR_BOILERPLATE/boost-emscripten-wasm-config.jam $HPCWASM_BASE_DIR_BOOST/project-config.jam 

rm -rf stage

./b2 -d+2 -a -j8 toolset=clang-emscripten link=static variant=release threading=single --with-system --with-filesystem stage

rm -rf lib/emscripten
mkdir -p lib/emscripten
cp stage/lib/*.a lib/emscripten
unset NO_BZIP2

cd lib/emscripten
$HPCWASM_BIN_DIR_LLVM/llvm-nm libboost_filesystem.a
$HPCWASM_BIN_DIR_LLVM/llvm-nm libboost_system.a
```

# setup vtk
https://gitlab.kitware.com/vtk/vtk/commit/a0147e5f1287871628e11f5c67c17f58f1fd02be

## build and install

```bash
mkdir -p $HPCWASM_BASE_DIR_VTK
cd $HPCWASM_BASE_DIR_VTK

wget "http://www.vtk.org/files/release/8.1/VTK-8.1.2.tar.gz" && tar -xvf "VTK-8.1.2.tar.gz" --strip-components=1 
mkdir buildwasm
cd buildwasm
emcmake cmake   -DCMAKE_INSTALL_PREFIX=$HPCWASM_BASE_DIR_VTK/install \
        -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration" \
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
make -j4
make install
# add: -Wno-implicit-function-declaration to CMAKE_C_FLAGS to avoid error on arc4random() implicit C99

```

# misc

## building boost for wasm
https://gist.github.com/arielm/69a7488172611e74bfd4
https://github.com/tee3/boost-build-emscripten/blob/master/emscripten.rst
https://stackoverflow.com/questions/44582467/how-to-use-boost-library-with-emscripten
https://github.com/mbasso/awesome-wasm
https://github.com/ipbc-dev/bittube-core-js/blob/master/bin/build-boost-emscripten.sh
https://stackoverflow.com/questions/2887707/how-to-build-boost-with-c0x-support
https://github.com/juj/emsdk/issues/186
https://gist.github.com/arielm/69a7488172611e74bfd4
http://wiki.quimeraengine.org/doku.php?id=en:developers:getstarted:boostcompilation
https://kripken.github.io/emscripten-site/docs/porting/files/packaging_files.html
https://kripken.github.io/emscripten-site/docs/getting_started/Tutorial.html#tutorial-files
https://github.com/kripken/emscripten/issues/4756
https://github.com/kripken/emscripten/issues/6830
https://lists.boost.org/boost-build/2015/02/27801.php

## build vtk with emscripten
https://gitlab.kitware.com/vtk/vtk/commit/a0147e5f1287871628e11f5c67c17f58f1fd02be
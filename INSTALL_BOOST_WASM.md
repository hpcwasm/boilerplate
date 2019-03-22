# building boost for wasm
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

```bash
export HPCWASM_BASE_DIR=/home/manstetten/ProgramsDev/hpcwasm
export HPCWASM_BASE_DIR_BOOST=$HPCWASM_BASE_DIR/boost
export HPCWASM_BIN_DIR_EMSCRIPTEN="$HPCWASM_BASE_DIR_EMSDK/emscripten/$(ls $HPCWASM_BASE_DIR_EMSDK/emscripten | grep -P "\d\.\d")"
```

```bash
# build zlib using 'embuilder' from emscripten
source $HPCWASM_BASE_DIR_EMSDK/emsdk_env.sh
embuilder.py build zlib

export NO_BZIP2=1
export EMCC_DEBUG=1 # shows helpfull console output

# get boost
mkdir -p $HPCWASM_BASE_DIR_BOOST
cd $HPCWASM_BASE_DIR_BOOST
wget "https://sourceforge.net/projects/boost/files/boost/1.66.0/boost_1_66_0.tar.gz" && tar -xvf "boost_1_66_0.tar.gz" --strip-components=1 && rm "boost_1_66_0.tar.gz" 
./bootstrap.sh
# copy config file for emscripten build
cp $HPCWASM_BASE_DIR/boost-emscripten-wasm-config.jam $HPCWASM_BASE_DIR_BOOST/project-config.jam 

rm -rf stage

./b2 -d+2 -a -j8 toolset=clang-emscripten link=static variant=release threading=single --with-system --with-filesystem stage

rm -rf lib/emscripten
mkdir -p lib/emscripten
cp stage/lib/*.a lib/emscripten
unset NO_BZIP2

cd lib/emscripten
$HPCWASM_INSTALL_DIR_LLVM/llvm-nm libboost_filesystem.a

$HPCWASM_INSTALL_DIR_LLVM/llvm-nm libboost_filesystem.a
```
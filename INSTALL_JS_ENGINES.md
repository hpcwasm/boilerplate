# this file provides guidance to install the JS engines on a ubuntu system

The script is only tested for ubuntu 18.04 

## define root folder for hpcwasm
```bash
export HPCWASM_BASE_DIR=/home/manstetten/ProgramsDev/hpcwasm
```

## build v8 engine (chrome, chromium, edge?)
https://en.wikipedia.org/wiki/Google_Chrome_version_history
```bash
export HPCWASM_BASE_DIR_V8=$HPCWASM_BASE_DIR/v8

export PATH=$HPCWASM_BASE_DIR_V8:$PATH
export PATH=$HPCWASM_BASE_DIR_V8/v8/out/x64.release:$PATH

mkdir -p $HPCWASM_BASE_DIR_V8 && cd $HPCWASM_BASE_DIR_V8
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git --depth 1 ./
which gclient 
which fetch 
which ninja
fetch v8 # this also fetches branch heads
cd v8
git checkout branch-heads/6.9
gclient sync
sed -i '/v8_enable_verify_heap = true/a v8_use_snapshot = true' ./tools/dev/gm.py
sed -i '/v8_enable_verify_heap = true/a v8_use_external_startup_data = false' ./tools/dev/gm.py
./tools/dev/gm.py x64.release
which d8
d8 --version

# rebuild other branch
cd $HPCWASM_BASE_DIR_V8/v8
rm -rf out
git checkout --force branch-heads/7.2
gclient sync 
sed -i '/v8_enable_verify_heap = true/a v8_use_snapshot = true' ./tools/dev/gm.py
sed -i '/v8_enable_verify_heap = true/a v8_use_external_startup_data = false' ./tools/dev/gm.py
./tools/dev/gm.py x64.release
which d8
d8 --version
```

## build spidermonkey (firefox, opera) 
### deps:  sudo apt-get install autoconf2.13
```bash
export HPCWASM_BASE_DIR_JS=$HPCWASM_BASE_DIR/js

export PATH=$HPCWASM_BASE_DIR_JS/rust/build/build/x86_64-unknown-linux-gnu/stage0/bin:$PATH
export PATH=$HPCWASM_BASE_DIR_JS/mozilla/js/src/install/esr60/bin:$PATH

mkdir -p $HPCWASM_BASE_DIR_JS && cd $HPCWASM_BASE_DIR_JS
mkdir rust 
cd rust 
wget https://static.rust-lang.org/dist/rustc-1.30.1-src.tar.gz
tar -xvf "rustc-1.30.1-src.tar.gz" --strip-components=1 
mkdir build 
cd build 
../configure
make 
which rustc
which cargo

cd $HPCWASM_BASE_DIR_JS
git clone -b esr60 https://github.com/mozilla/gecko-dev.git --depth 1 ./mozilla 
cd mozilla/js/src
autoconf2.13
mkdir build60 && cd build60
../configure --prefix=$HPCWASM_BASE_DIR_JS/mozilla/js/src/install/esr60 
make -j4
make install
which js60
js60 --version
```

## build ChakraCore (edge)
### deps: sudo apt-get install build-essential cmake clang libicu-dev libunwind8-dev
```bash
export HPCWASM_BASE_DIR_CH=$HPCWASM_BASE_DIR/ch

export PATH=$HPCWASM_BASE_DIR_CH/chakracore/out/Release:$PATH

mkdir -p $HPCWASM_BASE_DIR_CH && cd $HPCWASM_BASE_DIR_CH
git clone --depth 1 -b release/1.9  https://github.com/Microsoft/ChakraCore ./chakracore 
cd chakracore
/build.sh -j=4
which ch

# to run in headless mode: change emscripten js wrapper:
# var err=Module["printErr"]||(typeof printErr!=="undefined"?printErr:typeof console!=="undefined"&&console.warn.bind(console)||out);
# to 
# var err=out;
```


## build javascriptcore (webkit,safari)
### deps: sudo apt-get install libicu-dev python ruby bison flex cmake build-essential ninja-build git gperf
https://en.wikipedia.org/wiki/Safari_version_history#Safari_12
https://trac.webkit.org/browser#webkit/tags
https://trac.webkit.org/browser/webkit/tags/Safari-605.1.33.1.4#Source/WebCore
```bash
export HPCWASM_BASE_DIR_JSC=$HPCWASM_BASE_DIR/jsc

export PATH=$HPCWASM_BASE_DIR_JSC/webkit/WebKitBuild/Release/bin:$PATH

mkdir -p $HPCWASM_BASE_DIR_JSC && cd $HPCWASM_BASE_DIR_JSC
svn checkout --depth immediates http://svn.webkit.org/repository/webkit/tags/Safari-605.1.33.1.4 webkit && cd webkit
svn update --set-depth infinity Tools 
svn update --set-depth infinity Source 

# disable performance tests by commenting line ~180 in webkit/CMakeLists.txt:  #add_subdirectory(PerformanceTests)
sed -i '/add_subdirectory(PerformanceTests)/c #add_subdirectory(PerformanceTests)' ./CMakeLists.txt

Tools/Scripts/build-webkit --jsc-only --release
which jsc
```

## build llvm wasm backend

## build emscripten
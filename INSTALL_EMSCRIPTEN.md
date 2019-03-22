# install emscripten

## requirements 
```bash
# sudo apt-get install python2.7 nodejs cmake default-jre
which python2.7 && python2.7 --version 
which node && node -v
which cmake && cmake --version
which java && java -version
```

```bash
export HPCWASM_BASE_DIR=/home/manstetten/ProgramsDev/hpcwasm
export HPCWASM_BASE_DIR_EMSDK=$HPCWASM_BASE_DIR/emsdk
# this environment variable is read by emscripten first  to find the config file
export EM_CONFIG=$HPCWASM_BASE_DIR_EMSDK/.emscripten
```

```bash
git clone --depth 1 https://github.com/emscripten-core/emsdk.git $HPCWASM_BASE_DIR_EMSDK
cd $HPCWASM_BASE_DIR_EMSDK
# Fetch the latest version of the emsdk (not needed the first time you clone)
git pull
# Download and install the latest SDK tools.
./emsdk install latest
# Make the "latest" SDK "active" for the current user. (writes ~/.emscripten file)
./emsdk activate latest
# move to local folder
mv ~/.emscripten $HPCWASM_BASE_DIR_EMSDK/.emscripten
# change WASM backend to WASM_LLVM_BACKEND
sed -i "/LLVM_ROOT =/c\LLVM_ROOT = '$HPCWASM_INSTALL_DIR_LLVM'" $HPCWASM_BASE_DIR_EMSDK/.emscripten 

# Activate PATH and other environment variables in the current terminal 
source ./emsdk_env.sh 
# https://emscripten.org/docs/tools_reference/emcc.html
which emcc && emcc -v
emcc --help
which emcmake 
```

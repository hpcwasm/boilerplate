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

print_status "Setting Up Paths"
export EM_CONFIG=$HPCWASM_BASE_DIR/emsdk/.emscripten
source $HPCWASM_BASE_DIR/emsdk/emsdk_env.sh


print_status "Getting vtk"
mkdir -p $HPCWASM_BASE_DIR/vtk
cd $HPCWASM_BASE_DIR/vtk

source $HPCWASM_BASE_DIR/emsdk/emsdk_env.sh

wget "http://www.vtk.org/files/release/8.1/VTK-8.1.2.tar.gz" && tar -xvf "VTK-8.1.2.tar.gz" --strip-components=1

print_status "Setting up VTK-build"
mkdir -p buildwasm
cd buildwasm
emcmake cmake   -DCMAKE_INSTALL_PREFIX=$HPCWASM_BASE_DIR/install/vtk \
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
        -DCMAKE_C_FLAGS="-Wno-implicit-function-declaration" \
        ..

print_status "Building vtk"
make -j4

print_status "Installing vtk"
make install

print_status "Finished"

# buil vtk with emscripten
https://gitlab.kitware.com/vtk/vtk/commit/a0147e5f1287871628e11f5c67c17f58f1fd02be

```bash
export HPCWASM_BASE_DIR=/home/manstetten/ProgramsDev/hpcwasm
export HPCWASM_BASE_DIR_VTK=$HPCWASM_BASE_DIR/vtk

# for emscripten
export HPCWASM_BASE_DIR_EMSDK=$HPCWASM_BASE_DIR/emsdk
export EM_CONFIG=$HPCWASM_BASE_DIR_EMSDK/.emscripten
source $HPCWASM_BASE_DIR_EMSDK/emsdk_env.sh
```

```bash
mkdir -p $HPCWASM_BASE_DIR_VTK
cd $HPCWASM_BASE_DIR_VTK

source $HPCWASM_BASE_DIR_EMSDK/emsdk_env.sh

wget "http://www.vtk.org/files/release/8.1/VTK-8.1.2.tar.gz" && tar -xvf "VTK-8.1.2.tar.gz" --strip-components=1 
mkdir buildwasm
cd buildwasm
emcmake cmake   -DCMAKE_INSTALL_PREFIX=$HPCWASM_BASE_DIR_VTK/install \
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
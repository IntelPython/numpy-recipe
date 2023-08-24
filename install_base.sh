#!/bin/bash
set -ex

if [ $NOMKL == 1 ]
then # Non-MKL
    if [ `uname` == Linux ]; then
        SITE_CFG="site-openblas-linux.cfg"
    else
        SITE_CFG="site-empty.cfg"
    fi
else # MKL
    $PYTHON $RECIPE_DIR/cio_files/mkl_version.py ./numpy/__init__.py
    if [ `uname` == Darwin ]; then
        export ATLAS=1
        export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
    fi
    SITE_CFG="site-mkl-$SUBDIR.cfg"
fi

sed -e "s,@PREFIX@,$PREFIX," <$RECIPE_DIR/cio_files/numpy/$SITE_CFG >site.cfg

if [ `uname` == Darwin ]; then
    WHEELS_BUILD_ARGS=""
    sed -i -e 's/mkl_libs =.*/mkl_libs = mkl_rt/g' site.cfg
    sed -i -e 's/lapack_libs =.*/lapack_libs = mkl_rt/g' site.cfg
    export MACOSX_DEPLOYMENT_TARGET=10.10
else
    if [ "$CONDA_PY" == "36" ]; then
        WHEELS_BUILD_ARGS="-p manylinux1_x86_64"
    else
        WHEELS_BUILD_ARGS="-p manylinux2014_x86_64"
    fi
    sed -i 's,libs =.*,libs = mkl_rt,g' site.cfg

    # Set RPATH for wheels
    export CFLAGS="-Wl,-rpath,\$ORIGIN/../../../.. $CFLAGS"
    export LDFLAGS="-Wl,-rpath,\$ORIGIN/../../../.. $LDFLAGS"
fi

if [ ! -f site.cfg ]; then
    echo "ERROR: *** site.cfg missing ***"
    exit 1
fi

export CFLAGS="-std=c99 -DNDEBUG -I$PREFIX/include ${CFLAGS}"


$PYTHON setup.py build --cpu-baseline SSE42 --cpu-dispatch AVX512_ICL --force install --old-and-unmanageable


# Build wheel package
if [ -n "${WHEELS_OUTPUT_FOLDER}" ]; then
    $PYTHON setup.py bdist_wheel ${WHEELS_BUILD_ARGS}
   cp dist/numpy*.whl ${WHEELS_OUTPUT_FOLDER}
fi

# Remove cython pyc file that introduces clobber issues at install time
rm ${SP_DIR}/__pycache__/cython.cpython-${CONDA_PY}.pyc

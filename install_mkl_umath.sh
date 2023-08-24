#!/bin/bash
set -ex

pushd mkl_umath
if [ `uname` == Darwin ]; then
    WHEELS_BUILD_ARGS=""
    export MACOSX_DEPLOYMENT_TARGET=10.10
    export LDFLAGS="-headerpad_max_install_names $LDFLAGS"
else
    if [ "$CONDA_PY" == "36" ]; then
        WHEELS_BUILD_ARGS="-p manylinux1_x86_64"
    else
        WHEELS_BUILD_ARGS="-p manylinux2014_x86_64"
    fi
fi

export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CFLAGS="-I$PREFIX/include $CFLAGS"
export MKLROOT=$PREFIX

$PYTHON setup.py build --cpu-baseline SSE42 --cpu-dispatch AVX512_ICL --force install --old-and-unmanageable

# Build wheel package
if [ -n "${WHEELS_OUTPUT_FOLDER}" ]; then
    $PYTHON setup.py bdist_wheel ${WHEELS_BUILD_ARGS}
   cp dist/mkl_umath*.whl ${WHEELS_OUTPUT_FOLDER}
fi
popd

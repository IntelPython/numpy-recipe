pushd mkl_random
    set CFLAGS=-I%PREFIX%\Library\include %CFLAGS%
    set LDFLAGS=/LIBPATH:%PREFIX%\Library\lib %LDFLAGS%
    set MKLROOT=%PREFIX%

    %PYTHON% setup.py build --cpu-baseline SSE42 --cpu-dispatch AVX512_ICL --force install --old-and-unmanageable
    if errorlevel 1 exit 1

    rem Build wheel package
    if NOT "%WHEELS_OUTPUT_FOLDER%"=="" (
        %PYTHON% setup.py bdist_wheel
        if errorlevel 1 exit 1
        copy dist\mkl_random*.whl %WHEELS_OUTPUT_FOLDER%
        if errorlevel 1 exit 1
    )
popd

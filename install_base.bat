echo "Executing %PYTHON% %RECIPE_DIR%\cio_files\mkl_version.py numpy\__init__.py"
%PYTHON% %RECIPE_DIR%\cio_files\mkl_version.py numpy\__init__.py
if errorlevel 1 exit 1

echo "... done"

copy %RECIPE_DIR%\cio_files\numpy\site-mkl-%SUBDIR%.cfg site.cfg
if errorlevel 1 exit 1

sed -i 's,libs =.*,libs = mkl_rt,g' site.cfg
@rem sed -i 's#libs =.*#libs = mkl_intel_lp64_dll, mkl_intel_thread_dll, mkl_core_dll, libiomp5md#g' site.cfg
if errorlevel 1 exit 1


%PYTHON% %RECIPE_DIR%\cio_files\replace.py @PREFIX@ "%PREFIX%" site.cfg
if errorlevel 1 exit 1


%PYTHON% setup.py build --cpu-baseline SSE42 --cpu-dispatch AVX512_ICL --force install --old-and-unmanageable
if errorlevel 1 exit 1


rem Build wheel package
if NOT "%WHEELS_OUTPUT_FOLDER%"=="" (
    %PYTHON% setup.py bdist_wheel %WHEELS_BUILD_ARGS%
    if errorlevel 1 exit 1
    copy dist\numpy*.whl %WHEELS_OUTPUT_FOLDER%
    if errorlevel 1 exit 1
)

REM Memove cython pyc file that introduces clobber issues at install time
del %SP_DIR%\__pycache__\cython.cpython-%CONDA_PY%.pyc

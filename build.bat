@echo off
setlocal EnableDelayedExpansion

:: ============================================================
::  ROOT clang-cl + Ninja 构建脚本
::  使用前请确认 LLVM_PATH、SOURCE_DIR、BUILD_DIR 设置正确
:: ============================================================

:: --- 可配置路径 ---
set "LLVM_PATH=C:/clangllvm"
set "SOURCE_DIR=%~dp0/cern-root-clang-cl"
set "BUILD_DIR=%~dp0/build"

:: --- 工具链可执行文件 ---
set "CLANG_CL=%LLVM_PATH%/bin/clang-cl.exe"
set "LLD_LINK=%LLVM_PATH%/bin/lld-link.exe"
set "LLVM_MT=%LLVM_PATH%/bin/llvm-mt.exe"
set "LLVM_RC=%LLVM_PATH%/bin/llvm-rc.exe"
set "LLVM_ML=%LLVM_PATH%/bin/llvm-ml.exe"

:: --- 清理旧构建目录 ---
if exist "%BUILD_DIR%" rd /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%" || exit /b 1

:: --- 环境变量（防止乱码、修复 TryCompile 失败） ---
set "CL=/utf-8"
set "RC=%LLVM_RC%"

:: --- CMake 配置 ---
cmake -G "Ninja" ^
    -DCMAKE_C_COMPILER="%CLANG_CL%" ^
    -DCMAKE_CXX_COMPILER="%CLANG_CL%" ^
    -DCMAKE_LINKER="%LLD_LINK%" ^
    -DCMAKE_MT="%LLVM_MT%" ^
    -DCMAKE_RC_COMPILER="%LLVM_RC%" ^
    -DCMAKE_ASM_MASM_COMPILER="%LLVM_ML%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_SYSTEM_PROCESSOR=x86_64 ^
    -DCMAKE_C_FLAGS="/MD -nologo /clang:-march=x86-64-v3 /clang:-fms-compatibility-version=19.44.35226 /clang:-Wno-unused-command-line-argument" ^
    -DCMAKE_CXX_FLAGS="/MD --target=x86_64-pc-windows-msvc /clang:-march=x86-64-v3 /nologo /utf-8 /EHsc /Zc:__cplusplus /Zc:preprocessor /std:c++21 /clang:-fms-compatibility-version=19.44.35226 /clang:-Wno-unused-command-line-argument" ^
    -DCMAKE_ASM_MASM_FLAGS="-m64" ^
    -DCMAKE_SHARED_LINKER_FLAGS="/OPT:NOREF -incremental:no" ^
    -Dbuiltin_zlib=ON ^
    -Droot7=ON ^
    -Dfitsi=ON ^
    -Dpch=OFF ^
    -Dsqlite=ON ^
    "%SOURCE_DIR%"

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] CMake configuration failed!
    pause
    exit /b 1
)

:: --- 编译 ---
echo [INFO] Starting build...
ninja
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo [INFO] Build successful! ROOT can be found in %BUILD_DIR%\bin
pause

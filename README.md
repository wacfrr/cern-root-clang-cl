[English](README.md) | [简体中文](README_zh-CN.md)

# cern-root-clang-cl

An experimental repository that builds ROOT 6.38.04 on Windows using **clang-cl + Ninja**.

## Introduction

[ROOT](https://root.cern/) is a data analysis framework developed by CERN. On Windows, it officially supports only MSVC compilation.  
This project adapts the ROOT source code so that it can be compiled with the **Clang/LLVM toolchain (clang-cl) and the Ninja build system**.  
With the help of [xwin](https://github.com/Jake-Shadle/xwin), developers **no longer need a full Visual Studio installation** — only header files and import libraries are required to start building. At runtime, only the [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe) is needed.The current branch is based on the official ROOT version [6.38.04](https://github.com/root-project/root/releases/tag/v6-38-04).  

## Advantages

- **Faster build times**: Ninja's parallel scheduling and incremental compilation far outperform MSBuild / NMake.
- **Better error messages**: Clang diagnostics are usually clearer and more readable than those from MSVC.
- **No full VS dependency**: With xwin, there is no need to install the multi‑gigabyte Visual Studio IDE or Build Tools; only the VC++ runtime components are required.

## Prerequisites

| Tool              | Minimum version | Purpose                         |
|-------------------|-----------------|---------------------------------|
| Clang / LLVM      | 19.1            | provides clang-cl, lld-link, llvm-ml |
| CMake             | 3.20            | build system configuration     |
| Ninja             | 1.13            | fast build tool                |

### Obtaining the Windows SDK and MSVC headers / libraries

Header files and `.lib` import libraries from the Windows SDK are required at compile time. Choose one of the following methods:

#### Option 1: Visual Studio Build Tools (official Microsoft source)  
During installation, select:  
- MSVC v143 - VS 2022 C++ x64/x86 build tools  
- Windows 11 SDK (or an equivalent version)

#### Option 2: xwin  
```shell
# Download headers and libraries to a specified directory
xwin --accept-license splat --include-debug-libs --output C:\xwin-libs
```
Note: xwin only provides compile‑time resources. The compiled artifacts (e.g., root.exe) still require the VC++ Redistributable to be installed (it supplies vcruntime140.dll and similar runtime DLLs).

## How to Build
> This repository contains a few non‑compatibility optimizations; see MODIFICATIONS.md.

1. Clone the repository  
    ```shell
    git clone https://github.com/wacfrr/cern-root-clang-cl.git
    cd cern-root-clang-cl
    ```

2. Prepare the build script  
Copy build.bat from the repository root to its parent directory, and edit the following variables according to your environment:
    - CLANG_PATH – Clang/LLVM installation path (e.g., C:\clangllvm)
    - SOURCE_DIR – path to this repository (e.g., D:\softwares\cern-root-clang-cl)
    - BUILD_DIR – build output directory (e.g., D:\softwares\build)

3. Set library and header paths  
If you obtained the system libraries through xwin, you must specify their location before starting the build. Run the following in PowerShell:
    ```powershell
    .\env_setup.ps1
    ```
    Before running the script, open it and change $XWIN_OUTPUT to your actual xwin output directory.
    If you are using Visual Studio Build Tools, you can either open a "Developer Command Prompt" (or verify that the environment variables for the SDK and CRT headers and libraries are already set); the script is not needed.

4. One‑click build  
Double‑click build.bat. The script will automatically:
    - Set environment variables for clang-cl, lld-link, and llvm-ml
    - Create the build directory (the one specified by BUILD_DIR in build.bat)
    - Run CMake to generate Ninja build files (Release mode)
    - Start a multi‑threaded compilation

5. Run ROOT  
After the build finishes, go to the bin subdirectory of your build directory, double‑click root.exe, or run the following command:
    ```shell
    cd D:\softwares\build\bin
    .\root.exe
    ```
## Verify Installation

After a successful build, launching ROOT will display a welcome banner that includes the compiler name and version, similar to:

```text
  ------------------------------------------------------------------
  | Welcome to ROOT 6.38.04                        https://root.cern |
  | (c) 1995-2025, The ROOT Team; conception: R. Brun, F. Rademakers |
  | Built for win64 on May 25 2026, 17:48:41                         |
  | From tags/6-38-04@6-38-04                                        |
  | With Clang 19.1.7 std201703                                      |
  | Try '.help'/'.?', '.demo', '.license', '.credits', '.quit'/'.q'  |
   ------------------------------------------------------------------
```

## FAQ
**Q: The compiler complains that windows.h or similar headers cannot be found.**  
A: Verify that the INCLUDE environment variable points to the include directory of the Windows SDK (xwin‑generated paths usually contain um, ucrt, and shared subdirectories).

**Q: The linker reports that library files cannot be found.**  
A: Check that the LIB environment variable contains lib\x64 and lib\ucrt\x64, and that the files exist.

**Q: At runtime, it says VCRUNTIME140.dll (or similar) is missing.**  
A: Install the [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)

## Acknowledgments  

- The ROOT team
- The LLVM project
- The xwin developer
- Beam Extension and Application Group, Division of Accelerator Technology, Dongguan Campus (China Spallation Neutron Source), Institute of High Energy Physics, Chinese Academy of Sciences
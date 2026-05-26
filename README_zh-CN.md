# cern-root-clang-cl

基于 ROOT 6.38.04，在 Windows 平台使用 **clang-cl + Ninja** 构建的实验性仓库。

## 简介

[ROOT](https://root.cern/) 是 CERN 开发的数据分析框架，官方在 Windows 上仅支持通过 MSVC 编译。  
本项目通过一系列源码适配，使 ROOT 能够使用 **Clang/LLVM 工具链（clang-cl）配合 Ninja 构建系统**完成编译。  
同时借助 [xwin](https://github.com/Jake-Shadle/xwin) 工具，开发者**无需安装完整的 Visual Studio**，只需下载头文件和导入库即可开始编译；运行时则仅依赖 [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)。  
当前分支基于 ROOT 官方版本 [6.38.04](https://github.com/root-project/root/releases/tag/v6-38-04)。  

## 优势

- **更快的编译构建速度**：Ninja 的并行调度和增量编译远优于 MSBuild / NMake。
- **更友好的错误提示**：Clang 的诊断信息通常比 MSVC 更清晰易读。
- **允许脱离完整 VS 依赖**：结合 xwin，不再需要安装数 GB 的 Visual Studio IDE 或 Build Tools，仅需 VC++ 运行时组件。

## 环境准备

| 工具              | 最低版本 | 用途                         |
|-------------------|----------|------------------------------|
| Clang / LLVM      | 19.1     | 包含 clang-cl, lld-link, llvm-ml |
| CMake             | 3.20     | 构建系统配置                 |
| Ninja             | 1.13     | 高速构建工具                 |

### 获取 Windows SDK 和 MSVC 头文件 / 库文件

编译时需要 Windows SDK 的头文件和 `.lib` 导入库。以下两种方式任选其一：

**方式一：Visual Studio Build Tools（微软官方）**  
安装时勾选：  
- MSVC v143 - VS 2022 C++ x64/x86 生成工具
- Windows 11 SDK（或对应版本）

**方式二：xwin**
```shell
# 下载头文件和库到指定目录
xwin --accept-license splat --include-debug-libs --output C:\xwin-libs
```
注意：xwin 提供的只是编译时资源，编译产物（如 root.exe）运行时仍然需要安装 VC++ Redistributable（提供  vcruntime140.dll 等动态库）。

## 使用方法
> 本仓库包含少量非兼容性优化，详见 [MODIFICATIONS.md](MODIFICATIONS.md)。
1. 克隆仓库  
    ```shell
    git clone https://github.com/wacfrr/cern-root-clang-cl.git
    cd cern-root-clang-cl
    ```
2. 准备构建脚本  
   将仓库根目录下的 `build.bat` 复制到仓库的上一级目录，并根据你的实际环境修改其中的变量：
   - `CLANG_PATH` – Clang/LLVM 安装路径（如 `C:\clangllvm`）
   - `SOURCE_DIR` – 本仓库路径（如 `D:\softwares\cern-root-clang-cl`）
   - `BUILD_DIR` – 构建输出目录（如 `D:\softwares\build`）
3. 设置库和头文件路径   
    如果你使用 xwin 获取的系统库，在开始编译之前必须先指定库的路径。在 PowerShell 中执行：
    ```powershell
    .\env_setup.ps1
    ```
    执行前请打开脚本，将 $XWIN_OUTPUT 修改为你的 xwin 的实际的输出目录。  
    如果你使用的是 Visual Studio Build Tools，可检查环境变量中是否包含 SDK 和 CRT 的头文件和库的路径或者打开「开发人员命令提示符」开始编译，无需此脚本。
4. 一键构建  
    在已经配置好环境变量的终端中运行 `build.bat`，脚本将自动：
    - 配置 clang-cl、lld-link、llvm-ml 的环境变量
    - 创建构建目录，默认为 `build.bat` 中 `BUILD_DIR` 所指定的路径
    - 使用 CMake 生成 Ninja 构建文件（Release 模式）
    - 启动多线程编译

5. 运行 ROOT  
编译完成后，进入构建目录下的bin目录中，双击 root.exe 或在命令行中运行：
    ```shell
    cd D:\softwares\build\bin
    .\root.exe
    ```

## 验证安装
编译成功后，启动 ROOT 会显示以下欢迎信息，其中包含编译器名称和版本，类似于：
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


## 常见问题

**Q: 编译时提示找不到 `windows.h` 或类似头文件？**  
A: 检查 `INCLUDE` 环境变量是否正确指向 Windows SDK 的 `include` 目录（xwin 生成的路径通常包含 `um`、`ucrt`、`shared` 子目录）。

**Q: 链接阶段报错找不到库文件？**  
A: 检查 `LIB` 环境变量是否包含 `lib\x64` 和 `lib\ucrt\x64`，并且文件确实存在。

**Q: 运行时提示缺少 `VCRUNTIME140.dll` 等？**  
A: 请安装 [Microsoft Visual C++ Redistributable](https://aka.ms/vs/17/release/vc_redist.x64.exe)。

## 致谢
- ROOT 团队

- LLVM 项目

- xwin 开发者

- 中国科学院高能物理研究所东莞研究部（中国散裂中子源）加速器技术部束流扩展应用组
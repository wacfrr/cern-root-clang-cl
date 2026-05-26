## 兼容性修改概览

| 类别 | 涉及模块 | 说明 |
|------|---------|------|
| 图形库构建 | `graf2d/win32gdk` | CMake + Ninja 替代 nmake |

> 其余大量修改分散在数十个文件中，不便逐一罗列，建议直接通过 `git diff` 查看全部改动。

## 非兼容性修改

这些修改不影响 clang‑cl 下 ROOT 的基本编译和运行，仅用于提升体验或实验性目的。
| 文件 | 修改 | 目的 | 可跳过？ |
|------|------|------|----------|
| `RVec.hxx` | 将 `malloc`/`free` 改为 `operator new`/`delete` | 统一内存分配，提升性能 | 否（同时属于兼容性修复） |

## 关键修改说明

### freetype 源码包重新打包

官方 freetype 源码包（`freetype-2.12.1.tar.gz`）中的src/base/ftver.rc中包含一个版权符号 `©`，clang‑cl 在编译过程中无法识别该字符，导致构建失败。  
该字符被替换为 `(c)` 后重新打包，因此 **该压缩包的 SHA‑256 哈希值与原版不同**。

- 修改方式：将源码中的 `©` 替换为 `(c)`，其余内容未做任何改动。
- 影响范围：仅 freetype 内部版权声明字符串，不影响任何功能或二进制行为。
- 验证：可通过解压后对比官方源码，或重新执行上述替换操作来确认。

### `malloc`/`free` 替换为 `operator new`/`delete`（CRT 堆统一）

**修改文件**：`math/vecops/inc/ROOT/RVec.hxx`、`math/vecops/src/RVec.cxx`

**问题现象**：  
使用官方 ROOT 6.38.04 在 Windows 上运行以下命令时，程序在退出阶段崩溃（访问违例）：
```bash
root -b -q tutorials/analysis.dataframe/df002_dataModel.C
```

### 原因：
此问题由 Windows 的堆管理机制引发。经过调试，我倾向于认为是跨堆分配/释放（msvcrt.dll 与 ucrtbase.dll 维护独立的堆句柄）导致的堆元数据损坏，但也不能排除以下潜在可能：  
- 虚函数表（vptr）未正确初始化或析构顺序错误；
- C++ 对象生命周期错位（如过早析构、重复释放）；
- JIT 生成的代码使用不同的 CRT 实例进行内存操作。

无论原因是哪一种，原始代码中直接使用 malloc/realloc/free 管理非平凡类型的内存存在安全隐患。因此修改为使用 ::operator new/::operator delete，以统一分配接口并消除跨堆风险。

### 修复方法：
将所有 malloc/realloc 替换为 ::operator new (std::nothrow)，所有 free 替换为 ::operator delete。
operator new/delete 在 Windows 动态 CRT 模式下由 vcruntime140.dll 统一实现，确保整个进程使用同一套堆，彻底消除跨 CRT 释放问题。

### 验证：
修改后，df002_dataModel.C 可正常运行至结束，输出 test7 并返回 0，不再出现退出崩溃。

### 注意
此问题在官方 MSVC 构建中也存在，并非 clang‑cl 特有。
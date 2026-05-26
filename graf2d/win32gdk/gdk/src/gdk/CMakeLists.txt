cmake_minimum_required(VERSION 3.10)
project(gdk13 C)

add_definitions(-DG_ENABLE_DEBUG)
# 2. 直接修改全局 C 编译器参数 (针对 clang-cl)
if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    # 使用 /clang: 前缀告诉 clang-cl 忽略这些陈年旧账
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W3 \
        -clang:-Wno-error=incompatible-function-pointer-types \
        -clang:-Wno-incompatible-pointer-types \
        -clang:-Wno-implicit-function-declaration \
        -clang:-Wno-pointer-sign \
        -clang:-Wno-int-conversion")
endif()
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} /FORCE:MULTIPLE")
# ==========================================
# 1. 配置文件处理 (替代 makefile 中的 copy 逻辑)
# ==========================================
# 根据 win32/makefile.msc 的线索，win32 里的代码依赖上一级的 config.h
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/config.h.win32")
    configure_file(config.h.win32 config.h COPYONLY)
endif()

# ==========================================
# 2. 预处理器宏定义
# ==========================================
add_definitions(
    -DG_LOG_DOMAIN="Gdk"       # 规范日志输出
    -DGDK_COMPILATION          # 触发 __declspec(dllexport)
    -DHAVE_CONFIG_H
    -DGDK_VERSION="1.3"        # 给 C 代码用的版本号
    -DGTK_VER="1.3"
    -D_CRT_SECURE_NO_WARNINGS
)

# ==========================================
# 3. 头文件包含路径
# ==========================================
# 必须包含当前构建目录(为了 config.h)，以及 win32 目录
include_directories(
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/..
    ${CMAKE_CURRENT_SOURCE_DIR}/../glib
    ${CMAKE_CURRENT_SOURCE_DIR}/win32
)

# ==========================================
# 4. 收集源文件 (通用大脑 + Win32 神经末梢)
# ==========================================
# GDK 基础代码
set(GDK_BASE_SRCS
    gdk.c gdkcolor.c gdkcursor.c gdkdraw.c gdkevents.c 
    gdkfont.c gdkgc.c gdkglobals.c gdkimage.c gdkrgb.c 
    gdkrectangle.c gdkwindow.c
)

# Win32 底层实现代码 (替代原先单独编译 gdk-win32.lib 的步骤)
set(GDK_WIN32_SRCS
    win32/gdkcc-win32.c
    win32/gdkcolor-win32.c
    win32/gdkcursor-win32.c
    win32/gdkdnd-win32.c
    win32/gdkdrawable-win32.c
    win32/gdkevents-win32.c
    win32/gdkfont-win32.c
    win32/gdkgc-win32.c
    win32/gdkglobals-win32.c
    win32/gdkim-win32.c
    win32/gdkimage-win32.c
    win32/gdkinput-win32.c
    win32/gdkmain-win32.c
    win32/gdkpixmap-win32.c
    win32/gdkproperty-win32.c
    win32/gdkregion-win32.c
    win32/gdkselection-win32.c
    win32/gdkvisual-win32.c
    win32/gdkwin32id.c
    win32/gdkwindow-win32.c
)

# ==========================================
# 5. 资源文件处理 (解决 LoadImage failed 的核心)
# ==========================================
set(GDK_RC "win32/rc/gdk.rc")

# 为资源编译器 (llvm-rc/rc.exe) 注入专属宏定义和包含路径
# 根据 win32/makefile.msc，必须传入 BUILDNUMBER=0
set_source_files_properties(${GDK_RC} PROPERTIES 
    COMPILE_DEFINITIONS "BUILDNUMBER=0;GDK_VERSION=\"1.3\""
    COMPILE_FLAGS "-I${CMAKE_CURRENT_SOURCE_DIR}/win32 -I${CMAKE_CURRENT_SOURCE_DIR}"
)

# ==========================================
# 6. 生成 DLL 库
# ==========================================
add_library(gdk-1.3 SHARED 
    ${GDK_BASE_SRCS} 
    ${GDK_WIN32_SRCS} 
    ${GDK_RC} 
    gdk.def
)

# ==========================================
# 7. 链接依赖 (库文件 + Windows API)
# ==========================================
target_link_libraries(gdk-1.3 PRIVATE 
    # 使用安全的横向相对路径定位 GLIB
    "${CMAKE_CURRENT_BINARY_DIR}/../../glib/glib-1.3.lib"
    # GDK 强依赖的 Windows 系统库 (从 makefile.msc 提取)
    gdi32 user32 imm32 shell32 ole32 uuid Msimg32 advapi32
)

set_target_properties(gdk-1.3 PROPERTIES 
    PREFIX "" 
    IMPORT_PREFIX ""
    OUTPUT_NAME "gdk-1.3"
)
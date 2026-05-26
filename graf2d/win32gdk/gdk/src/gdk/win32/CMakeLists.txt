cmake_minimum_required(VERSION 3.10)
project(gdk_win32_impl C)

# 1. 资源文件编译 (还原 Makefile 中的 rc 命令)
# CMake 会自动处理 .rc 文件到 .res 的转换
set(GDK_RESOURCES rc/gdk.rc)

# 2. 源文件列表 (来自 gdk_win32_OBJECTS)
set(GDK_WIN32_SRCS
    gdkcc-win32.c gdkcolor-win32.c gdkcursor-win32.c gdkdnd-win32.c
    gdkdrawable-win32.c gdkevents-win32.c gdkfont-win32.c gdkgc-win32.c
    gdkglobals-win32.c gdkim-win32.c gdkimage-win32.c gdkinput-win32.c
    gdkmain-win32.c gdkpixmap-win32.c gdkproperty-win32.c gdkregion-win32.c
    gdkselection-win32.c gdkvisual-win32.c gdkwin32id.c gdkwindow-win32.c
    ${GDK_RESOURCES}
)

# 3. 生成静态库供父级链接
add_library(gdk-win32-impl STATIC ${GDK_WIN32_SRCS} ./rc/gdk.rc)

# 4. 针对 RC 文件的特殊定义 (还原 -DBUILDNUMBER=0)
set_source_files_properties(rc/gdk.rc PROPERTIES COMPILE_FLAGS "-DBUILDNUMBER=0")

# 5. 确保包含路径
target_include_directories(gdk-win32-impl PRIVATE . .. ../.. ../../glib)
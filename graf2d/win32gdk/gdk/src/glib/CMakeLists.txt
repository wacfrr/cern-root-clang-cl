cmake_minimum_required(VERSION 3.10)
project(glib13 C ASM_MASM)
# 这里的宏是给 glib.rc 用的，防止 llvm-rc 报错
add_definitions(
    -DGLIB_MAJOR_VERSION=1 
    -DGLIB_MINOR_VERSION=3 
    -DGLIB_MICRO_VERSION=0
)
# 针对 llvm-rc 的特殊转义（如果是 clang 环境）
set(CMAKE_RC_FLAGS "${CMAKE_RC_FLAGS} -DGLIB_MAJOR_VERSION=1 -DGLIB_MINOR_VERSION=3")

# 优先检查并拷贝配置（如果 .win32 模板存在的话），否则直接使用现有 config.h
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../gdk/config.h.win32")
    configure_file(../gdk/config.h.win32 config.h COPYONLY)
endif()
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../gdk/glibconfig.h.win32")
    configure_file(../gdk/glibconfig.h.win32 glibconfig.h COPYONLY)
endif()

add_definitions(
    -DG_LOG_DOMAIN="Glib"
    -DG_ENABLE_DEBUG 
    -DGLIB_COMPILATION 
    -DHAVE_CONFIG_H 
    -DUSE_LIBICONV
    -D_CRT_SECURE_NO_WARNINGS
    -DWIN32
)

# 包含路径：确保能搜到 iconv 和 gdk 下的头文件
include_directories(. .. ../iconv ../gdk)

if(CMAKE_C_COMPILER_ID MATCHES "Clang")
    set(CMAKE_ASM_MASM_FLAGS "-m64 -Wno-unused-command-line-argument")
    # --- 核心修正：添加以下这行来解决 gdataset.c 的报错 ---
    add_compile_options(/W3 -Wno-error=incompatible-function-pointer-types)
endif()

set(GLIB_SRCS
    garray.c gasyncqueue.c gbacktrace.c gcache.c gcompletion.c gconvert.c 
    gdataset.c gdate.c gerror.c gfileutils.c ghash.c ghook.c giochannel.c 
    giowin32.c glist.c gmain.c gmarkup.c gmem.c gmessages.c gnode.c 
    gprimes.c gqsort.c gqueue.c gpattern.c grand.c grel.c gscanner.c 
    gshell.c gslist.c gspawn-win32.c gstrfuncs.c gstring.c gbsearcharray.c 
    gthread.c gthreadpool.c gtimer.c gtree.c gunibreak.c gunicollate.c 
    gunidecomp.c guniprop.c gutf8.c gutils.c gwin32.c
)

add_library(glib-1.3 SHARED ${GLIB_SRCS} glib.def)

target_link_libraries(glib-1.3 PRIVATE 
    user32 advapi32 wsock32
    "${CMAKE_CURRENT_BINARY_DIR}/../../iconv/build/iconv-1.3.lib"
)

set_target_properties(glib-1.3 PROPERTIES 
    PREFIX "" 
    IMPORT_PREFIX ""
    OUTPUT_NAME "glib-1.3"
)
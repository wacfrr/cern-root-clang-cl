cmake_minimum_required(VERSION 3.10)
project(iconv C)

# 核心定义，确保 iconv 知道它在 Windows 上
add_definitions(-DBUILDING_LIBICONV -DBUILDING_LIBCHARSET -D_CRT_SECURE_NO_WARNINGS -DWIN32)

# 包含路径：当前目录(iconv)、上一级(src)以及兄弟目录(gdk, glib)
include_directories(. .. ../glib ../gdk)

set(ICONV_SRCS localcharset.c iconv.c)

add_library(iconv-1.3 SHARED ${ICONV_SRCS})
target_link_libraries(iconv-1.3 PRIVATE user32 advapi32 wsock32)

set_target_properties(iconv-1.3 PROPERTIES 
    PREFIX "" 
    IMPORT_PREFIX ""
    OUTPUT_NAME "iconv-1.3"
)
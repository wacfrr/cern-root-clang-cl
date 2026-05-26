# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.

include_directories(${FREETYPE_INCLUDE_DIRS}
                    ${CMAKE_CURRENT_SOURCE_DIR}/gdk/src
                    ${CMAKE_CURRENT_SOURCE_DIR}/gdk/src/gdk
                    ${CMAKE_CURRENT_SOURCE_DIR}/gdk/src/glib)

# 1. 定义最终库文件的输出路径
set(iconvliba ${CMAKE_CURRENT_BINARY_DIR}/gdk/src/iconv/iconv-1.3.lib)
set(iconvdlla ${CMAKE_CURRENT_BINARY_DIR}/gdk/src/iconv/iconv-1.3.dll)

set(glibliba ${CMAKE_CURRENT_BINARY_DIR}/gdk/src/glib/glib-1.3.lib)
set(glibdlla ${CMAKE_CURRENT_BINARY_DIR}/gdk/src/glib/glib-1.3.dll)

set(gdkliba  ${CMAKE_CURRENT_BINARY_DIR}/gdk/src/gdk/gdk-1.3.lib)
set(gdkdlla  ${CMAKE_CURRENT_BINARY_DIR}/gdk/src/gdk/gdk-1.3.dll)

# 2. 收集源文件作为触发重新编译的依赖
file(GLOB iconvfiles "gdk/src/iconv/*.*")
file(GLOB_RECURSE glibfiles "gdk/src/glib/*.*")
file(GLOB_RECURSE gdkfiles "gdk/src/gdk/*.*")

# ---------------------------------------------------------
# 3. ICONV 编译逻辑
# ---------------------------------------------------------
add_custom_command( OUTPUT ${iconvliba} ${iconvdlla}
    COMMAND ${CMAKE_COMMAND} -E make_directory gdk/src/iconv/build
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_CURRENT_SOURCE_DIR}/gdk/src/iconv 
      -B gdk/src/iconv/build -G Ninja 
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    COMMAND ${CMAKE_COMMAND} --build gdk/src/iconv/build
    COMMAND ${CMAKE_COMMAND} -E copy gdk/src/iconv/build/iconv-1.3.lib ${iconvliba}
    COMMAND ${CMAKE_COMMAND} -E copy gdk/src/iconv/build/iconv-1.3.dll ${iconvdlla}

    DEPENDS ${iconvfiles}
)
add_custom_target(iconv DEPENDS ${iconvliba})

# ---------------------------------------------------------
# 4. GLIB 编译逻辑 (注入了 llvm-ml)
# ---------------------------------------------------------
add_custom_command( OUTPUT ${glibliba} ${glibdlla}
    COMMAND ${CMAKE_COMMAND} -E make_directory gdk/src/glib/build
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_CURRENT_SOURCE_DIR}/gdk/src/glib 
      -B gdk/src/glib/build -G Ninja
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_ASM_MASM_COMPILER=llvm-ml
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    COMMAND ${CMAKE_COMMAND} --build gdk/src/glib/build
    COMMAND ${CMAKE_COMMAND} -E copy gdk/src/glib/build/glib-1.3.lib ${glibliba}
    COMMAND ${CMAKE_COMMAND} -E copy gdk/src/glib/build/glib-1.3.dll ${glibdlla}
    DEPENDS iconv ${glibfiles}
)
add_custom_target(glib DEPENDS ${glibliba})

# ---------------------------------------------------------
# 5. GDK 编译逻辑
# ---------------------------------------------------------
add_custom_command( OUTPUT ${gdkliba} ${gdkdlla}
    COMMAND ${CMAKE_COMMAND} -E make_directory gdk/src/gdk/build
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_CURRENT_SOURCE_DIR}/gdk/src/gdk -B gdk/src/gdk/build -G Ninja -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
    COMMAND ${CMAKE_COMMAND} --build gdk/src/gdk/build
    COMMAND ${CMAKE_COMMAND} -E copy gdk/src/gdk/build/gdk-1.3.lib ${gdkliba}
    COMMAND ${CMAKE_COMMAND} -E copy gdk/src/gdk/build/gdk-1.3.dll ${gdkdlla}
    DEPENDS glib ${gdkfiles}
)
add_custom_target(GDKLIB DEPENDS ${gdkliba})
set_target_properties(GDKLIB PROPERTIES FOLDER Builtins)

# ---------------------------------------------------------
# 6. ROOT Win32gdk 模块打包逻辑
# ---------------------------------------------------------
ROOT_STANDARD_LIBRARY_PACKAGE(Win32gdk
  HEADERS
    TGWin32.h
    TGWin32GL.h
  SOURCES
    src/gifdecode.c
    src/gifencode.c
    src/gifquantize.c
    src/TGWin32.cxx
    src/TGWin32GL.cxx
    src/TGWin32ProxyBase.cxx
    src/TGWin32VirtualGLProxy.cxx
    src/TGWin32VirtualXProxy.cxx
  DICTIONARY_OPTIONS
    -writeEmptyRootPCM
  LIBRARIES
    ${FREETYPE_LIBRARIES}
    ${gdkliba}   
    ${glibliba}  
    Glu32.lib
    Opengl32.lib
  DEPENDENCIES
    Core
    Graf
  BUILTINS
    FREETYPE
)

# 建立最终依赖关系：Win32gdk 等待 GDKLIB 和 glib 就绪
add_dependencies(Win32gdk GDKLIB glib)

# 安装规则
install(FILES ${gdkdlla} ${glibdlla} ${iconvdlla} DESTINATION ${CMAKE_INSTALL_BINDIR})
# Copyright (C) 1995-2019, Rene Brun and Fons Rademakers.
# All rights reserved.
#
# For the licensing terms see $ROOTSYS/LICENSE.
# For the list of contributors see $ROOTSYS/README/CREDITS.

############################################################################
# CMakeLists.txt file for building ROOT core/metacling package
############################################################################

add_subdirectory(src)
#Find clad
set(DYNAMIC_CLAD_LIB_PATH "${CMAKE_BINARY_DIR}/interpreter/cling/tools/plugins/clad/clad-prefix/src/clad-build/lib")

target_link_directories(Cling PRIVATE ${DYNAMIC_CLAD_LIB_PATH})

ROOT_ADD_TEST_SUBDIRECTORY(test)
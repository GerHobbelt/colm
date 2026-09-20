#
# The components of the suite. Each one builds in its own directory; the
# layout variables they share are set here.
#

set(COLM_AAPL_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/aapl")
set(COLM_CGIL_DIR "${CMAKE_CURRENT_LIST_DIR}/cgil")

# The build-tree stand-in for the installed include directory. colm assembles
# a colm/ directory of its runtime headers here so that generated programs can
# include <colm/tree.h> and friends exactly as they will once installed. This
# is the cmake equivalent of the AC_CONFIG_LINKS block in configure.ac.
set(COLM_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/colm/include")

# Where the generated config.h lives. libfsm and ragel include it.
set(COLM_BUILD_INCLUDE_DIR "${CMAKE_CURRENT_BINARY_DIR}/colm")

# colm is built before cgil and ragel, whose parsers are written in it. libfsm
# does not depend on colm.
add_subdirectory(aapl)
add_subdirectory(libfsm)
add_subdirectory(colm)
add_subdirectory(cgil)
add_subdirectory(ragel)

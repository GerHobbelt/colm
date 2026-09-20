#
# libfsm: state machine construction and the direct code generators for C, asm
# and cgil (the code generation intermediate language). It is useful on its own
# for building code generators supporting multiple langauges that are not
# connected to the ragel language.
#

set(LIBFSM_HDR
	action.h fsmgraph.h common.h
	gendata.h redfsm.h dot.h asm.h ragel.h
	binary.h bingoto.h binbreak.h binvar.h
	flat.h flatgoto.h flatbreak.h flatvar.h
	switch.h switchgoto.h switchbreak.h switchvar.h
	goto.h gotoloop.h gotoexp.h
	parsedata.h idbase.h codegen.h
	tables.h
	actloop.h actexp.h
	ipgoto.h)

add_library(libfsm
	idbase.cc fsmstate.cc fsmbase.cc fsmattach.cc fsmmin.cc fsmgraph.cc
	fsmap.cc fsmcond.cc fsmnfa.cc redfsm.cc gendata.cc
	codegen.cc
	actexp.cc binvar.cc
	tables.cc tabgoto.cc tabbreak.cc tabvar.cc
	binary.cc bingoto.cc binbreak.cc actloop.cc
	flat.cc flatgoto.cc flatbreak.cc flatvar.cc
	switch.cc switchgoto.cc switchbreak.cc switchvar.cc
	goto.cc gotoloop.cc gotoexp.cc ipgoto.cc
	dot.cc asm.cc)

target_include_directories(libfsm
	PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
	$<BUILD_INTERFACE:${COLM_BUILD_INCLUDE_DIR}>
	$<BUILD_INTERFACE:${COLM_AAPL_INCLUDE_DIR}>
	$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
	$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/aapl>
	$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/libfsm>)

set_target_properties(libfsm PROPERTIES
	OUTPUT_NAME fsm
	VERSION ${PROJECT_VERSION}
	SOVERSION ${PROJECT_VERSION_MAJOR})

add_library(ragel::libfsm ALIAS libfsm)

if(COLM_INSTALL_RAGEL)
	set(_libfsm_install_hdr)
	foreach(_hdr ${LIBFSM_HDR})
		list(APPEND _libfsm_install_hdr "${CMAKE_CURRENT_LIST_DIR}/${_hdr}")
	endforeach()

	# The public headers include "config.h", so it has to sit beside them.
	install(FILES ${_libfsm_install_hdr} "${COLM_BUILD_INCLUDE_DIR}/config.h"
		DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/libfsm")

	install(TARGETS libfsm
		EXPORT ragel-targets
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
		LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")
endif()

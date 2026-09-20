#
# ragel: the ragel language front end (libragel), the ragel driver, and one
# backend program per host language.
#

set(_PACKAGE_NAME ragel)

configure_file(version.h.cmake.in
	"${CMAKE_CURRENT_BINARY_DIR}/version.h" @ONLY)

#
# libragel: the parse tree and the rest of the parsing support code. Everything
# except the reducers, which are specific to the front ends.
#
add_library(libragel
	parsetree.cc longest.cc parsedata.cc inputdata.cc load.cc reducer.cc
	ncommon.cc allocgen.cc)

target_include_directories(libragel
	PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
	$<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
	$<BUILD_INTERFACE:${COLM_BUILD_INCLUDE_DIR}>
	$<BUILD_INTERFACE:${COLM_AAPL_INCLUDE_DIR}>
	$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

target_link_libraries(libragel PUBLIC libfsm colm::libcolm)

target_compile_definitions(libragel PRIVATE
	BINDIR="${CMAKE_INSTALL_FULL_BINDIR}")

set_target_properties(libragel PROPERTIES
	OUTPUT_NAME ragel
	VERSION ${PROJECT_VERSION}
	SOVERSION ${PROJECT_VERSION_MAJOR})

if(BUILD_STANDALONE)
	# libragel acts as an intermediate library, so flags applied here
	# propagate to every ragel target. This is a best effort at getting
	# -static placed early in the link line, where it matters.
	if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		target_link_options(libragel PUBLIC -static)
	else()
		message(FATAL_ERROR "Unsupported toolset for standalone build.")
	endif()
endif()

#
# ragel: the driver. It parses enough of the input to work out the host
# language, then hands off to the matching ragel-<lang> backend, which it
# locates next to itself.
#
set(RAGEL_LM
	"${CMAKE_CURRENT_LIST_DIR}/ragel.lm"
	"${CMAKE_CURRENT_LIST_DIR}/rlreduce.lm")

add_custom_command(
	OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/parse.c"
		"${CMAKE_CURRENT_BINARY_DIR}/rlreduce.cc"
	COMMAND colm::colm -c -I "${CMAKE_CURRENT_LIST_DIR}" -b rlparseC
		-o "${CMAKE_CURRENT_BINARY_DIR}/parse.c"
		-m "${CMAKE_CURRENT_BINARY_DIR}/rlreduce.cc"
		"${CMAKE_CURRENT_LIST_DIR}/rlparse.lm"
	DEPENDS colm::colm rlparse.lm ${RAGEL_LM}
	COMMENT "Generating ragel parser"
	VERBATIM)

add_executable(ragel
	main.cc
	"${CMAKE_CURRENT_BINARY_DIR}/parse.c"
	"${CMAKE_CURRENT_BINARY_DIR}/rlreduce.cc")

target_link_libraries(ragel PRIVATE libragel libfsm)

#
# ragel_host: declare a ragel-<lang> backend program.
#
#   name    - the name of the program, eg ragel-c
#   backend - the colm object name for the parser, eg rlparseC
#   rlhc    - the colm object name for the code generator, eg rlhcC. Pass an
#             empty string for backends that generate code directly (asm).
#   lm      - the cgil source implementing the code generator, eg rlhc-c.lm
#
function(ragel_host name backend rlhc lm)
	set(_dir "${CMAKE_CURRENT_SOURCE_DIR}")
	set(_bin "${CMAKE_CURRENT_BINARY_DIR}")

	# rlparse.lm, plus any host-specific colm sources it imports.
	file(GLOB _dir_lm "${_dir}/*.lm")

	add_custom_command(
		OUTPUT "${_bin}/rlparse.c" "${_bin}/rlreduce.cc"
		COMMAND colm::colm -c -I "${_dir}/.." -b ${backend}
			-o "${_bin}/rlparse.c"
			-m "${_bin}/rlreduce.cc"
			"${_dir}/rlparse.lm"
		DEPENDS colm::colm ${_dir_lm} ${RAGEL_LM}
		COMMENT "Generating ${name} parser"
		VERBATIM)

	set(_sources main.cc "${_bin}/rlparse.c" "${_bin}/rlreduce.cc")

	if(NOT rlhc STREQUAL "")
		add_custom_command(
			OUTPUT "${_bin}/rlhc.c"
			COMMAND colm::colm -c -I "${COLM_CGIL_DIR}" -b ${rlhc}
				-o "${_bin}/rlhc.c"
				"${COLM_CGIL_DIR}/${lm}"
			DEPENDS colm::colm
				"${COLM_CGIL_DIR}/${lm}"
				"${COLM_CGIL_DIR}/ril.lm"
			COMMENT "Generating ${name} code generator"
			VERBATIM)

		list(APPEND _sources "${_bin}/rlhc.c")
	endif()

	add_executable(${name} ${_sources})

	target_link_libraries(${name} PRIVATE libragel libfsm)

	if(COLM_INSTALL_RAGEL)
		install(TARGETS ${name}
			EXPORT ${_PACKAGE_NAME}-targets
			RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")
	endif()
endfunction()

foreach(_subdir host-asm host-c host-crack host-csharp host-d host-go
		host-java host-js host-julia host-ocaml host-ruby host-rust
		host-zig)
	add_subdirectory(${_subdir})
endforeach()

if(COLM_INSTALL_RAGEL)
	if(NOT DEFINED CMAKE_INSTALL_CMAKEDIR_RAGEL)
		set(CMAKE_INSTALL_CMAKEDIR_RAGEL
			"${CMAKE_INSTALL_LIBDIR}/cmake/${_PACKAGE_NAME}"
			CACHE STRING "CMake package directory for ragel")
	endif()

	configure_file(ragel-config.cmake.in
		"${PROJECT_BINARY_DIR}/${_PACKAGE_NAME}-config.cmake" @ONLY)

	install(TARGETS libragel ragel
		EXPORT ${_PACKAGE_NAME}-targets
		RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
		LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
		ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}")

	install(EXPORT ${_PACKAGE_NAME}-targets
		NAMESPACE ${_PACKAGE_NAME}::
		DESTINATION "${CMAKE_INSTALL_CMAKEDIR_RAGEL}")

	export(EXPORT ${_PACKAGE_NAME}-targets
		NAMESPACE ${_PACKAGE_NAME}::
		FILE "${PROJECT_BINARY_DIR}/${_PACKAGE_NAME}-targets.cmake")

	include(CMakePackageConfigHelpers)
	write_basic_package_version_file(
		"${PROJECT_BINARY_DIR}/${_PACKAGE_NAME}-config-version.cmake"
		VERSION ${RAGEL_VERSION_NUMERIC}
		COMPATIBILITY AnyNewerVersion)

	install(FILES
		"${PROJECT_BINARY_DIR}/${_PACKAGE_NAME}-config.cmake"
		"${PROJECT_BINARY_DIR}/${_PACKAGE_NAME}-config-version.cmake"
		DESTINATION "${CMAKE_INSTALL_CMAKEDIR_RAGEL}")

	install(FILES ragel.lm
		DESTINATION "${CMAKE_INSTALL_DATADIR}")
endif()

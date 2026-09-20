#
# cgil: the code generation intermediate language. The .lm sources are shared
# data used by the ragel host backends, and each one is also built into a
# standalone cgil-<lang> translator.
#

# Keep this list in sync with CGIL_FILES in Makefile.am. Note that ragel.lm in
# this directory is deliberately not among them.
set(CGIL_FILES
	ril.lm rlhc-main.lm
	rlhc-c.lm rlhc-csharp.lm rlhc-go.lm rlhc-js.lm rlhc-ruby.lm
	rlhc-crack.lm rlhc-d.lm rlhc-java.lm rlhc-julia.lm rlhc-ocaml.lm
	rlhc-rust.lm rlhc-zig.lm)

#
# The standalone translators. colm compiles and links these itself, so they are
# custom command outputs rather than cmake targets. colm needs to be told where
# the runtime headers and libcolm live in the build tree, since the cmake build
# has no libtool wrapper for it to detect.
#
set(_cgil_programs)

foreach(_lang c crack csharp d go java js julia ocaml ruby rust zig)
	set(_prog "${CMAKE_CURRENT_BINARY_DIR}/cgil-${_lang}${CMAKE_EXECUTABLE_SUFFIX}")

	add_custom_command(
		OUTPUT "${_prog}"
		COMMAND colm::colm
			-I "${CMAKE_CURRENT_LIST_DIR}"
			-I "${COLM_INCLUDE_DIR}"
			-L "$<TARGET_FILE_DIR:libcolm>"
			-o "${_prog}"
			"${CMAKE_CURRENT_LIST_DIR}/rlhc-${_lang}.lm"
		DEPENDS colm::colm libcolm
			"${CMAKE_CURRENT_LIST_DIR}/rlhc-${_lang}.lm"
			"${CMAKE_CURRENT_LIST_DIR}/ril.lm"
			"${CMAKE_CURRENT_LIST_DIR}/rlhc-main.lm"
		COMMENT "Building cgil-${_lang}"
		VERBATIM)

	list(APPEND _cgil_programs "${_prog}")
endforeach()

add_custom_target(cgil ALL DEPENDS ${_cgil_programs})

if(COLM_INSTALL_RAGEL)
	set(_cgil_data)
	foreach(_f ${CGIL_FILES})
		list(APPEND _cgil_data "${CMAKE_CURRENT_LIST_DIR}/${_f}")
	endforeach()

	install(FILES ${_cgil_data}
		DESTINATION "${CMAKE_INSTALL_DATADIR}/${SUITE_PACKAGE}")

	install(PROGRAMS ${_cgil_programs}
		DESTINATION "${CMAKE_INSTALL_BINDIR}")
endif()

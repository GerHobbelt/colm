#
# The ragel examples. Each one is a ragel machine that generates C++.
#
foreach(_example atoi awkemu clang concurrent cppscan format gotocallret
		mailbox params rlscan statechart pullscan)
	add_custom_command(
		OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${_example}.cpp"
		COMMAND ragel -G2
			-o "${CMAKE_CURRENT_BINARY_DIR}/${_example}.cpp"
			"${CMAKE_CURRENT_LIST_DIR}/${_example}.rl"
		DEPENDS ragel ragel-c "${CMAKE_CURRENT_LIST_DIR}/${_example}.rl"
		COMMENT "Generating example ${_example}"
		VERBATIM)

	add_executable(${_example}
		"${CMAKE_CURRENT_BINARY_DIR}/${_example}.cpp")
endforeach()

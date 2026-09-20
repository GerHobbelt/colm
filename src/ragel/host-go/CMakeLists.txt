ragel_host(ragel-go rlparseGo "rlhcGo" "rlhc-go.lm")

if(COLM_INSTALL_RAGEL)
	install(FILES out-go.lm
		DESTINATION "${CMAKE_INSTALL_DATADIR}")
endif()

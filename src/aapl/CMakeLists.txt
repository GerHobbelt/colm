#
# aapl: a header-only template library. The installed libfsm headers include
# it, so it goes out with either half of the suite.
#
if(COLM_INSTALL_COLM OR COLM_INSTALL_RAGEL)
	install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/"
		DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/aapl"
		FILES_MATCHING PATTERN "*.h")
endif()

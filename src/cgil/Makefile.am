SUBDIRS = test

CGIL_FILES = ril.lm rlhc-main.lm \
	rlhc-c.lm rlhc-csharp.lm rlhc-go.lm rlhc-js.lm rlhc-ruby.lm \
	rlhc-crack.lm rlhc-d.lm rlhc-java.lm rlhc-julia.lm rlhc-ocaml.lm rlhc-rust.lm \
	rlhc-zig.lm

# The cgil sources translate ril, the intermediate code generation language
# emitted by libfsm, into the host languages. They are used only by ragel, so
# they go with it.
if INSTALL_RAGEL
pkgdata_DATA = $(CGIL_FILES)
endif

EXTRA_DIST = $(CGIL_FILES) CMakeLists.txt

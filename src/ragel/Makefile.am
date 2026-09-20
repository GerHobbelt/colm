SUBDIRS = . host-ruby host-asm host-julia host-ocaml host-c \
	host-d host-csharp host-go host-java host-rust host-crack host-js \
	host-zig

# nodist_pkginclude_HEADERS = config.h

# libragel contains the parse tree and other parsing support code. Everything
# except the reducers, which are specific to the frontends.
#
# This is the ragel half of the suite. With --disable-install-ragel it is all
# still built, so it can be tested from the build tree, but none of it is
# installed.
if INSTALL_RAGEL
lib_LTLIBRARIES = libragel.la
bin_PROGRAMS = ragel
data_DATA = ragel.lm
else
noinst_LTLIBRARIES = libragel.la
noinst_PROGRAMS = ragel
endif

#
# libragel: ragel program minus host-specific code
#
libragel_la_CPPFLAGS = -I$(top_srcdir)/src/aapl $(LIBFSM_CPPFLAGS) $(LIBCOLM_CPPFLAGS) \
	-DBINDIR='"@bindir@"'

dist_libragel_la_SOURCES = \
	parsedata.h parsetree.h inputdata.h pcheck.h reducer.h rlscan.h load.h \
	nragel.h \
	parsetree.cc longest.cc parsedata.cc inputdata.cc load.cc reducer.cc \
	ncommon.cc allocgen.cc

libragel_la_LIBADD = $(LIBFSM_LA) $(LIBCOLM_LA)

if INSTALL_RAGEL
libragel_la_LDFLAGS = -no-undefined

if LINKER_NO_UNDEFINED
libragel_la_LDFLAGS += -Wl,--no-undefined
endif
endif

#
# ragel program.
#
ragel_CPPFLAGS = -I$(top_srcdir)/src/aapl $(LIBFSM_CPPFLAGS) $(LIBCOLM_CPPFLAGS)

dist_ragel_SOURCES = \
	main.cc

nodist_ragel_SOURCES = \
	parse.c rlreduce.cc

ragel_LDADD = $(LIBFSM_LA) $(LIBCOLM_LA) libragel.la
ragel_DEPENDENCIES = $(LIBFSM_LA) $(LIBCOLM_LA) libragel.la

BUILT_SOURCES = \
	version.h \
	parse.c rlreduce.cc

if WITH_RAGEL_KELBT
nodist_ragel_SOURCES += \
	rlscan.cc rlparse.cc rlparse.h 

BUILT_SOURCES += \
	rlscan.cc rlparse.cc rlparse.h 
endif

version.h: Makefile
	echo '#define RAGEL_VERSION "@RAGEL_VERSION@"' > version.h
	echo '#define RAGEL_PUBDATE "@RAGEL_PUBDATE@"' >> version.h

EXTRA_DIST = \
	CMakeLists.txt \
	version.h.cmake.in \
	ragel-config.cmake.in \
	$(RAGEL_LM) \
	rlscan.rl \
	rlparse.kh \
	rlparse.kl

CLEANFILES = parse.c commit.cc rlhc.c

if WITH_RAGEL_KELBT
CLEANFILES += rlscan.cc rlparse.cc rlparse.h 
endif

RAGEL_LM = \
	rlparse.lm \
	ragel.lm \
	rlreduce.lm

parse.pack: $(RAGEL_LM) $(COLM) $(COLM_WRAP)
	$(COLM_WRAP) -c -b rlparseC -o $@ -p parse.c -m rlreduce.cc $<

rlreduce.cc: parse.pack
	$(COLM_WRAP) -o $@ $<

parse.c: parse.pack
	$(COLM_WRAP) -o $@ $<

if WITH_RAGEL_KELBT

# This dependency comes from the import of the parser defines into the scanner.
rlscan.cc: rlparse.h
inputdata.cc: rlparse.h

ragel-rlscan.$(OBJEXT): rlscan.cc

rlscan.cc: rlscan.rl
	$(RAGEL) -G2 -I$(builddir) -o $@ $<

rlparse.h: rlparse.kh
	$(KELBT) -o $@ $<

rlparse.cc: rlparse.kl rlparse.kh
	$(KELBT) -o $@ $<

endif

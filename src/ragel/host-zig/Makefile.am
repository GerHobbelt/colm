bin_PROGRAMS = ragel-zig

ragel_zig_CPPFLAGS = -I$(top_srcdir)/src/aapl -I$(top_srcdir)/src/ragel -I$(top_srcdir)/src/include

dist_ragel_zig_SOURCES = main.cc rlhc.c

nodist_ragel_zig_SOURCES = \
	rlparse.c rlreduce.cc

ragel_zig_LDADD = $(LIBFSM_LA) $(LIBCOLM_LA) ../libragel.la

BUILT_SOURCES = rlparse.c rlreduce.cc rlhc.c

EXTRA_DIST = rlparse.lm

LM_DEPS = ../ragel.lm ../rlreduce.lm

rlparse.pack: rlparse.lm $(COLM) $(COLM_WRAP) $(LM_DEPS)
	$(COLM_WRAP) -c -I .. -b rlparseZig -o $@ -p rlparse.c -m rlreduce.cc $<

rlparse.c: rlparse.pack
	$(COLM_WRAP) -o $@ $<

rlreduce.cc: rlparse.pack
	$(COLM_WRAP) -o $@ $<

rlhc.c: $(COLM_SHARE)/rlhc-zig.lm $(COLM_SHARE)/ril.lm $(COLM) $(COLM_WRAP)
	$(COLM) -c -I $(COLM_SHARE) -b rlhcZig -o $@ $<

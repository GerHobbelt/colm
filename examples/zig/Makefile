RAGEL_ZIG = ragel-zig
ZIG = zig

# Zig has no goto, but ragel-zig lowers ragel's goto backends onto a labeled
# switch, so every code style works. -G2 is the fastest.
STYLE ?= -G2

ZIG_RAGEL_SOURCES = $(wildcard *.rl)
EXECUTABLES = $(ZIG_RAGEL_SOURCES:.rl=_zig)
INTERMEDIATES = $(ZIG_RAGEL_SOURCES:.rl=.zig)
KEEP_INTERMEDIATES ?= 0

ifneq ($(KEEP_INTERMEDIATES),0)
    $(info [BUILD] Keeping intermediate sources)
    .PRECIOUS: %.zig
else
    $(info [BUILD] Not keeping intermediate sources)
    .INTERMEDIATE: %.zig
endif

$(info [BUILD] Executables: $(EXECUTABLES))

all: $(EXECUTABLES)

clean:
	@echo [CLEAN]
	find . -name '*.o' | xargs -n 1 rm -f
	find . -name '*.ri' | xargs -n 1 rm -f
	rm -f $(EXECUTABLES)
	rm -f $(INTERMEDIATES)

%_zig: %.zig
	@echo [ZIG] $@
	@$(ZIG) build-exe $< -femit-bin=$@ -OReleaseFast

%.zig: %.rl
	@echo [RAGEL] $@
	@$(RAGEL_ZIG) $(STYLE) $< -o $*.zig

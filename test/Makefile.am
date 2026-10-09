SUBDIRS = harness aapl.d cgil.d colm.d ragel.d rlhc.d rlparse.d trans.d .

EXTRA_DIST = dist.sh

# Every suite runs through the one harness, after the suites have built what
# it needs. The harness takes its parallelism from MAKEFLAGS.
check-local:
	harness/harness

# The manual suite's cases are the examples in doc/colm/code. The harness puts
# its results in manual/working here.
clean-local:
	rm -Rf manual

dist: dist.sh
	@$(top_srcdir)/sedsubst $< $@ -w,+x $(SED_SUBST)

ALL_TESTS = $(shell ls t/*.t)

all:

test: $(ALL_TESTS)

$(ALL_TESTS): force
	perl6 $@

force:

BASE=../lib/TestML/Parser

$(BASE)/Grammar.pm6: grammar.yaml grammar.pl Makefile $(BASE)
	perl grammar.pl $< > $@

$(BASE):
	mkdir -p $@

clean:
	rm -fr $(BASE)

.PHONY: force
SRC = ../../../testml-tml
ALL = $(shell ls $(SRC) | grep '\.tml$$')

all: $(ALL)

$(ALL): force
	cp $(SRC)/$@ $@

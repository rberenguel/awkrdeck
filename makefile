PANDOC := pandoc -t revealjs --metadata pagetitle="..." -H dark.css -V width=\"100%\" -V height=\"90%\" -V transition=\"none\" --slide-level 1

SOURCE_MARKDOWN := $(wildcard *.md)
TARGET_MARKDOWN := $(SOURCE_MARKDOWN:%.md=%.md_2)
PANDOC_MARKDOWN := $(SOURCE_MARKDOWN:%.md=%.html)

AWK_FLAGS :=
PANDOC_FLAGS := -V revealjs-url=https://revealjs.com

.PHONY: html clean serve stop

all: $(PANDOC_MARKDOWN)

verbose: AWK_FLAGS += -v show_rules=1
verbose: all

local: PANDOC_FLAGS =
local: all

$(TARGET_MARKDOWN): %.md_2 : %.md $(SOURCE_MARKDOWN)
	AWKPATH=. gawk  -f converter.awk $(AWK_FLAGS) $<  > $@

$(PANDOC_MARKDOWN): %.html : %.md_2 $(TARGET_MARKDOWN)
	$(PANDOC) -s $< -o $@

html: $(PANDOC_MARKDOWN)

clean:
	rm *.md_2; rm *.html

serve: server.PID all

server.PID:
	python3 -m http.server & echo $$! > server.PID;

stop:
	kill `cat server.PID` && rm server.PID


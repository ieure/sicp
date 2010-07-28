CONTENT := $(shell find src -type f -not -name .DS_Store)
XML     := $(shell find src -type f -name \*html)

all: sicp.epub

sicp.epub: $(CONTENT)
	cd src && zip -r ../$@ $(^:src/%=%)

check:
	xmllint --noout $(XML)

clean:
	rm -f sicp.epub

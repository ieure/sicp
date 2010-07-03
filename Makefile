all: sicp.epub

sicp.epub:
	cd src && zip -r ../$@ *

clean:
	rm -f sicp.epub
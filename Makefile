all: sicp.epub

sicp.epub:
	cd src && zip -r ../$@ *

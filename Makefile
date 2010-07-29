
LATEX_DIR := src/latex
IMAGES_DIR := src/OEBPS/images
BUILD_DIR := $(LATEX_DIR)/build
#
# TEX_FILES becomes a list of *.tex files that are in LATEX_DIR
# SVG_FILES becomes the list of what would be the equivalent *.svg
# file names in IMAGES_DIR (even if they don't exist yet)
#
TEX_FILES := $(wildcard $(LATEX_DIR)/*.tex)
SVG_FILES := $(patsubst %.tex,%.svg,$(subst $(LATEX_DIR),$(IMAGES_DIR),$(TEX_FILES)))


.PHONY : clean tex tex_setup

all: sicp.epub

sicp.epub:
	cd src && zip -r ../$@ *

$(IMAGES_DIR)/%.svg: tex_setup $(LATEX_DIR)/%.tex
	pdflatex -output-dir $(BUILD_DIR)/ $(LATEX_DIR)/$*.tex
	pdfcrop --clip $(BUILD_DIR)/$*.pdf $(BUILD_DIR)/$*_cropped.pdf
	pdf2svg $(BUILD_DIR)/$*_cropped.pdf $@

tex_setup:
	mkdir -p $(BUILD_DIR)

tex: $(SVG_FILES)

clean:
	rm -f sicp.epub
	-rm -rf $(BUILD_DIR)
	-rm -f $(SVG_FILES)

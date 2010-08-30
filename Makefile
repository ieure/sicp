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
GIF_FILES := $(patsubst %.tex,%.gif,$(subst $(LATEX_DIR),$(IMAGES_DIR),$(TEX_FILES)))
CONTENT := $(shell find src -type f -not -name .DS_Store)
XML     := $(shell find src -type f -name \*html)


.PHONY : clean tex

all: sicp.epub

sicp.epub: $(CONTENT)
	cd src && zip -r ../$@ $(^:src/%=%)

check:
	xmllint --noout $(XML)

$(BUILD_DIR)/%_cropped.pdf: $(BUILD_DIR) $(LATEX_DIR)/%.tex
	cd $(LATEX_DIR); pdflatex -output-dir ./build ./$*.tex
	pdfcrop --clip $(BUILD_DIR)/$*.pdf $(BUILD_DIR)/$*_cropped.pdf

$(IMAGES_DIR)/%.svg: $(BUILD_DIR)/%_cropped.pdf
	convert $(BUILD_DIR)/$*_cropped.pdf $@

$(IMAGES_DIR)/%.gif: $(BUILD_DIR)/%_cropped.pdf
	convert $(BUILD_DIR)/$*_cropped.pdf $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

tex: $(SVG_FILES) $(GIF_FILES)

clean:
	rm -rf sicp.epub $(BUILD_DIR) $(SVG_FILES) $(GIF_FILES)

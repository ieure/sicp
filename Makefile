# TODO: Add potrace for gif -> svg conversion; convert still gives
#       rasterized images

LATEX_DIR := src/latex
IMAGES_DIR := src/OEBPS/images
BUILD_DIR := $(LATEX_DIR)/build
HUGE_MARK := $(BUILD_DIR)/huge.mark
NORMAL_MARK := $(BUILD_DIR)/normal.mark


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
	echo -n application/epub+zip > src/mimetype
	cd src && zip -0Xq ../$@ mimetype
	rm src/mimetype
	cd src && zip -Xr9D ../$@ $(^:src/%=%)

check:
	xmllint --noout $(XML)


$(BUILD_DIR)/huge/%_cropped.pdf: $(BUILD_DIR)/huge/ $(LATEX_DIR)/%.tex
	sed 's/\\sicpsize}{\\fontsize{16}{18}/\\sicpsize}{\\fontsize{200}{220}/' < $(LATEX_DIR)/sicpstyle.sty > $(LATEX_DIR)/sicpstyle2.sty
	mv $(LATEX_DIR)/sicpstyle2.sty $(LATEX_DIR)/sicpstyle.sty
	cd $(LATEX_DIR) && pdflatex -output-dir ./build/huge/ ./$*.tex
	pdfcrop --clip $(BUILD_DIR)/huge/$*.pdf $(BUILD_DIR)/huge/$*_cropped.pdf
	rm -f $(HUGE_MARK)

$(BUILD_DIR)/huge/%.pbm: $(BUILD_DIR)/huge/%_cropped.pdf
	convert $(BUILD_DIR)/huge/$*_cropped.pdf $@

$(IMAGES_DIR)/%.svg: $(BUILD_DIR)/huge/%.pbm
	potrace -s -o $@ $(BUILD_DIR)/huge/$*.pbm


$(BUILD_DIR)/%_cropped.pdf: $(BUILD_DIR) $(LATEX_DIR)/%.tex
	sed 's/\\sicpsize}{\\fontsize{200}{220}/\\sicpsize}{\\fontsize{16}{18}/' < $(LATEX_DIR)/sicpstyle.sty > $(LATEX_DIR)/sicpstyle2.sty
	mv $(LATEX_DIR)/sicpstyle2.sty $(LATEX_DIR)/sicpstyle.sty
	cd $(LATEX_DIR) && pdflatex -output-dir ./build ./$*.tex
	pdfcrop --clip $(BUILD_DIR)/$*.pdf $(BUILD_DIR)/$*_cropped.pdf
	rm -f $(NORMAL_MARK)

$(IMAGES_DIR)/%.gif: $(BUILD_DIR)/%_cropped.pdf
	convert $(BUILD_DIR)/$*_cropped.pdf $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/huge/:
	mkdir -p $(BUILD_DIR)/huge/


svg: $(SVG_FILES)

gif: $(GIF_FILES)

clean:
	rm -rf sicp.epub $(BUILD_DIR) $(SVG_FILES) $(GIF_FILES)

#! /bin/bash

SRC_DIR="src/OEBPS/"
IMAGE_SRC="http://mitpress.mit.edu/sicp/full-text/book/"

for img in `grep "media-type=\"image/" ${SRC_DIR}content.opf | sed "s/.*href=\"\([^\"]*\)\".*/\1/"`; do
    destination_file="${SRC_DIR}${img}"
    if [ ! -e "${destination_file}" ]; then
	image_file=`echo "${img}" | sed "s/^images\/\(.*\)/\1/"`
	echo ${destination_file}
	curl -s -o "${destination_file}" "${IMAGE_SRC}${image_file}"
    fi
done

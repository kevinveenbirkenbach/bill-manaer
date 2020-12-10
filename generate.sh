#!/bin/bash
# @see https://faceted.wordpress.com/2010/07/11/how-to-extract-text-from-pdf-files-using-poppler-and-gocr-on-ubuntu/
# sudo pacman -Syyu tesseract-data-deu tesseract-data-en tesseract
if [ -z "$1" ]
  then
		echo "You need to define an working directory" && exit 1;
fi
TMP_FOLDER="$(mktemp -d)/"
ORIGIN_FOLDER="$1/origin/";
OUTPUT_FOLDER="$1/readable/";
for origin_file in "$ORIGIN_FOLDER"*.*; do
	if [ "$(head -c 4 "$origin_file")" = "%PDF" ]; then
		tmp_file="$TMP_FOLDER$(basename "$origin_file")"
		echo "Generating $tmp_file..."
		pdfimages "$origin_file" "$tmp_file"
	else
		cp "$origin_file" "$TMP_FOLDER"
	fi
done
for tesseract_input_file in "$TMP_FOLDER"*.*; do
	txt_output_file_without_suffix="$OUTPUT_FOLDER$(basename "$origin_file")";
	echo "Generating $txt_output_file_without_suffix.txt..."
	tesseract -l deu "$tesseract_input_file" "$txt_output_file_without_suffix";
	echo "file content:"
	cat "$txt_output_file_without_suffix.txt"
done

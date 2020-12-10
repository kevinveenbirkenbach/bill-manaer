#!/bin/bash
# @see https://faceted.wordpress.com/2010/07/11/how-to-extract-text-from-pdf-files-using-poppler-and-gocr-on-ubuntu/
# sudo pacman -Syyu tesseract-data-deu tesseract-data-en tesseract
PPM_FOLDER="$PWD/ppm/";
PDF_FOLDER="$PWD/pdf/";
TXT_FOLDER="$PWD/txt/";
for pdf_origin_file in $PDF_FOLDER*.*; do
	ppm_output_file="$PPM_FOLDER$(basename $pdf_origin_file)"
	echo "Generating $ppm_output_file..."
	pdfimages $pdf_origin_file $ppm_output_file
done
for ppm_origin_file in $PPM_FOLDER*.ppm; do
	txt_output_file_without_suffix="$TXT_FOLDER$(basename $ppm_origin_file)";
	echo "Generating $txt_output_file_without_suffix.txt..."
	tesseract -l deu+eng "$ppm_origin_file" "$txt_output_file_without_suffix";
	echo "file content:"
	cat "$txt_output_file_without_suffix.txt"
done

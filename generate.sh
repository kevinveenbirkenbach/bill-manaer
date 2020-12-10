#!/bin/bash
# @author Kevin Veen-Birkenbach
# @param $1 Working directory
# @param $2 language
# @param $3 mode (update,initialize)
if [ -z "$2" ]
  then
		echo "You need to define an working directory and a language" && exit 1;
fi
if [ -z "$3" ]
  then
		MODE="initialize"
	else
		if [ "$3" != "update" ]
			then
				echo "Unknown option: $3" && exit 1
		fi
		MODE="$3"
fi
TMP_FOLDER="$(mktemp -d)/" &&
ORIGIN_FOLDER="$1/origin/" &&
OUTPUT_FOLDER="$1/generated/" || exit 1
if [ "$MODE" = "update" ]; then
	echo "Updating bills..."
else
	if [ "$(ls -A "$OUTPUT_FOLDER")" ]
		then
			echo "Cleaning up $OUTPUT_FOLDER..."
			rm -v "$OUTPUT_FOLDER"* || exit 1;
		else
			echo "$OUTPUT_FOLDER is allready cleaned up!"
		fi
fi
for origin_file in "$ORIGIN_FOLDER"*.*; do
	if [ "$MODE" = "update" ] && [ "$(find "$OUTPUT_FOLDER" -name "$(basename "$origin_file")"* -printf '.' | wc -m)" -lt "1" ] || [ "$MODE" = "initialize" ]; then
		if [ "$(head -c 4 "$origin_file")" = "%PDF" ]; then
			tmp_file="$TMP_FOLDER$(basename "$origin_file")"
      txt_output_file="$OUTPUT_FOLDER$(basename "$origin_file").txt"
      pdftotext "$origin_file" "$txt_output_file"
      content="$(cat "$txt_output_file")"
      if [ ${#content} -gt "9" ]
        then
          echo "Text successfully extracted to $txt_output_file:"
          cat "$txt_output_file"
        else
          rm -v "$txt_output_file"
          echo "Extract images..."
          pdfimages "$origin_file" "$tmp_file"
      fi
		else
			cp -v "$origin_file" "$TMP_FOLDER"
		fi
	else
		echo "Skipped $origin_file..."
	fi
done
if [ "$(ls -A "$TMP_FOLDER")" ]
	then
		for tesseract_input_file in "$TMP_FOLDER"*.*; do
			txt_output_file_without_suffix="$OUTPUT_FOLDER$(basename "$tesseract_input_file")";
			echo "Generating $txt_output_file_without_suffix.txt..."
			tesseract -l "$2" "$tesseract_input_file" "$txt_output_file_without_suffix";
			echo "file content:"
			cat "$txt_output_file_without_suffix.txt"
		done
	else
		echo "Skipped text generation because $TMP_FOLDER is empty..."
fi
echo "Cleanup..." && rm -v "$TMP_FOLDER"* && rmdir -v "$TMP_FOLDER";

#!/bin/bash

#====================================================================================================================
# Author: Alfred Hou
# E-mail: 825526231@qq.com
# Any question can send the e-mail to me
# Time: 2024/01/10
#====================================================================================================================


# Check input parameters
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <main_folder> <output_folder>"
    exit 1
fi

main_folder="$1"
output_folder="$2"

# Check input folder exist or not
if [ ! -d "$main_folder" ]; then
    echo "Error: Main folder does not exist."
    exit 1
fi

# Create output folder
mkdir -p "$output_folder"

# Create an array to save all files with same name
declare -A merged_files

# Deal with all sub_folders under main folder
for folder in "$main_folder"/*; do
    if [ -d "$folder" ]; then
        # Get sub_folder name (without path)
        sub_folder_name=$(basename "$folder")

        # Deal with all rename_consensus folder
        consensus_folder="$folder/rename_consensus"
        if [ -d "$consensus_folder" ]; then
            # Deal with all files in rename_consensus folder
            for file in "$consensus_folder"/*.fa; do
                if [ -f "$file" ]; then
                    # Get filenames (without path)
                    file_name=$(basename "$file")

                    # if there are already files with the same filename in the array, merge the contents
                    if [ -n "${merged_files[$file_name]}" ]; then
                        cat "$file" >> "${merged_files[$file_name]}"
                    else
                        # else, adding the file contents into the array
                        merged_files["$file_name"]=$file
                    fi
                fi
            done
        fi
    fi
done

# Write the merged files to output folder
for merged_file in "${!merged_files[@]}"; do
    output_file="$output_folder/$merged_file"
    cat "${merged_files[$merged_file]}" > "$output_file"
    echo "Merged files into $output_file"
done

mkdir -p "$output_folder"/raw_seq
for fa in "$output_folder"/*.fa ; do
	file_name=$(basename "$fa")
	seqkit rmdup -n "$fa" -o "$output_folder"/raw_seq/"$file_name"
done
rm -rf "$output_folder"/*.fa
echo "Merge all gene pairs were done!"

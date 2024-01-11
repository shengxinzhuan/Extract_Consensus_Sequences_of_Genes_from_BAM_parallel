#!/bin/bash

#====================================================================================================================
# Author: Alfred Hou
# E-mail: 825526231@qq.com
# Any question can send the e-mail to me
# Time: 2024/01/11
#====================================================================================================================


if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_folder> <output_folder> <threshold_percentage>"
    exit 1
fi

input_folder="$1"
output_folder="$2"
threshold_percentage="$3"
fail_folder="$output_folder/fail_seq"
filtered_folder="$output_folder/filtered_seq"

# Check if input folder exists
if [ ! -d "$input_folder" ]; then
    echo "Error: Input folder does not exist."
    exit 1
fi

# Create output folders
mkdir -p "$fail_folder"
mkdir -p "$filtered_folder"
rm -rf "$fail_folder"/*
rm -rf "$filtered_folder"/*
# Iterate over fasta files in the input folder
for file in "$input_folder"/*.fa; do
    filename=$(basename "$file")
    stats_file="${file%.fa}.stats"

    # Generate stats file using seqkit
    seqkit fx2tab -H -n -i -B A -B T -B C -B G -B N "$file" > "$stats_file"

    awk -v thredshold="$threshold_percentage" -v file="$file" -v fail_folder="$fail_folder" 'NR > 1{ if ($6 >= thredshold) print "cp "file" "fail_folder }' "$stats_file" | sort | uniq >> "$input_folder"/job_fail
    awk -v thredshold="$threshold_percentage" -v file="$file" -v filtered_folder="$filtered_folder" 'NR > 1{ max = ($6 > max) ? $6 : max } END { if (max < thredshold ) print "cp "file" "filtered_folder }' "$stats_file" | sort | uniq >>  "$input_folder"/job_filter

done

bash "$input_folder"/job_filter
bash "$input_folder"/job_fail

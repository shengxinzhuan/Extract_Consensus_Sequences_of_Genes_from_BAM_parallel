#!/bin/bash

#====================================================================================================================
# Author: Alfred Hou
# E-mail: 825526231@qq.com
# Any question can send the e-mail to me
# Time: 2024/01/10
#====================================================================================================================


# Check parameters
if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <input_folder> <replace_name>"
	exit 1
fi

input_folder="$1"
specified_name="$2"

# Check input folder 
if [ ! -d "$input_folder" ]; then
	echo "Error: Input folder does not exist !"
	exit 1
fi

# Create output folder
mkdir -p "$input_folder"/../rename_consensus/

# rename all consensus fasta
for fasta_file in "$input_folder"/*.fa ;  do
	if [ -f "$fasta_file" ]; then
		# get base name of fasta file (without path)
		base_name=$(basename -s .fa "$fasta_file")

		# replace sequence name using awk
		awk -v specified_name="$specified_name" '/^>/{if (NR > 1) print ""; print ">" specified_name; next}1' "$fasta_file" > "$input_folder"/../rename_consensus/"$base_name".rename.fa
		echo "Updated sequence names in $fasta_file"

	fi
done

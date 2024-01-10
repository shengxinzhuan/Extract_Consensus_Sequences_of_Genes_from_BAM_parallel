#!/bin/bash

#====================================================================================================================
# Author: Alfred Hou
# E-mail: 825526231@qq.com
# Any question can send the e-mail to me
# Time: 2024/01/10
#====================================================================================================================


# Check input parameter
if [ "$#" -ne 4 ]; then
	echo "Usage: $0 <bam_file> <bed_file> <output_dir> <threads>"
	exit 1
fi

# Set input file
bam_file="$1"
bed_file="$2"
output_dir="$3"
threads="$4"

# Create output directory
mkdir -p "$output_dir"

# split bed files
awk '{print > "'$output_dir'/"$4".bed"}' "$bed_file"

# Create file to save commands
commands_file1="${output_dir}/job_extract.txt"
> "$commands_file1" # remove old strings

commands_file2="${output_dir}/job_consensus.txt"
> "$commands_file2" # remove old strings

# extract bam region from bed
for file in "$output_dir"/*.bed ; do
	gene_name=$(awk '{print $4; exit}' "$file") # get gene name
	subbam_name="$output_dir/${gene_name}_subset.bam"
	consensus_name="$output_dir/${gene_name}_consensus.fa"
	echo "samtools view -hb -L $file $bam_file > $subbam_name" >> "$commands_file1"
	echo "samtools consensus --show-ins yes --show-del yes $subbam_name -o $consensus_name" >> "$commands_file2"
done

echo "Start Extract ~"
parallel -j "$threads" < "$commands_file1"
mkdir -p "$output_dir"/raw_bed
mv "$output_dir"/*.bed "$output_dir"/raw_bed/
echo "Extract Finish !"

echo "Start generate consensus fasta"

parallel -j "$threads" < "$commands_file2"
mkdir -p "$output_dir"/sub_bam
mv "$output_dir"/*.bam "$output_dir"/sub_bam/
echo "Consensus Fasta Finish !"

# replace all "*" to "N"
commands_file3="${output_dir}/job_replace_N.txt"
> "$commands_file3" # remove old strings
echo "sed -i 's/\*/N/g' ${output_dir}/*.fa" >> "$commands_file3"

parallel -j "$threads" < "$commands_file3"
mkdir -p "$output_dir"/raw_consensus
mv "$output_dir"/*.fa "$output_dir"/raw_consensus/

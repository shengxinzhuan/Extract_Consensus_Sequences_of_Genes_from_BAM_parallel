#!/bin/bash

# Check parameters
if [ "$#" -ne 1 ]; then
        echo "Usage: $0 <input_folder>"
        exit 1
fi

input_folder="$1"

# Check input folder 
if [ ! -d "$input_folder" ]; then
        echo "Error: Input folder does not exist !"
        exit 1
fi

# Create output folder
mkdir -p "$input_folder"/../merge_gene_and_topo/
rm -rf "$input_folder"/../merge_gene_and_topo/*
for tree in "$input_folder"/*.tree;
do 
	gene_name=$(basename "$tree" | cut -d. -f1)
	awk -v gene="$gene_name" '{print gene "\t" $0}' "$tree" > "$input_folder"/../merge_gene_and_topo/"$gene_name".gene_topo.txt
done



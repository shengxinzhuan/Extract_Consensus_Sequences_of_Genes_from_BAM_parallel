# Extract_Consensus_Sequences_of_Genes_from_BAM_parallel (developing)
This is a series of scripts on the rapid construction of target interval consensus sequences from bam files and the rapid construction of phylogenetic trees as well as visualisations
![image](https://github.com/shengxinzhuan/Extract_Consensus_Sequences_of_Genes_from_BAM_parallel/blob/main/extract_consensus.jpg)
# Based software (all you can install by conda or docker)
samtools<br />
parallel<br />
seqkit<br />
# Usage
The completed part consists of three scripts: generate_consensus_fasta_from_bam.sh, rename_fasta.sh, and merge_all_sample_gene_pair.sh. Their functionalities are as follows:
## generate_consensus_fasta_from_bam.sh
Usage: bash generate_consensus_fasta_from_bam.sh <bam_file> <bed_file> <output_dir> <threads> <br />
The purpose of this script is to extract subsets of a given BAM file based on a BED file, resulting in several smaller BAM files. Subsequently, the script utilizes the samtools consensus module to build consensus FASTA sequences from the extracted BAM files. Notably, the gene names in the fourth column of the BED file will be considered as the filenames for the output consensus FASTA files.<br />
  The sequencing types for BAM files can include WGS (Whole Genome Sequencing), RNA-Seq (RNA Sequencing), RAD-Seq (Restriction site-Associated DNA Sequencing), etc. It is recommended to use BAM files processed with Picard's MarkDuplicates for resequencing data.<br />
  The BED file consists of four columns: the first column represents the chromosome name (it's acceptable for non-chromosomal levels), the second column denotes the starting coordinate (please note the coordinate difference between Samtools and Bedtools), the third column indicates the ending coordinate, and the fourth column contains the gene name (you are free to name it according to your preference, but typically, it aligns with the names found in GFF annotations). The delimiter used is the Tab key.<br />
  The output_dir is the name of the output directory. If you are working with population data or large samples, it is recommended to make it consistent with the sample names in the BAM files to facilitate subsequent evolution analysis.<br />
  threads controls the number of parallel extractions. The choice of this value depends on personal preference.<br />
## rename_fasta.sh
Usage: bash rename_fasta.sh <input_folder> <replace_name><br />
This script renames the extracted consensus FASTA sequences to a standardized species name or sample identifier. The output of the script is a rename_consensus folder generated in the same directory as the specified folder. Inside this folder, you will find the consensus FASTA sequences with their names modified accordingly.<br />
## merge_all_sample_gene_pair.sh
Usage: bash merge_all_sample_gene_pair.sh <main_folder> <output_folder><br />
The purpose of this script is to merge consensus FASTA sequences obtained from several samples based on gene names, for subsequent single-gene tree construction. The basic logic involves traversing all folders in the current directory, identifying the rename_consensus folder within each folder. It then combines all consensus FASTA sequences with identical gene names across samples into a new FASTA file, and outputs it to a new folder named raw_seq within the same directory.<br />

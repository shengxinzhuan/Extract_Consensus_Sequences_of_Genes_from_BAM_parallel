# Extract_Consensus_Sequences_of_Genes_from_BAM_parallel (developing)
This is a series of scripts on the rapid construction of target interval consensus sequences from bam files and the rapid construction of phylogenetic trees as well as visualisations
![image](https://github.com/shengxinzhuan/Extract_Consensus_Sequences_of_Genes_from_BAM_parallel/blob/main/extract_consensus.jpg)
# Based software (all you can install by conda or docker)
samtools<br />
parallel<br />
seqkit<br />
# Usage
The completed part consists of four scripts: generate_consensus_fasta_from_bam.sh, rename_fasta.sh, merge_all_sample_gene_pair.sh, and filtered_fasta.sh. Their functionalities are as follows:
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
## filtered_fasta.sh
Usage: bash filtered_fasta.sh <input_folder> <output_folder> <threshold_percentage><br />
Due to issues related to genetic relationships or sequencing coverage, certain regions in the consensus FASTA sequences inevitably contain nucleotides represented by 'N'. This can affect the accuracy of our phylogenetic tree construction. Therefore, it is necessary to filter out sequences that exceed a certain threshold. <br />
The script requires three parameters: the path to the folder containing consensus FASTA files (it will traverse all files with the *.fa suffix in the specified directory), the path to the output folder (where two folders, 'fail_seq' and 'filtered_seq', will be created to store sequences exceeding or below a certain threshold), and the percentage threshold for the proportion of 'N' bases in the sequences (sequences with a proportion exceeding this value will be filtered out; for example, inputting 70 means that if the proportion of 'N' bases in any sequence in 1.fa exceeds 70%, then 1.fa will be filtered out and not used as input for subsequent tree construction). <br />
The script logic involves traversing all *.fa files in the specified directory, utilizing seqkit's fx2tab to calculate the proportions of five bases (A, G, T, G, N) and generating a table with these proportions in the directory. Subsequently, by traversing this table, the script determines whether the proportion of 'N' bases in a sequence exceeds the set threshold. Sequences exceeding the threshold are copied to the 'fail_seq' folder, while sequences below the threshold are copied to the 'filtered_seq' folder.<br />
## Phylogenetic tree construction
This part is relatively straightforward and can be accomplished with a few shell for loops nested with parallel. Here's an example:<br />
```
# First, let's create a directory named "aln_seq".
mkdir -p aln_seq
# Next, navigate to the "filtered_seq" folder to perfrom sequence alignment.
# The software used for sequence alignment can be mafft, muscle, et al.
# In this case, we will use mafft
cd filtered_seq/
for i in *.fa; do echo "mafft $i > ../aln_seq/${i}" ; done > job_aln
parallel -j 10 < job_aln
cd ../
# After completing the sequence alignment, you can use tools like trimal or gblock to trim the sequences.
mkdir -p trim_seq
cd aln_seq/
for i in *.fa ; do echo "trimal -in $i -out ../trim_seq/${i} -nogaps -automated1" ; done > job_trim
parallel -j 10 < job_trim
# Finally, we move on to the tree-building step. Here, we will use raxml-ng with the GTR+F+I model. 
# Alternatively, you can use iqtree2 for automatic model selection and tree construction. 
# It is recommended to run these processes with a single thread to ensure reproducibility in tree construction.
for i in *.fa ; do echo "raxml-ng --all --msa $i --threads 1 --model GTR+F+I --bs-trees 1000 --outgroup OUT" ; done > job_raxml
parallel -j 10 < job_raxml
```
The obtained "bestTree" file represents the consensus FASTA tree-building result, while the support values can be found in the "support" file.<br />

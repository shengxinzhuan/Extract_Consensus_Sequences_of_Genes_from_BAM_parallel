# Extract_Consensus_Sequences_of_Genes_from_BAM_parallel (developing)
This is a series of scripts on the rapid construction of target interval consensus sequences from bam files and the rapid construction of phylogenetic trees as well as visualisations
![image](https://github.com/shengxinzhuan/Extract_Consensus_Sequences_of_Genes_from_BAM_parallel/blob/main/extract_consensus.jpg)
# Based software (all you can install by conda or docker)
samtools<br />
parallel<br />
seqkit<br />
mafft or muscle <br />
trimal or gblock <br />
ete3 (python package, verison:3.1.3, which can be install using pip)<br />
iqtree2 or raxml-ng <br />
ggplot2<br />
dplyr<br />
# Usage
The completed part consists of four scripts: generate_consensus_fasta_from_bam.sh, rename_fasta.sh, merge_all_sample_gene_pair.sh, and filtered_fasta.sh. Their functionalities are as follows:
## generate_consensus_fasta_from_bam.sh
Usage: bash generate_consensus_fasta_from_bam.sh <bam_file> <bed_file> <output_dir> <threads> <br />
The purpose of this script is to extract subsets of a given BAM file based on a BED file, resulting in several smaller BAM files. Subsequently, the script utilizes the samtools consensus module to build consensus FASTA sequences from the extracted BAM files. Notably, the gene names in the fourth column of the BED file will be considered as the filenames for the output consensus FASTA files.<br />
  The sequencing types for BAM files can include WGS (Whole Genome Sequencing), RNA-Seq (RNA Sequencing), RAD-Seq (Restriction site-Associated DNA Sequencing), etc. It is recommended to use BAM files processed with Picard's MarkDuplicates for resequencing data.<br />
  The BED file consists of four columns: the first column represents the chromosome name (it's acceptable for non-chromosomal levels), the second column denotes the starting coordinate (please note the coordinate difference between Samtools and Bedtools), the third column indicates the ending coordinate, and the fourth column contains the gene name (you are free to name it according to your preference, but typically, it aligns with the names found in GFF annotations). The delimiter used is the Tab key.<br />
  The output_dir is the name of the output directory. If you are working with population data or large samples, it is recommended to make it consistent with the sample names in the BAM files to facilitate subsequent evolution analysis.<br />
  threads controls the number of parallel extractions. The choice of this value depends on personal preference.<br />
```
# Here, it's recommended to use the sample.mkdup.bam obtained through the workflow involving bwa-samtools-picard
# The recommended pipeline can be readed in this page: https://ming-lian.github.io/2019/02/08/call-snp/
# The bed file refers to a BED  file extracted according to one's specific needs (it can be genes, exon, intron, or TE structure).
# bed file format
# <chr>\t<start>\t<end>\t<gene_name>

# Demo Usage:
bash generate_consensus_fasta_from_bam.sh sample.mkdup.bam gene.bed sample_consensus_dir 30

# Demo Output:
|-sample_consensus_dir/ # output_folder
|    |--raw_bed/ # The bed files split from the input bed file
|    |--sub_bam/ # The region bam split from input bam and bed file
|    |--raw_consensus/ # The consensus fasta generate from region bam
|--job_extract.txt # The commandline for extract region bam
|--job_consensus.txt # The commandline for generate consensus fasta
|--job_replace_N.txt # The commandline to replace "*" into "N" for consensus fasta
```
## rename_fasta.sh
Usage: bash rename_fasta.sh <input_folder> <replace_name><br />
This script renames the extracted consensus FASTA sequences to a standardized species name or sample identifier. The output of the script is a rename_consensus folder generated in the same directory as the specified folder. Inside this folder, you will find the consensus FASTA sequences with their names modified accordingly.<br />
```
# Demo Usage:
bash rename_fasta.sh sample_consensus_dir/raw_consensus sample_name

# The difference before and after using this method is that the sequence names in the originally extracted FASTA files (which are typically chromosome numbers or scaffold IDs by default) will be replaced with a uniform name.
# >chr1\nNNNNNNNNN ----> >sample_name\nNNNNNNNN
```
## merge_all_sample_gene_pair.sh
Usage: bash merge_all_sample_gene_pair.sh <main_folder> <output_folder><br />
The purpose of this script is to merge consensus FASTA sequences obtained from several samples based on gene names, for subsequent single-gene tree construction. The basic logic involves traversing all folders in the current directory, identifying the rename_consensus folder within each folder. It then combines all consensus FASTA sequences with identical gene names across samples into a new FASTA file, and outputs it to a new folder named raw_seq within the same directory.<br />
```
# Demo Usage:
bash merge_all_sample_gene_pair.sh total_sample_folder merge_sample_folder

input folder:
|-total_sample_folder/
|--sample1/
|    |--rename_consensus/
|--sample2/
|    |--rename_consensus/
|--sample3/
|    |--rename_consensus/
|--sample4/
|    |--rename_consensus/

output folder:
|-merge_sample_folder/
|      |--raw_seq/
```
## filtered_fasta.sh
Usage: bash filtered_fasta.sh <input_folder> <output_folder> <threshold_percentage><br />
Due to issues related to genetic relationships or sequencing coverage, certain regions in the consensus FASTA sequences inevitably contain nucleotides represented by 'N'. This can affect the accuracy of our phylogenetic tree construction. Therefore, it is necessary to filter out sequences that exceed a certain threshold. <br />
The script requires three parameters: the path to the folder containing consensus FASTA files (it will traverse all files with the *.fa suffix in the specified directory), the path to the output folder (where two folders, 'fail_seq' and 'filtered_seq', will be created to store sequences exceeding or below a certain threshold), and the percentage threshold for the proportion of 'N' bases in the sequences (sequences with a proportion exceeding this value will be filtered out; for example, inputting 70 means that if the proportion of 'N' bases in any sequence in 1.fa exceeds 70%, then 1.fa will be filtered out and not used as input for subsequent tree construction). <br />
The script logic involves traversing all *.fa files in the specified directory, utilizing seqkit's fx2tab to calculate the proportions of five bases (A, G, T, G, N) and generating a table with these proportions in the directory. Subsequently, by traversing this table, the script determines whether the proportion of 'N' bases in a sequence exceeds the set threshold. Sequences exceeding the threshold are copied to the 'fail_seq' folder, while sequences below the threshold are copied to the 'filtered_seq' folder.<br />
```
# Demo Usage:
bash filtered_fasta.sh merge_sample_folder/raw_seq merge_sample_folder 70

input_folder:
|-merge_sample_folder/
|       |--raw_seq/
             |---1.fa,2.fa,3.fa,4.fa

output_folder:
|-merge_sample_folder/
|       |--raw_seq/
|            |---1.fa,2.fa,3.fa,4.fa
|            |---1.stats,2.stats,3.stats,4.stats # the AGCTN contents with per fasta files
|       |--fail_seq/ # these fasta files with N >=70%
|            |---1.fa
|       |--filtered_seq/ # these fasta files with N < 70%
|            |---2.fa,3.fa,4.fa
```
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
## Phylogenetic tree topology statistics
Here, we utilize software called "Newick Utilities" (which can be installed using conda) to remove branch length and other such information from the phylogenetic tree, retaining only its topology.<br />
```
# First, remove all branch length information from all bestTree files.
mkdir -p ../topo_stat/
for i in *.bestTree ; do nw_topology $i > ../topo_stat/${i%.*}.topo.tree ; done

# Subsequently, employ  sort and uniq to statistically analyze the distinct topological structures present.
cd ../topo/stat/
cat *.tree | sort | uniq -c > total.topo.stat
```
In this way, in the file 'total.topo.stat', we have obtained all the unique topological structures of trees present along with their respective counts.<br />
However, it's worth noting that the tree structure presented is not yet the most parsimonious. Taking an example with three species plus one outgroup, there could be several possible scenarios.<br />
![image](https://github.com/shengxinzhuan/Extract_Consensus_Sequences_of_Genes_from_BAM_parallel/blob/main/tree_topology.jpg)
As we can see, even a phylogenetic tree for just four species could including twelve distinct tree topologies (with each topology having four equivalent representations in string form).<br />
Of course, such a scenario is more commonly encountered in groups that have undergone recent radiation events; however, it is relatively infrequent among most other taxa. Yet, the exponential increase in tree topology complexity as species numbers grow is daunting.<br />
So here, I present a method based on the ete3 package for more efficient handling when dealing with a larger number of species.<br />
```
# First, remove all branch length information from all bestTree files.
mkdir -p ../topo_stat/
for i in *.bestTree ; do nw_topology $i > ../topo_stat/${i%.*}.topo.tree ; done
cd ../topo_stat/
cat *.tree > total.tree
python3 newick_stat.py total.tree ouput_stats.txt
# The output like this:
Unique topologies and their counts:
Topology: (,O);(,A);(B,C)
Count: 20
Tree Newick: (((B:1,C:1)1:1,A:1)1:1,O:1);
```
# Topological structure heatmap visualization
After obtaining the tree count in the statistical analysis, we also aspire to generate a heatmap representing the topological distribution of trees along the chromosomes. To achieve this, it is necessary first to normalize the structures of the trees and then categorize them according to our custom classification scheme. Finally, we will plot the heatmap to illustrate the distribution.<br />
Firstly, we concatenate the gene names with the tree topologies, taking into account that the fourth column in our BED file contains the gene names. Moreover, since the current filenames consist of the gene names followed by a specific suffix, I simply need to remove the string following the “.” character. In order to iterate through all files, I have written a simple script to process them. Ultimately, the resulting files will contain two columns: the first one for the gene names, and the second one for the original tree topologies (as output from the nw_topology process).<br />
```
bash merge_gene_names_with_tree_topo.sh <input_folder>
# The outputs were in an folder "merge_gene_and_topo" which localed in /<input_folder_path>/../merge_gene_and_topo
cat merge_gene_and_topo/*.tree > total.gene_topo.txt

# Demo output:
Gene1  (((A,B),C),O);
Gene2  (((A,C),B),O);
......
```
Subsequently, we utilize the ete3 package to process this file, harmonizing the topological structures within it into unique forms (ensuring consistency with the results obtained in the previous step). At this stage, we employ another script called "gene_with_only_topo.py".<br />
```
python gene_with_only_topo.py total.gene_topo.txt total.gene_topo.resort.txt

# Demo output:
Gene_ID  Topology
Gene1  (,O);(,C);(A,B)
Gene2  (,O);(,B);(A,C)
......
```
Next, we need to remove the header of the output, and then perform final matching on the plotting file using sort|uniq <br />
```
awk 'NR > 1 {print $2}' total.gene_topo.resort.txt | sort | uniq > gene_topo_with_num.txt

# Using the vim to add the number for each tree type
# Before:
(,O);(,C);(A,B)
(,O);(,A);(C,B)
(,O);(,B);(A,C)

# After:(using tab to split)
(,O);(,C);(A,B)  1
(,O);(,A);(C,B)  2
(,O);(,B);(A,C)  3

# Then using the add_gene_tree_rank.py to change the total.gene_topo.resort.txt file column2 into gene_topo_with_num.txt column2

python add_gene_tree_rank.py total.gene_topo.resort.txt gene_topo_with_num.txt > total.gene_topo_with_num.txt

# Before:
Gene_ID  Topology
Gene1  (,O);(,C);(A,B)
Gene2  (,O);(,B);(A,C)
......

# After:
Gene1  1
Gene2  2
......
```
Next, we will extract the consensus bed file and use it, along with the obtained 'total.gene_topo_with_num.txt', as input files. Additionally, a configuration file specifying colors will also need to be created and provided as an input.<br />
```
# The bedfile column4 must same as total.gene_topo_with_num.txt (The bed file can include regions that have been filtered out.)
# The format of the color configuration file is as follows: 
1  #FF0000
2  #00FF00
3  #0000FF
Unknown  #FFFFFF #(Please note that it should include an entry with the name "Unknown" to serve as the fill color for missing genes.)
```
After preparing these three input files, we can proceed to utilize the 'visual_heatmap.r' script for visualization purposes. Here, I provide outputs in two output formats – one where coordinates are based on chromosome lengths, and another where chromosome lengths are disregarded.
```
# Notice that this script were using the "ggplot2" and "dplyr" to data analysis.
Rscript visual_plot.r total.gene_topo_with_num.txt total.bed color.config.txt
```
The result can be see as follow. Your can edit it using Adboe Illustrator or Affinit Designer.
![image](https://github.com/shengxinzhuan/Extract_Consensus_Sequences_of_Genes_from_BAM_parallel/blob/main/topo_in_chromosome.with_length.jpg)

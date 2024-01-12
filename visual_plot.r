args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
  stop("\nUsage: Rscript viusal_heatmap.r <gene_and_topo.txt> <bed_file> <color_config>\nBoth input without header\n\n gene_and_topo.txt:\nGene1\ttype1(int)\nGene2\ttype2(int)\n......\n\n bed_file:\n chr\tstart\tend\tgene_name\n\n color_config:\ntype1\t#FFFFFF\ntype2\t#00FF00\n...\n", call. = FALSE)
}

gene_file <- args[1]
bed_file <- args[2]
color_config_file <- args[3]

library(ggplot2)
library(dplyr)

gene_types <- read.table(gene_file, header = F, stringsAsFactors = T)
colnames(gene_types) <- c("Gene","Type")

bed_data <- read.table(bed_file, header = F, stringsAsFactors = T)
colnames(bed_data) <- c("Chr","Start","End","Gene")


color_config <- read.delim(color_config_file, header = F, sep = '\t', stringsAsFactors = T)
colnames(color_config) <- c("Type","Color")
type_colors <- setNames(as.character(color_config$Color), as.character(color_config$Type))

bed_data_with_types <- left_join(bed_data, gene_types, by = "Gene") %>%
  mutate(Length = End - Start + 1,
         Type = factor(Type, levels = unique(c(levels(as.factor(Type)), "Unknown"))) # 确保所有类型都存在于因子水平


all_types <- levels(bed_data_with_types$Type)
missing_types <- setdiff(all_types, names(type_colors))
if(length(missing_types) > 0){
  type_colors[missing_types] <- "#FFFFFF" 

bed_data_with_types <- bed_data_with_types %>%
  group_by(Chr) %>%
  arrange(Chr, Start)

p1 <- ggplot(bed_data_with_types, aes(xmin = Start, xmax = End, ymin = 0, ymax = 1, fill = Type)) +
  geom_rect() +
  facet_wrap(~ Chr) +
  scale_fill_manual(values = type_colors, guide = "legend", name = "Phylogenetic Tree", na.translate = FALSE) +
  theme_bw() +
  labs(title = "Phylogenetic Tree Topology in Each Chromosome",
       x = "Chromosome",
       y = "")

ggsave("topo_in_chromosome.without_length.pdf", p1, dpi=300)



chrom_length <- bed_data %>%
  group_by(Chr) %>%
  summarise( Chr_length = max(End) + 1000) %>%
  ungroup()

plot_data_w_length <- left_join(bed_data, chrom_length, by = "Chr")
plot_data_w_length_types <- left_join(plot_data_w_length, gene_types, by = "Gene")
plot_data_w_length_types$Type[is.na(plot_data_w_length_types$Type)] <- "Unknown"
plot_data_scaled <- plot_data_w_length_types %>%
  mutate(ScaledStart = Start / Chr_length,
         ScaledEnd = End/ Chr_length)
plot_data_scaled <- plot_data_scaled %>%
  mutate(TypeColor = type_colors[as.character(Type)])
p2 <-ggplot(plot_data_scaled, aes(xmin = ScaledStart, xmax = ScaledEnd, ymin=0, ymax = 1, fill = TypeColor)) +
  geom_rect() +
  facet_wrap(~ Chr) +
  scale_fill_identity(guide = "legend", name = "Phylogenetic Tree", na.translate = F) +
  theme_bw() +
  labs(title = "Phylogenetic Tree Topology in Each Chromosome",
       x = "Chromosome",
       y = "")+
  scale_x_continuous(name = "Genomic Position (scaled)", limits = c(0,1), expand = c(0,0)) +
  facet_wrap(~ Chr, scales = "free_x")
ggsave("topo_in_chromosome.with_length.pdf",p2,dpi=300)


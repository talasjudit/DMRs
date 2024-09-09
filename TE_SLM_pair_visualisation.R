library(circlize)
library(ggforce)
library(tidyverse)

genome_links <- read.csv("TE-SLM_pairs_concatenated_all_sRNA.csv", header=TRUE)
genome_sizes <- read.csv("genome_size.csv", header = TRUE)

# Create a plot with chromosomes and positions on both axes
ggplot() +
  # Draw link lines from source to target positions
  geom_link(aes(
    x = synteny$source_start, xend = synteny$target_start,
    y = as.factor(synteny$source_chr), yend = as.factor(synteny$target_chr)
  ), color = "blue", size = 1) +
  
  # Points for start positions (optional for better visual clarity)
  geom_point(aes(x = synteny$source_start, y = as.factor(synteny$source_chr)), color = "red", size = 2) +
  geom_point(aes(x = synteny$target_start, y = as.factor(synteny$target_chr)), color = "green", size = 2) +
  
  # Add axis labels and title
  labs(x = "Genomic Position (Source)", y = "Genomic Position (Target)") +
  
  # Customize the theme
  theme_minimal() +
  
  # Title for the plot
  ggtitle("Synteny Plot with Chromosomes and Positions on Both Axes")


# Split genome sizes into source and target genomes
source_genome <- genome_sizes[genome_sizes$genome == "source", ]
target_genome <- genome_sizes[genome_sizes$genome == "target", ]

# Add cumulative lengths for each chromosome to position them correctly on the x-axis
source_genome$cum_length <- cumsum(c(0, head(source_genome$length, -1)))
target_genome$cum_length <- cumsum(c(0, head(target_genome$length, -1)))

# Merge the cumulative lengths with linkage data
genome_links <- merge(genome_links, source_genome[, c("chr", "cum_length")], by.x = "source_chr", by.y = "chr")
genome_links <- merge(genome_links, target_genome[, c("chr", "cum_length")], by.x = "target_chr", by.y = "chr", suffixes = c("_source", "_target"))

# Adjust positions in linkage file to absolute positions across chromosomes
genome_links$source_start_abs <- genome_links$source_start + genome_links$cum_length_source
genome_links$target_start_abs <- genome_links$target_start + genome_links$cum_length_target

# Plot with chromosomes represented
ggplot() +
  # Draw source genome chromosomes
  geom_segment(data = source_genome, aes(x = cum_length, xend = cum_length + length, y = 1, yend = 1), size = 2, color = "blue") +
  # Draw target genome chromosomes
  geom_segment(data = target_genome, aes(x = cum_length, xend = cum_length + length, y = 0, yend = 0), size = 2, color = "red") +
  # Draw ribbons connecting source and target genome positions
  geom_link(aes(
    x = genome_links$source_start_abs, xend = genome_links$target_start_abs,
    y = 1, yend = 0
  ), color = "gray", size = 1) +
  # Customize labels and title
  labs(x = "Genomic Position", y = "Genomes", title = "Linkage Plot between Source and Target Genomes") +
  # Customize the theme
  theme_minimal() +
  # Customize y-axis ticks and labels
  scale_y_continuous(breaks = c(0, 1), labels = c("Target Genome", "Source Genome"))


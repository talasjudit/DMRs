library(tidyverse)
library(broom) 


data <- read_tsv("Mp_WT_all_methylation_at_embryo_clusters_headers.gff", col_types = cols(
  chr = col_character(),
  start = col_double(),
  end = col_double(),
  embryo_CG = col_double(),
  embryo_CHG = col_double(),
  embryo_CHH = col_double(),
  thallus_CG = col_double(),
  thallus_CHG = col_double(),
  thallus_CHH = col_double(),
  embryo_nonCG = col_character(),
  thallus_nonCG = col_character()
))

# Step 1: Filter clusters larger than 99bp
filtered_data <- data %>%
  filter(end - start > 99) %>%
  # Step 2: Filter by methylation differences
  filter(
    embryo_CG - thallus_CG > 0,
    embryo_CHG - thallus_CHG > 0.05,
    embryo_CHH - thallus_CHH > 0.1,
    (embryo_CHG - thallus_CHG) + (embryo_CHH - thallus_CHH) > 0.3
  )


# Parse 'c' and 't' values from the nonCG columns
filtered_data <- filtered_data %>%
  mutate(
    embryo_nonCG_c = as.numeric(str_extract(embryo_nonCG, "(?<=c=)\\d+")),
    embryo_nonCG_t = as.numeric(str_extract(embryo_nonCG, "(?<=t=)\\d+")),
    thallus_nonCG_c = as.numeric(str_extract(thallus_nonCG, "(?<=c=)\\d+")),
    thallus_nonCG_t = as.numeric(str_extract(thallus_nonCG, "(?<=t=)\\d+"))
  )

# Filter out rows with NA values in any of these new columns
filtered_data <- filtered_data %>%
  filter(
    !is.na(embryo_nonCG_c) & !is.na(embryo_nonCG_t) &
      !is.na(thallus_nonCG_c) & !is.na(thallus_nonCG_t)
  )

# Apply Fisher's Exact Test for each row
filtered_data <- filtered_data %>%
  rowwise() %>%
  mutate(
    p_value = fisher.test(
      matrix(
        c(embryo_nonCG_c, embryo_nonCG_t, thallus_nonCG_c, thallus_nonCG_t),
        nrow = 2
      ), 
      alternative = "greater"
    )$p.value
  ) %>%
  ungroup()
    
    
    
    # Filter for significant differences
    significant_data <- filtered_data %>%
      filter(p_value < 0.001)
    
    # View the significant results
    print(significant_data)
    
    # Optionally, write the results to a new file
    write_tsv(significant_data, "significant_methylation_differences_embryo_clusters_500bp_gap.tsv")
    
    exclude_thallus_CG_DMRs <- significant_data %>%
      filter(thallus_CG < 0.1)
    
    write_tsv(exclude_thallus_CG_DMRs, "significant_methylation_differences_embryo_excluding_thallusCG_clusters_500bp_merge_421.tsv")
    
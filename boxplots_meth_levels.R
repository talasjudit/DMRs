library(RColorBrewer)

n421_long <- exclude_thallus_CG_DMRs %>%
    pivot_longer(
      cols = c(embryo_CG, embryo_CHG, embryo_CHH, thallus_CG, thallus_CHG, thallus_CHH),
      names_to = "context_tissue",
      values_to = "methylation_level"
    ) %>%
  select(context_tissue,methylation_level)
  

ggplot(n421_long, aes(x = context_tissue, y = methylation_level, fill = context_tissue)) +
  geom_boxplot() +
  labs(title = "Methylation Levels by Context and Tissue at n421 DMRs", x = "Context and Tissue", y = "Methylation Level") +
  theme_classic() +
  scale_fill_brewer(palette= "Paired") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),legend.position = "none")
 
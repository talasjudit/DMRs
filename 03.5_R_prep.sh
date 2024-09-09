paste \
Mp_WT_sporophyte_CpG_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_sporophyte_CHG_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_sporophyte_CHH_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_thallus_CpG_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_thallus_CHG_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_thallus_CHH_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_sporophyte_nonCG_meth_levels_at_sporophyte_clusters.gff \
Mp_WT_thallus_nonCG_meth_levels_at_sporophyte_clusters.gff |\
awk -v OFS="\t" '{print $1,$4,$5,$6,$15,$24,$33,$42,$51,$63,$72}' \
> Mp_WT_all_methylation_at_sporophyte_clusters.gff

cat Mp_WT_all_methylation_at_sporophyte_clusters.gff |\
awk 'BEGIN {print "chr\tstart\tend\tsporophyte_CG\tsporophyte_CHG\tsporophyte_CHH\tthallus_CG\tthallus_CHG\tthallus_CHH\tsporophyte_nonCG\tthallus_nonCG"} {print}' \
> Mp_WT_all_methylation_at_sporophyte_clusters_headers.gff

paste \
Mp_WT_sporophyte_CpG_meth_levels_at_thallus_clusters.gff \
Mp_WT_sporophyte_CHG_meth_levels_at_thallus_clusters.gff \
Mp_WT_sporophyte_CHH_meth_levels_at_thallus_clusters.gff \
Mp_WT_thallus_CpG_meth_levels_at_thallus_clusters.gff \
Mp_WT_thallus_CHG_meth_levels_at_thallus_clusters.gff \
Mp_WT_thallus_CHH_meth_levels_at_thallus_clusters.gff \
Mp_WT_sporophyte_nonCG_meth_levels_at_thallus_clusters.gff \
Mp_WT_thallus_nonCG_meth_levels_at_thallus_clusters.gff |\
awk -v OFS="\t" '{print $1,$4,$5,$6,$15,$24,$33,$42,$51,$63,$72}'\
> Mp_WT_all_methylation_at_thallus_clusters.gff

cat Mp_WT_all_methylation_at_thallus_clusters.gff |\
awk 'BEGIN {print "chr\tstart\tend\tsporophyte_CG\tsporophyte_CHG\tsporophyte_CHH\tthallus_CG\tthallus_CHG\tthallus_CHH\tsporophyte_nonCG\tthallus_nonCG"} {print}' \
> Mp_WT_all_methylation_at_thallus_clusters_headers.gff
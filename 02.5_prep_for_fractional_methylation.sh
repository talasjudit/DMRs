## convert to gff for window_by_annotation.pl

cd ../../DMRs

cat Mp_WT_thallus_CG_CHG_CHH_500bp_nonzero_merged_clusters.bed | awk -v OFS="\t" '{print $1,"bedtools","nonzero_C_methyl_islands",$2,$3,".",".",".","ID="NR""}' > Mp_WT_thallus_CG_CHG_CHH_500bp_nonzero_merged_clusters.gff 
cat Mp_WT_thallus_CG_CHG_CHH_200bp_nonzero_merged_clusters.bed | awk -v OFS="\t" '{print $1,"bedtools","nonzero_C_methyl_islands",$2,$3,".",".",".","ID="NR""}' > Mp_WT_thallus_CG_CHG_CHH_200bp_nonzero_merged_clusters.gff 

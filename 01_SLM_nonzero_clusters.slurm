#!/bin/bash -e
#SBATCH -p jic-short
#SBATCH --mem 20G
#SBATCH -c 16
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
#SBATCH --mail-user=judit.talas@jic.ac.uk # send-to address
#SBATCH --job-name=meth_counts
#SBATCH --array=0  # Two tasks, one for each type

source bedtools-2.27.0

types=(sporophyte embryo thallus)
contexts=(CpG CHG CHH)

work_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/BS-seq/takv6/DMRs"
cd $work_folder

# Determine the type based on SLURM_ARRAY_TASK_ID
type=${types[$SLURM_ARRAY_TASK_ID]}

# Filter each context file for the current type to retain only windows with methylation > 0.05
for context in "${contexts[@]}"; do
    awk -v OFS="\t" '!/^unplaced-scaffold/ && $6 > 0.05 {print $1, $4, $5, $6}' ../03_methylation_w100s_nightfury/Mp_WT_${type}_merged.${context}.w50.gff \
        >  Mp_WT_${type}_merged.${context}.nonzero.w50.gff
done


# Intersect the filtered files to find common windows across all contexts
bedtools intersect -a  Mp_WT_${type}_merged.CpG.nonzero.w50.gff -b  Mp_WT_${type}_merged.CHG.nonzero.w50.gff -wa -wb | \
bedtools intersect -a - -b  Mp_WT_${type}_merged.CHH.nonzero.w50.gff -wa -wb \
 >  Mp_WT_${type}_CG_CHG_CHH_nonzero.w50.gff


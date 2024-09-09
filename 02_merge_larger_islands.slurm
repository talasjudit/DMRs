#!/bin/bash -e
#SBATCH -p jic-medium
#SBATCH --mem 20G
#SBATCH -c 16
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
#SBATCH --mail-user=judit.talas@jic.ac.uk # send-to address
#SBATCH --job-name=meth_islands
#SBATCH --array=0-1

source bedtools-2.27.0


ARRAY=(Mp_WT_sporophyte Mp_WT_thallus Mp_WT_embryo)
library="${ARRAY[$SLURM_ARRAY_TASK_ID]}"
work_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/BS-seq/takv6/DMRs"
cd $work_folder

# merge to larger islands

bedtools merge -i ${library}_CG_CHG_CHH_nonzero.w50.gff -d 200  > ${library}_CG_CHG_CHH_200bp_nonzero_merged_clusters.bed
bedtools merge -i ${library}_CG_CHG_CHH_nonzero.w50.gff -d 500  > ${library}_CG_CHG_CHH_500bp_nonzero_merged_clusters.bed
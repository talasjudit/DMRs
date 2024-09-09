#!/bin/bash -e
#SBATCH -p jic-long # partition (queue)
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=Judit.Talas@jic.ac.uk
#SBATCH --array=0-5
#SBATCH --mem=40G
#SBATCH --cpus-per-task=6
#SBATCH --job-name=sRNA_map

# Adjust the ulimit for the number of open files
ulimit -n 4096

source package /nbi/software/testing/bin/bowtie-1.0.1
source samtools-1.7

libraries=(Mp_sporophyte_sRNA \
Mp_antheridia_sRNA \
Mp_embryo_sRNA \
Mp_archegoniophore_sRNA \
Mp_antheridiophore_sRNA \
Mp_thallus_sRNA)

work_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs"

cd $work_folder/SLMs/01_mapped_BAMs/3_mismatches_EDTA

#3 mismatches
zcat $work_folder/SLMs/trimmed_reads_bbduk_trim_galore/${libraries[$SLURM_ARRAY_TASK_ID]}_bbduk_trim_galore_trimmed.fq.gz | \
bowtie \
  -a \
  -v 3 \
  -S \
  -q ~/philscratch/Marchantia/TE_anno_EDTA/MpTak_v6.1.genome.EDTA.masked \
  - | \
samtools view -hb > $work_folder/SLMs/01_mapped_BAMs/3_mismatches_EDTA/${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all.bam

#remove unmapped reads
samtools view -b -F 4 $work_folder/SLMs/01_mapped_BAMs/3_mismatches_EDTA/${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all.bam \
> $work_folder/SLMs/01_mapped_BAMs/3_mismatches_EDTA/${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all_mapped.bam

rm $work_folder/SLMs/01_mapped_BAMs/3_mismatches_EDTA/${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all.bam

#sort bam file and create index
samtools sort -o sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all_mapped.bam ${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all_mapped.bam
samtools index sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all_mapped.bam

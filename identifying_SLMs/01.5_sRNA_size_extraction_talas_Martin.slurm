#!/bin/bash -e
#SBATCH -p jic-long # partition (queue)
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
#SBATCH --mail-user=judit.talas@jic.ac.uk # send-to address
#SBATCH --array=0-5
#SBATCH --mem=80G
#SBATCH --cpus-per-task=6
#SBATCH --job-name=sRNA_size_extraction

source samtools-1.7

libraries=(Mp_sporophyte_sRNA \
Mp_antheridia_sRNA \
Mp_embryo_sRNA \
Mp_archegoniophore_sRNA \
Mp_antheridiophore_sRNA \
Mp_thallus_sRNA)

output_folder="/jic/scratch/groups/Xiaoqi-Feng/talas/Marchantia/sRNA_mapping/01.5_24_nt_3_mismatched_bam/Martin"
work_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs/SLMs/01_mapped_BAMs/3_mismatches_Martin"

cd $output_folder

# optional loop extracts sRNA sizes 21 to 24

for i in {20..25};
do
samtools view -@ 2 -h $work_folder/sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_all_mapped.bam | \
awk -v s=$i 'length($10)==s||$1~/^@/'| \
samtools view -bS - > sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_"$i"_mapped.bam
done

samtools merge -f sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_20_25_mapped.bam sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_*.bam

rm sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_20_mapped.bam
rm sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_23_mapped.bam
rm sorted_${libraries[$SLURM_ARRAY_TASK_ID]}_sRNA_3_mismatch_25_mapped.bam
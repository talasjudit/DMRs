#!/bin/bash -e
#SBATCH -p jic-short
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=judit.talas@jic.ac.uk
#SBATCH --array=0
#SBATCH --mem=20G
#SBATCH --cpus-per-task=2
#SBATCH --job-name=sRNA_trim


source fastqc-0.11.3
source trim_galore-0.4.2
source cutadapt-1.9.1

libraries=(Mp_thallus_sRNA Mp_archegoniophore_sRNA Mp_antheridiophore_sRNA Mp_sporophyte_sRNA Mp_antheridia_sRNA Mp_embryo_sRNA)

work_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs"

cd $work_folder/SLMs/00_trimmed_reads/

#fastqc \
#    $work_folder/Raw_data/${libraries[$SLURM_ARRAY_TASK_ID]}.fq.gz \
#    -o $work_folder/Raw_data/

#trim_galore \
#    --max_length 28 \
#    --length 15 \
#    -o $work_folder/SLMs/00_trimmed_reads/ \
#    $work_folder/Raw_data/${libraries[$SLURM_ARRAY_TASK_ID]}.fq.gz

#############
#For Normal sRNA-seq libraries,the below command is used to remove adaptors
#Check adaptor sequence is correct.

#srun cutadapt \p
#    -m 15 \
#    -M 28 \
#    -a TGGAATTCTCGGGTGCCAAGGAACTCCAGTC \
#    -o $work_folder/SLMs/00_trimmed_reads/${libraries[$SLURM_ARRAY_TASK_ID]}_trimmed.fq.gz \
#    $work_folder/Raw_data/${libraries[$SLURM_ARRAY_TASK_ID]}.fq.gz \


#The below command is specialized for removing adaptors from sRNA libraries using the Realseq kit
# -m 21 -M 25 keeps reads of sizes 21-25

#srun cutadapt \
#    -u 1 \
#    -m 15 \
#    -M 28 \
#    -a TGGAATTCTCGGGTGCCAAGG \
#    -o $work_folder/SLMs/00_trimmed_reads/${libraries[$SLURM_ARRAY_TASK_ID]}_trimmed.fq.gz \
#    $work_folder/Raw_data/${libraries[$SLURM_ARRAY_TASK_ID]}.fq.gz


fastqc \
    $work_folder/SLMs/00_trimmed_reads/${libraries[$SLURM_ARRAY_TASK_ID]}_trimmed.fq.gz \
    -o $work_folder/SLMs/00_trimmed_reads/


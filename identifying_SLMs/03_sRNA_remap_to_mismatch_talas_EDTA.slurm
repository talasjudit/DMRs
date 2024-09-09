#!/bin/bash -e
#SBATCH -p jic-long # partition (queue)
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=Judit.Talas@jic.ac.uk
#SBATCH --array=0-5
#SBATCH --mem=120G
#SBATCH --cpus-per-task=40
#SBATCH --job-name=sRNA_map
#SBATCH -t 45-00:00

# Adjust the ulimit for the number of open files
ulimit -n 50000

source samtools-1.7
source package 46a62eca-4f8f-45aa-8cc2-d4efc99dd9c6

libraries=(
Mp_sporophyte_sRNA \
Mp_antheridia_sRNA \
Mp_embryo_sRNA
Mp_archegoniophore_sRNA \
Mp_antheridiophore_sRNA \
Mp_thallus_sRNA)

work_folder="/jic/scratch/groups/Xiaoqi-Feng/talas/Marchantia/sRNA_mapping"
output_folder="$work_folder/03_remapped_BAMs/EDTA"
input_fastq_dir="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs/SLMs/trimmed_reads_bbduk_trim_galore"
library=${libraries[$SLURM_ARRAY_TASK_ID]}
input_fastq="${input_fastq_dir}/${library}_bbduk_trim_galore_trimmed.fq.gz"
output_bam="${library}_sRNA_0_mismatch_20_25_remapped_to_3_mismatch.bam"
output_bam_mapped="${library}_sRNA_0_mismatch_20_25_remapped_to_3_mismatch_mapped.bam"
reference_fasta="$work_folder/02_bam_to_fasta/3_mismatches_EDTA/sorted_${library}_sRNA_3_mismatch_20_25_mapped.fasta"
singularity_image="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs/SLMs/Scripts/03_singularity_parallel_samtools_bowtie1.sif"

cd $output_folder

# Calculate the total number of bases in the reference FASTA file
total_bases=$(grep -v '^>' $reference_fasta | tr -d '\n' | wc -c)

echo "Total bases in $reference_fasta: $total_bases"

if (( total_bases > 3600000000 )); then
    # Split the reference FASTA file into chunks using seqkit
    seqkit split2 -p $(( (total_bases / 3600000000) + 1 )) $reference_fasta -O ${output_folder}

    # List chunk files
    chunk_files=(${output_folder}/sorted_${library}_sRNA_3_mismatch_20_25_mapped.part_*.fasta)

    # Debugging: Check if chunk files are created
    echo "Chunk files created:"
    ls -l ${output_folder}/sorted_${library}_sRNA_3_mismatch_20_25_mapped.part_*.fasta

    # Create a temporary file to store the list of chunk files
    chunk_file_list=$(mktemp)
    printf "%s\n" "${chunk_files[@]}" > ${chunk_file_list}

    # Debugging: Check the content of the chunk file list
    echo "Chunk file list content:"
    cat ${chunk_file_list}

    cat << EOF > env_${library}.list
SLURM_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
library=$library
input_fastq=$input_fastq
output_folder=$output_folder
chunk_file_list=$chunk_file_list
EOF

    # Build Bowtie indexes for each chunk
    singularity exec \
        --env-file env_${library}.list \
        --bind ${output_folder},${input_fastq_dir} \
        ${singularity_image} /bin/bash -c \
        "parallel --jobs ${SLURM_CPUS_PER_TASK} 'bowtie-build {} {.}' :::: ${chunk_file_list}"

    # Align reads to each chunk in parallel
    singularity exec \
        --env-file env_${library}.list \
        --bind ${output_folder},${input_fastq_dir} \
        ${singularity_image} /bin/bash -c \
        "parallel --jobs ${SLURM_CPUS_PER_TASK} 'zcat ${input_fastq} | bowtie -a --best -v 0 -S -q {.} - | samtools view -hb > {.}.bam' :::: ${chunk_file_list}"

    wait 

    # Merge all chunk BAM files
    samtools merge -@ 40 ${output_bam} ${output_folder}/sorted_${library}_sRNA_3_mismatch_20_25_mapped.part_*.bam
    wait
    # Remove intermediate BAM files
    rm ${output_folder}/sorted_${library}_sRNA_3_mismatch_20_25_mapped.part_*.bam
else
    # If no splitting is needed, proceed with the single reference FASTA file
    cat << EOF > env_${library}.list
SLURM_CPUS_PER_TASK=$SLURM_CPUS_PER_TASK
library=$library
input_fastq=$input_fastq
output_folder=$output_folder
EOF

    # Build Bowtie index for the single reference FASTA file
    singularity exec \
        --env-file env_${library}.list \
        --bind ${output_folder},${input_fastq_dir} \
        ${singularity_image} /bin/bash -c \
        "bowtie-build ${reference_fasta} ${reference_fasta%.fasta}"

    # Align reads to the reference FASTA
    singularity exec \
        --env-file env_${library}.list \
        --bind ${output_folder},${input_fastq_dir} \
        ${singularity_image} /bin/bash -c \
        "zcat ${input_fastq} | bowtie -a --best -v 0 -S -q ${reference_fasta%.fasta} - | samtools view -hb > ${output_bam}"
fi

# Remove unmapped reads
samtools view -@ 40 -b -F 4 ${output_bam} > ${output_bam_mapped}
wait
rm ${output_bam}

# Sort BAM file and create index
samtools sort -@ 40 -o sorted_${output_bam_mapped} ${output_bam_mapped}
samtools index -@ 40 sorted_${output_bam_mapped}

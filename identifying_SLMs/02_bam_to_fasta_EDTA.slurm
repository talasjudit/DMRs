#!/bin/bash -e
#SBATCH -p jic-long # partition (queue)
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=Judit.Talas@jic.ac.uk
#SBATCH --array=0-5
#SBATCH --mem=80G 
#SBATCH --cpus-per-task=6
#SBATCH --job-name=bam_to_fasta

source samtools-1.7

libraries=(Mp_sporophyte_sRNA \
Mp_antheridia_sRNA \
Mp_embryo_sRNA \
Mp_archegoniophore_sRNA \
Mp_antheridiophore_sRNA \
Mp_thallus_sRNA)

work_folder="/jic/scratch/groups/Xiaoqi-Feng/talas/Marchantia/sRNA_mapping/01.5_24_nt_3_mismatched_bam/EDTA"
output_folder="/jic/scratch/groups/Xiaoqi-Feng/talas/Marchantia/sRNA_mapping/02_bam_to_fasta/3_mismatches_EDTA"
library=${libraries[$SLURM_ARRAY_TASK_ID]}
input_bam="$work_folder/sorted_${library}_sRNA_3_mismatch_20_25_mapped.bam"
output_fasta="$output_folder/sorted_${library}_sRNA_3_mismatch_20_25_mapped.fasta"
singularity_image="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs/SLMs/Scripts/02_singularity_bamtofasta_samtools.sif"
chunk_script_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs/SLMs/Scripts"

cd $output_folder

# Define the number of reads per chunk
reads_per_chunk=1000000

# Split BAM file into smaller chunks
chunk_prefix="chunk_${library}_"
header_file="header_${SLURM_ARRAY_TASK_ID}.sam"

samtools view -H ${input_bam} > ${header_file}
if [ ! -s ${header_file} ]; then
    echo "Error: Failed to extract header from ${input_bam}"
    exit 1
fi

samtools view ${input_bam} | split -l ${reads_per_chunk} - ${chunk_prefix}

# Verify the split files
split_files=$(ls ${chunk_prefix}*)
if [ -z "$split_files" ]; then
    echo "Error: No chunk files created by split command"
    exit 1
fi
echo "Split files created: $split_files"

# Define the process_chunk function in the Singularity container execution context
singularity exec \
    --bind ${output_folder} \
    ${singularity_image} /bin/bash -c \
    "process_chunk() {
        local chunk=\$1
        local header_file=\$2
        local chunk_bam=\"\${chunk}.bam\"
        local chunk_fasta=\"\${chunk}.fasta\"
        
        echo \"Processing chunk: \$chunk with header: \$header_file\"
        
        cat \${header_file} \${chunk} | samtools view -bS - > \${chunk_bam}
        if [ \$? -ne 0 ]; then
            echo \"Error: Failed to create BAM file for chunk \${chunk}\"
            exit 1
        fi
        
        samtools view \${chunk_bam} | \
        awk 'BEGIN {OFS=\"\\n\"} {print \">\"\$1\"_\"\$3\":\"\$4\"_\"NR, \$10}' > \${chunk_fasta}
        if [ \$? -ne 0 ]; then
            echo \"Error: Failed to convert BAM to FASTA for chunk \${chunk_bam}\"
            exit 1
        fi

        # Clean up intermediate chunk files
        if [ -f \${chunk} ]; then
            rm \${chunk}
            echo \"Removed chunk file: \${chunk}\"
        fi

        if [ -f \${chunk_bam} ]; then
            rm \${chunk_bam}
            echo \"Removed BAM file: \${chunk_bam}\"
        fi
    }; export -f process_chunk; parallel --jobs ${SLURM_CPUS_PER_TASK} 'process_chunk {} ${header_file}' ::: ${chunk_prefix}*"

# Combine all chunk FASTA files into the final output FASTA
cat ${chunk_prefix}*.fasta > ${output_fasta}

# Clean up chunk files
rm ${chunk_prefix}*.fasta ${header_file}

#!/bin/bash -e
#SBATCH -p jic-long
#SBATCH --mail-type=end,fail
#SBATCH --mail-user=Judit.Talas@jic.ac.uk
#SBATCH --mem=120G
#SBATCH --cpus-per-task=32
#SBATCH --job-name=matching
#SBATCH -t 45-00:00

source samtools-1.9

libraries=(
Mp_sporophyte_sRNA)

work_folder="/jic/scratch/groups/Xiaoqi-Feng/talas/Marchantia/sRNA_mapping"
mismatch_bam_folder="$work_folder/03_remapped_BAMs/Martin/24_only"
phil_scratch_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/Mp_SLMs/SLMs"
library=${libraries[$SLURM_ARRAY_TASK_ID]}
sRNA_0_mismatch_file="$phil_scratch_folder/01_mapped_BAMs/0_mismatches/sorted_${library}_sRNA_0_mismatch_24_mapped.bam"
sRNA_3_remapped_file="$mismatch_bam_folder/sorted_${library}_sRNA_0_mismatch_24_remapped_to_3_mismatch_mapped.bam"
output_folder="$work_folder/04_matching_reads/Martin"

cd $output_folder

# Temporary file to store the 0 mismatch reads
zero_mismatch_temp=$(mktemp)

# Error handling: Check if the temporary file was created successfully
if [ ! -f "$zero_mismatch_temp" ]; then
    echo "Error: Temporary file for 0 mismatch reads could not be created."
    exit 1
fi

# Load the 0 mismatch BAM file into a temporary file
echo "Extracting 0 mismatch BAM file to temporary file..."
if ! samtools view -@ 32 "$sRNA_0_mismatch_file" > "$zero_mismatch_temp"; then
    echo "Error: Failed to extract 0 mismatch BAM file."
    exit 1
fi

# Check if the temporary file is not empty
if [ ! -s "$zero_mismatch_temp" ]; then
    echo "Error: The temporary file for 0 mismatch reads is empty."
    exit 1
fi

echo "Successfully extracted 0 mismatch BAM file."

# Reset counter for tracking progress
counter=0

# Process the 3 mismatch BAM file and match against the 0 mismatch temporary file
echo "Processing 3 mismatch BAM file and matching reads..."
if ! samtools view -@ 32 "$sRNA_3_remapped_file" | while read -r line; do
    read_name=$(echo "$line" | awk '{print $1}')
    location=$(echo "$line" | awk '{print $3}')

    # Find matching read in the temporary file
    zero_mismatch_info=$(grep "^$read_name" "$zero_mismatch_temp")

    # If the read was found in the 0 mismatch BAM file, print its full info along with the 3 mismatch location
    if [ -n "$zero_mismatch_info" ]; then
        echo "$zero_mismatch_info $location"
    fi

    # Logging progress every 100,000 reads
    ((counter++))
    if ((counter % 100000 == 0)); then
        echo "Processed $counter reads from 3 mismatch BAM file..."
    fi
done > "sorted_${library}_sRNA_0_mismatch_24_mapped_added_3_mismatch_locations.txt"; then
    echo "Error: Failed to process 3 mismatch BAM file."
    exit 1
fi

# Ensure the output file was created and is not empty
if [ ! -s "sorted_${library}_sRNA_0_mismatch_24_mapped_added_3_mismatch_locations.txt" ]; then
    echo "Error: Output file is empty or was not created."
    exit 1
fi

# Clean up temporary file
rm "$zero_mismatch_temp"
echo "Done processing."

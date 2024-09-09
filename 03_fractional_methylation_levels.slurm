#!/bin/bash -e
#SBATCH -p jic-medium
#SBATCH --mem 40G
#SBATCH -c 16
#SBATCH --mail-type=END,FAIL # notifications for job done & fail
#SBATCH --mail-user=judit.talas@jic.ac.uk # send-to address
#SBATCH --job-name=meth_counts
#SBATCH --array=0-15

source bedtools-2.27.0

# Define contexts and pairing types
contexts=("CpG" "CHG" "CHH" "nonCG")
pairings=("sporophyte_sporophyte" "sporophyte_thallus" "thallus_sporophyte" "thallus_thallus")

# Calculate index for contexts and pairings
context_index=$(($SLURM_ARRAY_TASK_ID / 4))
pairing_index=$(($SLURM_ARRAY_TASK_ID % 4))

# Extract specific context and pairing
context=${contexts[$context_index]}
pairing=${pairings[$pairing_index]}

# Break down the pairing into target and cluster types
target=$(echo $pairing | cut -d'_' -f1)
cluster=$(echo $pairing | cut -d'_' -f2)

singularity_image="/jic/research-groups/Phil-Carella/Judit_Talas/singularity_containers/window_by_annotation_perl.sif"
library="Mp_WT_${target}"
window_by_annotation_path="/jic/research-groups/Xiaoqi-Feng/bin/window_by_annotation_mc.pl"
work_folder="/jic/scratch/groups/Phil-Carella/talas/Marchantia/BS-seq/takv6/DMRs/sporophyte_thallus_diff/500bp_merge"
cd $work_folder

# Generate a unique environment list file for each array job
env_list_file="${library}_${context}_${cluster}_env.list"

cat << EOF > $env_list_file
work_folder=$work_folder
library=$library
window_by_annotation_path=$window_by_annotation_path
EOF

# Run the annotation script for the specific context and cluster
singularity exec --env-file $env_list_file $singularity_image /bin/bash -c \
"perl \${window_by_annotation_path} \
    -g Mp_WT_${cluster}_CG_CHG_CHH_500bp_nonzero_merged_clusters.gff -k -t 'ID' \
    -o \${library}_${context}_meth_levels_at_${cluster}_clusters.gff \
    /jic/scratch/groups/Phil-Carella/talas/Marchantia/BS-seq/takv6/03_methylation_w100s_nightfury/\${library}_merged.${context}.w1.gff"

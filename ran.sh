# 0. Split VCFs by population
# CHANGE PER CHROMOSOME
# VCF="/quobyte/bmhenngrp/from-lssc0/data/genomes/caapa_freeze3/vcf/20260518_Freeze3.BiallelicSNPs.nosingletons.shapeit5.chr6.vcf.gz"
# META="/quobyte/bmhenngrp/users/adina/SWIFr_summary_statistics/CAAPA2_frz2_IDs_metadata_Oct2025_nodup.txt"
# REMOVE="/quobyte/bmhenngrp/users/adina/SWIFr_summary_statistics/20260319_individuals_to_remove_detailed.txt"
# awk 'NR>1 {print $2}' "$REMOVE" > remove.txt
# for POP in British Kinh_Vietnamese Yoruba_1000G; do
#     awk -v p="$POP" 'NR>1 && $4==p {print $2}' "$META" |
#     grep -vFxf remove.txt > samples.txt
#     bcftools view -S samples.txt "$VCF" -Oz -o "chr6_${POP}.vcf.gz"
#     bcftools index -t "chr6_${POP}.vcf.gz"
# done
# rm samples.txt remove.txt

# 1. Define variables in bash
# CHANGE PER POPULATION AND CHROMOSOME
chr=6
path="/quobyte/bmhenngrp/users/adina/SWIFr_summary_statistics/african"
vcf="chr6_Yoruba_1000G.vcf.gz"
out="output_chr6_african"
freq=0.05

# 2. Create bed file with ranges of 8Mb to run in a job array
module load bcftools; bcftools query -f '%POS\n' $path/$vcf -o chr${chr}_position.txt
bash create_bed.sh chr${chr}_position.txt chr${chr}_positions.bed
rm chr${chr}_position.txt

# 3. Run runstats script to launch the jobs
mkdir -p logs/
num=$(wc -l chr${chr}_positions.bed | cut -d' ' -f1) #store number of arrays/chunks in $num
sbatch --array=1-${num}%20 1.runstats_array.sh $chr $path $vcf $freq $out
echo "number of chunks: $num"

# 4. Track progress of job array
# grep "Processing" logs/OUT_runstats_100kb_* | wc -l #number of variants computed
# tail -n 1 logs/OUT_runstats_100kb_* | grep "Successful" | wc -l #number of successful chunks
# tail -n 1 logs/OUT_runstats_100kb_* | grep -v 'Successful\|=\|^$' | wc -l #number of unfinished chunks (no lines that say Successful or empty (new line) or from tail ==> format)

#5. Merge output from each slurm array into one CSV file
# head for 1 header, tail for each CSV value appended
# head -n1 ${out}.chr${chr}.1.csv > ${out}.chr${chr}.all.csv 
# tail -n+2 ${out}.chr${chr}.*.csv | grep -v "==>" >> ${out}.chr${chr}.all.csv 
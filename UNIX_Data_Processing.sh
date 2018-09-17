#!/bin/bash

# This script processes maize and teosinte SNP data files by separating the data into chr files
# This script is for UNIX assignment #1 in BCB546X
# Jen Jaqueth
# 2018_16_9

# This script requires the awk_transpose script and two data files, fang_et_al_genotypes.txt and snp_positions.txt

# Splits out maize and teosinte genotypes to their respective files; Group is needed to get SNP names
grep -E "(Group|ZMMIL|ZMMLR|ZMMMR)" fang_et_al_genotypes.txt > maize_genotypes.txt
grep -E "(Group|ZMPBA|ZMPIL|ZMPJA)" fang_et_al_genotypes.txt > teosinte_genotypes.txt

# transposes genotypic data
awk -f transpose.awk maize_genotypes.txt > transposed_maize_genotypes.txt
awk -f transpose.awk teosinte_genotypes.txt > transposed_teosinte_genotypes.txt


sed '1d' snp_position.txt | sort -k1,1  > snp_position_sorted.txt		#removes header
sort -k1,1 -c snp_position_sorted.txt		# Sorts SNP names in preparation for joining
cut -f 1,3,4 snp_position_sorted.txt > snp_for_join.txt		#creates file with only SNP name, chr and position

# sorts genotypic data in preparation for joining
sed '1,3d' transposed_maize_genotypes.txt | sort -k1,1  > transposed_maize_genotypes_sorted.txt
sed '1,3d' transposed_teosinte_genotypes.txt | sort -k1,1  > transposed_teosinte_genotypes_sorted.txt

# joins SNP position file and SNP data
join -1 1 -2 1 snp_for_join.txt transposed_maize_genotypes_sorted.txt -t $'\t' > maize_full.txt
join -1 1 -2 1 snp_for_join.txt transposed_teosinte_genotypes_sorted.txt -t $'\t' > teosinte_full.txt

# uses while loop to create 1 file for each chr, and sorts by position
i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' maize_full.txt | sort -k3,3n > maize_chr$i.txt; let i=i+1; done
i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' teosinte_full.txt | sort -k3,3n > teosinte_chr$i.txt; let i=i+1; done

# uses while loop to create 1 file for each chr, sorting in reverse order and replacing "?/?" with "-/-"
i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' maize_full.txt | sort -k3,3nr | sed 's/\?/-/g'  > maize_rev_chr$i.txt; let i=i+1; done
i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' teosinte_full.txt | sort -k3,3nr | sed 's/\?/-/g'  > teosinte_rev_chr$i.txt; let i=i+1; done

# moves "unknown" or "multiple" SNPs to respective files
grep "unknown" maize_full.txt > maize_chr_unknown.txt
grep "unknown" teosinte_full.txt > teosinte_chr_unknown.txt
grep "multiple" maize_full.txt > maize_chr_multiple.txt
grep "multiple" teosinte_full.txt > teosinte_chr_multiple.txt
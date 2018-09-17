### **UNIX Assignment** ###

* This repository contains the files for ISU BCB546X class UNIX assignment

* [GitHub repository location](https://github.com/jaquethjs/BCB546X_UNIX_Assignment) 

* Created by Jen Jaqueth on September 8, 2018




### **Data Computing Location & Issue with GitHub** ###
This assignment was completed at my worksite on Pioneer Hi-Bred's HPC cluster. The working folder is 
/home/jaquetje/BCB546X_2018/assignments/UNIX\_Assignment


### **Data Inspection** ###

In this section, I used UNIX commands to inspected two files  `fang_et_al_genotypes.txt` and 
 `snp_position.txt`



### **Inspecting `fang_et_al_genotypes.txt`:** ###

> `$ head -n 3 fang_et_al_genotypes.txt`

This is a very big file with 1 row of header and many marker calls. Too many to look at at once.

> `$ head -n 1 fang_et_al_genotypes.txt > UNIX_Assignment_Jaqueth/inspect_fang_out.txt`

The header has many columns, starting with Sample\_ID, JH\_OTU, Group and then many marker columns. 

> `$ tail -n +3 fang_et_al_genotypes.txt | awk -F "\t" '{print NF; exit}'`

There 986 columns total, which means 983 marker columns.

> `$ wc fang_et_al_genotypes.txt`

There are 2783 rows, 2744038 words and 11051939 characters.

> `$ tail -n 1 fang_et_al_genotypes.txt`

The marker data are in the format of A/A and missing data are indicated by "?/?"

> `$ ls -lh `

The file size is 11M and it was last modified Sept 2 13:29.

> `$ awk -F "\t" '{print $1, $2, $3}' fang_et_al_genotypes.txt` 

I printed the first three columns to examine the group names

> `$  cut -f 3 fang_et_al_genotypes.txt | tail -n +2 | sort | uniq -c | sort -r | awk '{ print $2, $1 }' | sort -k2n  > Count_of_Groups.txt`

I counted the number of individuals in each of the groups in column #3, excluding the header, and then sorted and printed them to a file. I did this as a QC, since my next step is GREP-ing out marker data by group. Now I know the number of lines I should have for each group.

### **Inspecting `snp_position.txt`:** ###

> `(head -n 2; tail -n 2) <  snp_position.txt `

This is a file with one header row. It lists the markers and information about them. 

> `$ tail -n +3 snp_position.txt | awk -F "\t" '{print NF; exit}'`

There 15 columns total.

> `$ wc snp_position.txt`

There are 984 rows, 13198 words and 82763 characters. Since there is a header, it has 983 markers. This is an important QC because the other file also has 983 markers.  

> `$ ls -lh `

The file size is 81K and it was last modified Sept 2 13:29.






## **Data Processing Script**

I made these data processing steps into a script called `UNIX_Data_Processing.sh ` This script can be run with these commands

>`$ chmod a+rx UNIX_Data_Processing.sh ` 

>`$ ./UNIX_Data_Processing.sh `

## **Steps in the Data Processing Script**

First I extracted the maize and teosinte marker data into separate genotype files, including "Group" to get the SNP name.

> `$ grep -E "(Group|ZMMIL|ZMMLR|ZMMMR)" fang_et_al_genotypes.txt > maize_genotypes.txt   `
>
> `$ grep -E "(Group|ZMPBA|ZMPIL|ZMPJA)" fang_et_al_genotypes.txt > teosinte_genotypes.txt   `
> 

 

Then I transposed both files

>`$ awk -f transpose.awk maize_genotypes.txt > transposed_maize_genotypes.txt `
>
>`$ awk -f transpose.awk teosinte_genotypes.txt > transposed_teosinte_genotypes.txt `


Then in the snp_positions.txt, I removed the header (so the header wouldn't not be sorted into the marker data). Then I sorted the header-less file.


>`$ sed '1d' snp_position.txt | sort -k1,1  > snp_position_sorted.txt `
>
>`$ sort -k1,1 -c snp_position_sorted.txt   `



Next I cut out the columns SNP_ID, Chr and Pos, and put them in a new file in preparation to join. 

>`$ cut -f 1,3,4 snp_position_sorted.txt > snp_for_join.txt `


Then in the transposed files, I removed the 3 header rows (so the header wouldn't not be sorted into the marker data), and then I sorted the files.


>`$ sed '1,3d' transposed_maize_genotypes.txt | sort -k1,1  > transposed_maize_genotypes_sorted.txt `
>
>`$ sed '1,3d' transposed_teosinte_genotypes.txt | sort -k1,1  > transposed_teosinte_genotypes_sorted.txt `



Finally, the files are sorted without headers so I can join them. I added the -t $'\t' to make it tab delimited instead of white space.

>`$ join -1 1 -2 1 snp_for_join.txt transposed_maize_genotypes_sorted.txt -t $'\t' > maize_full.txt `
>
>`$ join -1 1 -2 1 snp_for_join.txt transposed_teosinte_genotypes_sorted.txt -t $'\t' > teosinte_full.txt `

To create 10 files, I used a `while` loop, making sure to pass the shell variable to `awk`. The shell variable for chr is "i" and the awk variable is "awk\_i". This creates 10 sorted files named maize_chr$i.txt. Then I did the same for teosinte.

>`$ i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' maize_full.txt | sort -k3,3n > maize_chr$i.txt; let i=i+1; done  `
>
>`$ i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' teosinte_full.txt | sort -k3,3n > teosinte_chr$i.txt; let i=i+1; done  `

Then I reverse sorted and changed ?/? to -/- for both the maize and teosinte files.

>`$ i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' maize_full.txt | sort -k3,3nr | sed 's/\?/-/g'  > maize_rev_chr$i.txt; let i=i+1; done  `
>
>`$ i=1; while [[ $i -le 10 ]]; do awk -v awk_i=$i '$2 == awk_i' teosinte_full.txt | sort -k3,3nr | sed 's/\?/-/g'  > teosinte_rev_chr$i.txt; let i=i+1; done  `


Next I created the files with SNPs with unknown positions.
>`$ grep "unknown" maize_full.txt > maize_chr_unknown.txt `ls
>
>`$ grep "unknown" teosinte_full.txt > teosinte_chr_unknown.txt `

Finally I created the files with SNPs with multiple positions.
>`$ grep "multiple" maize_full.txt > maize_chr_multiple.txt `
>
>`$ grep "multiple" teosinte_full.txt > teosinte_chr_multiple.txt `


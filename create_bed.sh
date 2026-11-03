#!/bin/bash

# Define the input and output files
input_file=$1
output_file=$2

# Initialize variables
current_start=0
current_end=0
last_position=0 #unused variable?

#sorts chr.txt by numeric order and read line by line
#if line number = 1, set current_start and current_end to the first position
#for rest of SNPs, if SNP position is outside 8 Mb of current_start, print new bed line and set a new current_start
#if not, move onto next SNP
#at last SNP, just print the last positions left
sort -n ${input_file} | awk '
BEGIN { region_size=8000000; }
{
    if (NR == 1) { 
        current_start = $1;
        current_end = $1;
    } else {
        if ($1 > current_start + region_size) {
            print current_start "\t" current_end;
            current_start = current_end;
        }
    }
    current_end = $1;
}
END {
    print current_start "\t" current_end;
}' > $2

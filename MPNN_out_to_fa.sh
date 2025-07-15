#!/bin/bash

input_folder="/home/rmcl/sopes/LHD101_MPNN_outputs/seqs"
output_file="combined_sequences.fa"

# Clear output file
# > "$output_file"

counter=1

for file in "$input_folder"/*; do
    scores=($(grep '^>T=' "$file" | sed -n 's/.*score=\([0-9.]*\).*/\1/p'))

    keep_file=false
    for score in "${scores[@]}"; do
        score_cmp=$(awk "BEGIN {print ($score < 1.1)}")
        if [[ "$score_cmp" == 1 ]]; then
            keep_file=true
            break
        fi
    done

    if [[ "$keep_file" == false ]]; then
        echo "No score < 1.1 in $file, skipping."
        continue
    fi

    seq_lines=($(grep -n '^>T=' "$file" | cut -d: -f1))

    if [[ ${#seq_lines[@]} -lt 2 ]]; then
        echo "Less than 2 sequences in $file, skipping."
        continue
    fi

    line1=$((seq_lines[0] + 1))
    line2=$((seq_lines[1] + 1))

    chainA=$(sed -n "${line1}p" "$file")
    chainB=$(sed -n "${line2}p" "$file")

    echo ">complex${counter}_A_B" >> "$output_file"
    echo "${chainA}:${chainB}" >> "$output_file"

    echo ">complex${counter}_A_A" >> "$output_file"
    echo "${chainA}:${chainA}" >> "$output_file"

    echo ">complex${counter}_B_B" >> "$output_file"
    echo "${chainB}:${chainB}" >> "$output_file"

    echo ">complex${counter}_B" >> "$output_file"
    echo "${chainB}" >> "$output_file"

    echo ">complex${counter}_A" >> "$output_file"
    echo "${chainA}" >> "$output_file"

    ((counter++))
done

echo "Done! Extracted $((counter - 1)) complexes to $output_file"

#!/bin/bash

output_file="ntru_best_parameters_per_length.csv"

echo "mLen,N,q,dF,dg,dr,actual_encryption_time,actual_decryption_time" > $output_file

function test_parameters {
    local mLen=$1
    local N=$2
    local q=$3
    local dF=$4
    local dg=$5
    local dr=$6

    python3 NTRU.py -G -N $N -q $q -df $dF -dg $dg -d $dr -k temp_key > /dev/null 2>&1
    dd if=/dev/urandom bs=1 count=$mLen of=temp_message > /dev/null 2>&1

    # Measure actual encryption time
    start_time=$(date +%s%N)
    python3 NTRU.py -k temp_key -eF temp_message -O encrypted_message > /dev/null 2>&1
    end_time=$(date +%s%N)
    actual_encryption_time=$((($end_time - $start_time) / 1000000))

    # Measure actual decryption time
    start_time=$(date +%s%N)
    python3 NTRU.py -k temp_key -dF encrypted_message -O decrypted_message > /dev/null 2>&1
    end_time=$(date +%s%N)
    actual_decryption_time=$((($end_time - $start_time) / 1000000))

    echo "$actual_encryption_time,$actual_decryption_time"
}

# Function to find the best parameters for a given message length
function find_best_parameters {
    local mLen=$1
    local best_encryption_time=99999999
    local best_decryption_time=99999999
    local best_params=""

    # Try different parameter combinations
    for i in $(seq 1 100); do
        # Generate random parameters
        N=$((RANDOM % 1024 + 256)) 
        q=$((RANDOM % 2048 + 512))
        dF=$((RANDOM % 20 + 1))     
        dg=$((RANDOM % 20 + 1))    
        dr=$((RANDOM % 20 + 1))

        # Test parameters and get actual times
        read -r actual_encryption_time actual_decryption_time <<< $(test_parameters $mLen $N $q $dF $dg $dr)

        # Check if this combination is better
        if [[ $actual_encryption_time -lt $best_encryption_time && $actual_decryption_time -lt $best_decryption_time ]]; then
            best_encryption_time=$actual_encryption_time
            best_decryption_time=$actual_decryption_time
            best_params="$N,$q,$dF,$dg,$dr"
        fi
    done

    # Write best parameters and times to the output file
    echo "$mLen,$best_params,$best_encryption_time,$best_decryption_time" >> $output_file
}

# Loop through message lengths from 1 to 500
for mLen in $(seq 1 500); do
    echo "Finding best parameters for message length $mLen..."
    find_best_parameters $mLen
done

echo "All tests completed. Results are saved in '$output_file'."

#!/bin/bash

# Best parameter sets to test
best_params=(
    "503 128 80 90 90 500"
    "503 512 90 50 90 300"
)

# Output file
output_file="ntru_best_performance_data.csv"

# Write header
echo "N,q,dF,dg,dr,mLen,key_gen_time,encryption_time,decryption_time" > $output_file

# Test function
function test_parameters {
    local N=$1
    local q=$2
    local dF=$3
    local dg=$4
    local dr=$5
    local mLen=$6

    # Generate keys
    echo "Generating keys for N=$N, q=$q, dF=$dF, dg=$dg, dr=$dr..."
    start_time=$(date +%s%N)
    python3 NTRU.py -G -N $N -q $q -df $dF -dg $dg -d $dr -k temp_key > /dev/null 2>&1
    end_time=$(date +%s%N)
    key_gen_time=$((($end_time - $start_time) / 1000000))

    # Generate random message
    dd if=/dev/urandom bs=1 count=$mLen of=temp_message > /dev/null 2>&1

    # Measure encryption time
    echo "Encrypting message of length $mLen..."
    start_time=$(date +%s%N)
    python3 NTRU.py -k temp_key -eF temp_message -O encrypted_message > /dev/null 2>&1
    end_time=$(date +%s%N)
    encryption_time=$((($end_time - $start_time) / 1000000))

    # Measure decryption time
    echo "Decrypting encrypted message..."
    start_time=$(date +%s%N)
    python3 NTRU.py -k temp_key -dF encrypted_message -O decrypted_message > /dev/null 2>&1
    end_time=$(date +%s%N)
    decryption_time=$((($end_time - $start_time) / 1000000))

    # Log results
    echo "$N,$q,$dF,$dg,$dr,$mLen,$key_gen_time,$encryption_time,$decryption_time" >> $output_file
    echo "Completed N=$N, q=$q, dF=$dF, dg=$dg, dr=$dr, mLen=$mLen - Key generation time: $key_gen_time ms, Encryption time: $encryption_time ms, Decryption time: $decryption_time ms"
}

# Loop over the best parameter sets
echo "Starting performance tests for best parameter sets..."
for params in "${best_params[@]}"; do
    test_parameters $params
done

echo "Performance testing complete. Results saved to $output_file."

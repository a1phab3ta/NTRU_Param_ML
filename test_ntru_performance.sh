#!/bin/bash

# Parameters to test
N_values=(107 167 251 347 503)
q_values=(128 256 512)
dF_values=(50 60 70 80 90)
dg_values=(50 60 70 80 90)
dr_values=(50 60 70 80 90)
mLen_values=(100 200 300 400 500)

# Output file
output_file="ntru_performance_data.csv"

# Write header
echo "N,q,dF,dg,dr,mLen,encryption_time,decryption_time" > $output_file

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
    python3 NTRU.py -G -N $N -q $q -df $dF -dg $dg -d $dr -k temp_key > /dev/null 2>&1

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
    echo "$N,$q,$dF,$dg,$dr,$mLen,$encryption_time,$decryption_time" >> $output_file
    echo "Completed N=$N, q=$q, dF=$dF, dg=$dg, dr=$dr, mLen=$mLen - Encryption time: $encryption_time ms, Decryption time: $decryption_time ms"
}

# Loop over all parameter values
echo "Starting performance tests..."
for N in "${N_values[@]}"; do
    for q in "${q_values[@]}"; do
        for dF in "${dF_values[@]}"; do
            for dg in "${dg_values[@]}"; do
                for dr in "${dr_values[@]}"; do
                    for mLen in "${mLen_values[@]}"; do
                        test_parameters $N $q $dF $dg $dr $mLen
                    done
                done
            done
        done
    done
done


echo "Performance testing complete. Results saved to $output_file."

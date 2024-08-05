#!/bin/bash

# Input file with predicted parameters
input_file="predicted_parameters.csv"

# Output file for results
output_file="ntru_best_performance_data.csv"

# Maximum allowed encryption and decryption time in milliseconds
max_time=30

# Write header
echo "mLen,N,q,dF,dg,dr,key_gen_time,encryption_time,decryption_time" > $output_file

# Initialize counters
total_count=0
count_within_criteria=0

# Function to test parameters
function test_parameters {
    local mLen=$1
    local N=$2
    local q=$3
    local dF=$4
    local dg=$5
    local dr=$6

    echo "Testing message length $mLen with parameters N=$N, q=$q, dF=$dF, dg=$dg, dr=$dr..."

    # Generate keys
    echo "Generating keys..."
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

    # Check if the times are within the allowed limit
    if [ "$encryption_time" -le "$max_time" ] && [ "$decryption_time" -le "$max_time" ]; then
        # Log the results
        echo "$mLen,$N,$q,$dF,$dg,$dr,$key_gen_time,$encryption_time,$decryption_time" >> $output_file
        echo "Parameters for message length $mLen meet the criteria: Encryption time: $encryption_time ms, Decryption time: $decryption_time ms"
        count_within_criteria=$((count_within_criteria + 1))
    else
        echo "Parameters for message length $mLen do not meet the criteria. Encryption time: $encryption_time ms, Decryption time: $decryption_time ms"
    fi

    total_count=$((total_count + 1))
}

# Read the parameters and test each
while IFS=, read -r mLen N q dF dg dr
do
    if [[ $mLen != "mLen" ]]; then  # Skip header
        test_parameters $mLen $N $q $dF $dg $dr
    fi
done < $input_file

# Calculate the percentage of parameter sets meeting the criteria
if [ $total_count -ne 0 ]; then
    percentage=$(echo "scale=2; ($count_within_criteria / $total_count) * 100" | bc)
else
    percentage=0
fi

echo "Parameter testing complete. Results saved to $output_file."
echo "Percentage of parameter sets meeting the criteria: $percentage%"

source ~/.research_config

# Define the allowed arguments
valid_args=("gasp_cis" "gasp_trans" "rd7_trans")

# function to check if argument is valid
is_valid_arg() {
    local arg="$1"
    for valid in "${valid_args[@]}"; do
        if [[ "$arg" == "$valid" ]]; then
            return 0
        fi
    done
    return 1
}

# Check if at least one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <gasp_cis|gasp_trans|rd7_trans>"
    exit 1
fi

# Check if the provided argument is valid
if is_valid_arg "$1"; then
    echo "Valid command: $1"
else
    echo "Invalid command: $1. Allowed commands are: ${valid_args[*]}"
    exit 1
fi

scp -r timbar@hpc3.wharton.upenn.edu:~/data/projects/sceptre3/nf_pipelines/$1 $LOCAL_SCEPTRE3_DATA_DIR/nf_pipelines
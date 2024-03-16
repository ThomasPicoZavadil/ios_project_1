

POSIXLY_CORRECT=yes

after_date="0"
before_date="999999"
username=""
log_files=()
currency_codes=()

# Flag to indicate whether the next argument should be treated as a currency code
add_currency=false

# Collect log files and currency codes from command line arguments
for arg in "$@"; do
    if [[ "$arg" == *.log ]]; then
        # Add log file to the array
        log_files+=("$arg")
    elif [[ "$arg" == "-c" ]]; then
        # Set the flag to true to indicate that the next argument should be treated as a currency code
        add_currency=true
    elif [[ "$add_currency" == true ]]; then
        # Add the currency code to the array
        currency_codes+=("$arg")
        # Reset the flag for the next iteration
        add_currency=false
    fi
done

# Iterate over each log file
for log_file in "${log_files[@]}"; do
    # Process command line arguments for this log file
    for arg in "$@"; do
        case "$arg" in
            "-a")
                after_date=$2
                shift 2
                ;;
            "-b")
                before_date=$2
                shift 2
                ;;
            "-c")
                # Skip -c and its argument
                shift 2
                ;;
            "list")
                shift
                username=$1
                # Iterate over each currency code and apply the filter
                for code in "${currency_codes[@]}"; do
                    awk -F';' -v code="$code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && $1 == user' "$log_file"
                done
                ;;
            "list-currency")
                shift
                username=$1
                # Iterate over each currency code and apply the filter
                for code in "${currency_codes[@]}"; do
                    awk -F';' -v code="$code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && !seen[$3]++ && $1 == user {print $3}' "$log_file" | sort
                done
                ;;
            "status")
                shift
                username=$1
                # Iterate over each currency code and apply the filter
                for code in "${currency_codes[@]}"; do
                    awk -F';' -v code="$code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, currency[c] }' "$log_file" | sort
                done
                ;;
            "profit")
                shift
                username=$1
                # Iterate over each currency code and apply the filter
                for code in "${currency_codes[@]}"; do
                    awk -F';' -v code="$code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, (currency[c] > 0) ? currency[c] * 1.2 : currency[c] }' "$log_file" | sort
                done
                ;;
        esac
    done
done

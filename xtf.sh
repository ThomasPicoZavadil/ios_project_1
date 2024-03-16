after_date="0"
before_date="999999"
username=""
log_files=()

for arg in "$@"; do
    # Check if the argument ends with ".log"
    if [[ "$arg" == *.log ]]; then
        # Add the argument to the log_files array
        log_files+=("$arg")
    fi
done

# Print the names of the log files
for file in "${log_files[@]}"; do
    echo "$file"
done

for log_file in "${log_files[@]}"; do
    while [ "$#" -gt 0 ]; do
        case "$1" in
            "-a")
                after_date=$2
                shift
                ;;
            "-b")
                before_date=$2
                shift
                ;;
            "-c")
                currency_code=$2
                shift
                ;;
            "list")
                shift
                username=$1
                awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && $1 == user' "$log_file"
                ;;
            "list-currency")
                shift
                username=$1
                awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && !seen[$3]++ && $1 == user {print $3}' "$log_file" | sort
                ;;
            "status")
                shift
                username=$1
                awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, currency[c] }' "$log_file" | sort
                ;;
            "profit")
                shift
                username=$1
                awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after && $3 == code || before=="" || after=="" || code=="") && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, (currency[c] > 0) ? currency[c] * 1.2 : currency[c] }' "$log_file" | sort
                ;;
        esac
        shift
    done
    shift
done

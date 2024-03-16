#invalid date formát
#předělat help
#zakázat 2 usery
#zakázat 2 commandy
#dodělat xtf_profit
#zakázat xtf_profit > 100
#zakázat 2 argumenty pro datum stejného typu
#kontrola logů

export POSIXLY_CORRECT=yes
XTF_PROFIT=${XTF_PROFIT:=20}

after_date=""
before_date=""
username=""
command="list"
unknown=()
log_files=()

filter() {
    if [[ $command == "list" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user' "$log_file"
    elif [[ $command == "list-currency" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user {print $3}' "$log_file" | sort | uniq
    elif [[ $command == "status" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, currency[c] }' "$log_file" | sort
    elif [[ $command == "profit" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, (currency[c] > 0) ? currency[c] * 1.2 : currency[c] }' "$log_file" | sort
    fi
}

main () {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -a)
                after_date=$2
                shift 2  # Move to the next option after shifting the value of -a
                ;;
            -b)
                before_date=$2
                shift 2  # Move to the next option after shifting the value of -b
                ;;
            -c)
                currency_code=$2
                shift 2  # Move to the next option after shifting the value of -c
                ;;
            -h|--help)
                echo ""
                echo "Usage: $0 [-h|--help] [FILTR] [PŘÍKAZ] UŽIVATEL LOG [LOG2 [...]]"
                echo "Options:"
                echo "  -h, --help       Display this help message"
                echo "  FILTR            Options: -a DATETIME, -b DATETIME, -c CURRENCY"
                echo "  PŘÍKAZ           Command: list, list-currency, status, profit"
                echo "  UŽIVATEL         User identifier"
                echo "  LOG              List of .log files"
                echo ""
                exit 0
                ;;
            list|list-currency|status|profit)
                command=$1
                shift
                ;;
            *)
                unknown+=("$1")
                shift
                ;;
        esac
    done

    for unk in "${unknown[@]}"; do
        if [[ $unk == "${unknown[0]}" && -z "$username" ]]; then
            username="$unk"
        else
            log_files+=("$unk")
        fi
    done

    for log in "${log_files[@]}"; do
        if [[ -f "$log" ]]; then
            if [[ "$log" == *.gz ]]; then
                gunzip -c "$log"
            else
                cat "$log"
                echo ""
            fi
        fi
    done | filter
}

main "$@"
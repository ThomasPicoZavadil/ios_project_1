after_date="0"
before_date="999999"
username=""

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
        "list")
            shift
            username="$1"
            awk -F';' -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after || before=" " || after=" ") && $1 == user' burza.log
            ;;
        "list-currency")
            shift
            username="$1"
            awk -F';' -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > after || before=" " || after=" ") !seen[$3]++ && $1 == user {print $3}' burza.log | sort
            ;;
        "status")
            shift
            username="$1"
            awk -F';' -v after="$after_date" -v before="$before_date" -v user="$username" '($2 < before && $2 > $after_date || before=" " || after=" ") && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, currency[c] }' burza.log | sort
            ;;
        "profit")
            shift
            username="$1"
            awk -F';' -v user="$username" -v datetime_arg="$after_date" '
                $1 == user && ($2 > datetime_arg || datetime_arg == "") { currency[$3] += $4 }
                END { for (c in currency) printf "%s : %.4f\n", c, (currency[c] > 0) ? currency[c] * 1.2 : currency[c] }' burza.log | sort
            ;;
    esac
    shift
done
#!/bin/bash

export POSIXLY_CORRECT=yes
XTF_PROFIT=${XTF_PROFIT:=20}

#deklarace proměnných a polí
after_date=""
before_date=""
currency_code=""
username=""
command="list"
unknown=()
log_files=()
user_counter=0
command_counter=0
after_counter=0
before_counter=0

#funkce pro kontrolu formátu data
check_format() {
    local formatted_date

    #datum ze vstupu je předěláno do správného formátu a to je potom porovnáno s původním datem
    #pokud se data shodují (resp. nebyly provedeny žádné změny) datum je schváleno
    if [[ -n "$after_date" ]]; then
        formatted_date=$(date -d "$after_date" +"%Y-%m-%d %H:%M:%S")
        if [ "$after_date" != "$formatted_date" ]; then
            exit 1
        fi
    elif [[ -n "$before_date" ]]; then
        formatted_date=$(date -d "$before_date" +"%Y-%m-%d %H:%M:%S")
        if [ "$before_date" != "$formatted_date" ]; then
            exit 1
        fi
    fi
}

#funkce pro filtrování záznamů podle příkazů a filtrů
#logické funkce s filtry after, before a currency jsou true v případach, ve kterých argument buď není poskytnut, nebo splňuje požadavky
#pro příkazy list-currency, status a profit, jsou použity příkazy sort, pro seřazení měn podle abecedy
#pro list-currency je zároveň použit uniq, aby se zajistilo, že každý kód s vypíše nanejvýš jednou
filter () {
    if [[ $command == "list" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user' "$log_file"
    elif [[ $command == "list-currency" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user {print $3}' "$log_file" | sort | uniq
    elif [[ $command == "status" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, currency[c] }' "$log_file" | sort
    elif [[ $command == "profit" ]]; then
        awk -F';' -v code="$currency_code" -v after="$after_date" -v before="$before_date" -v user="$username" -v profit="$XTF_PROFIT" '(($2 < before || before=="") && ($2 > after || after=="") && ($3 == code || code=="")) && $1 == user { currency[$3] += $4 } END { for (c in currency) printf "%s : %.4f\n", c, (currency[c] > 0) ? currency[c] + currency[c] * profit / 100 : currency[c] }' "$log_file" | sort
    fi
}

main () {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            -a)
                ((after_counter++))     #sleduje se počet zadaných argumentů after, aby se zabránilo zadání více stejných argumentů
                after_date=$2
                shift 2
                check_format            #formát data je následně zkontrolován
                ;;
            -b)
                ((before_counter++))    #sleduje se počet zadaných argumentů before, aby se zabránilo zadání více stejných argumentů
                before_date=$2
                shift 2
                check_format
                ;;
            -c) #kód měny je zde uložen pro následné filtrování
                currency_code=$2
                shift 2
                ;;
            -h|--help)  #vypsání nápovědy
                echo ""
                echo "Použití: $0 [-h|--help] [FILTR] [PŘÍKAZ] UŽIVATEL LOG [LOG2 [...]]"
                echo ""
                echo "PŘÍKAZ může být jeden z:"
                echo "  list – výpis záznamů pro daného uživatele"
                echo "  list-currency – výpis seřazeného seznamu vyskytujících se měn"
                echo "  status – výpis skutečného stavu účtu seskupeného a seřazeného dle jednotlivých měn"
                echo "  profit – výpis stavu účtu zákazníka se započítaným fiktivním výnosem"
                echo ""
                echo "FILTR může být kombinace následujících:"
                echo "  -a DATETIME – after: jsou uvažovány pouze záznamy PO tomto datu a čase (bez něj). DATETIME je formátu YYYY-MM-DD HH:MM:SS"
                echo "  -b DATETIME – before: jsou uvažovány pouze záznamy PŘED tímto datem a časem (bez něj)"
                echo "  -c CURRENCY – jsou uvažovány pouze záznamy odpovídající dané měně"
                echo ""
                echo "-h a --help vypíšou nápovědu"
                exit 0
                ;;
            list|list-currency|status|profit)   #pokud se argument rovná jednomu s příkazů, je jeho jméno uloženo do proměnné command
                ((command_counter++))           #zároveň se sleduje počet zadaných commandů, aby se zabránilo zadání více příkazů
                command=$1
                shift
                ;;
            *)  #pokud argument neodpovídá žádné z možností, je přesunut do pole unknown, aby se zjistilo, zda se jedná o jméno uživatele, nebo souboru
                unknown+=("$1")
                shift
                ;;
        esac
    done

    for unk in "${unknown[@]}"; do
        if [[ $unk != *.log && $unk != *.gz ]]; then    #pokud argument nekončí koncovkou .log nebo .gz, je považován za uživatelské jméno
            username="$unk"                             
            ((user_counter++))                          #zároveň se sleduje počet položek v poli username, aby se zabránilo případnému zadání více uživatelských jmen
        else
            log_files+=("$unk")                         #pokud argument končí jednou z uvedených koncovek, je považován za soubor
        fi
    done

    if [[ $user_counter != 1 || $after_counter > 1 || $before_counter > 1 || $command_counter > 1 ]]; then  #kontrola, zda některý z argumentů nebyl zapsán vícekrát
        exit 1
    fi

    for log in "${log_files[@]}"; do
        if [[ -f "$log" ]]; then
            if [[ "$log" == *.gz ]]; then
                gunzip -c "$log"    #rozbalování souborů komprimovaných pomocí gzip
            else
                cat "$log"
                echo ""
            fi
        fi
    done | filter
}

main "$@"
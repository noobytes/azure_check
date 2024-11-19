#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 [-f filename] [-d domain] [-h]"
    echo
    echo "Options:"
    echo "  -f filename   Provide a text file with multiple target domains (one per line)."
    echo "  -d domain     Specify a single target domain."
    echo "  -h            Display this help message."
}

# Function to check domain management status
check_domain() {
    local domain=$1
    local url="https://login.microsoftonline.com/getuserrealm.srf?login=username@$domain.onmicrosoft.com&xml=1"
    local response=$(curl -s "$url")

    # Define colors for output
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color

    if echo "$response" | grep -q "<NameSpaceType>Managed</NameSpaceType>"; then
        echo -e "${GREEN}[✔] $domain is managed by Azure${NC}"
    else
        echo -e "${RED}[✘] $domain is not managed by Azure or the response does not contain the expected data.${NC}"
    fi
}

# Handle options
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

while getopts ":f:d:h" opt; do
    case $opt in
        f)
            file=$OPTARG
            if [[ -f $file ]]; then
                while IFS= read -r domain; do
                    check_domain "$domain"
                done < "$file"
            else
                echo "Error: File '$file' not found."
                exit 1
            fi
            ;;
        d)
            domain=$OPTARG
            check_domain "$domain"
            ;;
        h)
            show_help
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
    esac
done


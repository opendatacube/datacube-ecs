#!/bin/bash
# Index new datasets and update ranges for WMS
# should be run after archiving old datasets so that
# ranges for WMS are correct
# environment variables:
# Usage: -p prefix(es) for search. If multiple use space seperated list enclosed in quotes
#        -b bucket containing data
#        -s suffix for search (optional). If multiple use space separated list enclosed in quotes
#                                         If multiple must be same length as prefix list,
#                                         if only one provided, suffix will be applied to ALL prefixes
# e.g. ./update_ranges -b dea-public-data -p "L2/sentinel-2-nrt/S2MSIARD/2018 L2/sentinel-2-nrt/2017"

usage() { echo "Usage: $0 -p <prefix> -b <bucket> [-s <suffix>]" 1>&2; exit 1; }

while getopts ":p:b:s:" o; do
    case "${o}" in
        p)
            prefix=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
        s)
            suffix=${OPTARG}
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${prefix}" ] || [ -z "${b}" ]; then
    usage
fi

IFS=' ' read -r -a prefixes <<< "$prefix"
IFS=' ' read -r -a suffixes <<< "$suffix"
first_suffix="${suffixes[0]}"

# index new datasets
# prepare script will add new records to the database
for i in "${!prefixes[@]}"
do
    if [ -z "${suffixes[$i]}"  ] && [ -z "${first_suffix}" ]
    then
        suffix_string=""
    elif [ -z "${suffixes[$i]}" ]
    then
        suffix_string="--suffix ${first_suffix}"
    else
        suffix_string="--suffix ${suffixes[$i]}"
    fi

    printf "prefix %s suffix %s \n" "${prefixes[$i]}" "$suffix_string"
    python3 indexing/ls_s2_cog.py $b --prefix "${prefixes[$i]}" "$suffix_string"
done

# update ranges in wms database
python3 update_ranges.py
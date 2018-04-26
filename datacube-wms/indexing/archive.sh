#!/bin/bash
# Archive datasets in prefixes older than specified number of days
# Usage: -d days prior to current date to archive
#        -p prefix for search
#        -b bucket containing data

while getopts ":d:b:p" o; do
    case "${o}" in
        d)
            d=${OPTARG}
            ;;
        p)
            p=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
    esac
done
shift $((OPTIND-1))

# d is number of days older than current date
# calculate date string
todate=$(date -d"$(date) -${d} day" +%s)

# list of folders with names formated to be %Y-%m-%d
# grep for "PRE" to get folders
folders=$(aws s3 ls s3://${b}/${p} | grep "PRE " | awk '{print $2}' | sed 's/\/$//')

# archive data in folders older than todate
for folder in $folders; do
    if [ $todate -ge  $(date -d $folder +%s) ]; then
        python ls_s2_cog.py ${b} --prefix ${p}/$folder --archive
    fi
done

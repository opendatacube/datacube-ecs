#!/bin/bash
# Archive datasets in prefixes older than specified number of days
# Usage: -d days prior to current date to archive
#        -p prefix for search
#        -b bucket containing data

usage() { echo "Usage: $0 [-d <days>] [-p <prefix>] [-b <bucket>]" 1>&2; exit 1; }

while getopts ":d:p:b:" o; do
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

if [ -z "${d}" ] || [ -z "${p}" ] || [ -z "${b}" ]; then
    usage
fi

# d is number of days older than current date
# calculate date string
todate=$(gdate -d"$(gdate) -${d} day" +%s)

# trim trailing '/' from prefix, we are adding it by default in search
p=${p%/}

# list of folders with names formated to be %Y-%m-%d
# grep for "PRE" to get folders
folders=$(aws s3 ls s3://${b}/${p}/ | grep "PRE " | awk '{print $2}' | sed 's/\/$//')
echo $folders
# archive data in folders older than todate
for folder in $folders; do
    if [ $todate -gt $(gdate -d $folder +%s) ]; then
        python ls_s2_cog.py ${b} --prefix ${p}/$folder --archive
    fi
done

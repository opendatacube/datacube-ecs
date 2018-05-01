#!/bin/bash
# Index new datasets and update ranges for WMS
# should be run after archiving old datasets so that
# ranges for WMS are correct
# environment variables:
# Usage: -p prefix(es) for search. If multiple use space seperated list enclosed in quotes
#        -b bucket containing data
# e.g. ./update_ranges -b dea-public-data -p "L2/sentinel-2-nrt/S2MSIARD/2018 L2/sentinel-2-nrt/2017"

usage() { echo "Usage: $0 [-p <prefix>] [-b <bucket>]" 1>&2; exit 1; }

while getopts ":p:b:" o; do
    case "${o}" in
        p)
            prefixes=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${prefixes}" ] || [ -z "${b}" ]; then
    usage
fi

# index new datasets
# prepare script will add new records to the database
for p in $prefixes
do
    python indexing/ls_s2_cog.py $b --prefix $p
done

# update ranges in wms database
python update_ranges.py
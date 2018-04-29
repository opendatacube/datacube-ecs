#!/bin/bash
# Index new datasets and update ranges for WMS
# should be run after archiving old datasets so that
# ranges for WMS are correct
# Usage: -p prefix for search
#        -b bucket containing data
# e.g. ./update_ranges dea-public-data L2/sentinel-2-nrt/S2MSIARD

usage() { echo "Usage: $0 [-p <prefix>] [-b <bucket>]" 1>&2; exit 1; }

while getopts ":p:b:" o; do
    case "${o}" in
        p)
            p=${OPTARG}
            ;;
        b)
            b=${OPTARG}
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${p}" ] || [ -z "${b}" ]; then
    usage
fi

# index new datasets
# prepare script will add new records to the database
python /ls_s2_cog.py $b --prefix $p

# update ranges in wms database
python datacube-wms/update_ranges.py
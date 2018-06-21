#! /usr/bin/env bash
# Pass the URL of the service to this script
# requires jq https://github.com/stedolan/jq

# Test for existance of tests folder
# Not all things will be testable with newman
# e.g. db setup, indexing
if [ ! -f "tests/${WORKSPACE}/${WORKSPACE}.data.json" ]
then
    echo "Test data not found, exiting..."
    exit 0
fi

# newman doesn't accept multiple data files yet
# process the json to add the service url
cat tests/${WORKSPACE}/${WORKSPACE}.data.json\
    | jq --arg SERVICEURL "http://$1" '[.[] | .path = $SERVICEURL]'\
    > "${WORKSPACE}-data.json"

newman run tests/${WORKSPACE}/${WORKSPACE}.postman_collection.json -d ${WORKSPACE}.data.json
success="$?"
rm "${WORKSPACE}-data.json"
exit "$success"
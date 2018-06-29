# Datacube ECS Service Tests

This folder contains test data and test collections for performing manual and automatic integration tests on Datacube ECS web services.

## Requirements
### Test Creation & Local Testing
+ Postman (https://www.getpostman.com/)

### Automated Testing
+ NodeJS >= v4
+ newman (https://www.npmjs.com/package/newman)

## Collections
Each web service has it's own folder with an exported Postman test collection and any test data required by the test collection.

### Collection Management
Tests for a webservice should be in a folder matching the service folder in `workspaces`. e.g. for Near Real Time Australia, the folder should be called nrt-au; for Cambodia Cube Geomedian the folder should be called `cc-geomedian`.

Each test collection JSON file should match the folder name and be followed by `.postman_collection.json`. e.g. for Near Real Time Australia, the collection file should be called `nrt-au.postman_collection.json`.

The data file for the test collection should match the folder name and by followed by `.data.json`. e.g. for Near Real Time Australia, the data file should be called `nrt-au.data.json`

As an example, the Near Real Time Australia folder will contain:
+ `nrt-au`
    + `nrt-au.postman_collection.json`
    + `nrt-au.data.json`

#### git
To use a test collection in Postman, use the `Import` option in Postman and select the `workspace.postman_collection.json` file. If you make changes to the collection, save the collection and use the export functionality to save the collection to `workspace.postman_collection.json`. If another person updates the collection you will need to `Import` the collection again to see the latest changes.

### Requests
In the datacube-ecs workspaces we use the `{{path}}` data variable to specify the service location (i.e. nrt-au.dea.ga.gov.au or geomedian.alb.amazons3.com). This `{{path}}` integrates with the `run_tests.sh` script discussed later.

### data.json
If using `run_tests.sh` the only requirement for `data.json` is each data object containing a `path` entry. This `path` entry will be overwritten by the `run_tests.sh` script.

### Running Collections Locally
Using the Postman Collection Runner is the easiest way to test services locally. Make sure to select the corresponding data file for the test collection.

## Running with Travis
Following the Postman guide to running with Travis (http://blog.getpostman.com/2017/08/23/integrate-api-tests-with-postman-newman-and-travis-ci/) will get the Travis process up and running. If using datacube-ecs workspaces there is a script available to automatically run tests and use data.

### run_tests.sh
The URL of the webservice is passed to `run_tests.sh` without protocol. e.g. `run_tests.sh nrt-au.alb.aws.com` The script will update the data file with the URL using HTTP protocol.



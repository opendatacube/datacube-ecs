# datacube-ecs
EC2 Container Service for Datacube

Installation
Requires software:
`docker`
`docker-compose`



## Docker Containers
### `docker-compose.yml`
Includes:
 * local postgres server (running on 5432) *TODO: Make private*
 * conda environment
 * datacube install
 * jupyter notebook (running on port 80)
The jupyter notebook will require a token to access it, which is availible from the console output.
This menas you will not be able to run `docker-compose` in daemon mode.


### `docker-compose-wms.yml`
Includes:
 * local postgres server (running on 5432) *TODO: Make private*
 * conda environment
 * datacube install
 * datacube-wms server (rnning on port 80)
You will need to set the environment variable `PUBLIC_URL`
(eg to "http://localhost/" or "http://y-public-ip.ec2.amazon.com") for the server to correctly populate the URLs
in the GetCapabilities document.


## Main Terraform
### `main.tf`

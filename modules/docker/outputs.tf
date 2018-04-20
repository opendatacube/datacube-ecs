output "name_and_digest_ecs" {
  value = "${local.ecs_final_name}"
  description = "Name and SHA256 digest of a docker image formatted for use in an AWS ECS Task definition JSON file"
}
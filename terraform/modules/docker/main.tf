
locals {
  split_list            = "${split(":", var.image_name)}"
  image_name            = "${element(local.split_list, 0)}"
  image_name_digest     = "${list(local.image_name, var.image_digest)}"
  ecs_final_name        = "${join("@", local.image_name_digest)}"
}
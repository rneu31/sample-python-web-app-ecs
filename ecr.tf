resource "aws_ecr_repository" "default" {
    name  = "playdotstakehome"

    # Allow for overwriting of image tags (for now)
    image_tag_mutability = "MUTABLE"

    # Enable scanning when desired
    # image_scanning_configuration {
    #   scan_on_push = true
    # }

    # Encrypt the repository, use a CMK in the future.
    encryption_configuration {
      encryption_type = "AES256"
    }
}

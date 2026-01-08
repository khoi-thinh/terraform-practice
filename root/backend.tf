terraform {
  backend "s3" {
    bucket = "devsecops-terraform-khoi"
    key    = "terraform/2tier-project.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}
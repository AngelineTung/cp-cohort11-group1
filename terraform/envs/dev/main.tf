module "app" {
  source = "../../modules/main-app"

  # Pass variables from tfvars to the module
  owner        = var.owner
  environment  = var.environment
  project_name = var.project_name
  region       = var.region
  allowed_cidr = var.allowed_cidr
  vpc_cidr     = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs

  # Pass other necessary variables...
  cert_files   = var.cert_files
}

module "iot_storage" {
  source      = "../../modules/iot-storage"
  environment = var.environment
  tags        = var.tags
}

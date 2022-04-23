variable "cloud_id" {
  description = "Cloud"
  default     = "b1gjitf868lee0aep2g3"
}
variable "token" {
  description = "Token"
}
variable "folder_id" {
  description = "Folder"
  default     = "b1g0khvpb12jt8uta8rh"
}
variable "zone" {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-b"
}
variable "public_key_path" {
  # Описание переменной
  default     = "~/.ssh/ubuntu.pub"
  description = "Path to the public key used for ssh access"
}
variable "private_key_path" {
  # Описание переменной
  default     = "~/.ssh/ubuntu"
  description = "Path to the private key used for ssh access"
}
variable "network_id" {
  description = "Network"
  default     = "enpnnagedut59q35etsl"
}
variable "subnet_id" {
  description = "Subnet"
  default     = "e2lmcv4ijpe3ro522253"
}
variable "instance_count" {
  description = "Number of instances to create"
  default     = 1
}
variable "service_account_id" {
  description = "service account id"
  default     = "ajehu5bu9371elilueo3"
}
variable "node_service_account_id" {
  description = "node service account id"
  default     = "ajehu5bu9371elilueo3"
}
variable "service_account_key_file" {
  description = "service account key file"
  default     = "key.json"
}

variable "compartment_id" {
  description = "Compartment ID of OCI account (Tenant OCID for root compartment)"
  sensitive   = true
}

variable "instance_shape" {
  description = "Shape of the instance"
  default     = "VM.Standard.A1.Flex"
}

variable "instance_ssh_public_key" {
  description = "Public key added to ~/.ssh/authorized_keys on the instance"
  type        = string
}

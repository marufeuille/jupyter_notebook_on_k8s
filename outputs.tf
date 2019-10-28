output "managed_host_ip" {
    value = "${alicloud_instance.instance.public_ip}"
}

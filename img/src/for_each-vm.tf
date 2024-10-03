data "yandex_compute_image" "each_vm" {
  family = var.vm_web_family
}
variable "each_vm" {
  type = list(object({  vm_name=string, cpu=number, ram=number, core_fraction=number }))
  default = [
    {vm_name="main", cpu=4, ram=2, core_fraction=20},
    {vm_name="replica", cpu=2, ram=1, core_fraction=5}
  ]
}

resource "yandex_compute_instance" "each_vm" {
  for_each = { for i in var.each_vm : i.vm_name => i }
  name = each.value.vm_name
  resources {
    cores  = each.value.cpu
    memory = each.value.ram
    core_fraction = each.value.core_fraction
  }
  platform_id = var.platform


  scheduling_policy {
  preemptible = var.vm_preemptible
  }
  network_interface {
    security_group_ids = [yandex_vpc_security_group.example.id]
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = true
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.each_vm.image_id
    }
  }

  metadata = {
    ssh-keys = local.ssh-keys
    serial-port-enable = local.serial-port-enable
  }
}









resource "yandex_compute_disk" "default" {
  count = 3
  name     = "disk${count.index }"
  type     = "network-ssd"
  size = 1
  labels = {
    environment = "test"
  }
}

resource "yandex_compute_instance" "storage" {
  name = "storage"
  platform_id = var.platform
  resources {
        cores = 2
        memory = 1
        core_fraction = 5
  }
  scheduling_policy {
    preemptible = var.vm_preemptible
  }
  depends_on = [yandex_compute_instance.web, yandex_compute_disk.default, yandex_vpc_security_group.example]
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.web.image_id
    }
  }
  dynamic "secondary_disk" {
    for_each = yandex_compute_disk.default.*.id
    content {
      disk_id = secondary_disk.value
    }
  }
  network_interface {
        subnet_id = yandex_vpc_subnet.develop.id
        nat     = true
  }
  metadata = {
    ssh-keys = local.ssh-keys
    serial-port-enable = local.serial-port-enable
  }
}
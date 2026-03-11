variable "servers" {
  description = "Map of server name => IP address"
  type        = map(string)
  default = {
    templates1 = "154.38.178.174"
    templates2 = "154.38.178.251"
  }
}

variable "ssh_user" {
  type    = string
  default = "root"
}

variable "ssh_private_key_path" {
  type    = string
  default = "~/.ssh/id_rsa"
}

resource "null_resource" "ssh_tuning" {
  for_each = var.servers

  connection {
    type        = "ssh"
    host        = each.value
    user        = var.ssh_user
    private_key = file(pathexpand(var.ssh_private_key_path))
  }

  # sysctl tuning (rede e conexões)
  provisioner "file" {
    content = <<-SYSCTL
      net.core.somaxconn = 1024
      net.core.netdev_max_backlog = 5000
      net.ipv4.tcp_max_syn_backlog = 4096
      net.ipv4.tcp_tw_reuse = 1
      net.ipv4.tcp_fin_timeout = 15
      net.ipv4.tcp_keepalive_time = 300
      net.ipv4.tcp_keepalive_intvl = 30
      net.ipv4.tcp_keepalive_probes = 5

      fs.file-max = 1048576
    SYSCTL

    destination = "/etc/sysctl.d/99-network-tuning.conf"
  }

  # SSH tuning mínimo e seguro
  provisioner "file" {
    content = <<-SSHD
      MaxSessions 100
      MaxStartups 100:30:200
      MaxAuthTries 6
      UseDNS no
      ClientAliveInterval 60
      ClientAliveCountMax 10
      LoginGraceTime 30
    SSHD

    destination = "/etc/ssh/sshd_config.d/99-tuning.conf"
  }

  # aumentar ulimits
  provisioner "file" {
    content = <<-LIMITS
      * soft nofile 1048576
      * hard nofile 1048576
      root soft nofile 1048576
      root hard nofile 1048576
    LIMITS

    destination = "/etc/security/limits.d/99-ssh.conf"
  }

  provisioner "remote-exec" {
    inline = [

      # aplicar sysctl
      "sysctl --system",

      # validar ssh antes de reiniciar
      "sshd -t",

      # restart seguro
      "sshd -t && (systemctl restart ssh || systemctl restart sshd)",

      "echo tuning aplicado"
    ]
  }

  triggers = {
    version = "2"
  }
}

output "tuned_servers" {
  value = { for k, v in var.servers : k => "SSH tuning applied to ${v}" }
}
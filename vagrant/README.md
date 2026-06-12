# Entorno de VMs para el curso de Ansible

Dos nodos gestionados en VirtualBox vía Vagrant:

| VM        | SO                | Familia | IP             | Hostname             |
|-----------|-------------------|---------|----------------|----------------------|
| `rocky8`  | Rocky Linux 8     | RedHat  | 192.168.56.21  | rocky8.curso.local   |
| `ubuntu22`| Ubuntu 22.04 LTS  | Debian  | 192.168.56.22  | ubuntu22.curso.local |

Rocky Linux 8 es un clon binario 1:1 de RHEL 8 (mismo `dnf`, `httpd`, etc.).
Ambas son **headless** (sin entorno gráfico).

## Acceso SSH

Usuario `vagrant`, con **dos métodos** configurados en las dos VMs:

- **Clave privada**: `../proyectos/inventario/id_curso`
- **Contraseña**: `Pa$$w0rd2026` (login por password habilitado en sshd)

```bash
ssh -i ../proyectos/inventario/id_curso vagrant@192.168.56.21   # rocky8
ssh vagrant@192.168.56.22                                       # ubuntu22 (te pedirá la contraseña)
```

## Software instalado en rocky8

- **Ansible** (última versión vía pip con python3.11, no la del repo)
- **ansible-navigator**
- **podman**

## 1. Instalar VirtualBox y Vagrant (una sola vez)

```bash
brew install --cask virtualbox
brew install --cask vagrant
```

> VirtualBox pedirá tu contraseña de admin y, en Mac Intel, tendrás que
> **permitir la extensión de Oracle** en  Ajustes del sistema →
> Privacidad y seguridad (botón "Permitir") y reiniciar si lo pide.

Comprueba:

```bash
VBoxManage --version
vagrant --version
```

## 2. Levantar las VMs

Desde esta carpeta (`vagrant/`):

```bash
vagrant up            # levanta rocky8 y ubuntu22 (la 1ª vez descarga las boxes)
vagrant status        # estado
vagrant ssh rocky8    # entrar por SSH
vagrant ssh ubuntu22
```

## 3. Probar con Ansible

```bash
ansible -i inventario.ini all -m ping
```

## Comandos útiles

```bash
vagrant halt          # apagar
vagrant up rocky8     # arrancar solo una
vagrant reload        # reiniciar aplicando cambios del Vagrantfile
vagrant destroy -f    # borrar las VMs (las boxes descargadas se quedan)
```

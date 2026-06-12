# Desplegar/Instalar software

## Tradicionalmente

         App1  + App2  +  App3           Problemas graves!
    --------------------------------        - Dependencias/Configuraciones
           Sistema Operativo                - Seguridad (Potencialmente App1 puede espiar App2 y sus datos)
    --------------------------------        - App1 BUG (CPU 100%) ----> OFFLINE
                Hierro                              App2 y App3 van detrás

## Máquinas virtuales

       App1   |   App2  +  App3         Esto resuelve los problemas de las instalaciones tradicionales, pero con un coste grande:
    --------------------------------        - La configuración/instalación es mucho más compleja
       SO1    |      SO2                    - El mnto es mucho más costoso
    --------------------------------        - Gasto de recursos importante (Merma de recursos)
       VM1    |      VM2                    - El rendimiento cae
    --------------------------------
           Hipervisor
           esXI, VBox, KVM, Citrix, 
           HyperV...
    --------------------------------
           Sistema Operativo        
    --------------------------------
                Hierro              

## Contenedores

       App1   |   App2  +  App3     
    --------------------------------
       C1     |      C2 
    --------------------------------
        Gestor de contenedores
    containerd, crio, docker, podman
    --------------------------------
      Sistema Operativo (Linux)     
    --------------------------------
                Hierro              


# Contenedores

Es un entorno aislado dentro de un kernel Linux donde correr procesos.
Aislado:
- Ese entorno tiene su propia configuración de red (su propia IP)
- Tiene sus propias variables de entorno
- Tiene su propio sistema de archivos
- Puede tener limitaciones de acceso a los recursos físicos de la máquina

En un contenedor puedo poner un SO? NO. Esta es la gran diferencia con respecto a las VMs.

Los creamos desde imágenes de contenedor.

## Imagen de contenedor

Es un triste archivo comprimido (tar) que contiene:
- una estructura de carpetas compatible con POSIX (no es obligatorio... pero siempre la llevan)
    bin/ etc/ var/ opt/ ...
- una serie de programas PREINSTALADOS en esa estructura de carpetas... CIENTOS de ellos en cualquier imagen de contenedor.
- entre ellos, un programa que a mi me resulte de especial utilidad (nginx, mariadb, jenkins...) con una preconfiguración
  Esa, la podré adaptar a mis necesidad en tiempo de ejecución (cuando cree el contenedor):
    - Variables de entorno
    - Ficheros de configuración

Adicionalmente viene un archivo de metadatos:
- El comando concreto que debe ejecutarse cuando creemos un contenedor con esta imagen
- ...

---

# Ansible

Para correr un playbook de ansible necesito:
- Ansible (en una determinada version)
- Colecciones
- Roles
- Dependencias de los módulos
- python... en una determinada versión, que sea compatible con la versión de ansible que voy a correr

En mi máquina puedo trampear y montarlo.
Pero el playbook lo ejecutaré no en mi máquina. Y allí habrá todo lo que necesito?

Los contenedores se convierten en la alternativa natural para crear entornos donde correr los playbooks.

Yo me creo una imagen de contenedor con todas esas cosas de arriba.

Y el playbook lo distribuyo junto con la imagen de contenedor que se debe usar para crear entornos (contenedores) donde ejecutar el playbook.

# Ansible Tower / Ansible Automation Platform

Existe el concepto de "Execution ENVIRONMENT".
Ese entorno es una imagen de contenedor... de la que AAP crea un contenedor cuando va a ejecutar un playbook.

Realmente lo que distribuimos con el playubook no es la imagen de contenedor.. sino las instrucciones para generar esa imagen de contenedor.

Habitualmente las imágenes de contenedor ser generan / especifican mediante ficheros Dockerfile

Ansible viene con su propio lenguaje para ello. Un lenguaje de Dominio espeífico, más restrictivo que el de DockerFile, pero de más alto nivel.

Esos ficheros se llaman execution-environment.yaml

```yaml
---
# Definición del Execution Environment (EE) para ansible-navigator.
#
# Construye una imagen de contenedor con ansible-core + las colecciones
# de Galaxy de requirements.yml. Se construye con ansible-builder:
#
#   pip3.11 install ansible-builder
#   ansible-builder build -t apache-ee:latest -f execution-environment.yml -v3
#
# La imagen resultante (apache-ee:latest) es la que referencia
# ansible-navigator.yml.

version: 3

images:
  # Imagen base de Execution Environment (trae ansible-core + ansible-runner, basada en dnf).
  # Pública. (Las antiguas quay.io/ansible/community-ee-* fueron retiradas -> 401).
  base_image:
    name: quay.io/ansible/awx-ee:latest

dependencies:
  # Colecciones de Galaxy a hornear dentro del EE.
  galaxy: requirements.yml
  # python: requirements.txt   # descomenta si necesitas librerías de Python extra
  # system: bindep.txt         # descomenta si necesitas paquetes del SO dentro del EE
---
# Archivo requirements.yaml
---
# Colecciones de Ansible Galaxy necesarias para este proyecto.
# (las mismas que figuran en colecciones.md)
#
# Se instalan dentro del Execution Environment al construirlo con
# ansible-builder (ver execution-environment.yml). Para una ejecución
# SIN EE, instálalas en el controlador con:
#   ansible-galaxy collection install -r requirements.yml

collections:
  - name: ansible.posix
  - name: community.general

```

# ansible-builder build -t apache-ee:latest -f execution-environment.yml -v3

Es un programa de la famila de Ansible que nos permite crear imágenes de contenedor que usaremos para crear contenedores donde correr playbooks de ansible partiendo de un fichero execution-environment.yaml

Realmente este comando genera por debajo un Dockerfile... pero la sintaxis del dockerfile es muy dura comparada con la sintaxis del execution-environment.yaml

Nuestro execution-environment.yaml da lugar a este Dockerfile:

```Dockerfile
# Execution Environment del proyecto.
#
# Construido sobre awx-ee (EE público con ansible-core + ansible-runner) porque
# las bases quay.io/ansible/community-ee-* fueron retiradas (401).
#
# Fijamos ansible-core 2.16: RHEL/Rocky 8 solo tiene los bindings de 'dnf' para
# Python 3.6, y ansible-core >=2.17 dejó de soportar Python 3.6 en el nodo. Con
# 2.16, rocky8 se gestiona con su python del sistema (3.6, con dnf) y ubuntu22
# con su 3.10.
#
# Build:
#   docker build -t apache-ee:latest -f apache-ee.Dockerfile .
FROM quay.io/ansible/awx-ee:latest

USER root
ENV HOME=/root

# Downgrade de ansible-core al python real donde vive ansible (vía shebang de ansible-playbook).
RUN PYBIN="$(head -1 "$(command -v ansible-playbook)" | sed 's/^#!//; s/ .*//')" && \
    "$PYBIN" -m pip install --no-cache-dir 'ansible-core>=2.16,<2.17'

# Colecciones compatibles con ansible-core 2.16:
#   community.general 11+ requiere >=2.17  -> 10.x
#   ansible.posix 2.x puede requerir core nuevo -> 1.5.x (incluye firewalld)
RUN ansible-galaxy collection install --upgrade --force \
        -p /usr/share/ansible/collections \
        'community.general:>=10.0.0,<11.0.0' \
        'ansible.posix:>=1.5.0,<2.0.0'

USER 1000
```

# Ansible navigator

Es otra herramienta que nos dan en la familia Ansible

Nos permite hacer casi el trabajo que hago en un AAP en local y por linea de comandos.
- Inspección del inventario gráfica
- Ejecución de playbooks
- Inspección de colecciones
- Generación automática de contenedores desde la imagen de contenedor.

Ansible navigator lleva su propio fichero de configuración. En ese fichero especificamos muchas cosas:
- Entorno de ejecución:
  - Qué entorno de ejecución quiero (IMAGEN DE CONTENEDOR)
  - Qué gestor de contenedores quiero (docker, podman...)
  - Cómo gestionar la imagen de esos contenedores: Descargarla de internet.. o usar una local.
  - Si quiero volumenes adicionales en el contenedor (para inyectar cosas en el entorno)

- Definir la estrategia de logging del ansible navigator:
  - Nivel de log en ejecuciones
  - Fichero de log

- Además, ansible navigator genera unos archivos llamados ARTIFACTS, son el resultado de ejecución de un playbook
- El inventario que vamos a usar.

Ansible navigator siempre inyecta en el contenedor la carpeta de mi playbook... pero
Me puede interesar que inyecte:
- Mi inventario
- Claves ssh

Este archivo no está pensado para distribuirse... Este archivo es con el que YO genero MI ENTORNO de ejecución de playbooks.
Ansible Automation Platform, genera SUS entornos... con SU especificación (auqnue usando MI IMAGEN de contenedor)
Otro compañero tendrá su fichero de ansible navigator (Habitualmente si somos varios desarrolando, usamos el mismo fichero...o lo intentamos)

```yaml
---
# Configuración de ansible-navigator para este proyecto.
# Doc: https://ansible.readthedocs.io/projects/navigator/settings/
#
# Ejecutar el playbook (modo stdout, como ansible-playbook):
#   ansible-navigator run playbook.yaml -i ../inventario/inventario.ini
#
# Modo TUI interactivo:
#   ansible-navigator run playbook.yaml --mode interactive

ansible-navigator:
  # --- Execution Environment ---
  execution-environment:
    enabled: true
    image: apache-ee:latest          # imagen construida con execution-environment.yml
    container-engine: auto           # auto = podman si existe; si no, docker (Mac=docker, rocky8=podman)
    pull:
      policy: never                  # 'never' = usa la imagen local (no la baja de un registro)
    # Volumen inyectado en el contenedor con el inventario y la clave SSH.
    # src es RELATIVO a esta carpeta (el Mac es el controlador); se monta en
    # /inventario dentro del EE. El inventario referencia la clave por ese path
    # de contenedor (/inventario/id_curso).
    #   ro = solo lectura.  (Sin 'Z': en podman-machine de macOS no aplica)
    #   Si navigator se queja del src relativo, pon la ruta absoluta del Mac.
    volume-mounts:
      - src: "../inventario"
        dest: "/inventario"
        options: "ro"

  # --- Comportamiento por defecto ---
  mode: stdout                       # stdout (como ansible-playbook) | interactive (TUI)

  playbook-artifact:
    enable: true
    save-as: "./artifacts/{playbook_name}-artifact-{time_stamp}.json"

  logging:
    level: info
    file: ./ansible-navigator.log

  # --- Inventario ---
  # Ruta RELATIVA al proyecto (portable: igual en el Mac y tras el git clone en
  # rocky8). navigator monta el fichero de inventario en el EE automáticamente;
  # la clave SSH la resuelve por el volumen montado en /inventario (ver arriba).
  ansible:
    inventory:
      entries:
        - ../inventario/inventario.ini
```

Nuestro archivo de inventario:
```yaml
# Inventario del curso apuntando a las VMs de VirtualBox/Vagrant.
#
# Dos métodos de acceso configurados en las VMs:
#   1) Clave privada:  id_curso (en esta misma carpeta)
#   2) Password del usuario 'vagrant':  Pa$$w0rd2026
#
# La clave apunta a /inventario/id_curso: el path donde ansible-navigator
# monta esta carpeta DENTRO del Execution Environment (ver ansible-navigator.yml).

[redhat]
rocky8 ansible_host=192.168.56.21

[debian]
ubuntu22 ansible_host=192.168.56.22

[curso:children]
redhat
debian

[curso:vars]
ansible_user=vagrant
ansible_ssh_private_key_file=/inventario/id_curso
ansible_python_interpreter=/usr/bin/python3
# ControlMaster/ControlPath desactivados: dentro del EE el socket de multiplexión
# SSH falla ("muxserver_listen: Bad file descriptor"). Sin mux conecta bien.
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ControlMaster=no -o ControlPath=none'
```


---

# Vagrant

Es otra herramienta de automatización, que nos permite gestionar MAQUINAS VIRTUALES.
Defino las máquinas virtuales en un archivo declarativo, con una sintaxis especial. Se lo paso a vagrant y él crea las VMs.

```Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Entorno del curso de Ansible: 2 nodos gestionados
#   - rocky8    -> Rocky Linux 8 (clon binario de RHEL 8, familia RedHat)
#   - ubuntu22  -> Ubuntu 22.04 LTS (Jammy, familia Debian)
#
# Red privada host-only (192.168.56.0/24) con IPs fijas para que el
# inventario de Ansible sea estable.
#
# Uso:
#   vagrant up            # levanta ambas
#   vagrant up rocky8     # levanta solo una
#   vagrant ssh rocky8    # entra por SSH
#   vagrant status        # estado
#   vagrant halt          # apaga
#   vagrant destroy -f    # borra las VMs

NODES = [
  { name: "rocky8",   box: "bento/rockylinux-8", ip: "192.168.56.21", hostname: "rocky8.curso.local"   },
  { name: "ubuntu22", box: "bento/ubuntu-22.04", ip: "192.168.56.22", hostname: "ubuntu22.curso.local" },
]

# Clave pública del curso (la privada está en ../proyectos/inventario/id_curso)
PUBKEY = File.read(File.expand_path("../proyectos/inventario/id_curso.pub", __dir__)).strip

# Contraseña del usuario 'vagrant' para login SSH por password
SSH_PASSWORD = "Pa$$w0rd2026"

Vagrant.configure("2") do |config|
  config.vm.boot_timeout = 600

  NODES.each do |node|
    config.vm.define node[:name] do |vm|
      vm.vm.box      = node[:box]
      vm.vm.hostname = node[:hostname]
      vm.vm.network "private_network", ip: node[:ip]

      vm.vm.provider "virtualbox" do |vb|
        vb.name   = node[:name]
        vb.memory = 1024
        vb.cpus   = 1
      end

      # --- Provisioner común: Python, clave pública y password SSH ---
      vm.vm.provision "shell", inline: <<-SHELL
        set -e
        # Python (lo necesita Ansible en el nodo gestionado)
        if command -v dnf >/dev/null 2>&1; then
          dnf install -y python3 >/dev/null 2>&1 || true
        elif command -v apt-get >/dev/null 2>&1; then
          apt-get update -y >/dev/null 2>&1 && apt-get install -y python3 >/dev/null 2>&1 || true
        fi

        # Clave pública del curso para el usuario vagrant
        install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
        touch /home/vagrant/.ssh/authorized_keys
        grep -qF '#{PUBKEY}' /home/vagrant/.ssh/authorized_keys || echo '#{PUBKEY}' >> /home/vagrant/.ssh/authorized_keys
        chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
        chmod 600 /home/vagrant/.ssh/authorized_keys

        # Contraseña del usuario vagrant + login SSH por password
        echo 'vagrant:#{SSH_PASSWORD}' | chpasswd
        sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        if [ -d /etc/ssh/sshd_config.d ]; then
          echo 'PasswordAuthentication yes' > /etc/ssh/sshd_config.d/00-curso.conf
        fi
        systemctl restart sshd 2>/dev/null || systemctl restart ssh 2>/dev/null || true
      SHELL

      # --- Provisioner solo rocky8: Ansible (última via pip), navigator, podman ---
      if node[:name] == "rocky8"
        vm.vm.provision "shell", inline: <<-SHELL
          set -e
          # podman (del repo) + python3.11 (necesario para el Ansible más reciente)
          dnf install -y podman python3.11 python3.11-pip >/dev/null
          # Última versión de Ansible + navigator + builder vía pip (NO el ansible viejo del repo)
          python3.11 -m pip install --upgrade pip >/dev/null
          python3.11 -m pip install --upgrade ansible ansible-navigator ansible-builder >/dev/null
          echo "=== Versiones instaladas en rocky8 ==="
          /usr/local/bin/ansible --version | head -1 || true
          /usr/local/bin/ansible-navigator --version || true
          /usr/local/bin/ansible-builder --version || true
          podman --version || true
        SHELL
      end
    end
  end
end
```


---

He montado un ubuntu 22
              rocky  8

## Rocky?

Es el antiguo CentOS.

    Redhat hacía:
        Fedora -> upstream -> RHEL                 -> CentOS

    Hoy en día el modelo:
        Fedora -> upstream -> CentOSStream -> RHEL -> Rocky
                                rama en fedora

A RHEL le interesa esto ... asi gente que no tiene pasta puede estar en el ecosistema... y cuando tengan pasta.. o para las cosas críticas, entran como un guante... suave.


---

SELinux => Security Enhanced for Linux

El kernel de linux permite montar una herramienta a la que preguntar antes de hacer cualquier operación (HOOKs).
Por defecto esto no se hace.. y está deshabilitado.
Pero puedo montarlo.
Y hay alternativas:
- SELinux es la que usamos en la familia REDHAT
- AppArmour en la familia Ubuntu

Cómo se usa.

Selinux tiene 2 modos de trabajo:
- Permisivo
- Forzado

Lo que hacemos es instalar la máquina...
Y pongo SELinux en modo permisivo...
Y pongo a correr los programas un ratito... (horas/dias)
Y SELinux va registrando todas las operaciones que se hacen.. y me prepara un listado de reglas de seguridad que permitirían al sistema operar como lo ha estado haciendo.
En un momento dado, reviso esas reglas. 
ESTA SI
ESTA NO
ESTA SI
ESTA TAMBIEN
Las aplico... y cambio el modo de SELinux a forzado!

Las reglas de configuración de seguridad de una máquina SON COMPLEJISIMAS... y es poco probable que el día 0 vaya a ser yo capaz de dejar aquello fino.
Por eso sale algo como SELinux y su modo permisivo.
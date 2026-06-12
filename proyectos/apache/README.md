# Despliegue de una web en Apache con Ansible

Playbook **idempotente** que despliega una aplicación web (desde un repo de git)
sobre Apache httpd, funcionando igual en **RHEL/Rocky** (familia RedHat) y
**Ubuntu/Debian**. Se ejecuta con **`ansible-navigator`** dentro de un
**Execution Environment** (contenedor) en lugar de instalar Ansible en la máquina.

> ¿Qué se arregló respecto a la versión inicial? Ver [CHANGELOG.md](CHANGELOG.md).

---

## Qué hace

1. Comprueba que el SO destino está soportado y que el repo de la app es accesible.
2. Instala los prerrequisitos (git, curl…) y **Apache** (httpd / apache2).
3. Clona la app y la **despliega** en el `DocumentRoot`, con copia de seguridad previa.
4. Genera el **VirtualHost** y abre el puerto en el **firewall** (firewalld / ufw).
5. Ajusta **SELinux** en RedHat y deshabilita el sitio por defecto en Ubuntu.
6. **Verifica** que la web responde con el código esperado (local y desde fuera).

## Arquitectura

```
   Controlador (Mac / WSL / Rocky)              Nodos gestionados
   ┌───────────────────────────┐                ┌──────────────────┐
   │ ansible-navigator         │   ssh + clave  │ rocky8  (RedHat) │ 192.168.56.21
   │   └─ Execution Environment│ ─────────────► │ ubuntu22 (Debian)│ 192.168.56.22
   │      (contenedor apache-ee)│                └──────────────────┘
   └───────────────────────────┘
```

El EE (`apache-ee`) lleva `ansible-core 2.16` + las colecciones `ansible.posix` y
`community.general`. La configuración de navigator
([ansible-navigator.yml](ansible-navigator.yml)) ya define la imagen, **monta el
inventario y la clave** (`../inventario`) y da de alta el inventario, así que no
hace falta pasar `-i`.

---

## Requisitos comunes

- Las dos VMs encendidas y accesibles por SSH (ver carpeta `vagrant/` del repo).
- Un **motor de contenedores**: Docker (Mac/Windows) o Podman (Rocky/Linux).
- **`ansible-navigator`** instalado en el controlador.
- El controlador debe **alcanzar por red** las IPs `192.168.56.21` y `192.168.56.22`.

## Configuración del despliegue

Los valores del despliegue se pasan en un fichero con la estructura de
[vars/plantilla_configuracion_despliegue_apache.yaml](vars/plantilla_configuracion_despliegue_apache.yaml).
En el repo va uno de ejemplo listo para probar:
[configuracion.despliegue.webejemplo.yaml](configuracion.despliegue.webejemplo.yaml)
(repo de la app, puerto 80, etc.). Se pasa con `-e @fichero`.

---

## ▶️ Ejecutar desde **macOS**

1. Arranca **Docker Desktop**.
2. Instala ansible-navigator y ansible-builder (Python 3.10+):
   ```bash
   python3 -m pip install --user ansible-navigator ansible-builder
   ```
3. Construye el Execution Environment con **ansible-builder** (imagen local):
   ```bash
   cd proyectos/apache
   ansible-builder build -t apache-ee:latest -f execution-environment.yml -v3
   ```
   > Docker debe estar arrancado; ansible-builder detecta el motor (docker/podman).
4. Lanza el playbook:
   ```bash
   ansible-navigator run playbook.yaml -e @configuracion.despliegue.webejemplo.yaml
   ```
   (Modo TUI interactivo: añade `--mode interactive`.)

---

## ▶️ Ejecutar desde **Windows**

Ansible **no corre de forma nativa en Windows**: se usa **WSL2** (una distro Linux).

1. Instala **WSL2** con Ubuntu y **Docker Desktop** con el *backend* de WSL2
   (o Podman). Abre una terminal de la distro WSL.
2. Dentro de WSL, instala ansible-navigator y ansible-builder:
   ```bash
   pip install ansible-navigator ansible-builder
   ```
3. Clona el repo **dentro del filesystem de WSL** (p. ej. `~/cursoAnsible`, **no**
   en `/mnt/c/...`: en `/mnt/c` la clave SSH pierde los permisos y `ssh` la rechaza).
4. Construye el EE y ejecuta (igual que en Mac):
   ```bash
   cd ~/cursoAnsible/proyectos/apache
   ansible-builder build -t apache-ee:latest -f execution-environment.yml -v3
   ansible-navigator run playbook.yaml -e @configuracion.despliegue.webejemplo.yaml
   ```

> ⚠️ **Red:** desde WSL2 hay que poder llegar a la red *host-only* de VirtualBox
> (`192.168.56.0/24`). Si no se alcanza, lo más cómodo es ejecutar el playbook
> **desde la propia VM Rocky** (siguiente apartado), que ya está en esa red.

---

## ▶️ Ejecutar desde **Rocky** (la VM como controlador)

La VM `rocky8` ya tiene **podman**, **ansible-navigator** y **ansible-builder**
instalados, y está en la misma red que las VMs, así que es el sitio más cómodo.

1. Entra y clona el repo:
   ```bash
   vagrant ssh rocky8          # o:  ssh -i ../inventario/id_curso vagrant@192.168.56.21
   git clone <URL-del-repo> cursoAnsible
   cd cursoAnsible/proyectos/apache
   ```
2. Construye el EE con **ansible-builder** (usa podman automáticamente):
   ```bash
   ansible-builder build -t apache-ee:latest -f execution-environment.yml -v3
   ```
3. Lanza el playbook (mismos comandos que en Mac/WSL; `container-engine: auto`
   elige podman automáticamente):
   ```bash
   ansible-navigator run playbook.yaml -e @configuracion.despliegue.webejemplo.yaml
   ```

> Desde Rocky se llega a `ubuntu22` (`.22`) y a sí mismo (`.21`) directamente.

---

## Verificar el resultado

```bash
curl http://192.168.56.21/      # rocky8   → 200 + contenido de la app
curl http://192.168.56.22/      # ubuntu22 → 200 + contenido de la app
```

## Idempotencia

Una **segunda** ejecución debe terminar con `changed=0` en ambos nodos (no
vuelve a tocar nada si no hay cambios en el repo de la app). Es la prueba de que
el playbook es idempotente.

---

## Estructura del proyecto

```
apache/
├── ansible-navigator.yml        # config de navigator (EE, volúmenes, inventario)
├── execution-environment.yml    # definición del EE para ansible-builder (ansible-core 2.16 + colecciones)
├── requirements.yml             # colecciones de Galaxy (ansible.posix, community.general)
├── configuracion.despliegue.webejemplo.yaml   # valores de ejemplo (-e)
├── playbook.yaml                # punto de entrada
├── pre-tasks/  tasks/  post-tasks/  handlers/  utils/  templates/
├── internal_vars/               # constantes y valores por defecto
└── vars/                        # plantilla de configuración del despliegue
```

---

## Enunciado del ejercicio (original)

> Queremos un playbook IDEMPOTENTE que sea capaz de dejarnos una web operativa
> dentro de un Apache httpd... apto para producción. Accesible y funcionando.
> La web estará en un repo de git.
>
> Vamos a partir de una máquina con RHEL o Ubuntu, ¡me da igual!
> Nos darán una IP/FQDN y un usuario ssh.
>
> NI SE OS OCURRA comenzar por los módulos. Eso es lo último que montamos del script.
> Lo único que queremos por ahora es la estructura general del playbook.
> Pensad en qué argumentos/parámetros pueden ser útiles.
>
> **SoC (Separation of Concerns):** el entorno Ansible (Linux) necesita Ansible;
> el entorno remoto solo necesita Python. Ansible se comunica por ssh/winrm.

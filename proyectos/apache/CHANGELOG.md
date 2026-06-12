# CHANGELOG — Correcciones del playbook de despliegue de Apache

Este documento explica **qué fallaba** en el playbook y **cómo se ha arreglado**,
para que se entienda el porqué de cada cambio. Todos los arreglos se hicieron
ejecutando el playbook de verdad contra dos nodos (Rocky Linux 8 y Ubuntu 22.04)
hasta dejarlo funcionando **de punta a punta y de forma idempotente**.

> Formato de cada entrada: **Síntoma → Causa → Arreglo → Lección**.

---

## 1. Sintaxis y nombres de módulos

### 1.1 `archive` no es de `ansible.builtin`
- **Síntoma:** `couldn't resolve module/action 'ansible.builtin.archive'`.
- **Causa:** el módulo `archive` pertenece a la colección `community.general`, no a `ansible.builtin`.
- **Arreglo:** `ansible.builtin.archive` → `community.general.archive` en `tasks/tareas.despliegue.aplicacion.yaml`.
- **Lección:** no todos los módulos son `builtin`; comprueba la colección en la documentación.

### 1.2 Indentación rota en el módulo `template`
- **Síntoma:** el playbook fallaba al parsear `tasks/tareas.configuracion.apache.yaml`.
- **Causa:** `src`, `dest` y `mode` estaban al nivel de la tarea, no **dentro** de `ansible.builtin.template:`.
- **Arreglo:** indentar esos parámetros bajo el módulo. `become`/`notify` van al nivel de la tarea.
- **Lección:** los parámetros del módulo cuelgan del nombre del módulo; los *keywords* de tarea (`become`, `notify`, `when`, `tags`) cuelgan de la tarea.

### 1.3 Variable sin `{{ }}`
- **Síntoma:** se creaba un directorio literalmente llamado `configuracion_despliegue_apache.aplicacion.deploy.path`.
- **Causa:** `path:` recibía el nombre de la variable como texto, sin `{{ }}`.
- **Arreglo:** `path: "{{ configuracion_despliegue_apache.aplicacion.deploy.path }}"`.

### 1.4 Acción `meta` inválida
- **Síntoma:** `ERROR! invalid meta action requested: end-host`.
- **Causa:** la acción correcta lleva guion bajo.
- **Arreglo:** `meta: end-host` → `meta: end_host` en `pre-tasks/tareas.verificacion.yaml`.

### 1.5 Ruta de variable incoherente
- **Síntoma/Causa:** la verificación usaba `configuracion_despliegue_apache.repo.url`, pero el resto del playbook (y la plantilla de `vars/`) usa `...aplicacion.repo.url`.
- **Arreglo:** alinear la verificación a `...aplicacion.repo.url`.

### 1.6 `notify` sobre un `include_tasks`
- **Síntoma:** `'notify' is not a valid attribute for a TaskInclude`.
- **Causa:** un `include_tasks` no acepta `notify` directamente.
- **Arreglo:** mover el `notify` **dentro de `apply:`** del include (se aplica a las tareas incluidas).

---

## 2. Soporte multi-distro (Rocky/clones de RHEL)

### 2.1 Rocky no se reconocía como RedHat
- **Síntoma:** en Rocky el playbook se cortaba (`meta: end_host`) y buscaba carpetas `tasks/rocky/`, `utils/rocky/` inexistentes.
- **Causa:** se decidía la familia con `ansible_distribution`, que en Rocky vale **`Rocky`** (no `Redhat`). Las carpetas son `redhat/` y `ubuntu/`.
- **Arreglo:** nueva variable **`familia`** derivada de `ansible_os_family` (`RedHat`→`redhat`, `Debian`→`ubuntu`) en `pre-tasks/tareas.carga.datos.yaml`, usada en **todas** las rutas y *lookups* en lugar de `ansible_distribution`. `distros_soportadas` pasa a `[redhat, ubuntu]`.
- **Lección:** para decidir "familia de SO" usa `ansible_os_family`, no `ansible_distribution` (así soportas Rocky, Alma, CentOS… con el mismo código).

### 2.2 Intérprete de Python y `dnf` en RHEL 8
- **Síntoma:** en Rocky, `setup`/módulos fallaban con `SyntaxError: future feature annotations` (Python 3.6) o `Could not import the dnf python module` (Python 3.11).
- **Causa:** RHEL/Rocky **8** solo tiene los *bindings* de `dnf` para el **Python 3.6** del sistema, y `ansible-core ≥ 2.17` ya **no soporta Python 3.6 en el nodo**.
- **Arreglo:** el Execution Environment usa **`ansible-core 2.16`** (el último que soporta Python 3.6 en el nodo). Así Rocky se gestiona con su `/usr/bin/python3` (3.6, con `dnf`) y Ubuntu con su 3.10.
- **Lección:** la versión de ansible-core del *controlador* condiciona qué Python pueden usar los *nodos*; en RHEL 8 + `dnf` es un punto delicado.

---

## 3. Permisos (`become`)

### 3.1 Faltaba `become: true` en tareas que escriben como root
- **Síntoma:** `Permission denied: /var/apache`, y los firewalls no aplicaban.
- **Causa:** varias tareas que requieren privilegios no tenían `become: true`.
- **Arreglo:** añadido `become: true` en: crear el directorio de despliegue, copiar la app, borrar `.git`, abrir el firewall (`firewalld` y `ufw`).
- **Lección:** toda tarea que escribe fuera del `$HOME` del usuario SSH o gestiona servicios suele necesitar `become`.

### 3.2 Rutas con `~` y `become`
- **Síntoma:** `Source /root/ansible_app_deploy/ not found`.
- **Causa:** `~` se expande a `/home/vagrant` (sin become) o `/root` (con become). El `git clone` (sin become) y el `copy` (con become) usaban rutas distintas.
- **Arreglo:** rutas **absolutas** en `internal_vars/constantes.playbook.yaml` (`/var/tmp/...`), accesibles por ambos usuarios. Y se crea el directorio de backups.
- **Lección:** evita `~` en rutas compartidas entre tareas con y sin `become`.

---

## 4. Lógica de instalación y despliegue

### 4.1 Glob de versión incompatible con apt
- **Síntoma:** en Ubuntu, `no available installation candidate for git=2*`.
- **Causa:** la ruta de prerrequisitos pasa el glob de versión (`2*`) tal cual a `apt`, que **no admite globs** en `paquete=version` (a diferencia de `dnf`). La ruta de Apache sí resuelve la versión candidata antes (`apt-cache madison`), pero la de prerrequisitos no.
- **Arreglo (mínimo):** `git` con `version_matching: latest` (es una herramienta, no el foco del despliegue).
- **Pendiente/mejora:** la ruta de prerrequisitos debería resolver la versión candidata como hace la de Apache.

### 4.2 `python3-debian` para repos deb822
- **Síntoma:** `Failed to import the required Python library (python3-debian)`.
- **Causa:** el módulo `deb822_repository` necesita `python3-debian` en el nodo.
- **Arreglo:** *bootstrap* que instala `python3-debian` en Ubuntu antes de registrar la PPA (`utils/ubuntu/tareas.instalacion.paquete.yaml`).

### 4.3 Parar el servicio antes de instalarlo
- **Síntoma:** `Could not find the requested service httpd`.
- **Causa:** en una instalación nueva se intentaba **parar** Apache antes de instalarlo (el servicio aún no existe).
- **Arreglo:** parar solo si ya está instalado: `when: apache_requiere_cambio_version and (apache_version_instalada | trim | length > 0)`.

---

## 5. Que Apache sirva REALMENTE la app

> Tras lo anterior, el playbook "terminaba bien" pero servía las páginas por
> defecto (Rocky daba **403**, Ubuntu **200 pero la página de Ubuntu**). La app
> sí se copiaba a `/var/apache/aplicacion`, pero Apache no la servía.

### 5.1 SELinux en Rocky (403)
- **Causa:** SELinux *Enforcing*; el directorio tenía contexto `var_t` y `httpd` solo sirve `httpd_sys_content_t`.
- **Arreglo:** en familia `redhat`, instalar `policycoreutils-python-utils`, fijar el contexto con `community.general.sefcontext` (`httpd_sys_content_t`) y aplicarlo con `restorecon`.

### 5.2 Vhost por defecto en Ubuntu
- **Causa:** `000-default.conf` seguía habilitado y ganaba al entrar por IP.
- **Arreglo:** `a2dissite 000-default` en familia `ubuntu` para que sirva nuestro vhost.

### 5.3 `ServerName` mal calculado
- **Causa:** con `fqdn: '*'` la plantilla generaba `ServerName localhost` (un `replace` lo transformaba).
- **Arreglo:** la plantilla omite `ServerName` cuando `fqdn` es `*` (vhost *catch-all*, sirve cualquier host).

---

## 6. Pruebas (post-tasks) que no probaban nada

- **Síntoma:** los tests "pasaban" aunque Apache devolviera 403 o la página por defecto.
- **Causa 1:** el test con `curl` usaba `-w '{{ http_status_code }}'`, que imprime el **literal** `200` sin comprobar el código real.
- **Causa 2:** el test "desde fuera" usaba `delegate_to: localhost` (el controlador) pero apuntaba a `http://localhost`, que dentro del Execution Environment no es la VM.
- **Arreglo:**
  - Test local: `-w '%{http_code}'` (el código real) + `failed_when` que compara con el esperado.
  - Test externo: apuntar a `http://{{ ansible_host }}` (la **IP de la VM**), no a `localhost`.
- **Lección:** un test que nunca falla no es un test. Valida el **código y/o el contenido** reales.

---

## 7. Idempotencia

Se verificó ejecutando el playbook **dos veces seguidas**: la segunda ejecución
da **`changed=0`** en ambos nodos. El bloque de despliegue solo actúa cuando hay
cambios reales en el repo de la app (`git`/`diff`); el resto de tareas (paquetes,
firewall, SELinux, `a2dissite`, plantilla) son idempotentes.

---

## Resultado final

```
http://<ip-rocky>/    → HTTP 200 → contenido de la app
http://<ip-ubuntu>/   → HTTP 200 → contenido de la app
```

Despliegue correcto e idempotente en **Rocky Linux 8** y **Ubuntu 22.04**,
ejecutado con **ansible-navigator** dentro de un **Execution Environment**.

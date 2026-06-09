Queremos un playbook IDEMPOTENTE que sea capaz de dejarnos una web operativa
dentro de un Apache httpd.... apto para producción.
Accesible y funcionando.
La web estará en un repo de git.

Vamos a partir de una máquina con RHEL o Ubuntu me da igual!

Nos darán una IP/FQDN.. y un usuario ssh.

NI SE OS OCURRA comenzar por los módulos! Eso es lo último que montamos del script.

Lo único que queremos por ahora es la estructura general del playbook.

Pensad en qué argumentos/parámetros pueden ser útiles.


Monto apache:
    apt
    yum

Necesitamos un directorio donde desplegar la web
    git clone

Crear un archivo de configuracion en una carpeta del apache


SoC: Separation of Concerns
---

    Entorno Ansible (Linux)                                         Entorno remoto
    Que necesita tener instalado ansible                            python
    ANSIBLE             ------------------ssh/winrm--------------->
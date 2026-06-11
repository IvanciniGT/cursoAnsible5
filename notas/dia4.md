

    Máquina / Entorno con Ansible instalado                             Entornos destino

        Máquina de Ansible                                                  Servidor Web 1  
                                                                            ...
                                                                            Servidor Web 400
        
            ^^ Aquí es donde tengo ansible instalado
        

Para ejecutar mi playbook:

    $ ansible-galaxy collection install ansible.posix
    $ ansible-galaxy collection install otras 400 colecciones que mi playbook necesite
    $ ansible-playbook -i INVENTARIO mi-fichero-playbook.yaml ...

Esto es un problemón! de proporciones EPICAS!
Yo, el desarrollo, lo haré en mi entorno.
En mi entorno tendré Ansible?   Más vale!
Tendré esas colecciones?        Más vale! Tendré que instalarlas.

En el entorno de producción esas colecciones existirán? AH!?
Es más... existirán las versiones mismas que yo tengo instaladas? UPS!?
Porque además... puede ser que en ese entorno de producción, se ejecute mi playbook y otros 400 playbooks...
Y cada uno necesite sus colecciones... en sus versiones! Ein?!?!?!?!?!

Como gestionamos esto? CONTENEDORES!
Esta es la forma estandar hoy en día.

El flujo normal:

    Desarrollo en local (tengo ansible instalado)
        creo playbook, lo pruebo usando un inventario local de pruebas -> GIT (playbook)

    Enterno de producción lo que tengo es Automation Platform (aka Ansible Tower)
        En esta herramienta subiremos los playbooks? No los subo
        Mis playbooks estarán en un repo de GIT.
        En el Automation platform, doy de alta el repo de git.
        Automation platform, lo escanea... y detecta los playbooks que hay en ese repo.
        Y yo activo de esos los que me viene bien.
        Y luego puedo, después de registrarlos:
        - Ejecutarlos a manubrio (APRETANDO EL COHETE)
        - Programar su ejecución en el tiempo
        - Lanzar una llamada http con un jenkins o similar al AutomationPllatform... para que éste lo ejecute.
        Y esa ejecución no se hace contra mi inventario de pruebas. Se hace contra el inventario REAL de máquinas de la empresa.
        Que también está registrado en Ansible Automation.

        Pero automation platform dónde ejecuta el playbook? En un ENTORNO.

        Y ese entorno, será un contenedor.
        Lo que querría yo es que ese contenedor donde se ejecute el playbook sea igual (tenga lo mismo) que el entorno
        donde he desarrollado... Y ahñi es donde tengo garantías de que va a funcionar sin problemas.
        Al menos de que tengo lo requisitos necesarios para su ejecución.

        NO VAMOS A LANZAR EL COMANDO: ansible-galaxy collection install ansible.posix

        VAMOS A DEFINIR UNA IMAGEN DE CONTENEDOR, que incluya esa colección.. y el resto que necesite.

        ansible-galaxy collection install ansible.posix = ANSIBLE DE HACE 10 años.

        > ansible-navigator y definicion de entornos = ANSIBLE DE HOY EN DIA!

        Ahora no vamos a configurar eso.. estamos con el playbook... 
        Pero es bueno que anotemos que necesitamos esta colección especial... para luego darla de alta en nuestra imagen de contenedor... cuando la creemos.
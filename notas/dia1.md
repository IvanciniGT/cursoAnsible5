
# Linux?

Un kernel de SO.

Un SO no es un programa.
De hecho RHEL, Ubuntu, Debian no son Sistemas Operativos.
Son distribuciones de que sistema Operativo? GNU(70%)/Linux(30%).

## Qué era Unix?

Unix era un SO, que creaba la Americana de telco AT&T. Lo hacía un dpto. llamado Lab. Bell.
Dejó de fabricarse a finales de los 90.. principios de los 2000.

Unix se licenciaba de forma muy diferentes a como se licencian hoy en día los SO. Hoy en día tenemos el concepto de EULA (End User License Agreement). AT&T licenciaba el SO a grandes corporaciones (universidades, empresas, fabricantes de hardware), que lo adaptaban a sus necesidades.

Llegó a haber más de 200 variantes de Unix... y muchas de ellas presentaban prolemas de compatibilidad.

Salieron 2 estándares para resolverlo:
- POSIX
- SUS: Single unix specification

## Qué es Unix?

Hoy en día, por UNIX nos referimos a esos estándares (SUS + POSIX).
Hay SO de fabricantes diversos que cumplen con esos estándares:
- IBM: AIX (Unix®)
- HP:  HP-UX (Unix®)
- Oracle: Solaris (Unix®)
- Apple: MacOS (Unix®)

Hay gente que creo SOs basados en esos estándares pero no los certificaron.

- Universidad de Berkley en California: 386BSD
  Se metieron en un follón legal. Cuando se resolvió el litigio (ganó Univ. Berkley) ya no usábamos esa arquitectura de microprocesador. Se reusó el código no obstante para nuevos SO: FreeBSD, NetBSD, OpenBSD, MacOS.
- GNU (Richard Stallman y amigos)
  GNU = GNU is Not Unix
  Montaron de todo lo que hacía falta para un SO: Compiladores, bibliotecas, entornos gráficos (GNOME), editores de texto: (GEDIT), shells de tipo cli (bash), hasta juegos: CHESS... menos una cosa: EL KERNEL
- Frustrado nuestro amigo Linus Torvalds, montó su propio kernel de SO compartible SUPUESTAMENTE con esos estándares... Y pasó lo que tenía que pasar: GNU + Linux -> GNU/Linux

Ese SO, lo puedo instalar tala cual.. pero es duro.
Hay muchas empresas que ofrecen ese S.O. con un paquete cerrado de programa por encima:
- Gestores de arranque del SO.
- Entornos gráficos
- Selección de shells
- Gestores de paquetes para instalaciones
- Herramientas de seguridad avanzadas (SELinux, AppArmour)
- ...

Distros de GNU/Linux:
- Debian -> Ubuntu, Mint...
- Redhat Enterprise Linux (RHEL): Oracle Linux, Rocky, Amazon Linux, Alma
   ^^^
   Upstream
   ^^^
  Fedora

# RHEL

## Qué aporta Redhat en su distro y como se gestiona el licenciamiento?

- Preselección de programas:
  - UI: GNOME
  - Shell: Bash
  - Gestor de paquetes? RPM, DNF, YUM
  - SELinux
  - ...
- Hace algunos cambios al kernel
- Soporte

Todo ello se consigue mediante una subscripción : Derecho a usar el producto, Soporte, Actualizaciones..

# Ansible

Es el nombre comercial con el Redhat publica/agrupa una serie/familia de productos pensados para automatizar tareas de Administración de Sistemas.
- Ansible Engine/Project: Herramienta de linea de comandos que nos permite crear scripts de automatización
- Ansible Automation Platform (Antiguamente el Tower <- AWX ): 
  - Automatizar la ejecución de playbooks (scripts)
  - Gestión de secretos (credenciales...)
  - Gestión CENTRALIZADA de playbooks/inventarios/registros de ejecución
  - API REST para la ejecución de playbooks
- Ansible Galaxy: Respositorio de Roles...

---

# Ansible engine

Nos permite crear scripts... pero .. cuántos años llevamos creando scripts de automatización? LA HUEVA!
Que hemos usado tradicionalmente? Scripts en un lenguajes de programación que nos ofrecía /definía: POSIX!
Un lenguaje de programación interpretado por la SHELL... Qué shell? Cualquier shell compatible(que cumpla) con el estándar POSIX...
Luego.. implementaciones concretas de la SHELL ofrecen funcionaldiades / sintaxis adicionales (BASH)

Si llevamos décadas creando scripts de automatización con BASH/SH.... para qué una nueva herramientas?
Qué aporta?
- Un lenguaje tirando a DECLARATIVO (más o menos - no es puro declarativo) más cómodo, sobre todo para tratar de conseguir IDEMPOTENCIA... (cualidad que no es implicita y automática al usar ANSIBLE)
- Gestión de inventarios.

Esas 2 cosas juntas ofrecen mejoras significativas frente a la creación de scripts con lenguajes tradicionales (SH, BASH, PYTHON)

## LENGUAJE DECLARATIVO

En un paradigma de programación, junto a otros paradigmas que existen:
- Imperativo
- Procedural
- Funcional
- Orientado a objetos

### Paradigma de programación...

Es solo un nombre hortera que los desarrolladores hemos dado a las formas en las que usamos un lenguaje de programación para pedir cosas a nuestra computadora.
Pero.. no es un concepto exclusivo ni original de los lengaujes de programación.. En el mundo de los lenguajes naturales (los que hablamos los humanos) también tenemos "paradigmas".

> Felipe, pon una silla debajo de la ventana!        IMPERATIVO

> mkdir ventana     -> mkdir es la abreviatura de: "make directory ventana" <- IMPERATIVO!
Estamos muy acostumbrados a los lenguajes imperativos en el mundo IT. Pero son una mierda! Y cada día los odiamos más.

> Felipe IF (Si) hay algo debajo de la ventana que no sea una silla:      CONDICIONAL
>   Quítalo!                                         IMPERATIVO
> Felipe, IF NOT silla debajo de la ventana:
>   Felipe, If not silla  == False THEN
>       GOTO ikea, compra Silla
>   Felipe, pon una silla debajo de la ventana!        IMPERATIVO

Por qué se está complicando el script?
Porque quiero que ese script funcione con idependencia del estado inicial en el que se encuentre el sistema.
Siempre quiero llevar al mismo estado final: Tener una silla debajo de la ventana, con independencia del estado inicial.

Cómo se llama eso: IDEMPOTENCIA!

Idempotencia... es una propiedad matemática. Una operación es idempotente si ejecutada 300 veces sobre el mismo operador y sus sucesivos resultados el valor no cambia:
    x1 -> Idempotente

En el mundo IT entendemos que un script es IDEMPOTENTE si con independencia del estado inicial, siempre llego al mismo estado final... O dicho de otra forma: Si ejecutado el script 300 veces, siempre llego al mismo estado final.

Pero.. en español (o los lenguajes naturales) también tenemos eso:

> Felipe: Debajo de la ventana ha de haber una silla. Es tu responsabilidad.  DECLARATIVO

    Simplemente digo lo que es!

    En esa frase, estoy haciendo 2 cosas:
    - Definir el estado final "Debajo de la ventana ha de haber una silla"
    - Pasarle la pelota a Felipe: "Es tu responsabilidad"
      Delego en Felipe el trabajo... Y lo primero que tendrá que hacer Felipe es?
      Determinar el plan de ejecución para conseguir ese estado final. 

## Ansible es Idempotente? NO
 
O mejor planteado... El lenguaje que nos ofrece Ansible es declarativo? NO

Pero se escucha mucho esto no? Ansible y sus playbooks son idempotentes.. y usa lenguaje declarativo...

Los módulos de Ansible se recomienda que se creen de forma que garaticen idempotencia.
Y con los módulos de ansible hablamos usando un lenguaje IDEMPOTENTE!

De hecho, el lenguaje en el que escrbimos los playbooks (scripts de ansible) es un lenguaje que usa paradigma: IMPERATIVO!

Un script hecho en Ansible (playbook) puede ser idempotente o no!
Es más fácil hacerlo idempotente que si lo hiciera en un lenguaje totalmente imperativo, ya que los módulos si me ofrecen (en su mayor parte) un lenguaje declarativo... Pero el script en su conjunto es IMPERATIVO!

Hay otras herramientas de automatización que si hablan un lenguaje puro declarativo... y ofrecen idempotencia OUT OF THE BOX: Openshift (kubernetes), Terraform.

## Módulos de Ansible

Colecciones de funciones que hacen tareas concretas.
Ansible no sabe hacer la O con un canuto!
Cualquier operación que ejecuto en Ansible es mendiante un MODULO!

Esos módulos los escribimos (principalmente) en python. De hecho hay ya miles escritos...

Se recomienda a quien desarrolla los módulos que sus funciones sean idempotentes... y que me ofrezcan un lenguaje DECLARATIVO.

La mayor aprte de ellos lo son... No todos: 
- El módulo SHELL NO ES IDEMPOTENTE PER SE y no me ofrece un lenguaje DECLARATIVO
- Y más como ese!

---

# Por qué quiero esa idempotencia?



---

# Qué es Devops?

Una filosofía, una cultura, un movimiento en pro de la automatización... Automatización de qué?
Automatización de todo lo que hay entre el DEV -> OPS.

1º El hardware es una cosa bastante cara y delicada. Solo se justifica por permitirnos operar sobre él software
2º El software es una cosa bastante cara y delicada. Solo se justifica por permitirnos gestionar datos que aportan valor a negocio.

    NEGOCIO (€€€) ---> Datos ---> Software ---> Hardware
                                                    ^
                                                  Adminsitrarlo

El objetivo comunico de ese hardware es permitirnos correr un software.

Ese software hay que desarrollarlo.
Para desarrollarlo:

                    Automatizable?              HERRAMIENTAS
    Plan                POCO
    Code                CADA VEZ MAS (IAs)
    Build               TOTALMENTE
                            java                maven, gradle
                            js/ts               npm, yarn
                            C#                  nuget, msbuild, dotnet
    Test            
        Diseño          CADA VEZ MAS (IAs)
        Ejecución       TOTALMENTE!             Código:
                                                    JUNIT, TESTNG, MSTEST, UNITTEST, MOCHA
                                                Interfaces WEB:
                                                    SELECNIUM, CYPRESS, KARMA, WEBDRIVER
                                                Interfaces Mobile:
                                                    KATALON, APPIUM
                                                Interfaces desktop: UFT
                                                Rendimiento y carga: JMETER, LOAD RUNNER...
                                                Calidad de código: SONARQUBE
                                                APIS HTTP: Postman, SOAP UI, KARATE, READYAPI, ...
        Dónde se ejecutan esas pruebas?
            - En la máquina del desarrollador? NO... No me fío... Está maleá!
            - En la máquina del tester?        NO... No me fío... Está maleá!
            - En un entorno previo de test?    Antes si... ya tampoco!
              Cuántas veces se instalaba antes en el entorno de PRE? 3 al final del proyecto
              Y Ahora? con las met. ágiles? Cada nada. Y después de 20 instalaciones como va a estar el entorno? MALEAO 
            - Qué hacemos hoy en día? Cual es la tendencia? Entornos de prueba efímeros! Como los kleenex
              De usar y tirar! Creo enterno, instalo, pruebo, genero informe y desmantelo.
            Con esto ayudan: Máquinas virtuales... pero cada vez más: CONTENEDORES
                Necesito automatizar la generación de esos entornos:
                    - Docker
                    - Kubernetes (aunque menos)
                    - Vagrant
                    - Terraform / Cloud Formation
                    - Ansible, Puppet, Chef, Salt
---------------------------------> INTEGRACIÓN CONTINUA = Tener CONTINUAmente en el entorno de INTEGRACIÓN la última versión de un producto sometida a pruebas automatizadas -> PRODUCTO: Informe de pruebas en tiempo real.
    Release
                        TOTALMENTE
---------------------------------> ENTREGA CONTINUA: CONTINUOUS DELIVERY (CD)
    Deploy              TOTALMENTE
                    - Kubernetes (Openshift, Tanzu...)
                    - Vagrant
                    - Terraform / Cloud Formation
                    - Ansible, Puppet, Chef, Salt
---------------------------------> DESPLIEGUE CONTINUA: CONTINUOUS DEPLOYMENT (CD)
    Operation           TOTALMENTE
                    - Kubernetes (Openshift, Tanzu...)
    Monitor
                        TOTALMENTE
                    - Kubernetes
                    - Prometheus/Grafana
                    - ELK
                    - Nagios
                    - DataDog
                    - ...

Para automatizar PROCESOS: 
- INTEGRACION CONTINUA
- ENTREGA CONTINUA
- DESPLIEGUE CONTINUO

Necesito otros programas... que automaticen la ejecución de las tareas automatizadas... de forma orquestada!
Alguien que llame al que compila el código, después al que crea entornos, después al que los configura, luego al que instala, luego al que hace pruebas...
Qué herramientas hacen esto? SERVIDORES DE AUTOMATIZACION
- Jenkins
- Argo
- Bamboo
- Travis
- TeamCity
- Azure DEVOPS
- Gitlab CI/CD
- ...
---

# IaC: Infraestructura como código?

Tener un fichero (script) con la definición de la infra y poder desplegarlo en automático? NO

Va mucho más allá...
Es tratar la infra commo si fuera código! No es definir la infra en código (bueno si...)... pero es mucho más... es TRATARLA COMO CODIGO.
Y lo primero que hago con un código es: SOMETERLO A CONTROL DE VERSIONES!

Y hoy en día tengo va 1.0.0 de la infra, pensada para ejecutar la v1.0.0 del producto X de software.

Y ahora el producto para a v2.0.0 (le han añadido soporta para un redis.. que haga cache a la BBDD y no vaya tanto a la misma a hacer consultas)
Necesito una nueva versión de la infra... que añada un redis...
Implicará crear:
-  Nuevos Servidores / VMs / Contenedores (y varios.. en Cluster: HA!)
   -  Hadware + SO + Configuraciones dentro de ese SO.
-  Balanceador de carga o VIPA
-  Almacenamiento?
-  Monitorización
-  Usuario/Contraseña?
-  ...

Qué versión de la infra genero? v1.0.0 -> v1.1.0

Quizás ... cambio el servidor de email.. y necesito cambiar un fichero de configuración del despliegue!
    v1.1.0 -> v1.1.1

Esas versiones puede incluso coexistir en el tiempo. Puedo tener una versión de la infra en el entorno de pre... preparada para la nueva versión del producto y otra versión en pro, con la versión anterior.
Puedo tener incluso versiones distintas en pro si opero varios clientes... y los voy pasando poco a poco.


IaC no es SOLO tener ficheritos declarando recursos... ES TRATARLOS A TODOS LOS EFECTOS COMO CODIGO:
- Control de versiones
- Pruebas 
- Despliegues
- Rollbacks


Pregunta... quién es el candidato ideal a automatizar trabajos de maven/gradle, msbuild (empaquetado de la app)? desarrollador.. que sabe del tema y el que lo ha hecho durante años a mano.
Pregunta... quién es el candidato ideal a automatizar trabajos de pruebas? tester.. que sabe del tema y el que lo ha hecho durante años a mano.
Pregunta... quién es el candidato ideal a automatizar trabajos de sysadmin? administradores de sistema.. que sabe del tema y el que lo ha hecho durante años a mano.
Pregunta... quién es el candidato ideal a automatizar procesos? Necesito un perfil nuevo: al que se llamó DEVOPS!
El tio/tia que configura los pipelines del JENKINS. Necesita un conocimiento general PERO DE TODAS ESTAS HERRAMIENTAS.

Lamentablemente el nombre DEVOPS como perfil se ha malogrado... y hoy en día en muchas empresas al SysAdmin v2.0 (que trabaja con herramientas de automatización)... Por la misma lógica... porque no llamamos devops al dev 2.0 o al tester v2.0?

---

# Versionado en el mundo IT... usando El Esquema SEMANTICO SEMVER de versionado.

A.B.C

                ¿Cuándo suben?
A   MAJOR       BREAKING CHANGES: Cambios que rompen compatibilidad.
B   MINOR       Nueva funcionalidad
                Se marca una funcionalidad como obsoleta (DEPRECATED)
                    + OPCIONALMENTE PUEDEN VENIR ADEMAS ARREGLOS DE BUGS
C   PATCH       Arreglos de bugs: BUG FIXES

---

# Kubernetes?

Es una herramienta para definir y operar mediante un lenguaje DECLARATIVO un entorno de producción (basado en contenedores) de forma autoamtizada.

---

# Metodologías ágiles de desarrollo de software: SCRUM, KANBAN

El concepto clave, la gran diferencia con respecto a lo que hoy en día llamamos metodologías tradicionales (cascada, espiral, V), se entrega el producto de forma INCREMENTAL AL CLIENTE! Buscamos feedback muy rápido del cliente!
Y para ello, en cuanto tenbgo 3 cositas, se lo pongo en producción.

Esta guay... pero esto que ha resuelto muchos problemas, ha venido con sus propios problemas!

> Cuántas veces se pasaba a producción un producto (software) al operar con una met. "tradicional"? 1 cuando acababa.
> Y ahora? Cada mes ! ( cada 2 semanas,... cada 6 semanas...)
> Y .. espera... para pasar a producción un sistema, lo primero es? Pruebas a nivel de producción!
>
> Y espera...
> Si en la primera entrega (SPRINT 1) se añade la funcionaldiad R1, R2, R3, pruebo la R1, R2, R3
> Pero sien la segunda entrega meto la R4 y R5... qué hay que probar? TODAS.

Es decir las instalaciones se multiplican.
Pero las pruebas crecen exponencialmente!

Y la pregunta es... de dónde sale la pasta? y el tiempo? y los recursos? Y la respuesta es:
NI HAY PASTA, NI HAY TIEMPO, NI HAY RECURSOS.

Por lo que la única solución que queda es: AUTOMATIZAR

Y aquí es cuando aparece DEVOPS!
Es imposible ir a una metodología AGIL sin abrazar una cultura DEVOPS.

---

# Ansible es una herramienta de automatización DE TAREAS!

Y la debo tratar como tal.
No tengo que pensar que es algo que existe de forma aislada!
Es solo un eslabon más en la cadena de herramientas que AUTOMATIZAN TRABAJOS.
Por si solo no aporta tanto valor!
La gracia es tener una cadena completa de AUTOMATIZACION!
Y ansible es parte de ella.

Eso significa que será imprescindible configurar esos scripts para:
- Poder recibir parámetros
- Generar OUTPUTS que sean consumidos por otros elabones de la cadena

---

Y ahora encaja de forma natural otro concepto!

# Cúantas veces se va a ejecutar un playbook?

LA HUEVA!
En un modelo tradicional de trabajo... cuántas veces tenía que instalar o configurar algo en el entorno de producción? POCAS!
Con metodologíuas ágiles y el concepto de IaC.... cuántas veces tenía que instalar o configurar algo en el entorno de producción? LA HUEVA!
Y cómo va a estar el entorno de producción? NPI
    Que quiero pasar de la infra v1.1.0 a la v1.1.1 o quiero volver a la v1.0.0 que hay problema y hay que dar marcha atrás.

Y AQUI ES DONDE SE HACE TOTALMENTE NECESARIO EL CONCEPTO DE IDEMPOTENCIA! No es un capricho.
Antes tenía un script de instalación de Oracle "oracle-install.sh"
Y cuando creaba la infra, ejecutaba ese script. SE ACABO!

Esto no vale a día de hoy.
Ese script lo ejecutaré continuamente, con cambios en configuraciones, marchas atrás.... nuevas versiones... AUTOHEALTH
Si un entorno falla... (MONITOR/OBSERV)... lo primero, ejecuto el script de nuevo... para ver si se arregla.

NO VAMOS A CREAR UN SCRIPT PARA INSTALAR ORACLE o el programa X!                                                    Lenguaje IMPERATIVO!!!!
NO VAMOS A CREAR UN SCRIPT PARA CONFIGURAR EL SO de unos servidores!

VAMOS A CREAR UN SCRIPT PARA ASEGURARME QUE TENGO UNA INSTALACION OEPRATIVA con una determinada configuración!      LENGUAJE DECLARATIVO!!!!
VAMOS A CREAR UN SCRIPT PARA ASEGURARME QUE TENGO un SO CONFIGURADO COMO ME INTERESA!

El abrazar una cultura devops se hace poco a poco... y tardamos años.
Y lo primero es AUTOMATIZAR TAREAS! Y quizás el ansible hoy lo ejecuto yo a mano ( y la persiana aprieto yo el botón)
Pero con la idea de interar esto el día de mañana en flujos de automatización más completos.


---

# Redhat fabrica muchos otros programas!

Muchos de ellos suelen necesitar o al menos ejecutarse de forma más optimizada en su distro... no todos.

- Openshift
- Satelite
- Ansible
- JBoss
- Redhat Virtualization
- Podman
- ...

---

# AUTOMATIZAR en nuestro caso la gestión/operación, Administración de un RHEL.

## Qué es automatizar?

Crear una máquina (o cambiar el comportamiento de una mediante programas) para hacer algo que antes hacia un humano con sus manos.

Puedo automatizar el lavado de la ropa (LAVADORA) , que incluso puedo cambiar su comportamiento con programas (PROGRAMA DE FRIO, PRENDAS DELICADAS...), para asi no tenerme que poner yo a rascar ropa contra una tabla arrugá!

En nuestro caso (mundo IT) la máquina la tenemos: COMPUTADORA... lo que hacemos es programas.

En el mundo IT -> AUTOMATIZAR = PROGRAMAR!

En nuestro caso, no vamos a desarrollar aplicaciones, ni drivers, ni librerías, ni demonios. Vamos a desarrollar scripts.

CONSECUENCIA: El papel de un SysAdmin hoy en día NO ES ADMINISTRAR SISTEMAS -> Crear programas que Administren sistemas.

## La automatización de procesos != Automatización de tareas

Tengo una persiana. la subo y bajo con cuerdita. Le pongo un motor y un botón. Qué he automatizado?
- La tarea de subir y bajar la persiana.

He automatizado el PROCESO de subir y bajar la persiana? No, sigue haciendo falta intervención manual: Apretar el botón
Ahora bien.. un avez automatizada esa tarea... y automatizada la determinación de la cantidad de luz que hay en la calle (mediante por ejemplo un sensor de luz), puedo montar una MAQUINA(PROGRAMA) que automatice todo el proceso:
    - Cuando detecte (TRIGGER) que hay poca luz fuera: BAJA LA PERSINA
    - Cuando detecte (TRIGGER) que hay mucha luz fuera: SUBE LA PERSINA

---

# Estructura de un Playbook (esquema que ofrece ANSIBLE)

```yaml
# Un playbook es un libro de plays.
# Cada play es un script que vamos a escribir. En lenguaje IMPERATIVO! Como si fuera la bash.
- name:   NOMBRE DEL PLAY (Script)
  hosts:  nginx
            # Lo habitual no es usar esto para limitar... sino para fijar los potenciales candidatos sobre los que ejecutar el playbook

            # LIMITACION DE LOS NODOS(SERVIDORES...) donde se ejecutará el script
            # El script, cuando lo ejecutemos, irá OBLIGATORIAMENTE acompañado de un inventario
            # $    ansible-playbook -i INVENTARIO playbook.yaml    --limit nginx1
            # NOTAS:
            # - Habrá otros 30 argumentos que puedo pasar.. ya los veremos
            # - Realmente esto está obsoleto... ya no usamos este comando.
            #   Hoy en día, los playbooks los ejecutamos dentro de CONTENEDORES!
            # $    ansible-navigator
            #   Hemos dicho que las tareas de ansible las ejecutan? MODULOS !
            #   Qué módulos tengo disponibles? Querré los que necesite.
            #   Y existirán esos en el TOWER? o en la máquina de mi primo que quiere también correr el playbook?
            #   Cada módulo tendrá sus propios requisitos/dependencias... que tendrán que estar instaladas en el entorno de ejecución.
            #   Según ansible ha ido creciendo, es más crítico controlar los entornos de ejecución.
            #   Hoy en dia, esos entornos se definen en un ficheor YAML.. con el que nos creamos nuestra imagen de contenedor propia.
  gather_facts: false # true
        # Recoge todos los datos disponibles del host sobre el que se ejecuta el playbooks: Nombre, IP, RAM, cpu, procesos corriendo...
        # NO SE USA EN LA SANTA VIDA ! Siempre en false.
        # Es una locura obsoluta la cantidad de datos que esto trae.. y el tiempo que tarda.
        # Si me interesa un dato o un conjunto de datos, que uso? El módulo "setup"... que me permite traer lo que quiero! Y NO MAS!
  vars: # Sirve para definir CONSTANTES!
        # Tiene una mierda de nombre increible. NO SE USA PARA VARIABLES! SE USA PARA CONSTANTES!
        # Las variables no es algo que defina dentro del fichero... si son variables es que querré que tengan muchos valores..
        # Y entonces las pondré en ficheros independientes.. las pondré en inventario... las pasaré en tiempo de ejecución... YA VERE!
        # No quiero tener que entrar aquí a cambiarlo.
        # CONSTANTES!
        constante1: VALOR
        constante2: valor
    # Hay más cosas.. que ya hablaremos
  # Las tareas concretas que debe ejecutar el script se definen dentro de claves especiales para tal finalidad. 
  # Y en Ansible tenemos 4
  # Las tres primeras: pre_tasks, tasks y post_tasks son identicas entre si (su comportamiento)
  # Solo es que van en orden.. y es conceptual...
  pre_tasks:        # Requisitos para poder ejecutar las tasks
    - name:     Tarea1
      # detalle
    - name:     Tarea2
      # detalle
  tasks:            # Las tareas propias de nuestro script
      # detalle
    - name:     Tarea3
      notify:   Handler1  
      # detalle
  # - name: Tarea que fuerza ejecución de handles activados en este momento
  #   meta:     flush-handlers # En general esto se suele poder conseguir con un buen diseño del playbook... Pero hay casos donde puede venir bien
                # end-play
                # end-host
  #   En general el módulo "meta" lo usamos poco... pero si resuelve escenarios (trucos sucios = HACK) que no es facil recolver por otras vias.
    - name:     Tarea4  
      notify:   Handler1
  post_tasks:       # Comprobaciones, informes, notificaciones al acabaer el proceso.
    - name:     Tarea5
      nofity:   evento1
      # detalle
    - name:     Tarea6
      nofity:   evento1
      # detalle
  # Aquí hay una linea clara de división.
  # Los handlers solo se ejecutan cuando son activados. 
  # Hay 2 formas de activarlos:
  # - Que una tarea los active (NOTIFY A UN NOMBRE) cuando una tarea se completa exitosamente       ESTO ES UNA ÑAPA SUCIA!
  # - Que una tarea notifique (lance) un EVENTO que un handler escuche!                             GUAY!!!! 
  #   Esto es mantenible... lo otro es ñapa sucia y asquerosa!
  # Los handlers que han sido activados en un bloque se ejecutan todos seguidos, en el mismo orden que están definidos después de que las tareas
  # de un bloque (pre... tasks... o post han sido ejecutadas.)
  # NOTA: HAY UNA COSA QUE PUEDO PONER EN EL CODIGO para forzar a que los handlers que hayan sido activados YA se ejecuten en ese momento sin esperar al final del bloque:
  # Una tarea que está soportada por unn MODULO estandar de ANSIBLE: meta
  # Si un handler es activado varias veces, SOLO SE EJECUTA 1
  handlers:
    - name: Handler1
      # detalle
    - name: Handler2
      listen:  evento1
      # detalle
    - name: Handler3
      listen:  evento1
      # detalle
```

---

# A partir de aqui:

Nos toca meternos con el detalle de las tareas.
Y hay 2 cosas que ver:
- Atributos generales de ansible que podemos configurar a nivel de tarea:
  - when_changed
  - when_failed
  - when
  - tags
  - ...
- Atributos específicos de cada módulo. Nuestro objetivo no es aprender a usar todos los módulos de ansible.
  Ni siquiera aprender a usar todos los módulos que nos permiten administrar RHEL.
  Hay miles! Nos podemos pasar literalmente 3/4 meses de curso y no acabar.. y además muchos de ellos no los usaríamos en la santa vida.
  Nuestro objetivo es aprender a usar CUALQUIER MODULO!

---

Imaginad que tengo en mi inventario de máquinas:
- Servidores web:
  - Nginx:
    - nginx1
    - nginx2
  - Apache:
    - apache1
    - apache2
- Servidores BBDD
  - Oracles:
    - ...
  - MySQL:
    - ...
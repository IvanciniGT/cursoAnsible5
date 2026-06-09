# Jinja y Ansible

Jinja es una librería de python para crear plantillas de textos.
Ansible se apoya fuertemente en plantillas jinja.

```yaml
 - name: tarea 1 de un play
   #módulo: configuración
   vars:
        numero1: 5
        numero2: 10
        texto1:  hola
        nombre:  Felipe
   when: # Podemos poner una expresión jinja
        numero1 > 5
```

IMPORTANTISISMO!

Las expresiones jinja va siempre entre {{ expresion }}.
Y tenemos una situación muy peculiar con YAML... Porque en YAML las {} tiene un significado muy concreto: MAPA
En YAML, cuando queremos usar expresiones jinja es obligatorio encerrarlas entre "" para que no las confunda con MAPAS.
Esto es un poco tostón!

ANSIBLE ha hecho que ciertas propiedades de las que metemos en los plays no requieran las {{}} para facilitar su escritura... Las pone él internamente!


# Funciones

Jinja (la libreria de python) define funciones, que vienen de serie:

- upper
- lower
- default
- y otras 50

Pero jinja admite también que la gente pueda definir sus funciones.
Y de hecho ANSIBLE amplia la colección de funciones disponible.

Lo habitual a la hora de usar estas funciones es usar sintaxis de FILTROs...
Como si fueran pipes de Linux

    nombre | upper | default(Federico)

# Operadores Jinja

## De existencia

    is defined              Para mirar si una variable esta definida o no.. y si tiene un valor o no.
    is not defined
    is none
    is not none

```yaml

    # Inventario
        # host1 -> puerto_usado: 80
        # host2 -> puerto_usado: 8080
        # host3 

    - name: Abrir puerto en el firewall
      # Esto lo quiero hacer no en todas las máquinas.. solo en las que explicitamente se solicite mediante una variable. Un sitio donde poder definir variables es en el inventario, asociadas a hosts o a grupos
      modulo: configuracion
      when: puerto_usado is defined
```

## De comparación                                
 == (2 iguales juntos)          Igual
 != ( ! = )                     Distinto
 >
 <
 > =
 < =
## Lógicos
 and
 or
 not
## Aritméticos
 +
 -
 *
 /                                                                          10/3 = 3.333
 **                             potencia    
 //                             división entera                             10//3 = 3
 %                              módulo (resto de la división entera)        10%3  = 1
                10 | 3
                -9 +---- 
                 1   3
# Pertenencia
 in                 Si un dato está en un conjunto de datos
```yaml
        - name: tarea que opera sobre elementos definidos previamente
          modulo: configuracion
          vars:
            puertos_permitidos: 
                - 80
                - 8080
                - 22
            puerto: 22
          when: puerto in puertos_permitidos
 not in
```

---

# Estados en los que puede acabar una tarea:

OK (success)
    La tarea no ha generado errores
CHANGED
    La tarea se ha ejecutado bien (OK) pero además ha generado cambios en el entorno
FAILED
    La tarea falló al ejecutarse
SKIPPED
    La tarea fue saltada (ignorada) por un condicional

Una tarea es ejecutada por un MODULO: SIEMPRE!

```yaml
    - name: Abrir puerto en el firewall
      # modulo: configuracion
      when: puerto_usado is defined
```
Esa tarea es un desaste absoluto! DISPARATE. RUINA!!!!!
Qué problema tiene tal y como está definida? El nombre!
NO ES DECLARATIVO!

El playbook es IMPERATIVO
Las tareas SON Y DEBEN SER DECLARATIVAS!.

    Abrir puerto en el firewall es DECLARATIVO? NO, es imperativo

Variante declarativa:

    Asegurar que el puerto esté abierto en el firewall.

    Puede ser que:
    - El puerto estuviera cerrado. Al ejecutar esa tarea que pasaría? SE ABRE EL PUERTO   -> CHANGED
    - El puerto ya estuviera abierto previamente. Al ejecutar esa tarea que pasaría? NADA -> OK
    - El puerto no estuviera abierto... y da error al abrirlo? FAILURE

El comportamiento por defecto de ansible al ejecutar un playbook es que SI UNA TAREA FALLA, CORTA LA EJECUCION... INMEDIATO. PARA ESE HOST. NO SIGUE CON MAS TAREAS

    Se puede modificar ese comportamiento con:
     ignore_errors: true     Si la tarea falla que anote el error, pero que siga ejecutando

Cuándo una tarea se marca como fallida?
  Las tareas son ejecutadas por un módulo... y el módulo es el responsable de decidir si la tarea si ha ejecutado bien o no.
  Esto es guay... delego esa responsabilidad... 
  El problema es que no todos los módulos son igual de listos. Hay módulos un poco menos listos!
  Por ejemplo:

```yaml
    - name: Tarea que ejecuta un comando bash
      shell: SCRIPT GENERICO HA HECHO CAMBIOS EN LA MAQUINA? NO HAY MANERA HUMANA
```

## Preguntas...

> Cuál es el trabajo del módulo "shell"? 

Ejecutar el comando/script que le pase

> Cómo determina el módulo si la tarea ha provocado cambios en el sistema?

En este caso, el módulo shell siempre devuelve que ha provoicado cambios.. porque no tiene forma de saber si se han provocado o no... y opta por la opción más convervadora! DECIR QUE SI!

> Pero previo a eso... cómo sabe si la tarea ha acabado no con error?

Capturando el código de salida del script: Return Code. Todo proceso en Linux, Windows...cuando termina devuelve un código de salida:
    0   -> GUAY
    !=0 -> ERROR

En concreto el módulo shell hace eso.
Hay más módulos que hacen eso: command, win_shell


Me interesa ese comportamiento? SI o NO .. depende del caso de uso.


    > mkdir ventana... y me la pela si ha tenido que crear o no la carpeta.. mientras al final exista.
    QUIERO IDEMPOTENCIA

        shell:   mkdir -p ruta/a/la/carpeta
    
    > Quiero asegurarme que la carpeta queda creada... pero necesito saber si se ha creado ahora o no!

        shell: |
            #!/bin/bash

            if [ -d "$DIRECTORIO" ]; then 
                exit 0
            fi

            mkdir -p $DIRECTORIO
            exit 100
    
    Y ahora lo que hago es marcar la tarea como OK cuando el Código de salida sea 0
    Y marcarla como changed cuando el código sea 100
    Y marcarla como error cuando sea ni 0 ni 100

Y ansible tiene atributos para todas esas cosas

    failed_when
    changed_when

Los módulos, cuando se ejecutan, mandan un JSON de vuelta a Ansible.
Lo del JSON nos da igual.. El hecho es que manda información de vuelta a ANSIBLE, que yo puedo consultar.
Para consultar esa información necesito REGISTRAR la tarea: REGISTER !

Una vez registrada la tarea, puedo acceder a los datos que el módulo devuelva mediante la sintaxis:

    nombre_registrado.PROPIEDAD_DEVUELTA

Qué datos devuelve un MODULO? DEPENDE 100% del módulo.
Toca mirar la documentación.

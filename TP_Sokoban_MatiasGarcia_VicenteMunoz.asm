.data
@especiales
clear_str:  .ascii "\033[2J\033[H"  @ código de escape ANSI para limpiar pantalla y mover cursor a arriba a la izquierda
.equ clear_len, . - clear_str

@mapas
mapa1:  .ascii "#######\n"
    	.ascii "#  .  #\n"
        .ascii "#  $  #\n"
        .ascii "#  @  #\n"
        .ascii "#######\n"
.equ mapa1_len, . - mapa1   
mapa1_ancho: .int 8 

mapa2:  .ascii "########\n"
    	.ascii "#  #   #\n"
    	.ascii "# $ .  #\n"
        .ascii "#  @ $ #\n"
        .ascii "#   .  #\n"
        .ascii "########\n"
.equ mapa2_len, . - mapa2   
mapa2_ancho: .int 9 

mapa3:  .ascii "##########\n"
    	.ascii "#        #\n"
    	.ascii "#   ..   #\n"
    	.ascii "#  $$$$  #\n"
        .ascii "#   @    #\n"
        .ascii "#        #\n"
        .ascii "#   ..   #\n"
        .ascii "##########\n"
.equ mapa3_len, . - mapa3   
mapa3_ancho: .int 11 



mapa4: 	.ascii "#########################\n"
        .ascii "#                .      #\n"
        .ascii "#           $           #\n"
        .ascii "#                       #\n"
        .ascii "#         @             #\n"
        .ascii "#                       #\n"
        .ascii "#            $          #\n"
        .ascii "#               .       #\n"
        .ascii "#########################\n"
.equ mapa4_len, . - mapa4   
mapa4_ancho: .int 26 

@Archivo
archi:     .asciz "ranking_sokoban.txt" // manejamos archivos de texto “.txt”
buffer_file:   .space 62   			  // espacio para poner contenido archivo
.equ len_buffer_file, 62
buffer_record: .space 62				//espacio para string a guardar en archivo
.equ len_buffer_record, 62

@buffer
buffer_input_teclado: .space 16
len_input_teclado = . - buffer_input_teclado
buffer_numero_ascii: .space 12
.equ len_buffer_numero_ascii, 12 

@Mensajes:
msg_welcome: .ascii "Proyecto Sokoban Arm \n"
len_welcome = . - msg_welcome
msg_map_select: .ascii "Seleccione un mapa: 1, 2, 3 o 4 \n"
len_map_select = . - msg_map_select
msg_input_invalido: .ascii "input invalido \n"
len_input_invalido = . - msg_input_invalido
msg_movements: .ascii "Controles: Movimiento (W/A/S/D) Reiniciar(R) Salir(Q) \n"
len_msg_movements = . - msg_movements
msg_victory: .ascii "*** Nivel Completado Felicidades ***\n"
len_msg_victory = . - msg_victory
msg_victory_result: .ascii "Ingrese su nombre, no mas de 15 caracteres: \n"
len_msg_victory_result = . - msg_victory_result
msg_victory_title: .ascii "Nombre           | Nivel        | Pasos        | Tiempo      \n"
len_msg_victory_title = . - msg_victory_title


espacio_resultados: .ascii " | "
len_espacio_resultados = . - espacio_resultados


salto_de_linea: .ascii "\n"
len_salto_de_linea = . - salto_de_linea

@RepresentacionGraficaChars:
char_player: .ascii "@"
char_wall: .ascii "#"
char_box: .ascii "$"
char_objective: .ascii "."
char_box_at_objective: .ascii "*"
char_player_over_objective: .ascii "+"
char_floor: .ascii " "

@VariablesEstado:
map_in_memory: .space 512
map_in_memory_len: .word 0
map_in_memory_width: .word 0
current_level: .word 0

pos_personaje: .word 0
mov_personaje: .word 0 
pos_caja_mover: .word 0
mov_caja: .word 0

movements: .int 0
start_time: .space 8
finish_time: .space 8
tiempo_total: .space 8
.text

@ llama a imprimir en pantalla
@ imprimir: r1 = dirección del texto, r2 = largo
imprimir:

	.fnstart 

	push { r0, r7, lr }

	mov r7, #4                      @ Salida por pantalla 

	mov r0, #1                       @ salida cadena  

	swi 0

	pop { r0, r7, lr }

	bx lr

	.fnend

@escribe en pantalla el string de clear_str para limpiar la pantalla
limpiar_pantalla:
	.fnstart
	push { r1, r2, lr }

	ldr r1, =clear_str
	mov r2, $clear_len
	bl imprimir

	pop { r1, r2, lr }
	bx lr
	.fnend

@imprime un mensaje de bienvenida y de seleccion de mapa en pantalla
imprimir_welcome:
	.fnstart
	push { r1, r2, lr }

	ldr r1, =msg_welcome
	mov r2, $len_welcome
	bl imprimir

	ldr r1, =msg_map_select
	mov r2, $len_map_select
	bl imprimir

	pop { r1, r2, lr }
	bx lr
	.fnend

@imprime un mensaje de input invalido en pantalla
imprimir_input_invalido:
	.fnstart
	push { r1, r2, lr }

	ldr r1, =msg_input_invalido
	mov r2, $len_input_invalido
	bl imprimir

	pop { r1, r2, lr }
	bx lr
	.fnend

@imprime un mensaje de input invalido en pantalla
imprimir_msg_movements:
	.fnstart
	push { r1, r2, lr }

	ldr r1, =msg_movements
	mov r2, $len_msg_movements
	bl imprimir

	pop { r1, r2, lr }
	bx lr
	.fnend

@finaliza el programa
salir:

	.fnstart

	mov r7, #1

	swi 0                           @ SWI, Software interrupt

	.fnend
	
@ copiar_mapa: r0 = origen, r1 = largo
@ copia r1 bytes desde r0 hacia map_in_memory y guarda el largo
copiar_mapa:
    push {r2, r3, r4, lr}
    ldr r2, =map_in_memory         @ r2 = destino
    ldr r4, =map_in_memory_len
    str r1, [r4]                @ map_in_memory_len = largo
bucle_copiar_mapa:
    cmp r1, #0
    beq fin_copia
    ldrb r3, [r0], #1           @ lee un byte del origen y avanza
    strb r3, [r2], #1           @ lo guarda en el destino y avanza
    sub r1, r1, #1
    b bucle_copiar_mapa
fin_copia:
    pop {r2, r3, r4, lr}
    bx lr

@carga el mapa activo segun el id en map_in_memory_id
set_mapa_1:
	.fnstart
	push {r0,r1, lr }
	ldr r0, =mapa1
	ldr r1, =mapa1_len
	bl copiar_mapa
	ldr r0, =map_in_memory_width
	ldr r1, =mapa1_ancho
   	ldr r1, [r1]
	str r1, [r0] 
	pop { r0, r1, lr }
	bx lr

	.fnend

@carga el mapa 2 en map_in_memory
set_mapa_2:
	.fnstart
	push {r0,r1, lr }
	ldr r0, =mapa2
	ldr r1, =mapa2_len
	bl copiar_mapa
	ldr r0, =map_in_memory_width
	ldr r1, =mapa2_ancho
   	ldr r1, [r1]
	str r1, [r0] 
	pop { r0, r1, lr }
	bx lr

	.fnend

@carga el mapa 3 en map_in_memory
set_mapa_3:
	.fnstart
	push {r0,r1, lr }
	ldr r0, =mapa3
	ldr r1, =mapa3_len
	bl copiar_mapa
	ldr r0, =map_in_memory_width
	ldr r1, =mapa3_ancho
   	ldr r1, [r1]
	str r1, [r0] 
	pop { r0, r1, lr }
	bx lr

	.fnend
@carga el mapa 4 en map_in_memory
set_mapa_4:
	.fnstart
	push {r0,r1, lr }
	ldr r0, =mapa4
	ldr r1, =mapa4_len
	bl copiar_mapa
	ldr r0, =map_in_memory_width
	ldr r1, =mapa4_ancho
   	ldr r1, [r1]
	str r1, [r0] 
	pop { r0, r1, lr }
	bx lr

	.fnend

@Copia el mapa seleccionado desde la sección .data a la matriz activa de juego en memoria
cargar_mapa:
	.fnstart
	push {r0, lr}
	ldr r0, =current_level
	ldr r0, [r0]
	cmp r0, #1
	bleq set_mapa_1
	cmp r0, #2
	bleq set_mapa_2
	cmp r0, #3
	bleq set_mapa_3
	cmp r0, #4
	bleq set_mapa_4
	pop {r0, lr}
	bx lr
	.fnend

@imprime el mapa activo en pantalla
imprimir_mapa:
	.fnstart
	push { r1, r2, lr }
	
	ldr r1, =map_in_memory
	ldr r2, =map_in_memory_len       
	ldr r2, [r2]
	bl imprimir
	
	pop { r1, r2, lr }
	bx lr
	.fnend	

@Dibuja en pantalla el estado actual del juego limpiando previamente la consola
mostrar_mapa:
	.fnstart
	push {lr}
	bl limpiar_pantalla
	bl imprimir_mapa
	pop {lr}
	bx lr
	.fnend

@recibe en r0 el char a buscar en el mapa
@devuelve en r1 la cantidad de caracteres recorridos hasta encontrarlo o -1 si no se encuentra
encontrar_char_en_mapa:
	.fnstart
	push { r2, r3, r4, lr }
	ldr r2, =map_in_memory         @ r2 = destino
    ldr r4, =map_in_memory_len
    ldr r4, [r4]                @ map_in_memory_len = largo
	mov r1, #0
bucle_encontrar_mapa:
    cmp r1, r4				  @ compara con el largo del mapa
    beq fin_bucle
    ldrb r3, [r2, r1]           @ r3 = map_in_memory[r1]
	cmp r3, r0                  @ compara con el char buscado
	beq fin_bucle                @ si es igual, termina
    add r1, r1, #1
    b bucle_encontrar_mapa
fin_bucle:
	cmp r1, r4
	beq no_encontrado
	b fin_encontrar_char
	no_encontrado:
	mov r1, #-1
	fin_encontrar_char:
	pop {r2 ,r3 ,r4 ,lr}
	bx lr
	.fnend

@recibe en r0 el char a escribir y en r1 la posicion donde escribir en el mapa
escribir_en_mapa:
	.fnstart
	push { r2, lr}
	ldr r2, =map_in_memory         @ r2 = destino
	add r2, r2, r1 					@ r2 = destino + posicion
	strb r0, [r2]               @ escribe el char en la posicion
	pop {r2,lr}
	bx lr
	.fnend

/*
entradas: r1 recibe direccion de memoria donde va a guardar el string
	  r2 recibe la cantidad de caracteres a leer
*/
pedirTexto:
    .fnstart
    push {r0,r7,lr}

    mov r7, #3
    mov r0, #0
    swi 0

    pop {r0,r7,lr}
    bx lr
    .fnend

@pido input de teclado y lo guardo en buffer_input_teclado
pedirInputTeclado:
	.fnstart
	push {r1,r2,lr}
	bl limpiar_buffer_teclado
	ldr r1, =buffer_input_teclado
	mov r2, $len_input_teclado
	bl pedirTexto

	pop {r1,r2,lr}
	bx lr
	.fnend

/* 
   Input r3: dividendo, r4: divisor
   Ouput: r5: resto, r6: cociente
*/
dividir:
    .fnstart
    push {r3, r4, lr}

    mov r6, #0
    ciclo:
	cmp r3, r4
	blt finCiclo

	sub r3, r4
	add r6, #1

	bal ciclo

    finCiclo:
	mov r5, r3
	pop {r3, r4, lr}
	bx lr
    .fnend


@recibe en r0 un char y devuelve en r1 su valor numerico si es un digito, sino devuelve -1
@pasa un numero en ascii de una cifra a su valor numerico, si no es un digito devuelve -1
pasar_ascii_a_numero:
	.fnstart
	push {r0, lr}
	cmp r0, #'0'
	blt no_es_digito            @ menor que '0'
	cmp r0, #'9'
	bgt no_es_digito            @ mayor que '9'
	sub r1, r0, #'0'
	pop {r0, lr}
	bx lr
	no_es_digito:
	mov r1, #-1
	pop {r0, lr}
	bx lr
	.fnend

@recibe en r1 un numero de una cifra y devuelve en r2 su valor en ascii
pasar_numero_a_ascii_una_cifra:
	.fnstart
	push {r1, lr}
	add r2, r1, #'0'
	pop {r1, lr}
	bx lr
	.fnend

@limpiar el buffer de numero ascii llenandolo de espacios
limpiar_buffer_numero_ascii:
	.fnstart
	push {r0, r1, lr}
	ldr r0, =buffer_numero_ascii
	mov r1, $len_buffer_numero_ascii
	bucle_limpiar_buffer:
	cmp r1, #0
	beq fin_bucle_limpiar_buffer
	mov r2, #' '
	strb r2, [r0], #1
	sub r1, r1, #1
	b bucle_limpiar_buffer
	fin_bucle_limpiar_buffer:
	pop {r0, r1, lr}
	bx lr
	.fnend

@limpia el buffer de input de teclado llenandolo de espacios
limpiar_buffer_teclado:
	.fnstart
	push {r0, r1, lr}
	ldr r0, =buffer_input_teclado
	mov r1, $len_input_teclado
	bucle_limpiar_buffer_teclado:
	cmp r1, #0
	beq fin_bucle_limpiar_buffer_teclado
	mov r2, #' '
	strb r2, [r0], #1
	sub r1, r1, #1
	b bucle_limpiar_buffer_teclado
	fin_bucle_limpiar_buffer_teclado:
	pop {r0, r1, lr}
	bx lr
	.fnend

@convierte un numero en r0 a ascii y lo guarda en buffer_numero_ascii
pasar_numero_a_ascii:
	.fnstart
	push {r0, r1, r2, r3, r4, r5, r6, r7, lr}
	bl limpiar_buffer_numero_ascii
	ldr r7, =buffer_numero_ascii
	add r7, r7, $len_buffer_numero_ascii  @ r7 apunta al final del buffer
	mov r3, r0  					      @ r3 = numero a convertir
	mov r4, #10 						  @ divido por 10 para obtener digitos
	bucle_recorrer_numero:
	@r3 = numero a convertir r4 divisor
	bl dividir
	mov r3, r6  						  @ el resto del numero a convertir lo muevo al cociente
	mov r1, r5  						  @ El resto es la cifra a convertir
	bl pasar_numero_a_ascii_una_cifra
	sub r7, r7, #1 						  @ me muevo una posicion atras en el buffer
	strb r2, [r7] 						  @ guardo el digito convertido en ascii
	cmp r3, #0
	bne bucle_recorrer_numero
	pop {r0, r1, r2, r3, r4, r5, r6, r7, lr}
	bx lr
	.fnend



@recibe una posicion dentro del mapa en r1 y devuelve en r2 la posicion arriba en el mapa,
@devuelve -1 para posiciones invalidas
obtener_arriba_pos:
	.fnstart
	push {r0, r1,lr}
	ldr r0, =map_in_memory_width
	ldr r0, [r0]
	cmp r1, r0
	blt obtener_arriba_invalida @ pos < ancho: primera fila 

	sub r2, r1, r0              @ r2 = pos - ancho
	b obtener_arriba_fin

	obtener_arriba_invalida:
	mov r2, #-1
	obtener_arriba_fin:
	pop {r0, r1, lr}
	bx lr
	.fnend

@recibe una posicion dentro del mapa en r1 y devuelve en r2 la posicion abajo en el mapa,
@devuelve -1 para posiciones invalidas
obtener_pos_abajo:
.fnstart
	push {r0, r1,lr}
	ldr r0, =map_in_memory_width
	ldr r0, [r0]
	add r2, r1, r0              @ r2 = pos + ancho
	
	ldr r0, =map_in_memory_len
	ldr r0, [r0]                @ r0 = largo total del mapa
	cmp r2, r0
	bge obtener_abajo_invalida  @ r2 >= largo: se salió del mapa

	b obtener_abajo_fin

	obtener_abajo_invalida:
	mov r2, #-1
	obtener_abajo_fin:
	pop {r0, r1, lr}
	bx lr
	.fnend

@obtiene en en r1 la posicion desde la que se desea mover
@carga en r0 la tecla de movimiento
@devuelve en r2 la posicion a la cual moverse, o -1 si es invalida
obtener_posicion_siguiente:
	.fnstart
	push {r0, r1, lr}
	ldr r0, =buffer_input_teclado
	ldrb r0, [r0]               @ r0 = tecla de movimiento
	cmp r0, #'w'
	beq movimiento_arriba
	cmp r0, #'W'
	beq movimiento_arriba
	cmp r0, #'s'
	beq movimiento_abajo
	cmp r0, #'S'
	beq movimiento_abajo
	cmp r0, #'a'
	beq movimiento_izquierda
	cmp r0, #'A'
	beq movimiento_izquierda
	cmp r0, #'d'
	beq movimiento_derecha
	cmp r0, #'D'
	beq movimiento_derecha
	b fin_manejo_movimiento_no_reconocida     @ tecla no reconocida

	movimiento_arriba:
	bl obtener_arriba_pos       @ r2 = pos de arriba o -1
	b fin_obtener_posicion_siguiente
	movimiento_abajo:
	bl obtener_pos_abajo        @ r2 = pos de abajo o -1
	b fin_obtener_posicion_siguiente
	movimiento_izquierda:
	sub r2, r1, #1
	b fin_obtener_posicion_siguiente
	movimiento_derecha:
	add r2, r1, #1
	b fin_obtener_posicion_siguiente
	fin_manejo_movimiento_no_reconocida:
	mov r2, #-1

	fin_obtener_posicion_siguiente:
	pop {r0, r1, lr}
	bx lr
	.fnend

@pide input de teclado por pantalla y la devuelve en r0
@pedido de movimiento
pedir_movimiento:
	.fnstart
	push { lr}
	bl imprimir_msg_movements
	bl pedirInputTeclado
	ldr r0,=buffer_input_teclado
	ldrb r0, [r0]
	pop { lr}
	bx lr
	.fnend

guardar_movimiento_caja:
	.fnstart
	push { r0, r1, r2, lr}
	ldr r0, =map_in_memory
	ldrb r1, [r0, r2]           @ r1 = char en la posición nueva	
	cmp r1, #'.'
	beq guardar_movimiento_caja_valido_objetivo
	ldr r0, =char_box
	ldrb r0, [r0]               @ r0 = '$'
	b dibujar_caja
	guardar_movimiento_caja_valido_objetivo:
	ldr r0, =char_box_at_objective
	ldrb r0, [r0]               @ r0 = '*'

	dibujar_caja:
	mov r1, r2                  @ r1 = posición nueva
	bl escribir_en_mapa         @ dibuja la caja en la nueva
	pop {r0, r1, r2, lr}
	bx lr
	.fnend


@recibe en r2 la posicion nueva de la caja y valida si es un movimiento valido, si lo es guarda la nueva posicion en pos_caja_mover
validar_y_guardar_movimiento_caja:
	.fnstart
	push { r0, r1, r2, lr}
	ldr r0, =map_in_memory
	ldrb r1, [r0, r2]           @ r1 = char en la posición nueva
	cmp r1, #' '
	beq validar_movimiento_caja_valido
	cmp r1, #'.'
	beq validar_movimiento_caja_valido
	mov r5, #-1 
	b validar_movimiento_caja_fin
	validar_movimiento_caja_valido:
	mov r5, #0
	bl guardar_movimiento_caja
	validar_movimiento_caja_fin:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@maneja el movimiento de la caja, devuelve en r5 si fue valido o no, y actualiza pos_caja_mover
manejar_movimiento_caja:
	.fnstart
	push { r0, r1, r2, lr}
	ldr r1, =pos_caja_mover
	ldr r1, [r1]                @ r0 = pos de la caja a mover
	bl obtener_posicion_siguiente  @ r2 = pos a la que se quiere mover la caja
	cmp r2, #0
	blt movimiento_caja_invalido
	blge validar_y_guardar_movimiento_caja
	b fin_manejo_movimiento_caja
	movimiento_caja_invalido:
	mov r5, #-1
	fin_manejo_movimiento_caja:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend
	


@recibe en r2 la posicion nueva del personaje y mueve al personaje a esa posicion, actualizando pos_personaje y el mapa
guardar_movimiento:
	.fnstart
	push { r0, r1, r3, r4, lr}
	ldr r1, =pos_personaje
	ldr r1, [r1]                @ r1 = posición vieja
	ldr r4, =map_in_memory
	ldrb r3, [r4, r1]           @ r3 = char en la posición vieja

	ldr r0 , =char_player_over_objective
	ldrb r0, [r0]               @ r0 = '+'
	cmp r3, r0
	beq mover_jugador_sobre_objetivo

	ldr r0, =char_floor
	ldrb r0, [r0]               @ r0 = ' '
	bl escribir_en_mapa         @ borra al jugador de la vieja
	b seguir_guardar_movimiento

	mover_jugador_sobre_objetivo: @estaba parado sobre un objetivo
	ldr r0, =char_objective
	ldrb r0, [r0]               @ r0 = '.'
	bl escribir_en_mapa         @ borra al jugador de la vieja y deja el objetivo

	seguir_guardar_movimiento:
	
	@actualiza pos del jugador
	mov r1, r2                  @ r1 = posición nueva
	ldr r0, =pos_personaje
	str r1, [r0]                @ actualiza pos_personaje

	ldr r0, =char_objective
	ldrb r0, [r0] 
	ldrb r3, [r4, r1]                  @ r3 = char en la posición nueva
	cmp r3, r0
	beq dibujar_personaje_sobre_objetivo
	
	ldr r0, =char_player
	ldrb r0, [r0]               @ r0 = '@'
	b dibujar_personaje

	dibujar_personaje_sobre_objetivo:
	ldr r0, =char_player_over_objective
	ldrb r0, [r0]               @ r0 = '+'

	dibujar_personaje:
	bl escribir_en_mapa         @ dibuja al jugador en la nueva
	pop {r0, r1, r3, r4, lr}
	bx lr
	.fnend


@recibe en r2 la posicion nueva del personaje y valida si es un movimiento valido, si lo es guarda la nueva posicion en pos_personaje
validar_y_guardar_movimiento:
	.fnstart
	push { r0, r1, r2, r5, r6, lr}
	ldr r0, =map_in_memory
	ldrb r1, [r0, r2]           @ r1 = char en la posición nueva
	cmp r1, #' '
	beq validar_movimiento_valido
	cmp r1, #'.'
	beq validar_movimiento_valido
	cmp r1, #'$'
	beq validar_movimiento_caja
	bl imprimir_input_invalido  @ casillas no vacias TODO: manejar cajas y objetivos
	b validar_movimiento_fin
	
	@intento de mover caja
	validar_movimiento_caja:
	ldr r6, =pos_caja_mover
	str r2, [r6]                @ guardo la posicion de la caja a mover
	bl manejar_movimiento_caja
	cmp r5, #-1
	beq validar_movimiento_fin

	validar_movimiento_valido:
	ldr r0, =movements
	ldr r1, [r0]
	add r1, r1, #1
	str r1, [r0]                @ incrementa contador de movimientos
	bl guardar_movimiento
	validar_movimiento_fin:
	pop {r0, r1, r2, r5, r6, lr}
	bx lr
	.fnend


@manejo de movimiento
@recibe en r0 la tecla obtenida y se guarda si es valido el movimiento
verificar_y_mover:
.fnstart
	push {r0, r1, r2, lr}
	ldr r1,=pos_personaje
	ldr r1, [r1]

	bl obtener_posicion_siguiente  @ r2 = pos a la que se quiere mover el jugador
	cmp r2, #0
	blge validar_y_guardar_movimiento   

	fin_manejo_movimiento:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@inicializa la posicion del jugador en el mapa
inicializar_jugador:
	.fnstart
	push {r0, r1, lr}
	ldr r0,=char_player
	ldrb r0, [r0]
	bl encontrar_char_en_mapa
	ldr r2,=pos_personaje
	str r1, [r2]
	ldr r0,=movements
	mov r1, #0
	str r1, [r0]
	ldr r0,=start_time
	bl obtener_tiempo
	pop {r0, r1, lr}
	bx lr
	.fnend

@recibe en r0 la direccion de memoria donde guardar el tiempo y lo guarda el tiempo actual
obtener_tiempo:
	.fnstart
	push {r0,r1,r7, lr}
	mov r1, #0
	mov r7, #78 @ syscall de gettimeofday
	swi 0
	pop {r0, r1, r7, lr}
	bx lr
	.fnend

@valida si ya no hay cajas en el mapa, si no hay devuelve 1, sino devuelve 0 en r3
verificar_victoria:
	.fnstart
	push {r0, r1, r2, lr}
	mov r3, #0
	ldr r0, =char_box
	ldrb r0, [r0]               @ r0 = '$'
	bl encontrar_char_en_mapa
	cmp r1, #-1
	beq victoria
	b fin_verificar_victoria
	victoria:
	mov r3, #1
	fin_verificar_victoria:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@calcula la diferencia entre el tiempo de inicion y el tiempo de fin y lo guarda en tiempo_total
calcular_tiempo_total:
	.fnstart
	push {r0, r1, r2, lr}
	ldr r0,=finish_time
	bl obtener_tiempo
	ldr r0,=finish_time
	ldr r0, [r0]
	ldr r1,=start_time
	ldr r1, [r1]
	sub r0, r0, r1
	ldr r2,=tiempo_total
	str r0, [r2]
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@receibe en r0 un numero y lo imprime en pantalla
imprimir_numero:
	.fnstart
	push {r0, r1, r2, lr}
	bl pasar_numero_a_ascii
	ldr r1,=buffer_numero_ascii
	mov r2, $len_buffer_numero_ascii
	bl imprimir
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@receibe en r0 la direccion de memoria de un string, en r2 la cantidad de caracteres a copiar y en r1 la direccion de memoria donde copiarlo
copiar_string:
	.fnstart
	push {r0, r1, r2, lr}
	bucle_copiar_string:
	cmp r2, #0
	beq fin_bucle_copiar_string
	ldrb r3, [r0], #1
	strb r3, [r1], #1
	sub r2, r2, #1
	b bucle_copiar_string
	fin_bucle_copiar_string:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@ borra el salto de linea del buffer de input de teclado y lo reemplaza por un espacio
eliminar_salto_de_linea:
	.fnstart
	push {r0, r1, r2, r3, lr}
	ldr r0,=buffer_input_teclado
	mov r2, $len_input_teclado
	mov r3, #0
	bucle_eliminar_salto_de_linea:
	cmp r3, r2
	beq fin_eliminar_salto_de_linea
	ldrb r1, [r0]
	cmp r1, #'\n'
	beq reemplazar_por_espacio
	add r0, r0, #1
	add r3, r3, #1
	b bucle_eliminar_salto_de_linea
	reemplazar_por_espacio:
	mov r1, #' '
	strb r1, [r0]
	fin_eliminar_salto_de_linea:
	pop {r0, r1, r2, r3, lr}
	bx lr
	.fnend


@ arma el string de record a guardar en el archivo, con el formato: nombre nivel movimientos tiempo
armar_record:
	.fnstart
	push { r0, r1, r2, lr }
	ldr r1,=buffer_record
	
	bl pedirInputTeclado
	bl eliminar_salto_de_linea
	ldr r0,=buffer_input_teclado
	mov r2, $len_input_teclado
	bl copiar_string
	add r1, r1, $len_input_teclado

	ldr r0,=espacio_resultados
	mov r2, $len_espacio_resultados
	bl copiar_string
	add r1, r1, $len_espacio_resultados

	ldr r0,=current_level
	ldr r0, [r0]
	bl pasar_numero_a_ascii
	ldr r0,=buffer_numero_ascii
	mov r2, $len_buffer_numero_ascii
	bl copiar_string
	add r1, r1, $len_buffer_numero_ascii
	
	ldr r0,=espacio_resultados
	mov r2, $len_espacio_resultados
	bl copiar_string
	add r1, r1, $len_espacio_resultados
	
	ldr r0,=movements
	ldr r0, [r0]
	bl pasar_numero_a_ascii
	ldr r0,=buffer_numero_ascii
	mov r2, $len_buffer_numero_ascii
	bl copiar_string
	add r1, r1, $len_buffer_numero_ascii

	ldr r0,=espacio_resultados
	mov r2, $len_espacio_resultados
	bl copiar_string
	add r1, r1, $len_espacio_resultados

	ldr r0,=tiempo_total
	ldr r0, [r0]
	bl pasar_numero_a_ascii
	ldr r0,=buffer_numero_ascii
	mov r2, $len_buffer_numero_ascii
	bl copiar_string
	add r1, r1, $len_buffer_numero_ascii
	
	ldr r0,=salto_de_linea
	mov r2, $len_salto_de_linea
	bl copiar_string
	pop { r0, r1, r2, lr }
	bx lr
	.fnend


@imprime un salto de linea en pantalla
imprimir_salto_de_linea:
	.fnstart
	push {r1, r2, lr}
	ldr r1,=salto_de_linea
	mov r2, $len_salto_de_linea
	bl imprimir
	pop {r1, r2, lr}
	bx lr
	.fnend

@abre el archivo de record y guarda el descriptor en r6, si hubo error devuelve -1 en r6
abrir_archivo_record:
	.fnstart
	push {r0, r1, r2, lr}
	mov r7, #5          		// Abrir archivo
    ldr r0, =archi      		// puntero al nombre del archivo
                         			// en r0 devuelve el descriptor
    mov r1, #2          		// 0: Lectura, 1: Escritura 2: lectura/escritura
    mov r2, #438         		// Permisos (0666 en octal rw para todos, son  permisos de linux), se pone 0 en caso de lectura.
    swi 0				// SysCall
    mov r6, r0  			// Guardo el descriptor en r6
	error_abrir_archivo_record:
	fin_abrir_archivo_record:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@cierra el archivo de record
cerrar_archivo_record:
	.fnstart
	push {r0, r1, r2, lr}
	mov r0, r6
	mov r7, #6          		// Cerrar archivo
	swi 0				// SysCall
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@lee e imprime el ranking del archivo de record, si hubo error al abrir el archivo no imprime nada
leer_ranking:
	.fnstart
	push {r0, r1, r2, lr}
	bl abrir_archivo_record
	cmp r6, #-1
	beq error_abrir_archivo_record_leer_ranking
	bucle_leer_ranking:

	mov r0, r6
	ldr r1,=buffer_file
	mov r2, $len_buffer_file
	mov r7, #3          		// Leer archivo
	swi 0				// SysCall
	cmp r0, #0
	ble fin_bucle_leer_ranking  @ 0 = EOF, negativo = error
	mov r2, r0                  @ imprime solo lo que se leyó
	ldr r1, =buffer_file
	bl imprimir
	b bucle_leer_ranking

	fin_bucle_leer_ranking:
	bl cerrar_archivo_record
	error_abrir_archivo_record_leer_ranking:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@se para en el final del archivo para evitar sobreescribir
ir_a_fin_de_archivo_record:
	.fnstart
	push {r0, r1, r2, lr}
	mov r7, #19         	// System call para mover el cursor en un archivo
    mov r0, r6           	// Descriptor del archivo
    mov r1, #0           	// offset
    mov r2, #2           	// SEEK_END (colocar el puntero al final del archivo)
    swi 0			// SysCall
	pop {r0, r1, r2, lr}
	bx lr
	.fnend

@guarda el nuevo record
escribir_ranking:
	.fnstart
	push {r0, r1, r2, lr}
	bl abrir_archivo_record
	cmp r6, #-1
	beq error_abrir_archivo_record_escribir_ranking
	bl ir_a_fin_de_archivo_record
	mov r0, r6          		// Nos aseguramos que r0 contenga descriptor
    mov r7, #4          		// Escritura, write
    ldr r1, =buffer_record		// puntero a memoria donde está el nuevo texto
    mov r2, $len_buffer_record		// cantidad de caracteres a escribir
    swi 0				// syscall
	bl cerrar_archivo_record
	error_abrir_archivo_record_escribir_ranking:
	pop {r0, r1, r2, lr}
	bx lr
	.fnend


@pantalla de victoria
victory_screen:
	.fnstart
	push {r0, r1, r2, lr }
	bl calcular_tiempo_total
	ldr r1,=msg_victory_result
	mov r2, $len_msg_victory_result
	bl imprimir
	bl armar_record
	bl escribir_ranking
	ldr r1,=msg_victory_title
	mov r2, $len_msg_victory_title
	bl imprimir
	bl leer_ranking
	bl imprimir_salto_de_linea
	pop {r0, r1, r2, lr }
	bx lr
	.fnend

.global main


main:
bl imprimir_welcome

bucle_seleccion_mapa:
	@pedir input
	bl pedirInputTeclado
	ldr r0,=buffer_input_teclado
	ldrb r0, [r0]
	
	@validar input
	bl pasar_ascii_a_numero
	cmp r1, #1				@ si no es un digito o es 0, input invalido
	blt input_invalido
	cmp r1, #4
	bgt input_invalido			@ si es mayor que 4, input invalido

	@seleccion valida, setear mapa
	ldr r0, =current_level
	str r1, [r0]
	b fin_bucle_seleccion_mapa

	@input invalido, imprimir mensaje y volver a pedir input
	input_invalido:
	bl imprimir_input_invalido
	b bucle_seleccion_mapa
fin_bucle_seleccion_mapa:
bl cargar_mapa
bl inicializar_jugador


bucle_juego:
	bl mostrar_mapa
	bl pedir_movimiento
	@manejar input
	cmp r0, #'q'				@ si es 'q' termina el bucle	
	beq fin_bucle_juego
	cmp r0, #'r'
	bne no_es_r
	bl cargar_mapa 			@ si es 'R' recarga el mapa      
	
	@reset player pos
	bl inicializar_jugador

	b seguir	
	no_es_r:
	blne verificar_y_mover		@ si no es 'R' ni 'q' verifica y mueve al jugador
	bl verificar_victoria
	cmp r3, #1
	beq fin_bucle_juego_victoria
	seguir:
	b bucle_juego
fin_bucle_juego_victoria:
	bl mostrar_mapa
	ldr r1, =msg_victory
	mov r2, $len_msg_victory
	bl imprimir
	bl victory_screen 
                         
fin_bucle_juego:
mov r7, #1

swi 0                           @ SWI, Software interrupt
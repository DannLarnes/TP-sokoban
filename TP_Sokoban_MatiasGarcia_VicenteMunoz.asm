.data
@especiales
clear_str:  .ascii "\033[2J\033[H"  @ caracter especiales para limpiar pantalla y mover cursor a 0,0
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



@buffer
buffer_input_teclado: .ascii "                                                                                           "
len_input_teclado = . - buffer_input_teclado

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
	ble finCiclo

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

@recibe en r0 un numero de una cifra y devuelve en r1 su valor en ascii
pasar_numero_a_ascii_una_cifra:
	.fnstart
	push {r0, lr}
	add r1, r0, #'0'
	pop {r0, lr}
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
	ldr r0, =buffer_input_teclado
	ldrb r0, [r0]               @ r0 = tecla de movimiento
	cmp r0, #'w'
	beq manejar_movimiento_caja_arriba
	cmp r0, #'W'
	beq manejar_movimiento_caja_arriba
	cmp r0, #'s'
	beq manejar_movimiento_caja_abajo
	cmp r0, #'S'
	beq manejar_movimiento_caja_abajo
	cmp r0, #'a'
	beq manejar_movimiento_caja_izquierda
	cmp r0, #'A'
	beq manejar_movimiento_caja_izquierda
	cmp r0, #'d'
	beq manejar_movimiento_caja_derecha
	cmp r0, #'D'
	beq manejar_movimiento_caja_derecha

	manejar_movimiento_caja_arriba:
	bl obtener_arriba_pos       @ r2 = pos de arriba o -1
	b intentar_mover_caja
	manejar_movimiento_caja_abajo:
	bl obtener_pos_abajo        @ r2 = pos de abajo o -1
	b intentar_mover_caja
	manejar_movimiento_caja_izquierda:
	sub r2, r1, #1
	b intentar_mover_caja
	manejar_movimiento_caja_derecha:
	add r2, r1, #1

	intentar_mover_caja:
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
	bl guardar_movimiento
	validar_movimiento_fin:
	pop {r0, r1, r2, r5, r6, lr}
	bx lr
	.fnend

@manejo de movimiento
@recibe en r0 la tecla obtenida y se guarda si es valido el movimiento
manejo_movimiento:
.fnstart
	push {r0, r1, r2, lr}
	ldr r1,=pos_personaje
	ldr r1, [r1]

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
	b fin_manejo_movimiento     @ tecla no reconocida

	movimiento_arriba:
	bl obtener_arriba_pos       @ r2 = pos de arriba o -1
	b intentar_moverse
	movimiento_abajo:
	bl obtener_pos_abajo        @ r2 = pos de abajo o -1
	b intentar_moverse
	movimiento_izquierda:
	sub r2, r1, #1
	b intentar_moverse
	movimiento_derecha:
	add r2, r1, #1

	intentar_moverse:
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
	pop {r0, r1, lr}
	bx lr
	.fnend

@valida si ya no hay cajas en el mapa, si no hay devuelve 1, sino devuelve 0 en r3
validar_victoria:
	.fnstart
	push {r0, r1, r2, lr}
	mov r3, #0
	ldr r0, =char_box
	ldrb r0, [r0]               @ r0 = '$'
	bl encontrar_char_en_mapa
	cmp r1, #-1
	beq victoria
	b fin_validar_victoria
	victoria:
	mov r3, #1
	fin_validar_victoria:
	pop {r0, r1, r2, lr}
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
	blne manejo_movimiento		@ si no es 'R' ni 'q' escribe en el mapa
	bl validar_victoria
	cmp r3, #1
	beq fin_bucle_juego_victoria
	seguir:
	b bucle_juego
fin_bucle_juego_victoria:
	bl mostrar_mapa
	ldr r1, =msg_victory
	mov r2, $len_msg_victory
	bl imprimir 
                         
fin_bucle_juego:
mov r7, #1

swi 0                           @ SWI, Software interrupt
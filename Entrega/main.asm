TITLE ESTADÍSTICAS						(main.asm)

; Descripción:
; Este software fue desarrollado para la clase de Arquitectura de Computadores 2014-I
; Esta diseñado para generar diferentes estadísticas a partir de datos contenidos en un archivo de texto

INCLUDE Irvine32.INC


.data

CuadrosAscii BYTE 220,0,219,0,223,0,219,0;176,0,177,0,178,0,219,0  ;219,0,219,0,178,0,177,0,176,0
;CuadrosAscii BYTE 220,0,219,0,223,0,219,0,220,0,219,0,223,0,220,0
contadorBarra DWORD 0 ; contador para animaciones
mensaje DWORD 14 DUP(0)	; array que tiene la dirección donde empieza cada una de las líneas del mensaje
numLineasMsjBv = 13
;líneas del mensaje de bienvenida 
;con espacios en blanco para que cada mensaje se vea centrado
mensajeBienvenida1 BYTE			       " ",0																					;1 caracter
mensajeBienvenida2 BYTE			       17 DUP(" "),"Bienvenido al programa de estudio estad",161d,"stico",0						;45 caracteres
mensajeBienvenida3 BYTE			       " ",0																					;1 caracter
mensajeBienvenida4 BYTE				   23 DUP(" "),"Arquitectura del Computador 2014-I",0										;34 caracteres 
mensajeBienvenida5 BYTE			       " ",0																					;1 caracter   
mensajeBienvenida6 BYTE				   22 DUP(" "),"Este software fue desarrollado por:",0										;35 caracteres
mensajeBienvenida7 BYTE				   17 DUP(" "),"Gustavo Le",162d,"n Preciado Jim",130d,"nez C.C. 1037635880",0				;45 caracteres
mensajeBienvenida8 BYTE				   16 DUP(" "),"Gustavo Andr",130d,"s Angarita Vel",160d,"squez C.C. 1037635327",0			;48 caracteres
mensajeBienvenida9 BYTE			       " ",0																					;1 caracter
mensajeBienvenida10 BYTE			   19 DUP(" "),"Este software est",160d," dise",164d,"ado para calcular",0					;41 caracteres
mensajeBienvenida11 BYTE			   20 DUP(" "),"distintas medidas estad",161d,"sticas a partir",0							;39 caracteres
mensajeBienvenida12 BYTE			   27 DUP(" "),"de los datos de un archivo",0												;26 caracteres
mensajeBienvenida13 BYTE			   10 DUP(" "), 60 DUP("-"),0; indica el final del mensaje.									;60 caracteres
mensajeBienvenida14 BYTE			   " ",0																					;1 caracter
contadorMensaje DWORD 0 ;servirá para desplazar el mensaje de bienvenida

auxCiclos	DWORD 5 DUP(0); array que servirá como variables auxiliares y de control durante los ciclos

tiempoEspera WORD 100,1000 ; tiempos de espera para las animaciones

;fondos y colores de texto
colores1 EQU lightBlue + (white * 16); Azul claro sobre blanco
colores2 EQU lightCyan + (lightBlue * 16)
colores3 EQU white + (lightBlue * 16)

contMensaje BYTE 0

.code

;-----------------------------------------------------------------------------------------------------------
main PROC
;-----------------------------------------------------------------------------------------------------------
mov eax, colores2
call SetTextColor
call Clrscr
call pintarBarrasIni
call cargarMensaje
inicio:
call mostrarMensaje
INC contMensaje
CMP contMensaje, 23
JL inicio
	exit
main ENDP

;-----------------------------------------------------------------------------------------------------------
cargarMensaje PROC
;Carga los mensajes en el array
;-----------------------------------------------------------------------------------------------------------
MOV mensaje,OFFSET mensajeBienvenida1 
MOV [mensaje+4],OFFSET mensajeBienvenida2
MOV [mensaje+8],OFFSET mensajeBienvenida3
MOV [mensaje+12],OFFSET mensajeBienvenida4
MOV [mensaje+16],OFFSET mensajeBienvenida5
MOV [mensaje+20],OFFSET mensajeBienvenida6
MOV [mensaje+24],OFFSET mensajeBienvenida7
MOV [mensaje+28],OFFSET mensajeBienvenida8
MOV [mensaje+32],OFFSET mensajeBienvenida9
MOV [mensaje+36],OFFSET mensajeBienvenida10
MOV [mensaje+40],OFFSET mensajeBienvenida11
MOV [mensaje+44],OFFSET mensajeBienvenida12
MOV [mensaje+48],OFFSET mensajeBienvenida13
MOV [mensaje+52],OFFSET mensajeBienvenida14

RET
cargarMensaje ENDP

;-----------------------------------------------------------------------------------------------------------
mostrarMensaje PROC
;Muestra el mensaje de bienvenida en 6 líneas entre dos barras animadas, las 6 líneas se van desplazando para 
;mostrar todo el mensaje de bienvenida
;-----------------------------------------------------------------------------------------------------------
; Muevo las direcciones al array


CALL Clrscr ; limpiar la pantalla

CALL animarBarra
CALL animarBarra

;CALL Crlf

mov eax, colores3
call SetTextColor

MOV ecx,6
MOV eax,contadorMensaje ; indica en qué línea debe empezar

MOV auxCiclos,eax
CICLO: ; en este ciclo se imprimen las líneas dentro de  las barras

	MOV eax,auxCiclos
	MOV edx,4
	MUL edx ; multiplica el numero de la línea por 4 para el desplazamiento en memoria

	MOV edx, [mensaje+eax]
	CALL WriteString ;imprime la línea del mensaje
	CALL Crlf

	CMP auxCiclos,numLineasMsjBv ; controla que el valor de auxCiclos siempre este entre 0 y el número de líneas del mensaje
	JL MENOR
	MOV auxCiclos,0
	JMP NoMENOR
	MENOR:
	INC auxCiclos
	NoMENOR:

LOOP CICLO

;CALL Crlf

cmp contadorMensaje,numLineasMsjBv ; controla que el valor de contadorMensaje siempre este entre 0 y el número de líneas del mensaje
JL MEN
MOV contadorMensaje,0
JMP NoMEN
MEN:
INC contadormensaje
NoMEN:

mov eax, colores2
call SetTextColor

CALL animarBarra
CALL animarBarra


	MOV ax, [tiempoEspera+2] 
	
	CALL delay
	
	CMP contadorBarra, 6
	JL menor6
		MOV contadorBarra, 0
		JMP finsi
	menor6:
		INC contadorBarra
		INC contadorBarra
	finsi:
	
RET
mostrarMensaje ENDP

;-----------------------------------------------------------------------------------------------------------
pintarBarrasIni PROC
;Pinta las barras superior e inferior en una animación que pinta de a 4 caracteres (código ascii 176) hasta llegar a 80
;-----------------------------------------------------------------------------------------------------------
CALL pintarBarra ; barra superior
CALL pintarBarra ; barra superior

;8 líneas en las que irá el mensaje de bienvenida
;Líneas en blanco durante la entrada de las barras
;CALL Crlf
CALL Crlf
CALL Crlf
CALL Crlf	
CALL Crlf
CALL Crlf
CALL Crlf
;CALL Crlf

CALL pintarBarra ; barra inferior
CALL pintarBarra ; barra inferior

RET
pintarBarrasIni ENDP

;-----------------------------------------------------------------------------------------------------------
pintarBarra PROC
;Procedimiento auxiliar para pintarBarrasIni este pinta cada una de las barras cada que es llamado
;-----------------------------------------------------------------------------------------------------------
MOV	ecx, 20 ; el ciclo se realizará 20 veces para llegar a 80 caracteres
	
CiloImprimir:
		
	MOV edx, OFFSET CuadrosAscii;
	CALL	WriteString
	MOV edx, OFFSET CuadrosAscii[2];
	CALL	WriteString
	MOV edx, OFFSET CuadrosAscii[4];
	CALL	WriteString
	MOV edx, OFFSET CuadrosAscii[6];
	CALL	WriteString

	MOV ax, tiempoEspera 
	CALL delay
	
	
LOOP CiloImprimir

RET
pintarBarra ENDP

;-----------------------------------------------------------------------------------------------------------
animarBarra PROC
;Procedimiento para que la barra de cuadros parpadee intercambiando el simbolo ascii 176 y 177
; cambia el caracter con el que se pinta la barra cada que es invocado
;-----------------------------------------------------------------------------------------------------------

MOV cx,80 ; hará un ciclo 40 veces pintando de a dos caracteres 176 o 177
L1:

	MOV edx, OFFSET CuadrosAscii
	ADD edx, contadorBarra
	CALL	WriteString
	CMP contadorBarra, 6
	JL menor6
		MOV contadorBarra, 0
		JMP finsi
	menor6:
		INC contadorBarra
		INC contadorBarra
	finsi:

LOOP L1 ;fin cilo para pintar la barra
		
RET
animarBarra ENDP

END main
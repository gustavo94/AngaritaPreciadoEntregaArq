TITLE ESTADÍSTICAS						(main.asm)

;-----------------------------------------------------------------------------------------------------------
; BACKUP
;-----------------------------------------------------------------------------------------------------------

; Descripción:
; Este software fue desarrollado para la clase de Arquitectura de Computadores 2014-I
; Esta diseñado para generar diferentes estadísticas a partir de datos contenidos en un archivo de texto

INCLUDE Irvine32.INC


.data

CuadrosAscii BYTE 176,0,177,0,178,0,219,0
interruptor BYTE 0 ; interuptor para animaciones
mensaje DWORD 9 DUP(0)	; array que tiene la dirección donde empieza cada una de las líneas del mensaje
mensajeBienvenida1 BYTE			       17 DUP(" "),"Bienvenido al programa de estudio estad",161d,"stico",0 ;líneas del mensaje de bienvenida 
mensajeBienvenida2 BYTE				   23 DUP(" "),"Arquitectura del Computador 2014-I",0		    ;con espacios en blanco para que cada mensaje se vea centrado
mensajeBienvenida3 BYTE				   22 DUP(" "),"Este software fue desarrollado por:",0
mensajeBienvenida4 BYTE				   18 DUP(" "),"Gustavo Le",162d,"n Preciado Jim",130d,"nez C.C 1037635880",0
mensajeBienvenida5 BYTE				   16 DUP(" "),"Gustavo Andr",130d,"s Angarita Vel",160d,"squez C.C 1037635327",0
mensajeBienvenida6 BYTE				   19 DUP(" "),"Este software est",160d," dise",164d,"ado para calcular",0
mensajeBienvenida7 BYTE				   20 DUP(" "),"distintas medidas estad",161d,"sticas a partir",0
mensajeBienvenida8 BYTE				   9 DUP(" "),"de los datos de un archivo y la selecci",162d,"n de la medida deseada",0
mensajeBienvenida9 BYTE				   10 DUP(" "), 60 DUP("-"),0; indica el final del mensaje.
contadorMensaje DWORD 0 ;servirá para desplazar el mensaje de bienvenida

auxCiclos	DWORD 5 DUP(0); array que servirá como variables auxiliares y de control durante los ciclos

tiempoEspera WORD 100,1000 ; tiempos de espera para las animaciones

;fondos y colores de texto
colores1 EQU lightBlue + (white * 16); Azul claro sobre blanco
colores2 EQU blue + (lightBlue * 16)



.code

;-----------------------------------------------------------------------------------------------------------
main PROC
;-----------------------------------------------------------------------------------------------------------
mov eax, colores1
call SetTextColor
call Clrscr
call pintarBarras
inicio:
call mostrarMensaje
JMP INICIO
	exit
main ENDP

;-----------------------------------------------------------------------------------------------------------
mostrarMensaje PROC
;Muestra el mensaje de bienvenida en 6 líneas entre dos barras animadas, las 6 líneas se van desplazando para 
;mostrar todo el mensaje de bienvenida
;-----------------------------------------------------------------------------------------------------------
; Muevo las direcciones al array
MOV mensaje,OFFSET mensajeBienvenida1 
MOV [mensaje+4],OFFSET mensajeBienvenida2
MOV [mensaje+8],OFFSET mensajeBienvenida3
MOV [mensaje+12],OFFSET mensajeBienvenida4
MOV [mensaje+16],OFFSET mensajeBienvenida5
MOV [mensaje+20],OFFSET mensajeBienvenida6
MOV [mensaje+24],OFFSET mensajeBienvenida7
MOV [mensaje+28],OFFSET mensajeBienvenida8
MOV [mensaje+32],OFFSET mensajeBienvenida9

CALL Clrscr ; limpiar la pantalla

CALL animarBarra

CALL Crlf

MOV ecx,6
MOV eax,contadorMensaje ; indica en que línea debe empezar

MOV auxCiclos,eax
CICLO: ; en este ciclo se imprimen las líneas dentro de  las barras

	MOV eax,auxCiclos
	MOV edx,4
	MUL edx ; multiplica el numero de la línea por 4 para el desplazamiento en memoria

	MOV edx, [mensaje+eax]
	CALL WriteString ;imprime la línea del mensaje
	CALL Crlf

	CMP auxCiclos,8 ; controla que el valor de auxCiclos siempre este entre 0 y 8
	JL MENOR8
	MOV auxCiclos,0
	JMP NoMENOR8
	MENOR8:
	INC auxCiclos
	NoMENOR8:

LOOP CICLO

CALL Crlf

cmp contadorMensaje,8 ; controla que el valor de contadorMensaje siempre este entre 0 y 8
JL MEN8
MOV contadorMensaje,0
JMP NoMEN8
MEN8:
INC contadormensaje
NoMEN8:

CALL animarBarra


	MOV ax, [tiempoEspera+2] 
	
	CALL delay
	
	
RET
mostrarMensaje ENDP

;-----------------------------------------------------------------------------------------------------------
pintarBarras PROC
;Pinta las barras superior e inferior en una animación que pinta de a 4 caracteres (código ascii 176) hasta llegar a 80
;-----------------------------------------------------------------------------------------------------------
CALL pintarBarra ; barra superior

;8 líneas en las que irá el mensaje de bienvenida
;Líneas en blanco durante la entrada de las barras
CALL Crlf
CALL Crlf
CALL Crlf
CALL Crlf	
CALL Crlf
CALL Crlf
CALL Crlf
CALL Crlf

CALL pintarBarra ; barra inferior

RET
pintarBarras ENDP

;-----------------------------------------------------------------------------------------------------------
pintarBarra PROC
;Procedimiento auxiliar para pintarBarras este pinta cada una de las barras cada que es llamado
;-----------------------------------------------------------------------------------------------------------
MOV	ecx, 20 ; el ciclo se realizará 20 veces para llegar a 80 caracteres
	
CiloImprimir:
		
	MOV edx, OFFSET CuadrosAscii; caracter 176
		
	CALL	WriteString
	CALL	WriteString
	CALL	WriteString
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


MOV cx,10 ; hará un ciclo 40 veces pintando de a dos caracteres 176 o 177
L1:
	CMP interruptor,2 ;escoge qué caracter usar para pintar la barra
	MOV edx, OFFSET CuadrosAscii
	JG FINSI
		ADD edx,2
	FINSI:
		CALL	WriteString
		CALL	WriteString
		CALL	WriteString
		CALL	WriteString
		CALL	WriteString
		CALL	WriteString
		CALL	WriteString
		CALL	WriteString

LOOP L1 ;fin cilo para pintar la barra

CMP interruptor,2 ; Cambia el estado de la variable de seleccion del caracter
JL SINO2
	CMP interruptor,3
	JLE SINO2
		MOV interruptor,0
	
JMP FINSI2
SINO2:
		INC interruptor
FINSI2:
		
		
RET
animarBarra ENDP

END main
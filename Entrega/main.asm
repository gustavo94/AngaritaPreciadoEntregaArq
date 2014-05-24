TITLE REGRESION LINEAL Template						(main.asm)

; Descripcion:
; Este software fue desarrollado para la clase de arquitectura del computador 2013-II
; Esta diseñado para realizar una regresion lineal multiple apartir de los puntos ingresados por el usuario
; Revision date:

INCLUDE Irvine32.INC
.data
CuadrosAscii BYTE 176,0,177,0
swich BYTE 0 ; interuptor para animaciones
mensaje DWORD 9 DUP(0); array que tiene la direccion donde empieza cada una de las lineas del mensaje
mensajeBienvenida1 BYTE			        17 DUP(" "),"Bienvenido Al Programa De Estudio Estadistico",0 ;lineas del mensaje de bienvenida 
mensajeBienvenida2 BYTE				   23 DUP(" "),"Arquitectura Del Computador 2012-I",0		    ;con espacios en blanco para que cada mensaje se vea centrado
mensajeBienvenida3 BYTE				   22 DUP(" "),"Este Software Fue Desarrollado Por:",0
mensajeBienvenida4 BYTE				   18 DUP(" "),"Gustavo Le",162d,"n Preciado Jiménez C.C 1037635880",0
mensajeBienvenida5 BYTE				   16 DUP(" "),"Gustavo Andr",130d,"s Angarita Velasquez C.C 1037635327",0
mensajeBienvenida6 BYTE				   19 DUP(" "),"Este software esta dise",164d,"ado para calcular",0
mensajeBienvenida7 BYTE				   20 DUP(" "),"distintas medidas estadisticas apartir",0
mensajeBienvenida8 BYTE				   8 DUP(" "),"de los datos de un archivo y la seleccion de la medida deseada",0
mensajeBienvenida9 BYTE				   80 DUP("-"),0; indica el final del mensaje.
contadorMensaje DWORD 0 ;servira para desplazar el mensaje de bienvenida

auxCiclos	DWORD 5 DUP(0); array que servira como variables auxiliares y de control para durante los ciclos


tiempoEspera DWORD 29999999,50 ; tiempos de espera para las animaciones
.code
main PROC
mov eax,lightBlue + (white * 16) ; Azul claro sobre blanco
call SetTextColor
	CALL Clrscr
	CALL pintarBarras
INICIO:
CALL mostrarMensaje
JMP INICIO
	exit
main ENDP

;-----------------------------------------------------------------------------------------------------------
mostrarMensaje PROC
;Mustra en mensaje de bienvenida en 6 lineas entre dos barras animadas, las 6 lineas se van desplazando para 
;mostrar todo el mensaje de bienvenida
;-----------------------------------------------------------------------------------------------------------
MOV mensaje,OFFSET mensajeBienvenida1 ; Muevo las direcciones al array
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
MOV eax,contadorMensaje ; indica en que linea debe empezar

MOV auxCiclos,eax
CICLO: ; en este ciclo se imprimen las lineas dentro de  las barras

	MOV eax,auxCiclos
	MOV edx,4
	MUL edx ; multiplica el numero de la linea por 4 para el desplazamiento en memoria

	MOV edx, [mensaje+eax]
	CALL WriteString ;imprime la linea del mensaje
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


	MOV ecx, [tiempoEspera+1] 
	
	Espera:  ; ciclo de espera para la animacion
	LOOP Espera
	
	
RET
mostrarMensaje ENDP

;-----------------------------------------------------------------------------------------------------------
pintarBarras PROC
;Pinta las barras superior e inferior en una animacion que pinta de a 4 caracteres (codigo ascii 176) hasta llegar a 80
;-----------------------------------------------------------------------------------------------------------
CALL pintarBarra ; barra superior

;8 lineas en las que ira el mensaje de bienvenida
CALL Crlf
CALL Crlf
CALL Crlf
CALL Crlf	;Lineas en blanco durante la entrada de las barras
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
MOV	ecx, 20 ; el ciclo se realizara 20 veces para llegar a 80 caracteres
	
CiloImprimir:
		
	MOV edx, OFFSET CuadrosAscii; caracter 176
		
	CALL	WriteString
	CALL	WriteString
	CALL	WriteString
	CALL	WriteString

	MOV auxCiclos, ecx 
	MOV ecx, tiempoEspera 
	
	Espera:  ; ciclo de espera para la animacion
	LOOP Espera
	
	MOV ecx,auxCiclos
	
LOOP CiloImprimir

RET
pintarBarra ENDP

;-----------------------------------------------------------------------------------------------------------
animarBarra PROC
;Procedimiento para que la barra de cuadros parpadee intercambiando el simbolo ascii 176 y 177
; cambia el caracter con el que se pinta la barra cada que es invocado
;-----------------------------------------------------------------------------------------------------------


MOV cx,40 ; hara un ciclo 40 veces pintando de a dos caracteres 176 o 177
L1:
	CMP swich,2 ;escoge que caracter usar para pintar la barra
	JL SINO
		MOV edx, OFFSET CuadrosAscii
	JMP FINSI
	SINO:
		MOV edx, OFFSET CuadrosAscii
		ADD edx,2
	FINSI:
		CALL	WriteString
		CALL	WriteString

LOOP L1 ;fin cilo para pintar la barra

CMP swich,2 ; Cambia el estado de la variable de seleccion del caracter
JL SINO2
	CMP swich,3
	JLE SINO2
		MOV swich,0
	
JMP FINSI2
SINO2:
		INC swich
FINSI2:
		
		
RET
animarBarra ENDP

END main
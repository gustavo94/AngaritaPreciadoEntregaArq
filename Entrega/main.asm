TITLE ESTADÍSTICAS						(main.asm)

; Descripción:
; Este software fue desarrollado para la clase de Arquitectura de Computadores 2014-I
; Esta diseñado para generar diferentes estadísticas a partir de datos contenidos en un archivo de texto

INCLUDE Irvine32.inc
INCLUDE Macros.inc

PTRREAL8 TYPEDEF PTR REAL8 ;tipo de datos para punteros a real8

.DATA

;código de la tilde: a=160, e=130, i=161, o=162, u=163

;decoración del mensaje de bienvenida
CuadrosAscii BYTE 219,0,178,0,177,0," ",0;176,0,177,0,178,0,219,0
;CuadrosAscii BYTE 220,0,219,0,223,0,219,0;176,0,177,0,178,0,219,0  ;219,0,219,0,178,0,177,0,176,0
;CuadrosAscii BYTE 220,0,219,0,223,0,219,0,220,0,219,0,223,0,220,0
contadorBarra DWORD 0 ; contador para animaciones

;líneas del mensaje de bienvenida 
;con espacios en blanco para que cada mensaje se vea centrado
mensaje DWORD 14 DUP(0)	; array que tiene la dirección donde empieza cada una de las líneas del mensaje
numLineasMsjBv = 13
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

;líneas del mensaje de despedida 
;con espacios en blanco para que cada mensaje se vea centrado
mensajeD DWORD 14 DUP(0)	; array que tiene la dirección donde empieza cada una de las líneas del mensaje
numLineasMsjDp = 4
mensajeDespedida1 BYTE			       " ",0																					;1 caracter
mensajeDespedida2 BYTE			       23 DUP(" "),"Gracias por usar nuestro software.",0										;34 caracteres
mensajeDespedida3 BYTE			       " ",0																					;1 caracter
mensajeDespedida4 BYTE				   22 DUP(" "),"Esperamos que haya sido de utilidad.",0										;36 caracteres 
mensajeDespedida5 BYTE			       " ",0																					;1 caracter																				;1 caracter

contadorMensaje DWORD 0 ;servirá para desplazar el mensaje de bienvenida/despedida
contMensaje BYTE 0

;cuenta cuántas veces ha sido ejecutado el programa
contEjecuciones DWORD 0

auxCiclos	DWORD 5 DUP(0); array que servirá como variables auxiliares y de control durante los ciclos

tiempoEspera WORD 10,10 ; tiempos de espera para las animaciones

;fondos y colores de texto
colores1 EQU lightBlue + (white * 16); Azul claro sobre blanco
colores2 EQU lightCyan + (lightBlue * 16)
colores3 EQU white + (lightBlue * 16)


stringEstadisticos BYTE "1. Media aritm",130,"tica",0dh,0ah
				   BYTE	"2. Mediana",0dh,0ah
				   BYTE	"3. Moda",0dh,0ah
				   BYTE "4. Media geom",130,"trica",0dh,0ah
				   BYTE	"5. Media arm",162,"nica",0dh,0ah
				   BYTE	"6. Percentiles",0dh,0ah
				   BYTE	"7. Cuartiles",0dh,0ah
				   BYTE	"8. Deciles",0dh,0ah
				   BYTE	"9. Momentos respecto al origen",0dh,0ah
				   BYTE	"10. Momentos centrales o respecto a la media",0dh,0ah
				   BYTE	"11. Varianza",0dh,0ah
				   BYTE	"12. Desviaci",162,"n t",161,"pica",0dh,0ah
				   BYTE	"13. Cuasi-varianza",0dh,0ah
				   BYTE	"14. Desviaci",162,"n media respecto a la media",0dh,0ah
				   BYTE	"15. Desviaci",162,"n media respecto a la mediana",0dh,0ah,0

;direccion del archivo
urlDatos BYTE 260 DUP(0)
fileHandle  HANDLE ?

;arreglos con los datos, los datos sin repetir y las frecuencias de los datos sin repetir
maxDatos = 600
numeros REAL8 maxDatos DUP(-1.), -1.
numerosDistintos REAL8 maxDatos DUP(-1.), -1.
frecuencias QWORD maxDatos DUP(-1.), -1.
cantDatos DWORD 0
cantDatosDistintos DWORD 0
frecuenciaMax DWORD 0 ;para la moda

;auxiliar para leer los datos
tamanoBufer = 5000
buferArchivo BYTE tamanoBufer DUP(?), 0
datoActual BYTE ?
relleno DWORD 0 ;se debe poner para que el valor de realactual no interfiera en la lectura
realActual REAL8 ?
coma DWORD 0
contCicloDecimales DWORD 0
realesLeidos DWORD 0
saltoDeLinea DWORD 0
finArchivo DWORD 0

;auxiliares para las sumatorias
auxSumatoria REAL8 0.
diez REAL8 10.
unDecimo REAL8 0.1

;estadisticos
media REAL8 ?
mediana REAL8 ?
;moda REAL8 maxDatos DUP(-1.), -1.
mediageometrica REAL8 ?
mediaarmonica REAL8 ?
percentiles REAL8 101 DUP(-1.)
cuartiles REAL8 5 DUP(-1.)
deciles REAL8 11 DUP(-1.)
momentosOrigen REAL8 ?
momentosCentrales REAL8 ?
varianza REAL8 ?
desvEstandar REAL8 ?
cuasiVarianza REAL8 ?
desvMedia REAL8 ?
desvMediana REAL8 ?

;orden de los momentos
ordenMomOrig DWORD ?
ordenMomCent DWORD ?

;contiene booleanos que indican si el usuario solicitó el estadístico n
buferUsuario BYTE 40 DUP(0)
boolEstadisticos DWORD 15 DUP(0)

;apunta a los diferentes estadisticos
ptrEstaadisticos PTRREAL8 15 DUP(?)






.CODE

;-----------------------------------------------------------------------------------------------------------
main PROC
;-----------------------------------------------------------------------------------------------------------
FINIT

;prepara la consola
MOV eax, colores2
CALL SetTextColor
CALL Clrscr

;mensaje de bienvenida
CALL pintarBarrasIni
CALL cargarMensaje
inicio:
CALL mostrarMensaje
INC contMensaje
CMP contMensaje, 23
JL inicio
CALL waitMsg
CALL Clrscr

;hace todos los cálculos
CALL calcularEstadisticos

ejec:
MOV eax, colores3
CALL SetTextColor
CALL Clrscr
CALL contadorEjec
CALL crlf
mWrite <"Por favor indique el orden que se usar",160," para calcular el momento ",0dh,0ah,"con respecto al origen:",0dh,0ah>
CALL readInt
MOV ordenMomOrig, eax
mWrite <"Por favor indique el orden que se usar",160," para calcular el momento ",0dh,0ah,"con respecto a la media",0dh,0ah>
CALL readInt
MOV ordenMomCent, eax

CALL pedirEstadisticos
CALL mostrarEstadisticosSelec

CALL Crlf
mWrite "Desea ejecutar nuevamente el programa? 1=si, 0=no"
CALL Crlf
CALL readInt
CMP eax, 0 
JNE ejec

CALL mostrarDespedida

CALL waitMsg
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

MOV mensajeD,OFFSET mensajeDespedida1
MOV [mensajeD+4],OFFSET mensajeDespedida2
MOV [mensajeD+8],OFFSET mensajeDespedida3
MOV [mensajeD+12],OFFSET mensajeDespedida4
MOV [mensajeD+16],OFFSET mensajeDespedida5

RET
cargarMensaje ENDP

;-----------------------------------------------------------------------------------------------------------
mostrarMensaje PROC
;Muestra el mensaje de bienvenida en 6 líneas entre dos barras animadas, las 6 líneas se van desplazando para 
;mostrar todo el mensaje de bienvenida
;-----------------------------------------------------------------------------------------------------------

CALL Clrscr ; limpiar la pantalla

CALL animarBarra
CALL animarBarra

;CALL Crlf

MOV eax, colores3
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
MOV eax, colores2
CALL SetTextColor

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
; Procedimiento para que la barra de cuadros parpadee intercambiando el simbolo ascii 176 y 177
; cambia el caracter con el que se pinta la barra cada que es invocado
;-----------------------------------------------------------------------------------------------------------
MOV eax, colores2
CALL SetTextColor

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

DEC cx
JNZ L1 ;fin cilo para pintar la barra
		
RET
animarBarra ENDP


;-----------------------------------------------------------------------------------------------------------
contadorEjec PROC
;Muestra el número de veces que se ha ejecutado el programa
;Solo se muestra después de la primera ejecución
;-----------------------------------------------------------------------------------------------------------

CMP contEjecuciones, 0
JE ceroEjec

;muestra el número de veces que se ha ejecutado el programa
mWrite "El programa se ha ejecutado "
MOV eax, contEjecuciones
CALL writeDec
CMP contEjecuciones, 1
JNE noUno
mWrite " vez"
JMP todos
noUno:
mWrite " veces"
todos:
CALL Crlf

ceroEjec:

INC contEjecuciones

RET
contadorEjec ENDP


;-----------------------------------------------------------------------------------------------------------
mostrarDespedida PROC
;Muestra el mensaje de despedida
;-----------------------------------------------------------------------------------------------------------
CALL Clrscr ; limpiar la pantalla

call pintarBarrasIni
MOV contadorBarra, 0

CALL Clrscr

CALL animarBarra
CALL animarBarra

;CALL Crlf

mov eax, colores3
call SetTextColor

MOV ecx, numLineasMsjDp
INC ecx

MOV auxCiclos, 0

CICLOFIN: ; en este ciclo se imprimen las líneas dentro de  las barras

	MOV eax, auxCiclos

	MOV edx,4
	MUL edx ; multiplica el numero de la línea por 4 para el desplazamiento en memoria

	MOV edx, [mensajeD+eax]
	CALL WriteString ;imprime la línea del mensaje
	CALL Crlf
	
	INC auxCiclos

LOOP CICLOFIN

CALL Crlf

CALL animarBarra
CALL animarBarra

RET
mostrarDespedida ENDP


;-----------------------------------------------------------------------------------------------------------
calcularEstadisticos PROC
;Carga el archivo y calcula los estadísticos
;-----------------------------------------------------------------------------------------------------------
mov eax, colores3
call SetTextColor

;pide la ubicación del archivo y lo abre
mWrite "Por favor ingrese la ruta del archivo que contiene los datos: "
CALL crlf

preguntaRuta:
MOV edx, OFFSET urlDatos
MOV ecx, SIZEOF urlDatos
CALL readString

MOV	edx,OFFSET urlDatos
CALL OpenInputFile
MOV	fileHandle, eax

;revisa que se haya abierto correctamente el archivo
CMP	eax, INVALID_HANDLE_VALUE
JNE	file_ok
mWrite <"No se pudo abrir el archivo. Por favor ingrese una direcci",162,"n v",160,"lida",0dh,0ah>
JMP	preguntaRuta
file_ok:

;lee el archivo o sale si hay un error leyendo
MOV	edx, OFFSET buferArchivo
MOV	ecx, tamanoBufer
CALL ReadFromFile
JNC	check_buffer_size
mWrite <"Error leyendo el archivo. Por favor ingrese una direcci",162,"n v",160,"lida",0dh,0ah>
CALL	WriteWindowsMsg
JMP	preguntaRuta
	
check_buffer_size:
CMP	eax, tamanoBufer
JB	buf_size_ok
mWrite <"El archivo es demasiado extenso. Ingrese la direcci",162,"n de un archivo m",160,"s corto",0dh,0ah>
JMP	preguntaRuta
	
buf_size_ok:	
MOV	buferArchivo[eax],0 ;terminación nula para el archivo. eax contiene la cantidad de caracteres leídos

;cierra el handle
MOV	eax,fileHandle
CALL CloseFile

;se leen los números y se meten en el arreglo
MOV esi, 0
leerNum:

	;reinicializa los valores de los auxiliares
	MOV saltoDeLinea, 0
	MOV coma, 0
	MOV contCicloDecimales, 0

	;carga el cero
	FLDZ
	FSTP realActual

	;ciclo de lectura de caracteres
	MOV ecx, 80
	
	leerChar:

		MOV eax, 0
		MOV al, buferArchivo[esi]
		INC esi

		;si el archivo terminó, sale del ciclo
		CMP al, 0
		JNE noFinArchivo
		MOV finArchivo, 1
		JMP finNumero
		noFinArchivo:

		;si hay cr o lf, aumenta saltoDeLinea y pasa al siguiente caracter
		CMP al, 13
		JNE noCr
		INC saltoDeLinea
		;si ya se leyeron los dos, se pasa al siguiente número
		CMP saltoDeLinea, 2
		JE finNumero
		JMP finChar
		noCr:
		CMP al, 10
		JNE noLf
		INC saltoDeLinea
		;si ya se leyeron los dos, se pasa al siguiente número
		CMP saltoDeLinea, 2
		JE finNumero
		JMP finChar
		noLf:
		
	
		;si hay una coma o un punto, activa el booleano para empezar a poner los decimales
		CMP al, 44
		JNE noEsComa
		MOV coma, 1
		JMP finChar
		noEsComa:
		CMP al, 46
		JNE noEsPunto
		MOV coma, 1
		JMP finChar
		noEsPunto:

		;convierte el caracter en el número que representa
		SUB eax, 48

		;guarda el valor en el auxiliar
		MOV datoActual, al
		FILD DWORD PTR datoActual

		;si coma es 0 (falso), multiplica por 10
		CMP coma, 0
		JNE decimales
		FLD realActual
		FMUL diez
		FADD
		FSTP realActual
		JMP finChar

		;si coma es 1 (verdadero), divide por 10
		decimales:
		INC contCicloDecimales
		MOV ebx, contCicloDecimales
		;ciclo de división por 10 para llegar al valor correcto
		cicloDiv:
			FDIV diez
		DEC ebx
		CMP ebx, 0
		JNE cicloDiv
		FLD realActual
		FADD
		FSTP realActual
		
		finChar:
	DEC ecx
	CMP ecx, 0
	JNE leerChar
	finNumero:
	
	;;;;;;;;;;;;;;para comprobar que lee bien
	;mwrite "final"
	;FLD realActual
	;CALL writeFloat
	;fstp realactual
	;CALL crlf
	;;;;;;;;;;;;;;;;

	;guarda el número en el array
	FLD realActual
	MOV eax, realesLeidos
	FSTP numeros[eax]
	INC realesLeidos

	;si llegó al final del archivo, sale
	CMP finArchivo, 1
	JE finLectura

	;si no ha llegado al número máximo de reales que puede almacenar, sigue leyendo
	CMP realesLeidos, maxDatos
	JL leerNum
finLectura:

CALL ordenar


CALL calcMedia
CALL calcMediana
;CALL calcModa
CALL calcMediageometrica
CALL calcMediaarmonica
CALL calcPercentiles
CALL calcCuartiles
CALL calcDeciles
CALL calcMomentosOrigen
CALL calcMomentosCentrales
CALL calcVarianza
CALL calcDesvEstandar
CALL calcCuasiVarianza
CALL calcDesvMedia
CALL calcDesvMediana


RET
calcularEstadisticos ENDP

;-----------------------------------------------------------------------------------------------------------
pedirEstadisticos PROC
;Pide al usuario ingresar los estadísticos que desea
;-----------------------------------------------------------------------------------------------------------

CALL clrscr
mWrite <"Seleccione los estad",161,"sticos que desea calcular.",0dh,0ah>
MOV edx, OFFSET stringEstadisticos
CALL writeString

seleccionEstad:
CALL crlf
mWrite <"Escriba una lista separada por comas y presione enter. Ejemplo: 1,2,3.",0dh,0ah>

MOV edx, OFFSET buferUsuario
MOV ecx, LENGTHOF buferUsuario
DEC ecx ;se deja el último caracter en 0 siempre
CALL readString

MOV ecx, eax
INC ecx

;interpreta la cadena ingresada (en ecx está el tamaño de la cadena + 1)
MOV esi, 0
MOV eax, 0
cicloUsuario:
	;si el caracter leido es una coma o se llegó al final del búfer, 
	;mueve 1 a la posición correspondiente del array de booleanos
	CMP buferUsuario[esi], 44
	JNE noComaUsu
		comaUsu:
		DEC eax
		MOV edx, 4
		MUL edx
		NOT boolEstadisticos[eax]
		MOV eax, 0
		JMP continueUsu
	noComaUsu:
	CMP buferUsuario[esi], 0
	JE comaUsu

	;el número puede tener dos cifras. multiplica la primera por 10 y suma la siguiente
	MOV ebx, 0
	MOV bl, buferUsuario[esi]
	SUB ebx, 48
	MOV edx, 10
	MUL edx
	ADD eax, ebx

	continueUsu:
	INC esi
LOOP cicloUsuario

CALL crlf
mWrite <"Por favor confirme su selecci",162,"n. 1=si, 0=cambiar",0dh,0ah>
CALL readInt
CMP eax, 0
JNE finSeleccion
mWrite <"Indique los estad",161,"sticos que desea agregar o escriba nuevamente ",0dh,0ah,"los que desea quitar de la lista",0dh,0ah>
JMP seleccionEstad

finSeleccion:

RET
pedirEstadisticos ENDP

;-----------------------------------------------------------------------------------------------------------
mostrarEstadisticosSelec PROC
;Muestra los estadísticos seleccionados por el usuario
;-----------------------------------------------------------------------------------------------------------

;si el estadístico n fue marcado (está en 1), lo imprime. De lo contrario, pasa al siguiente
CMP boolEstadisticos, -1
JNE pasa2
	mwrite "1-"
pasa2:
CMP boolEstadisticos[4], -1
JNE pasa3
	mwrite "2-"
pasa3:
CMP boolEstadisticos[8], -1
JNE pasa4
	mwrite "3-"
pasa4:
CMP boolEstadisticos[12], -1
JNE pasa5
	mwrite "4-"
pasa5:
CMP boolEstadisticos[16], -1
JNE pasa6
	mwrite "5-"
pasa6:
CMP boolEstadisticos[20], -1
JNE pasa7
	mwrite "6-"
pasa7:
CMP boolEstadisticos[24], -1
JNE pasa8
	mwrite "7-"
pasa8:
CMP boolEstadisticos[28], -1
JNE pasa9
	mwrite "8-"
pasa9:
CMP boolEstadisticos[32], -1
JNE pasa10
	mwrite "9-"
pasa10:
CMP boolEstadisticos[36], -1
JNE pasa11
	mwrite "10-"
pasa11:
CMP boolEstadisticos[40], -1
JNE pasa12
	mwrite "11-"
pasa12:
CMP boolEstadisticos[44], -1
JNE pasa13
	mwrite "12-"
pasa13:
CMP boolEstadisticos[48], -1
JNE pasa14
	mwrite "13-"
pasa14:
CMP boolEstadisticos[52], -1
JNE pasa15
	mwrite "14-"
pasa15:
CMP boolEstadisticos[56], -1
JNE pasaFin
	mwrite "15"
pasaFin:

;reinicializa el vector de booleanos
MOV ecx, 15
MOV esi, 0
ponerCeroSiguiente:
	MOV boolEstadisticos[esi], 0
	ADD esi, 4
LOOP ponerCeroSiguiente
RET
mostrarEstadisticosSelec ENDP

;-----------------------------------------------------------------------------------------------------------
imprimirDato PROC
;Muestra un único dato
;-----------------------------------------------------------------------------------------------------------

RET
imprimirDato ENDP

;-----------------------------------------------------------------------------------------------------------
imprimirArreglo PROC
;Muestra un arreglo de datos
;-----------------------------------------------------------------------------------------------------------

RET
imprimirArreglo ENDP

;-----------------------------------------------------------------------------------------------------------
ordenar PROC
;Ordena el vector y calcula las frecuencias
;-----------------------------------------------------------------------------------------------------------

RET
ordenar ENDP

;-----------------------------------------------------------------------------------------------------------
calcMedia PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcMedia ENDP

;-----------------------------------------------------------------------------------------------------------
calcMediana PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcMediana ENDP

;-----------------------------------------------------------------------------------------------------------
calcMediageometrica PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcMediageometrica ENDP

;-----------------------------------------------------------------------------------------------------------
calcMediaarmonica PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcMediaarmonica ENDP

;-----------------------------------------------------------------------------------------------------------
calcPercentiles PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcPercentiles ENDP

;-----------------------------------------------------------------------------------------------------------
calcCuartiles PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcCuartiles ENDP

;-----------------------------------------------------------------------------------------------------------
calcDeciles PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcDeciles ENDP

;-----------------------------------------------------------------------------------------------------------
calcMomentosOrigen PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcMomentosOrigen ENDP

;-----------------------------------------------------------------------------------------------------------
calcMomentosCentrales PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcMomentosCentrales ENDP

;-----------------------------------------------------------------------------------------------------------
calcVarianza PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcVarianza ENDP

;-----------------------------------------------------------------------------------------------------------
calcDesvEstandar PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcDesvEstandar ENDP

;-----------------------------------------------------------------------------------------------------------
calcCuasiVarianza PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcCuasiVarianza ENDP

;-----------------------------------------------------------------------------------------------------------
calcDesvMedia PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcDesvMedia ENDP

;-----------------------------------------------------------------------------------------------------------
calcDesvMediana PROC
;Calcula el estadístico
;-----------------------------------------------------------------------------------------------------------

RET
calcDesvMediana ENDP

;fin del programa
END main
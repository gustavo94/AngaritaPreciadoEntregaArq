TITLE ESTAD�STICAS						(main.asm)

; Descripci�n:
; Este software fue desarrollado para la clase de Arquitectura de Computadores 2014-I
; Esta dise�ado para generar diferentes estad�sticas a partir de datos contenidos en un archivo de texto

INCLUDE Irvine32.inc
INCLUDE Macros.inc


.DATA

;c�digo de la tilde: a=160, e=130, i=161, o=162, u=163

;decoraci�n del mensaje de bienvenida
CuadrosAscii BYTE 219,0,178,0,177,0," ",0;176,0,177,0,178,0,219,0
;CuadrosAscii BYTE 220,0,219,0,223,0,219,0;176,0,177,0,178,0,219,0  ;219,0,219,0,178,0,177,0,176,0
;CuadrosAscii BYTE 220,0,219,0,223,0,219,0,220,0,219,0,223,0,220,0
contadorBarra DWORD 0 ; contador para animaciones

;l�neas del mensaje de bienvenida 
;con espacios en blanco para que cada mensaje se vea centrado
mensaje DWORD 14 DUP(0)	; array que tiene la direcci�n donde empieza cada una de las l�neas del mensaje
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

;l�neas del mensaje de despedida 
;con espacios en blanco para que cada mensaje se vea centrado
mensajeD DWORD 14 DUP(0)	; array que tiene la direcci�n donde empieza cada una de las l�neas del mensaje
numLineasMsjDp = 4
mensajeDespedida1 BYTE			       " ",0																					;1 caracter
mensajeDespedida2 BYTE			       23 DUP(" "),"Gracias por usar nuestro software.",0										;34 caracteres
mensajeDespedida3 BYTE			       " ",0																					;1 caracter
mensajeDespedida4 BYTE				   22 DUP(" "),"Esperamos que haya sido de utilidad.",0										;36 caracteres 
mensajeDespedida5 BYTE			       " ",0																					;1 caracter																				;1 caracter

contadorMensaje DWORD 0 ;servir� para desplazar el mensaje de bienvenida/despedida
contMensaje BYTE 0

;cuenta cu�ntas veces ha sido ejecutado el programa
contEjecuciones DWORD 0

auxCiclos	DWORD 5 DUP(0); array que servir� como variables auxiliares y de control durante los ciclos

tiempoEspera WORD 10,10 ; tiempos de espera para las animaciones

;fondos y colores de texto
colores1 EQU lightBlue + (white * 16); Azul claro sobre blanco
colores2 EQU lightCyan + (lightBlue * 16)
colores3 EQU white + (lightBlue * 16)

stringEstadisticos     BYTE "1. Media aritm",130,"tica",0dh,0ah
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
frecuencias DWORD maxDatos DUP(0), 0
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
numDos REAL8 2.
unDecimo REAL8 0.1
menosUno REAL8 -1.

;Auxiliares para ordenar
posActual DWORD 0
indiceCicloOrdenar DWORD 0
indiceCicloComparar DWORD 0
menorValor REAL8 0.
epsilon REAL8 1.0E-12
posMenor DWORD 0

;Auxiliares para imprimir
ceroReal REAL8 0.
numeroReal REAL8 0.

;estadisticos
media REAL8 0.
mediana REAL8 0.
moda REAL8 maxDatos DUP(-1.), -1.
mediageometrica REAL8 0.
mediaarmonica REAL8 0.
percentiles REAL8 101 DUP(-1.)
cuartiles REAL8 5 DUP(-1.)
deciles REAL8 11 DUP(-1.)
momentosOrigen REAL8 0.
momentosCentrales REAL8 0.
varianza REAL8 0.
desvEstandar REAL8 0.
cuasiVarianza REAL8 0.
desvMedia REAL8 0.
desvMediana REAL8 0.

;auxiliares para los estad�sticos
ordenMomOrig DWORD ?
ordenMomCent DWORD ?
posModa DWORD 0

;contiene booleanos que indican si el usuario solicit� el estad�stico n
buferUsuario BYTE 80 DUP(0)
boolEstadisticos DWORD 15 DUP(0)


;para evitar problemas
relleno2 DWORD 100 DUP(0)



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

;hace todos los c�lculos excepto los momentos
CALL leerArchivo
CALL calcularEstadisticos

ejec:
	MOV eax, colores3
	CALL SetTextColor
	CALL Clrscr
	CALL contadorEjec
	mWrite <"Para cada ejecuci",162,"n usted puede utilizar un orden diferente para los momentos",0dh,0ah,"Por favor ingr",130,"selos a continuaci",162,"n",0dh,0ah>
	CALL crlf
	mWrite <"Por favor indique el orden que se usar",160," para calcular el momento ",0dh,0ah,"con respecto al origen:",0dh,0ah>
	CALL readInt
	MOV ordenMomOrig, eax
	mWrite <"Por favor indique el orden que se usar",160," para calcular el momento ",0dh,0ah,"con respecto a la media",0dh,0ah>
	CALL readInt
	MOV ordenMomCent, eax
	CALL calcularMomentos
	CALL pedirEstadisticos
	CALL imprimirEstadisticosSelec

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
;Muestra el mensaje de bienvenida en 6 l�neas entre dos barras animadas, las 6 l�neas se van desplazando para 
;mostrar todo el mensaje de bienvenida
;-----------------------------------------------------------------------------------------------------------

CALL Clrscr ; limpiar la pantalla

CALL animarBarra
CALL animarBarra

;CALL Crlf

MOV eax, colores3
call SetTextColor

MOV ecx,6
MOV eax,contadorMensaje ; indica en qu� l�nea debe empezar

MOV auxCiclos,eax
CICLO: ; en este ciclo se imprimen las l�neas dentro de  las barras

	MOV eax,auxCiclos
	MOV edx,4
	MUL edx ; multiplica el numero de la l�nea por 4 para el desplazamiento en memoria

	MOV edx, [mensaje+eax]
	CALL WriteString ;imprime la l�nea del mensaje
	CALL Crlf

	CMP auxCiclos,numLineasMsjBv ; controla que el valor de auxCiclos siempre este entre 0 y el n�mero de l�neas del mensaje
	JL MENOR
	MOV auxCiclos,0
	JMP NoMENOR
	MENOR:
	INC auxCiclos
	NoMENOR:

LOOP CICLO

;CALL Crlf

cmp contadorMensaje,numLineasMsjBv ; controla que el valor de contadorMensaje siempre este entre 0 y el n�mero de l�neas del mensaje
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
;Pinta las barras superior e inferior en una animaci�n que pinta de a 4 caracteres (c�digo ascii 176) hasta llegar a 80
;-----------------------------------------------------------------------------------------------------------
CALL pintarBarra ; barra superior
CALL pintarBarra ; barra superior

;8 l�neas en las que ir� el mensaje de bienvenida
;L�neas en blanco durante la entrada de las barras
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

MOV	ecx, 20 ; el ciclo se realizar� 20 veces para llegar a 80 caracteres
	
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

MOV cx,80 ; har� un ciclo 40 veces pintando de a dos caracteres 176 o 177
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
;Muestra el n�mero de veces que se ha ejecutado el programa
;Solo se muestra despu�s de la primera ejecuci�n
;-----------------------------------------------------------------------------------------------------------

CMP contEjecuciones, 0
JE ceroEjec

;muestra el n�mero de veces que se ha ejecutado el programa
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

CICLOFIN: ; en este ciclo se imprimen las l�neas dentro de  las barras

	MOV eax, auxCiclos

	MOV edx,4
	MUL edx ; multiplica el numero de la l�nea por 4 para el desplazamiento en memoria

	MOV edx, [mensajeD+eax]
	CALL WriteString ;imprime la l�nea del mensaje
	CALL Crlf
	
	INC auxCiclos

LOOP CICLOFIN

CALL Crlf

CALL animarBarra
CALL animarBarra

RET
mostrarDespedida ENDP


;-----------------------------------------------------------------------------------------------------------
leerArchivo PROC
;Carga el archivo y llama al metodo que ordena el vector
;-----------------------------------------------------------------------------------------------------------
mov eax, colores3
call SetTextColor

;pide la ubicaci�n del archivo y lo abre
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
MOV	buferArchivo[eax],0 ;terminaci�n nula para el archivo. eax contiene la cantidad de caracteres le�dos

;cierra el handle
MOV	eax,fileHandle
CALL CloseFile

;se leen los n�meros y se meten en el arreglo
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

		;si el archivo termin�, sale del ciclo
		CMP al, 0
		JNE noFinArchivo
		MOV finArchivo, 1
		JMP finLectura
		noFinArchivo:

		;si hay cr o lf, aumenta saltoDeLinea y pasa al siguiente caracter
		CMP al, 13
		JNE noCr
		INC saltoDeLinea
		;si ya se leyeron los dos, se pasa al siguiente n�mero
		CMP saltoDeLinea, 2
		JE finNumero
		JMP finChar
		noCr:
		CMP al, 10
		JNE noLf
		INC saltoDeLinea
		;si ya se leyeron los dos, se pasa al siguiente n�mero
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

		;convierte el caracter en el n�mero que representa
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
		;ciclo de divisi�n por 10 para llegar al valor correcto
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
	JG leerChar
	finNumero:

	;guarda el n�mero en el array
	FLD realActual
	MOV eax, 8
	MUL realesLeidos
	FSTP numeros[eax]
	INC realesLeidos
	
	;si lleg� al final del archivo, sale
	CMP finArchivo, 1
	JE finLectura

	;si no ha llegado al n�mero m�ximo de reales que puede almacenar, sigue leyendo
	CMP realesLeidos, maxDatos
	JL leerNum
finLectura:

;;;;;;;;;;;comprobar que se haya llenado correctamente el array
;MOV edx, OFFSET numeros; para el metodo imprimirArregloReales
;CALL imprimirArregloReales; para comprobar que leyo correctamente
;CALL crlf
;;;;;;;;;;;;;;;

CALL ordenar

;;;;;;;;;;;;;;;;;;comprobar ordenamiento
;MOV edx, OFFSET numeros; para el metodo imprimirArregloReales
;CALL imprimirArregloReales; para comprobar que ordeno correctamente 
;CALL waitmsg
;;;;;;;;;;;;;;;

RET
leerArchivo ENDP

;-----------------------------------------------------------------------------------------------------------
calcularEstadisticos PROC
; Calcula los estad�sticos excepto los momentos, que pueden ser calculados con diferentes �rdenes
;-----------------------------------------------------------------------------------------------------------


CALL calcMedia
CALL calcMediana
CALL calcModa
CALL calcMediageometrica
CALL calcMediaarmonica
CALL calcPercentiles
CALL calcCuartiles
CALL calcDeciles
;CALL calcMomentosOrigen
;CALL calcMomentosCentrales
CALL calcVarianza
CALL calcDesvEstandar
CALL calcCuasiVarianza
CALL calcDesvMedia
CALL calcDesvMediana


RET
calcularEstadisticos ENDP

;-----------------------------------------------------------------------------------------------------------
calcularMomentos PROC
; Calcula los momentos seg�n los datos que ingres� el usuario
;-----------------------------------------------------------------------------------------------------------

CALL calcMomentosOrigen
CALL calcMomentosCentrales

RET
calcularMomentos ENDP

;-----------------------------------------------------------------------------------------------------------
pedirEstadisticos PROC
;Pide al usuario ingresar los estad�sticos que desea
;-----------------------------------------------------------------------------------------------------------

CALL clrscr
mWrite <"Seleccione los estad",161,"sticos que desea calcular.",0dh,0ah>
MOV edx, OFFSET stringEstadisticos
CALL writeString

seleccionEstad:
CALL crlf
mWrite <"Escriba una lista separada por comas y presione enter. Ejemplo: 1,2,3",0dh,0ah>

MOV edx, OFFSET buferUsuario
MOV ecx, LENGTHOF buferUsuario
DEC ecx ;se deja el �ltimo caracter en 0 siempre
CALL readString

MOV ecx, eax
INC ecx

;interpreta la cadena ingresada (en ecx est� el tama�o de la cadena + 1)
MOV esi, 0
MOV eax, 0
cicloUsuario:
	;si el caracter leido es una coma o se lleg� al final del b�fer, 
	;mueve 1 a la posici�n correspondiente del array de booleanos
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

	;el n�mero puede tener dos cifras. multiplica la primera por 10 y suma la siguiente
	MOV ebx, 0
	MOV bl, buferUsuario[esi]
	SUB ebx, 48
	MOV edx, 10
	MUL edx
	ADD eax, ebx

	continueUsu:
	INC esi
LOOP cicloUsuario

CALL mostrarEstadisticosSelec
mWrite <"Por favor confirme su selecci",162,"n. 1=si, 0=cambiar",0dh,0ah>
CALL readInt
CALL crlf
CMP eax, 0
JNE finSeleccion
mWrite <"Indique los estad",161,"sticos que desea agregar o escriba nuevamente ",0dh,0ah,"los que desea quitar de la lista",0dh,0ah>
JMP seleccionEstad

finSeleccion:

RET
pedirEstadisticos ENDP

;-----------------------------------------------------------------------------------------------------------
mostrarEstadisticosSelec PROC
;Muestra los estad�sticos seleccionados por el usuario
;-----------------------------------------------------------------------------------------------------------
CALL crlf
mWrite <"Los ",161,"ndices no v",160,"lidos han sido ignorados",0dh,0ah>
mWrite <"Estadisticos Seleccionados:",0dh,0ah>
CALL crlf

;si el estad�stico n fue marcado (est� en -1), lo imprime. De lo contrario, pasa al siguiente
CMP boolEstadisticos, -1
JNE pasa2
	mwrite <"1. Media aritm",130,"tica",0dh,0ah>
pasa2:
CMP boolEstadisticos[4], -1
JNE pasa3
	mwrite <"2. Mediana",0dh,0ah>
	pasa3:
CMP boolEstadisticos[8], -1
JNE pasa4
	mwrite <"3. Moda",0dh,0ah>
	pasa4:
CMP boolEstadisticos[12], -1
JNE pasa5
	mwrite <"4. Media geom",130,"trica",0dh,0ah>
pasa5:
CMP boolEstadisticos[16], -1
JNE pasa6
	mwrite <"5. Media arm",162,"nica",0dh,0ah>
pasa6:
CMP boolEstadisticos[20], -1
JNE pasa7
	mwrite <"6. Percentiles",0dh,0ah>
pasa7:
CMP boolEstadisticos[24], -1
JNE pasa8
	mwrite <"7. Cuartiles",0dh,0ah>
pasa8:
CMP boolEstadisticos[28], -1
JNE pasa9
	mwrite <"8. Deciles",0dh,0ah>
pasa9:
CMP boolEstadisticos[32], -1
JNE pasa10
	mwrite <"9. Momentos respecto al origen",0dh,0ah>
pasa10:
CMP boolEstadisticos[36], -1
JNE pasa11
	mwrite <"10. Momentos centrales o respecto a la media",0dh,0ah>
pasa11:
CMP boolEstadisticos[40], -1
JNE pasa12
	mwrite <"11. Varianza",0dh,0ah>
pasa12:
CMP boolEstadisticos[44], -1
JNE pasa13
	mwrite <"12. Desviaci",162,"n t",161,"pica",0dh,0ah>
pasa13:
CMP boolEstadisticos[48], -1
JNE pasa14
	mwrite <"13. Cuasi-varianza",0dh,0ah>
pasa14:
CMP boolEstadisticos[52], -1
JNE pasa15
	mwrite <"14. Desviaci",162,"n media respecto a la media",0dh,0ah>
pasa15:
CMP boolEstadisticos[56], -1
JNE pasaFin
	mwrite <"15. Desviaci",162,"n media respecto a la mediana",0dh,0ah>
pasaFin:

;Se reinicializan en imprimirEstadisticos
;reinicializa el vector de booleanos
;MOV ecx, 15
;MOV esi, 0
;ponerCeroSiguiente:
;	MOV boolEstadisticos[esi], 0
;	ADD esi, 4
;LOOP ponerCeroSiguiente


RET
mostrarEstadisticosSelec ENDP

;-----------------------------------------------------------------------------------------------------------
imprimirEstadisticosSelec PROC
;Imprime el valor o arreglo correspondiente al estadistico seleccionado
;-----------------------------------------------------------------------------------------------------------
;si el estad�stico n fue marcado (est� en -1), lo imprime. De lo contrario, pasa al siguiente
CMP boolEstadisticos, -1
JNE pasa2
	mwrite <"1. Media aritm",130,"tica",0dh,0ah>
	MOV edx, OFFSET media
	CALL imprimirDato
pasa2:
CMP boolEstadisticos[4], -1
JNE pasa3
	mwrite <"2. Mediana",0dh,0ah>
	MOV edx, OFFSET mediana 
	CALL imprimirDato
pasa3:
CMP boolEstadisticos[8], -1
JNE pasa4
	mwrite <"3. Moda",0dh,0ah>
	MOV edx, OFFSET moda 
	CALL imprimirArregloReales
pasa4:
CMP boolEstadisticos[12], -1
JNE pasa5
	mwrite <"4. Media geom",130,"trica",0dh,0ah>
	MOV edx, OFFSET mediageometrica  
	CALL imprimirDato
pasa5:
CMP boolEstadisticos[16], -1
JNE pasa6
	mwrite <"5. Media arm",162,"nica",0dh,0ah>
	MOV edx, OFFSET mediaarmonica   
	CALL imprimirDato
pasa6:
CMP boolEstadisticos[20], -1
JNE pasa7
	mwrite <"6. Percentiles",0dh,0ah>
	MOV edx, OFFSET percentiles  
	CALL imprimirArregloReales
pasa7:
CMP boolEstadisticos[24], -1
JNE pasa8
	mwrite <"7. Cuartiles",0dh,0ah>
	MOV edx, OFFSET cuartiles   
	CALL imprimirArregloReales
pasa8:
CMP boolEstadisticos[28], -1
JNE pasa9
	mwrite <"8. Deciles",0dh,0ah>
	MOV edx, OFFSET deciles    
	CALL imprimirArregloReales
pasa9:
CMP boolEstadisticos[32], -1
JNE pasa10
	mwrite <"9. Momento respecto al origen de orden ">
	MOV eax, ordenMomOrig
	CALL writeDec
	CALL crlf
	MOV edx, OFFSET momentosOrigen    
	CALL imprimirDato
pasa10:
CMP boolEstadisticos[36], -1
JNE pasa11
	mwrite <"10. Momento central o respecto a la media de orden ">
	MOV eax, ordenMomCent
	CALL writeDec
	CALL crlf
	MOV edx, OFFSET momentosCentrales     
	CALL imprimirDato
pasa11:
CMP boolEstadisticos[40], -1
JNE pasa12
	mwrite <"11. Varianza",0dh,0ah>
	MOV edx, OFFSET varianza      
	CALL imprimirDato
pasa12:
CMP boolEstadisticos[44], -1
JNE pasa13
	mwrite <"12. Desviaci",162,"n t",161,"pica",0dh,0ah>
	MOV edx, OFFSET desvEstandar       
	CALL imprimirDato
pasa13:
CMP boolEstadisticos[48], -1
JNE pasa14
	mwrite <"13. Cuasi-varianza",0dh,0ah>
	MOV edx, OFFSET cuasiVarianza        
	CALL imprimirDato
pasa14:
CMP boolEstadisticos[52], -1
JNE pasa15
	mwrite <"14. Desviaci",162,"n media respecto a la media",0dh,0ah>
	MOV edx, OFFSET desvMedia         
	CALL imprimirDato
pasa15:
CMP boolEstadisticos[56], -1
JNE pasaFin
	mwrite <"15. Desviaci",162,"n media respecto a la mediana",0dh,0ah>
	MOV edx, OFFSET desvMediana          
	CALL imprimirDato
pasaFin:

;reinicializa el vector de booleanos
MOV ecx, 15
MOV esi, 0
ponerCeroSiguiente:
	MOV boolEstadisticos[esi], 0
	ADD esi, 4
LOOP ponerCeroSiguiente

RET
imprimirEstadisticosSelec ENDP

;-----------------------------------------------------------------------------------------------------------
imprimirDato PROC
;Muestra un �nico dato
;Para este metodo la direccion del Datos debe estar en el registro edx
;-----------------------------------------------------------------------------------------------------------
	MOV esi,[edx]
	MOV DWORD PTR numeroReal,esi
	MOV esi,[edx+4]
	MOV DWORD PTR numeroReal[4],esi
	FLD numeroReal
	CALL WriteFloat
	CALL Crlf
	FSTP numeroReal

RET
imprimirDato ENDP

;-----------------------------------------------------------------------------------------------------------
imprimirArregloReales PROC
;Muestra un arreglo de datos. La primera posici�n debe encontrarse en el reg EDX
;ceroReal REAL8 0.
;numeroReal REAL8 0.
;-----------------------------------------------------------------------------------------------------------
MOV ebx,0
ImprimirReal:
	MOV esi,[edx+ebx]
	MOV DWORD PTR numeroReal,esi
	MOV esi,[edx+ebx+4]
	MOV DWORD PTR numeroReal[4],esi
	FLD numeroReal
	CALL WriteFloat
	CALL Crlf
	FSTP numeroReal
	;CALL waitMsg
	ADD ebx,8
MOV esi,[edx+ebx]
MOV DWORD PTR numeroReal,esi
MOV esi,[edx+ebx+4]
MOV DWORD PTR numeroReal[4],esi
FLD numeroReal
FCOMP ceroReal ; compara ST(0) con cero
FNSTSW ax ; mueve la palabra de estado hacia AX
SAHF ; copia AH a EFLAGS
JNB ImprimirReal
;CALL waitMsg
RET
imprimirArregloReales ENDP

;-----------------------------------------------------------------------------------------------------------
ordenar PROC
;Ordena el vector y calcula las frecuencias
;posActual DWORD 0
;indiceCicloOrdenar DWORD 0
;indiceCicloComparar DWORD 0
;posMenor DWORD 0
;menorValor REAL8 0.
;-----------------------------------------------------------------------------------------------------------

MOV posActual, 0
CicloOrdenar:
	MOV eax, posActual
	MOV posMenor, eax ;establece la posici�n del menor en la actual
	MOV eax,8
	MUL posActual
	FLD numeros[eax]
	FSTP menorValor;inicia menorValor en el valor de la posicion actual
	MOV esi,posActual
	INC esi
	MOV indiceCicloComparar,esi; este ciclo inicia en posActual+1
	CicloComparar:
		MOV eax,8
		MUL indiceCicloComparar
		FLD numeros[eax] ; ST(0) = numeros[eax]
		FCOMP menorValor ; compara ST(0) con menorValor y desapila
		FNSTSW ax ; mueve la palabra de estado hacia AX
		SAHF ; copia AH a EFLAGS
		JA esMayor
			MOV eax,8
			MUL indiceCicloComparar
			FLD numeros[eax]
			FSTP menorValor
			MOV esi, indiceCicloComparar
			MOV posMenor,esi
		esMayor:

	INC indiceCicloComparar
	MOV esi,realesLeidos
	CMP indiceCicloComparar,esi
	JL CicloComparar; el ciclo termina en la ultima posicion del vector
	;FinCicloComparar

	;Intercambio de posiciones
	
	FLD menorValor ;st(0) = menor
	MOV eax,8
	MUL posActual
	FLD numeros[eax] ;st(0) = numPosActual, st(1) = menor
	MOV eax,8
	MUL posMenor
	FSTP numeros[eax]; desapila la posicion actual, st(0)= menorValor
	MOV eax,8
	MUL posActual
	FSTP numeros[eax];desapila menorValor
	;Fin intercambio

	INC posActual

INC indiceCicloOrdenar
MOV esi,realesLeidos
DEC esi ;llega hasta el n�mero de reales le�dos - 1
CMP indiceCicloOrdenar,esi
JL CicloOrdenar

RET
ordenar ENDP

;-----------------------------------------------------------------------------------------------------------
calcMedia PROC
;Calcula el estad�stico
;auxSumatoria REAL8 0.
;-----------------------------------------------------------------------------------------------------------

MOV posActual, 0
FLDZ
;sumatoria
cicloMedia:
	MOV esi, posActual
	FLD numeros[esi*8]
	FADD
INC posActual
MOV esi, realesLeidos
CMP posActual, esi
JL cicloMedia
;divisi�n
FILD realesLeidos
FDIV
FSTP media

RET
calcMedia ENDP

;-----------------------------------------------------------------------------------------------------------
calcMediana PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

;ve si la cantidad de datos es par o impar
MOV ebx, 2
MOV eax, realesLeidos
DIV ebx
CMP edx, 0
JNE noEsPar
	;la mediana es el promedio entre los datos en las posiciones (realesleidos/2) y (realesleidos/2)+1
	FLD numeros[eax*8] ;(realesleidos/2)+1
	FLD numeros[eax*8-8] ;(realesleidos/2)
	FADD
	FLD numDos
	FDIV
	FSTP mediana
	JMP  finMediana
noEsPar:

;la mediana es el dato en la posici�n roof(realesleidos/2)=eax+1
FLD numeros[eax*8]
FSTP mediana


finMediana:

RET
calcMediana ENDP

;-----------------------------------------------------------------------------------------------------------
calcModa PROC
;Calcula el estad�stico
;numeros REAL8 maxDatos DUP(-1.), -1.
;numerosDistintos REAL8 maxDatos DUP(-1.), -1.
;frecuencias DWORD maxDatos DUP(-1.), -1.
;cantDatosDistintos DWORD 0
;frecuenciaMax DWORD 0 ;para la moda
;posActual DWORD
;posModa DWORD 0
;-----------------------------------------------------------------------------------------------------------

;carga el primero
FLD numeros
FST realActual
FSTP numerosDistintos
INC frecuenciaMax
INC frecuencias
INC cantDatosDistintos
MOV posActual, 1
MOV posModa, 0

cicloFrecu:
	
	MOV esi, posActual
	FLD numeros[esi*8]
	FCOMP realActual
	FNSTSW ax ; mueve la palabra de estado hacia AX
	SAHF ; copia AH a EFLAGS
	JNE diferente
		;si el dato siguiente es igual al dato actual del array sin repetidos:
		MOV esi, posModa
		INC frecuencias[esi*4]
		MOV eax, frecuencias[esi*4]
		CMP frecuenciaMax, eax
		JGE finCompFrec ;si la frecuencia m�xima es mayor o igual a la del dato actual, no cambia
			INC frecuenciaMax
		JMP finCompFrec
	diferente:
		FLD numeros[esi*8]
		FST realActual
		INC posModa
		MOV esi, posModa
		FSTP numerosDistintos[esi*8]
		INC frecuencias[esi*4]
		INC cantDatosDistintos
	finCompFrec:

INC posActual
MOV ebx, realesLeidos
CMP posActual, ebx
JL cicloFrecu

;pasa los datos con frecuencia==frecuenciaMax al vector moda
MOV posActual, 0
MOV posModa, 0
cicloModa:
	MOV esi, posActual
	MOV eax, frecuencias[esi*4]
	CMP frecuenciaMax, eax
	JNE noEsModa
		MOV ebx, posModa
		FLD numerosDistintos[esi*8]
		FSTP moda[ebx*8]
		INC posModa
	noEsModa:
INC posActual
MOV esi, cantDatosDistintos
CMP posActual, esi
JL cicloModa

RET
calcModa ENDP

;-----------------------------------------------------------------------------------------------------------
calcMediageometrica PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcMediageometrica ENDP

;-----------------------------------------------------------------------------------------------------------
calcMediaarmonica PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcMediaarmonica ENDP

;-----------------------------------------------------------------------------------------------------------
calcPercentiles PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcPercentiles ENDP

;-----------------------------------------------------------------------------------------------------------
calcCuartiles PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcCuartiles ENDP

;-----------------------------------------------------------------------------------------------------------
calcDeciles PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcDeciles ENDP

;-----------------------------------------------------------------------------------------------------------
calcMomentosOrigen PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcMomentosOrigen ENDP

;-----------------------------------------------------------------------------------------------------------
calcMomentosCentrales PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcMomentosCentrales ENDP

;-----------------------------------------------------------------------------------------------------------
calcVarianza PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcVarianza ENDP

;-----------------------------------------------------------------------------------------------------------
calcDesvEstandar PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcDesvEstandar ENDP

;-----------------------------------------------------------------------------------------------------------
calcCuasiVarianza PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcCuasiVarianza ENDP

;-----------------------------------------------------------------------------------------------------------
calcDesvMedia PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcDesvMedia ENDP

;-----------------------------------------------------------------------------------------------------------
calcDesvMediana PROC
;Calcula el estad�stico
;-----------------------------------------------------------------------------------------------------------

RET
calcDesvMediana ENDP

;fin del programa
END main
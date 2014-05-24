TITLE MASM Template						(main.asm)

; Description:
; 
; Revision date:

INCLUDE Irvine32.inc
.data
myMessage BYTE "MASM program example",0dh,0ah,0

posVal REAL10 -999999999999999999.0
negVal REAL8 -1.5
intVal REAL8 999999999999999999.0

bcdVal TBYTE 0
guard BYTE 5 DUP(0FFh)

checkThis TBYTE 987654321

.code
main PROC
	call Clrscr
   
	fld	posVal		
	fbstp bcdVal	
   
	fld	negVal		; -1.5
	fbstp bcdVal	; rounds down to -2  ( 80 00 00 00 00 00 00 00 02 )
      
	mov	 edx,OFFSET myMessage
	call WriteString

	exit
main ENDP

END main
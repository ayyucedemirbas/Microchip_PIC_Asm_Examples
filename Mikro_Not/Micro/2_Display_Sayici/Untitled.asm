	LIST P=16F877A
	INCLUDE "P16F877A.inc"
	SAYAC EQU 0X20
	SAY1 EQU 0X21
	SAY2 EQU 0X22
	SAY3 equ 0x23

	ORG 0
	GOTO BASLA
	ORG 4

KESME
	retfie
	
	
BASLA
	BSF STATUS,RP0
	clrf TRISD
	CLRF TRISA
	BCF STATUS,RP0
	clrf SAYAC
	clrf PORTD
	movlw b'00001010' ; 2 ve 4. Display yanar.
	movwf PORTA
	
SAY
	BCF STATUS,RP0
	incf SAYAC
	call LOOKUP
	movwf PORTD
	call BEKLE
	goto SAY
	

BEKLE
	movlw 0x10
	movwf SAY1
D1
	movlw 0XFF
	movwf SAY2
D2
	movlw 0xFF
	movwf SAY3
D3
	decfsz SAY3,F
	goto D3
	decfsz SAY2,F
	goto D2
	decfsz SAY1,F
	goto D1
	return


LOOKUP
	movf SAYAC,0
	addwf PCL,1
	
	nop 
	retlw b'00111111';0        
	retlw b'00000110';1
	retlw b'01011011';2
	retlw b'01001111';3
	retlw b'01100110';4
	retlw b'01101101';5
	retlw b'01111101';6
	retlw b'00000111';7
	retlw b'01111111';8
	clrf SAYAC
	retlw b'01100111';9
	
	end
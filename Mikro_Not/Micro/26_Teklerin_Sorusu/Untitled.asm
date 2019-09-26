list p=16F877A
include "P16F877A.inc"

ORG 0
goto Ana_Program
ORG 4

Kesme
	retfie
	
Ana_Program
	CLRF PORTA
	BSF STATUS,RP0
	CLRF TRISA
	CLRF TRISD
	BCF STATUS,RP0
	
Dongu
	CLRF PORTD
	MOVLW B'00000010'
	MOVWF PORTA
	movlw B'01011011'	
	MOVWF PORTD
	
	CLRF PORTD
	MOVLW B'00000001'
	MOVWF PORTA
	movlw B'01001111'	
	MOVWF PORTD
	goto Dongu

end
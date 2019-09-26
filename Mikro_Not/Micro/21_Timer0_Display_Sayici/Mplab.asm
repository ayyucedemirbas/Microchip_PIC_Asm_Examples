list p = 16F877A
include "P16F877A.inc"
Sayac_Display equ 0x21
Sayac_Kesme equ 0x22

ORG 0
goto Ana_Program

ORG 4 

Kesme
	BTFSS INTCON,TMR0IF
	retfie
	BCF INTCON,TMR0IF

	movlw D'60'
	movwf TMR0	

	decfsz Sayac_Kesme
	retfie
	
	movlw D'20'
	movwf Sayac_Kesme

	incf Sayac_Display
	CALL Lookup
	movwf PORTD
	retfie

Ana_Program
	
	MOVLW D'60'
	MOVWF TMR0
	
	movlw D'20'
	movwf Sayac_Kesme

	CLRF PORTD
	MOVLW B'00001001'
	MOVWF PORTA

	BSF STATUS,RP0
	CLRF TRISA
	CLRF TRISD
	
	MOVLW B'00000111'
	MOVWF OPTION_REG

	MOVLW B'11100000'
	MOVWF INTCON

	BCF STATUS,RP0

Dongu
	goto Dongu
	
Lookup
	movf Sayac_Display,w
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
	clrf Sayac_Display
	retlw b'01100111';9
	

end
list p =16F877A
include "P16F877A.inc"
ORG 0
goto Ana_Program
ORG 4

Kesme
	BTFSS INTCON,RBIF
	retfie
	BTFSC PORTB,6
	goto Tus7_Kontrol
	goto Tus6_islemler

Tus7_Kontrol
	BTFSC PORTB,7
	retfie
	goto Tus7_islemler
	
Tus6_islemler
	incf PORTC
	CLRF PORTD
	MOVLW B'00000010'
	MOVWF PORTA
	MOVLW b'01011011'	
	MOVWF PORTD
	goto Cikis

Tus7_islemler
	incf PORTC
	CLRF PORTD
	MOVLW B'00000001'
	MOVWF PORTA
	MOVLW b'01001111'	
	MOVWF PORTD
	goto Cikis

Cikis
	BCF INTCON,RBIF
	retfie

Ana_Program
	CLRF PORTA
	CLRF PORTB
	CLRF PORTD
	CLRF PORTC
	
	BSF STATUS,RP0
	MOVLW B'11000000'
	MOVWF TRISB

	BCF OPTION_REG,7

	CLRF TRISA
	CLRF TRISD
	CLRF TRISC	

	MOVLW 0X06
	MOVWF ADCON1

	MOVLW B'11001000'
	MOVWF INTCON
	
	BCF STATUS,RP0	

Dongu
	goto Dongu	

end
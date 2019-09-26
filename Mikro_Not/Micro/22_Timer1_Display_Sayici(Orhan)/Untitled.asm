list p=16F877A
include "P16F877A.inc"
Sayac_Display equ 0x21
Sayac_Kesme equ 0x22
ORG 0
	goto Ana_Program
ORG 4
	goto Kesme

Kesme
	BTFSS INTCON,INTF
	goto TMR1_Kontrol
	goto Tus_islemler

TMR1_Kontrol
	BTFSS PIR1,TMR1IF
	retfie
	goto TMR1_islemler

TMR1_islemler
	BCF PIR1,TMR1IF
	DECFSZ Sayac_Kesme,1
	retfie

	movlw D'30'
	movwf Sayac_Kesme
	
	incf Sayac_Display
	call Lookup
	movwf PORTD
	retfie
	
Tus_islemler
	movlw B'00000001'
	xorwf T1CON,F
	BCF INTCON,INTF
	retfie
	
Ana_Program
	CLRF Sayac_Display
	CLRF PORTB
	CLRF PORTD
	MOVLW B'00001010'
	MOVWF PORTA

	movlw D'30'
	MOVWF Sayac_Kesme

	BSF STATUS,RP0
	CLRF TRISA
	CLRF TRISD

	MOVLW B'00000001'
	MOVWF TRISB

	BCF OPTION_REG,7 

	BCF STATUS,RP0

	CLRF T1CON

	CLRF TMR1H
	CLRF TMR1L
	
	BCF PIR1,TMR1IF
	BSF STATUS,RP0
	BSF PIE1,TMR1IE

	BCF STATUS,RP0

	MOVLW B'11010000'
	MOVWF INTCON

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
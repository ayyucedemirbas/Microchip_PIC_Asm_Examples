list p=16F877A
include "P16F877A.inc"
ORG 0x000
Sayac equ 0x21
Durum equ 0x22
Sayac0 equ 0x23
Sayac1 equ 0x24

goto ana_program
	ORG 0x004

Kesme
	btfss INTCON,INTF
	retfie

	MOVLW B'00000001'
	XORWF Durum,f
	BCF INTCON,INTF; RB0 Flagýný resetle
	retfie

ana_program
	CLRF Sayac
	CLRF Durum
	CLRF PORTB
	CLRF PORTC
	CLRF PORTD
	MOVLW B'10010000'
	MOVWF INTCON
	BSF STATUS,RP0
	BCF OPTION_REG,7
	MOVLW B'00000001'
	MOVWF TRISB
	CLRF TRISC
	BCF STATUS,RP0

DONGU
	btfss Durum,0
	goto DONGU
	incf Sayac	
	call Gecik
	movf Sayac,w
	movwf PORTC
	goto DONGU

Gecik
	movlw D'255'
	movwf Sayac0
	movwf Sayac1

Sayac0_Etiketi	
	decfsz Sayac0,1
	goto Sayac0_Etiketi
	
	movlw D'255'
	movwf Sayac0
	
	decfsz Sayac1,1
	goto Sayac0_Etiketi
	return
END
	

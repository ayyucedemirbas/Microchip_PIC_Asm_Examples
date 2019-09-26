	list p=16f877A
	include "p16f877A.inc"
	Sayac equ 0x25
	Durum equ 0x26
	ORG 0
	goto ana_program
	clrf PCLATH
	ORG 4

Kesme
	bcf INTCON,T0IF
	decfsz Sayac,1
	retfie
	
	movlw D'15'
	movwf Sayac

	btfss Durum,0
	GOTO ilk
	GOTO Devam

ilk
	MOVLW B'00000001'
	MOVWF PORTD
	BSF Durum,0
	retfie

Devam
	rlf PORTD,1
	retfie

ana_program
	BCF STATUS,RP0
	movlw D'15'
	MOVWF Sayac
	clrf Durum	
	CLRF PORTD

	BSF STATUS,RP0
	clrf TRISD
	
	movlw B'01010111'            
	movwf OPTION_REG  ; Timer0 Ayarlar.  

	bsf INTCON,T0IE      
	bsf INTCON,GIE    
	BCF STATUS,RP0
Dongu
	goto Dongu
	end
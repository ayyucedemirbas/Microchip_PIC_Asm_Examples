	list p=16f877
	include "p16f877.inc"
	
	Sayac equ 0x25

	ORG 0
	goto ana_program
	clrf PCLATH
	ORG 4

Kesme
	bcf INTCON,T0IF

	incfsz Sayac,1
	retfie

	Banksel PORTD
	incf PORTD
	retfie

ana_program
	clrf Sayac

	Banksel PORTD
	clrf PORTD

	Banksel TRISD
	clrf TRISD
	
	movlw 0xD3         
	movwf OPTION_REG     ; D2 = 1101 0011 (5.Bit TOCS Timer0 Dahili Clock, 3.Bit Timer0 Prescaler olacak, 0,1,2 Bitleri Prescaler deðeri)

	bsf INTCON,T0IE      ; 5.Bit Timer0 Kesmesini Açma
	bsf INTCON,GIE       ; 7.Bit Tüm kesmelere izin verir
	
Dongu
	goto Dongu
	end
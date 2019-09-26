list p=16F877A
include "p16F877A.inc"
__config H'3F31'

	ORG 0x000
	goto ana_program
	ORG 0x004

kesme
	btfsc INTCON,0
	goto tustakimi
	retfie

tustakimi
	clrf PORTD
	bcf INTCON,0
	bcf PORTB,2
	bcf PORTB,1
	bcf PORTB,0
	btfsc PORTB,7
	goto yedi
	btfsc PORTB,6
	goto dort
	btfsc PORTB,5
	goto bir
	btfsc PORTB,4
	goto p

	bcf PORTB,3
	bsf PORTB,2
	btfsc PORTB,7
	goto sekiz
	btfsc PORTB,6
	goto bes
	btfsc PORTB,5
	goto iki
	btfsc PORTB,4
	goto sifir

	bcf PORTB,2
	bsf PORTB,1
	btfsc PORTB,7
	goto dokuz
	btfsc PORTB,6
	goto alti
	btfsc PORTB,5
	goto uc
	btfsc PORTB,4
	goto a

	bcf PORTB,1
	bsf PORTB,0
	btfsc PORTB,7
	goto bol
	btfsc PORTB,6
	goto carp
	btfsc PORTB,5
	goto cikar
	btfsc PORTB,4
	goto topla

	goto kesmesonu

bir
	movlw b'00000110'
	retfie

iki
	movlw b'01011011'
	goto kesmesonu

uc
	movlw b'01001111'
	goto kesmesonu

dort
	movlw b'01100110'
	goto kesmesonu

bes
	movlw b'01101101'
	goto kesmesonu
alti
	movlw b'01111101'
	goto kesmesonu

yedi
	movlw b'00000111'
	goto kesmesonu

sekiz
	movlw b'01111111'
	goto kesmesonu

dokuz
	movlw b'01101111'
	goto kesmesonu

p
	movlw b'01110011'
	goto kesmesonu

sifir
	movlw b'00111111'
	goto kesmesonu

a
	movlw b'01110111'
	goto kesmesonu

bol
	movlw b'01111100'
	goto kesmesonu

carp 
	movlw b'00111001'
	goto kesmesonu

cikar
	movlw b'01000000'
	goto kesmesonu

topla
	movlw b'01110000'

kesmesonu
	movwf PORTD
	bsf PORTB,3
	bsf PORTB,2	
	bsf PORTB,1
	bsf PORTB,0
	retfie

ana_program
	movlw b'11001000'
	movwf INTCON
	bsf STATUS,RP0
	movlw b'11110000'
	movwf TRISB
	movlw b'00000000'
	movwf TRISA
	movwf TRISD
	bcf STATUS,RP0
	movlw b'001111'
	movwf PORTA
	clrf PORTD
	bsf PORTB,3
	bsf PORTB,2	
	bsf PORTB,1
	bsf PORTB,0
	
dongu
	goto dongu
	end
	

	include	<p16f877.inc>

sayac	equ	21h


	org	0000 			   
	goto	START

	org	0004
	goto kesme
	

	org	0010
START               

	clrf	sayac
	MOVLW 	b'00000110'
	MOVWF	TMR0

	bsf	STATUS,5

	movlw	B'10000011'
	movwf	OPTION_REG

	movlw	B'11100000'
	movwf	INTCON

	bcf	STATUS,5

	


son	
	NOP
	NOP
	goto	son



kesme
	movlw	0x78
	
	incf	sayac,1
	subwf	sayac,0

	btfsc	STATUS,C
	goto	son
	bcf	INTCON,2
	goto start

	end


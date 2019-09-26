	include	<p16f877.inc>

	deg1	equ	21h


	org		0000 			   
	goto	START
	
	org		0004 			   
	goto	kesme


	org	0010
START   
	
	clrf	deg1            

	MOVLW   d'251'
	MOVWF	TMR0

	bsf	STATUS,5

	movlw	B'10000000'
	movwf	OPTION_REG

	movlw	B'11100000'
	movwf	INTCON

	bcf	STATUS,5

		
son	

	goto	son



kesme
	incf	deg1
	MOVLW   d'251'
	MOVWF	TMR0
	bcf		INTCON,TMR0IF

	retfie





	end


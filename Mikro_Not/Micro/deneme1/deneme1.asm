	include	<p16f877.inc>

reg1	EQU	023h

deg1	EQU	028h
deg2	EQU	029h

	org	0000 			   
	goto	START
	

	org	0010

START               
	

	bsf	STATUS,RP0
	;clrf	TRISB
	MOVLW	0XF0
	MOVWF	TRISB
	bcf	STATUS,RP0
	;BCF 	PORTB,7
	;movlw	0x01
	;movwf	reg1
	;movwf	PORTB

	

 	call	gecikme

	MOVLW	0xf0
	MOVWF	PORTB





	
	;RLF		reg1,1
;	movf	reg1,0
;	movwf	PORTB

	
	;CALL	gecikme
	;CALL	gecikme
	;CALL	gecikme	
	;CALL	gecikme
	CALL	gecikme
	CALL	gecikme

DON


	BTFSC	PORTB,4
	GOTO	TUS1YAK
	call	gecikme

	BTFSS	PORTB,4
	GOTO	TUS1SON
	call	gecikme



	BTFSC	PORTB,5
	GOTO	TUS2
	call	gecikme

	BTFSC	PORTB,6
	GOTO	TUS3
	call	gecikme

	BTFSC	PORTB,7
	GOTO	TUS4
	call	gecikme

	goto	DON

TUS1YAK
	MOVLW	0X01
	MOVWF	PORTB
	GOTO	DON

TUS1SON
	MOVLW	0X00
	MOVWF	PORTB
	GOTO	DON

TUS2
	MOVLW	0X02
	MOVWF	PORTB
	GOTO	DON

TUS3
	MOVLW	0X04
	MOVWF	PORTB
	GOTO	DON

TUS4
	MOVLW	0X08
	MOVWF	PORTB
	GOTO	DON

	
	
	










gecikme    
	movlw   H'FF'	     
	movwf   deg1		
etiket1	      
	movlw	H'FF'
	movwf    deg2      		
etiket2	
	nop
	nop
	decfsz  deg2,F         
	goto    etiket2
	decfsz  deg1,F
	goto    etiket1
	return

	end

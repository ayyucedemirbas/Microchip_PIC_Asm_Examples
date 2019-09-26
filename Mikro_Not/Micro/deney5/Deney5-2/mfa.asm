
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 	
				

;-------------------------------------------------------------------

say	equ		0x20
say1	equ		0x21
say2	equ		0x22
say3	equ		0x23	
dur   	equ		0x24					
	org	0
	goto	ana_program
	org	4
;-------------------------------------------------------------------
kesme	
	btfss INTCON,3
	goto bitir				
	btfss INTCON,0
	goto bitir
	bcf INTCON, 0
	btfsc PORTB,4
	incf	say	
	btfsc PORTB,5
	incf	say1	
	btfsc PORTB,6
	incf	say2
	btfsc PORTB,7
	incf	say3	
bitir
	bcf INTCON, 0
    retfie

ana_program
	banksel TRISB	
	movlw b'10000000'
	movwf OPTION_REG
	movlw b'10001000'
	movwf INTCON
	movlw b'11111111'
	movwf TRISB
	clrf  TRISA	
	clrf	TRISD	
	banksel PORTB
	movlw D'250'
	movwf dur
	clrf PORTB
	clrf PORTA
	clrf PORTD
	clrf	say	
	clrf	say1	
	clrf	say2	
	clrf	say3
	goto	dongu
;-------------------------------------------------------------------
DS0
	bsf PORTA,0
	movf	say, W
	call	tablo
	movwf	PORTD
	movlw	D'10'
	subwf	say ,W
	btfsc	STATUS, Z
	clrf	say	
	bcf PORTA,0 
	return
;-------------------------------------------------------------------
DS1
	bsf PORTA,1
	movf	say1, W
	call	tablo
	movwf	PORTD
	movlw	D'10'
	subwf	say1 ,W
	btfsc	STATUS, Z
	clrf	say1 
	bcf PORTA,1
	return
;-------------------------------------------------------------------
DS2
	bsf PORTA,2
	movf	say2, W
	call	tablo	
	movwf	PORTD
	movlw	D'10'
	subwf	say2 ,W
	btfsc	STATUS, Z
	clrf	say2
	bcf PORTA,2	 
	return
;-------------------------------------------------------------------
DS3
	bsf PORTA,3
	movf	say3, W
	call	tablo
	movwf	PORTD
	movlw	D'10'
	subwf	say3 ,W
	btfsc	STATUS, Z
	clrf	say3
	bcf PORTA,3 
	return
bekle
	nop
	nop
	decfsz dur,1
	goto bekle
	movlw D'250'
	movwf dur
	return
;-------------------------------------------------------------------
tablo
	addwf	PCL, F
	retlw	0x3F		; 0 rakamý için segment deðeri.
	retlw	0x06		; 1 rakamý için segment deðeri.
	retlw	0x5B		; 2 rakamý için segment deðeri.
	retlw	0x4F		; 3 rakamý için segment deðeri.
	retlw	0x66		; 4 rakamý için segment deðeri.
	retlw	0x6D		; 5 rakamý için segment deðeri.
	retlw	0x7D		; 6 rakamý için segment deðeri.
	retlw	0x07		; 7 rakamý için segment deðeri.
	retlw	0x7F		; 8 rakamý için segment deðeri.
	retlw	0x6F		; 9 rakamý için segment deðeri.
dongu
	call DS0
	call bekle
	call DS1
	call bekle
	call DS2
	call bekle
	call DS3
	call bekle
	goto	dongu
	end
;******************************************************************* 

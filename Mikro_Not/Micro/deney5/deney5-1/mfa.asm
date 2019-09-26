
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 	
				

;-------------------------------------------------------------------
say	equ		0x20
say1	equ		0x21
say2	equ		0x22
say3	equ		0x23
dur   	equ		0x24
tmrsayaci equ 0x25						
	org	0
	goto	ana_program
	org	4
;-------------------------------------------------------------------
kesme	
	btfss PIR1,1
    goto bitir
    bcf PIR1,1
	movlw	D'25'        ;125*25*16*4=200000mikrosn=200ms
	subwf	tmrsayaci ,W
	btfsc	STATUS, Z
	goto art
	incf tmrsayaci
	goto bitir
art 
	clrf tmrsayaci
	incf say
bitir
	bcf PIR1,1
	movlw D'10'
    retfie

ana_program
	banksel TRISC	
	movlw b'11000000'
	movwf INTCON
	bsf PIE1,1
	clrf  TRISA	
	clrf	TRISD
	movlw D'250'
    movwf PR2	
	banksel PORTA
	movlw b'00010111'  ;TMR2 aktif  postcaler=1/4 Presecaler=1/16
    movwf T2CON 
	movlw D'250'
	movwf dur
	clrf PORTA
	clrf PORTD
	clrf	say	
	clrf	say1	
	clrf	say2	
	clrf	say3
	clrf tmrsayaci
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
	call onlar
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
	goto yuzler
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
	goto binler
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
	goto tasma
	bcf PORTA,3 
	return
;-------------------------------------------------------------------

onlar
	clrf	say
	incf	say1
	return	
yuzler
	clrf	say1 
	incf	say2
	return		
binler
	clrf	say2 
	incf	say3
	return	
tasma
	clrf	say3 
	clrf	say
	clrf	say1
	clrf	say2 
	return	
bekle
	nop
	nop
	decfsz dur,1
	goto bekle
	movlw D'250'
	movwf dur
	return
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

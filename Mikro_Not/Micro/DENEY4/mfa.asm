	
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tanýmlamalarý 
				;programa dahil ediliyor.
	__config H'3F31' 	;PWRT on, diðer sigortalar kapalý, 
				;Osilatör XT ve 4Mhz


	ORG 	0		
	goto 	ana_program	
	ORG 4				
interrupt
	btfsc INTCON, 1
	bcf INTCON, 1						
	btfss INTCON,0
	goto bitir
	bcf INTCON, 0
	btfsc PORTB,4	
	goto satira
	btfsc PORTB,5	
	goto satirb
	btfsc PORTB,6	
	goto satirc
	btfsc PORTB,7	
	goto satird
satira	
	call kanal1
	btfsc PORTB,4
	goto buton1
	call kanal2
	btfsc PORTB,4
	goto buton2
	call kanal3
	btfsc PORTB,4
	goto buton3
	call kanal4
	btfsc PORTB,4
	goto butona	
satirb
	call kanal1
	btfsc PORTB,5
	goto buton4
	call kanal2
	btfsc PORTB,5
	goto buton5
	call kanal3
	btfsc PORTB,5
	goto buton6
	call kanal4
	btfsc PORTB,5
	goto buton8	
satirc
	call kanal1
	btfsc PORTB,6
	goto buton7
	call kanal2
	btfsc PORTB,6
	goto buton8
	call kanal3
	btfsc PORTB,6
	goto buton9
	call kanal4
	btfsc PORTB,6
	goto butonc
satird
	call kanal1
	btfsc PORTB,7
	goto butonf
	call kanal2
	btfsc PORTB,7
	goto buton0
	call kanal3
	btfsc PORTB,7
	goto butone
	call kanal4
	btfsc PORTB,7
	goto buton0
	goto bitir
buton1
	movlw b'00000110'
	movwf PORTD
	goto bitir
buton2
	movlw b'01011011'
	movwf PORTD
	goto bitir
buton3
	movlw b'01001111'
	movwf PORTD
	goto bitir
buton4
	movlw b'01100110'
	movwf PORTD
	goto bitir
buton5
	movlw b'01101101'
	movwf PORTD
	goto bitir
buton6
	movlw b'01111101'
	movwf PORTD
	goto bitir
buton7
	movlw b'00000111'
	movwf PORTD
	goto bitir
buton8
	movlw b'11111111'
	movwf PORTD
	goto bitir
buton9
	movlw b'01101111'
	movwf PORTD
	goto bitir
buton0
	movlw b'00111111'
	movwf PORTD
	goto bitir
butona
	movlw b'11110111'
	movwf PORTD
	goto bitir
butonc
	movlw b'00111001'
	movwf PORTD
	goto bitir
butone
	movlw b'01111001'
	movwf PORTD
	goto bitir
butonf
	movlw b'01110001'
	movwf PORTD
	goto bitir
kanal1
	bsf PORTB,0
	bcf PORTB,1
	bcf	PORTB,2
	bcf PORTB,3
	return
kanal2
	bcf PORTB,0
	bsf PORTB,1
	bcf	PORTB,2
	bcf PORTB,3
	return
kanal3
	bcf PORTB,0
	bcf PORTB,1
	bsf	PORTB,2
	bcf PORTB,3
	return
kanal4
	bcf PORTB,0
	bcf PORTB,1
	bcf	PORTB,2
	bsf PORTB,3
	return
bitir
	bsf PORTB,0
	bsf PORTB,1
	bsf PORTB,2
	bsf PORTB,3
	retfie				


ana_program						
	bsf STATUS,RP0
	movlw b'10000000'
	movwf OPTION_REG
	movlw b'10001000'
	movwf INTCON
	movlw b'11110000'
	movwf TRISB
	movlw b'00000000'
	movwf TRISD
	bcf STATUS,RP0
	clrf PORTD
	bsf PORTB,0
	bsf PORTB,1
	bsf PORTB,2
	bsf PORTB,3

ana_j1
	goto 	ana_j1			;Sonsuz boþ döngü iþletiliyor.  
	END				;Assembly programý sonu.
;******************************************************************

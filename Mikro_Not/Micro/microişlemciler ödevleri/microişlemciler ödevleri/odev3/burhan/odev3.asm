list p=16F877A
include "p16F877a.inc"
	pvm_sayaci EQU 0x21
	temp EQU 0x22 
	ORG 0
	goto ana_program
	ORG 4
	goto kesme

ana_program
	movlw d'15'
	movwf pvm_sayaci
	

	banksel INTCON
	movlw b'11010000'
	movwf INTCON

	banksel TRISB
	movlw b'00000001' 
	movwf TRISB
	
	movlw d'0'
	movwf TRISC

	banksel PORTC
	clrf PORTC
	bcf PORTC,2

	banksel PR2
	movlw d'49'
	movwf PR2
	
	banksel CCPR1L
	movlw b'00000111'
 	movwf CCPR1L

	banksel CCP1CON
	movlw b'00101100'
	movwf CCP1CON

	banksel PIE1
	movlw d'2'
	movwf PIE1;tmr2 pr2 eþleþmesýne kesmesýne ýzýn verme býtý

	banksel T2CON
	movlw b'00000101'
	movwf T2CON;presscaler t2 ye aktif yaptýk

dongu 
	goto dongu

kesme	
	btfss INTCON,1
	retfie	
	bcf INTCON,1

	decfsz pvm_sayaci,f
	goto artir
	goto dongu
artir
	movlw b'00000001'
	movwf temp
	btfss temp,0
	
	goto durum2
	
	banksel CCPR1L
	movlw b'00000011'
	addwf CCPR1L,1

	banksel CCP1CON
	bcf CCP1CON,5
durum2
	banksel CCPR1L
	movlw b'00000010'
	addwf CCPR1L,1

	banksel CCP1CON
	bsf CCP1CON,5
	
retfie
end
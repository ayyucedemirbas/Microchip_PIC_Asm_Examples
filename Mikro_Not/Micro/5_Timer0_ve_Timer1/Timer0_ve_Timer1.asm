	list p=16F877
	include "p16F877.inc"

    Tmr0Sayaci equ 0x25         
    Tmr1Sayaci equ 0x26        
	ORG 0
	clrf PCLATH   	           
	goto Ana_program            
	ORG 4

Kesme
	btfsc INTCON,T0IF
	goto Timer0_islemler	

	Banksel PIR1
	btfsc PIR1,TMR1IF	
	goto Timer1_islemler
	retfie

Timer0_islemler
	bcf INTCON,T0IF
	decfsz Tmr0Sayaci,f
	retfie

Led0
	Banksel PORTD
	movlw 0x01
	xorwf PORTD,F
	movlw 30
	movwf Tmr0Sayaci
	retfie

Timer1_islemler
	bcf PIR1,TMR1IF
	decfsz Tmr1Sayaci,f
	retfie

Led1
	Banksel PORTD
	movlw 0x02
	xorwf PORTD,F

	movlw 40
	movwf Tmr1Sayaci
	retfie



Ana_program
	movlw 30                  
	movwf Tmr0Sayaci            	

	movlw 40                   
	movwf Tmr1Sayaci          
                          
	movlw 0x17           	 	 
	banksel OPTION_REG   		
	movwf OPTION_REG
     	 
    clrf TRISD  
	bcf STATUS,RP0
    clrf PORTD
	
	movlw 0x01
	movwf T1CON

	bcf PIR1,TMR1IF
	banksel PIE1
	bsf PIE1,TMR1IE
	movlw 0xE0
	movwf INTCON
	           
	bcf STATUS,RP0

ana_j1
	goto ana_j1
	END
LIST P=16F877
INCLUDE "P16F877.INC"

PWM_DEGER equ 0x20
SAY_0 equ 0x21
SAY_1 equ 0x22
TEMP equ 0x23

org 0x000

	BANKSEL ADCON1
	MOVLW 0X06
	MOVWF ADCON1

	banksel PORTA
	clrf PORTA

	banksel TRISC
	bcf TRISC,2

	banksel TRISA
	movlw b'11111111'
	movwf TRISA

	banksel CCP1CON
	movlw b'00001100'
	movwf CCP1CON
	
	banksel CCPR1L
	clrf CCPR1L

	banksel PR2
	movlw d'24'
	movwf PR2
	
	banksel PWM_DEGER
	movlw d'50'
	movwf PWM_DEGER

	banksel T2CON
	movlw b'00000110'
	movwf T2CON
	call AYARLA

TUS_KONTROL
	banksel PORTA

	btfsc PORTA,0
	call HIZLAN

	btfsc PORTA,1
	call YAVASLA
	
	goto TUS_KONTROL

HIZLAN
	banksel PWM_DEGER
	movlw d'100'
	subwf PWM_DEGER,W

	btfss STATUS,C
	incf PWM_DEGER,F
	call AYARLA

	call BEKLE
	return

YAVASLA
	banksel PWM_DEGER
	movf PWM_DEGER,W
	sublw b'00000000'

	btfss STATUS,C
	decf PWM_DEGER,F
	call AYARLA

	call BEKLE
	return

AYARLA
	banksel PWM_DEGER
	movf PWM_DEGER,W

	banksel TEMP
	andlw b'00000011'
	movwf TEMP
	swapf TEMP,W
	andlw b'11110000'
	iorlw b'00001100'
	
	banksel CCP1CON
	movwf CCP1CON
	
	banksel PWM_DEGER
	movf PWM_DEGER,W
	movwf TEMP
	rrf TEMP,F
	rrf TEMP,W
	andlw b'00111111'
	movwf CCPR1L
	return

BEKLE
	banksel SAY_0
	movlw 0xFF
	movwf SAY_1

	decfsz SAY_0,1
	goto BEKLE_SUB
	
	movlw 0xFF
	movwf SAY_0

	return

BEKLE_SUB
	decfsz SAY_1,1
	goto BEKLE_SUB
	goto BEKLE

end







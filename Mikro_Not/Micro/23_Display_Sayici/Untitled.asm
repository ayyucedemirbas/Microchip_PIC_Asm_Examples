list p = 16F877A
include "P16F877A.inc"

Sayac_Kesme equ 0x22
Sayac_Birler equ 0x23
Sayac_Onlar equ 0x24
Sayac_Yuzler equ 0x25
Sayac_Binler equ 0x26
Son_Deger equ 0x27


ORG 0
goto Ana_Program

ORG 4
goto Kesme

Kesme
	movwf Son_Deger

	BTFSS INTCON,TMR0IF
	goto Cikis
	BCF INTCON,TMR0IF
	
	DECFSZ Sayac_Kesme
	goto Cikis
	
	movlw D'10'
	MOVWF Sayac_Kesme

Tmr0_islemler
	incf Sayac_Birler
	movlw D'10'
	subwf Sayac_Birler,w
	btfss STATUS,Z
	goto Cikis
	clrf Sayac_Birler

	incf Sayac_Onlar	
	movlw D'10'
	subwf Sayac_Onlar,w
	btfss STATUS,Z
	goto Cikis
	clrf Sayac_Onlar

	incf Sayac_Yuzler	
	movlw D'10'
	subwf Sayac_Yuzler,w
	btfss STATUS,Z
	goto Cikis
	clrf Sayac_Yuzler

	incf Sayac_Binler	
	movlw D'15'
	subwf Sayac_Binler,w
	btfss STATUS,Z
	goto Cikis
	clrf Sayac_Binler

Cikis
	movf Son_Deger,w
	retfie	

Ana_Program
	BSF STATUS,RP0
	clrf TRISA
	clrf TRISD

	MOVLW B'00000111'
	MOVWF OPTION_REG

	BCF STATUS,RP0
	clrf PORTA
	clrf PORTD
	clrf TMR0
	movlw B'11100000'
	MOVWF INTCON
	
	MOVLW B'00000001'
	movwf PORTA

	movlw D'15'
	movwf Sayac_Kesme

	CLRF Sayac_Birler
	CLRF Sayac_Onlar
	CLRF Sayac_Yuzler
	CLRF Sayac_Binler

Dongu
	CLRF PORTD
	MOVLW B'00000001'
	MOVWF PORTA
	MOVF Sayac_Birler,w
	CALL Lookup
	MOVWF PORTD
	NOP
	NOP
	NOP


	CLRF PORTD
	MOVLW B'00000010'
	MOVWF PORTA
	MOVF Sayac_Onlar,w
	CALL Lookup
	MOVWF PORTD
	NOP
	NOP
	NOP


	CLRF PORTD
	MOVLW B'0000100'
	MOVWF PORTA
	MOVF Sayac_Yuzler,w
	CALL Lookup
	MOVWF PORTD
	NOP
	NOP
	NOP


	CLRF PORTD
	MOVLW B'00001000'
	MOVWF PORTA
	MOVF Sayac_Binler,w
	CALL Lookup
	MOVWF PORTD
	NOP
	NOP
	NOP

	goto Dongu
		
Lookup
	addwf PCL,1
	retlw b'00111111';0        
	retlw b'00000110';1
	retlw b'01011011';2
	retlw b'01001111';3
	retlw b'01100110';4
	retlw b'01101101';5
	retlw b'01111101';6
	retlw b'00000111';7
	retlw b'01111111';8
	retlw b'01100111';9
end


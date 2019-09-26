list p=16f877a
include "p16f877a.inc"
SAYAC1 EQU 0x23
SAYAC2  EQU 0x24
SAYAC3 EQU 0x25
SAYAC4  EQU 0x26
ORG 0
GOTO ANA
 ORG 4
KESME
BTFSS PIR1,0
RETFIE
BCF PIR1,0


INCF SAYAC1,F
MOVF SAYAC1,W
XORLW D'10'
BTFSS STATUS,2
RETFIE
CLRF SAYAC1
BANKSEL SAYAC2
INCF SAYAC2,F
MOVF SAYAC2,W
XORLW D'10'
BTFSS STATUS,2
RETFIE
CLRF SAYAC2
RETFIE
GECIK
MOVLW D'50'
MOVWF SAYAC3
DON

MOVLW D'50'
MOVWF SAYAC4
DON1
DECFSZ SAYAC4,F
GOTO DON1
DECFSZ SAYAC3,F
GOTO DON
RETURN
TABLO
ADDWF PCL,F
RETLW H'3F'
RETLW H'06'
RETLW H'5B'
RETLW H'4F'
RETLW H'66'
RETLW H'6D'
RETLW H'7D'
RETLW H'07'
RETLW H'7F'
RETLW H'6F'

ANA
BANKSEL SAYAC1
CLRF SAYAC1
CLRF SAYAC2
CLRF SAYAC3
CLRF SAYAC4
BANKSEL TRISA 
CLRF TRISA
BANKSEL TRISD 
CLRF TRISD
MOVLW H'06'
MOVWF ADCON1
BANKSEL PORTA
MOVLW H'03'
MOVWF PORTA
BANKSEL PORTD 
CLRF PORTD
BANKSEL T1CON
MOVLW B'00110001'
MOVWF T1CON
BANKSEL PIE1
BSF PIE1,0

BANKSEL INTCON
MOVLW B'11000000'
MOVWF INTCON


DONGU
CALL GECIK
	MOVLW H'01'
	MOVWF PORTA
	MOVF SAYAC1,W
	CALL TABLO
	MOVWF PORTD
	CALL GECIK
	BANKSEL PORTA
	MOVLW H'02'
	MOVWF PORTA
	MOVF SAYAC2,W
	CALL TABLO
	MOVWF PORTD

GOTO DONGU

END
list p=16f877a
include "p16f877a.inc"
SAYAC1 EQU 0x22
SAYAC2 EQU 0x23
SAYAC EQU 0x24
ORG 0
GOTO ANA
ORG 4
KESME
BTFSS INTCON ,1
RETFIE
BTFSC PORTB,0
RETFIE
;BCF INTCON,1
BANKSEL SAYAC
INCF SAYAC,F


BANKSEL PORTA

MOVLW H'01'
MOVWF PORTA
MOVF SAYAC,W
CALL TABLO
MOVWF PORTD
CALL GECIK
CALL GECIK
MOVF SAYAC,W
XORLW D'10'
BTFSS STATUS,2
RETFIE
BANKSEL SAYAC
CLRF SAYAC
RETFIE


ANA
BANKSEL TRISA 
CLRF TRISA
BANKSEL TRISD
CLRF TRISD
BANKSEL PORTD
CLRF PORTD
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA


BANKSEL TRISB
MOVLW H'01'
MOVWF TRISB

BANKSEL INTCON
MOVLW B'10010000'
MOVWF INTCON

BANKSEL OPTION_REG 
MOVLW H'00'
MOVWF OPTION_REG
BANKSEL SAYAC 
CLRF SAYAC 
CLRF SAYAC1
CLRF SAYAC2
DONGU 
GOTO DONGU
GECIK
MOVLW H'FF'
MOVWF SAYAC1
DON1
MOVLW H'FF'
MOVWF SAYAC2
DON2
DECFSZ SAYAC2,F
GOTO DON2
DECFSZ SAYAC1,F
GOTO DON1
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
END
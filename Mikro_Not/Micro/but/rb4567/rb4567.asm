list p=16f877a
include "p16f877a.inc"
;SAYAC EQU 0x23
SAYAC1 EQU 0x24
SAYAC2 EQU 0x25

org 0
 GOTO ANA 
 ORG 4
KESME
BTFSS INTCON,0
GOTO SON
CLRF PORTD
BTFSC PORTB,4
GOTO BES
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
MOVLW H'66'
MOVWF PORTD
MOVWF PORTD
CALL GECIK
GOTO SON
BES
BTFSC PORTB,5
GOTO ALTI
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
MOVLW H'6D'
MOVWF PORTD
MOVWF PORTD
CALL GECIK
GOTO SON
ALTI
BTFSC PORTB,6
GOTO YEDI
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
MOVLW H'7D'
MOVWF PORTD
MOVWF PORTD
CALL GECIK
GOTO SON
YEDI
BTFSC PORTB,7
GOTO SON
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
MOVLW H'07'
MOVWF PORTD
MOVWF PORTD
CALL GECIK
GOTO SON
SON
BCF INTCON,0
RETFIE



ANA
BANKSEL TRISA
CLRF TRISA 
BANKSEL PORTA 
CLRF PORTA
MOVLW h'01'
MOVWF PORTA
BANKSEL TRISB 
MOVLW H'FF'
MOVWF TRISB
BANKSEL PORTB
 CLRF PORTB
BANKSEL TRISD 
CLRF TRISD
BANKSEL PORTD 
CLRF PORTD
 BANKSEL INTCON
MOVLW B'10001000'
MOVWF INTCON
BANKSEL OPTION_REG 
CLRF OPTION_REG
BANKSEL SAYAC1
CLRF SAYAC1
CLRF SAYAC2
DONGU 


GOTO DONGU
GECIK
MOVLW H'FF'
MOVWF SAYAC1
DON

MOVLW H'FF'
MOVWF SAYAC2
DON1
DECFSZ SAYAC2,F
GOTO DON1
DECFSZ SAYAC1,F
GOTO DON
RETURN




END

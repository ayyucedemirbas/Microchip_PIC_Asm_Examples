list p=16f877a
include "P16f877a.inc"
ORG 0
GOTO ANA 
ORG 4
 KESME
 RETFIE
 ANA
 BANKSEL TRISD 
CLRF TRISD 
BANKSEL PORTD 
 CLRF PORTD
BANKSEL TRISA
CLRF TRISA
BANKSEL PORTA
MOVLW H'00'
MOVWF PORTA
DONGU
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
MOVLW H'3F'
MOVWF PORTD
MOVWF PORTD
MOVWF PORTD
MOVWF PORTD
CLRF PORTD
BANKSEL PORTA
MOVLW H'02'
MOVWF PORTA
BANKSEL PORTD

MOVLW H'06'
MOVWF PORTD
MOVWF PORTD
MOVWF PORTD
MOVWF PORTD
CLRF PORTD
GOTO DONGU
END

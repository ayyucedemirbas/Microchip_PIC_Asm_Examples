list p=16f877A
include "P16F877A.inc"
ORG 0
GOTO ANA
 ORG 4 
 KESME
 BTFSS INTCON,0
RETFIE
BTFSC PORTB,4
GOTO BES
BANKSEL PORTB 
MOVLW H'01'
XORWF PORTB
GOTO SON
BES 
BTFSC PORTB,5
GOTO ALTI
BANKSEL PORTB 
MOVLW H'02'
XORWF PORTB
GOTO SON
ALTI
BTFSC PORTB,6
GOTO YEDI
BANKSEL PORTB 
MOVLW H'04'
XORWF PORTB
GOTO SON
YEDI
BTFSC PORTB,7
GOTO SON
BANKSEL PORTB 
MOVLW H'08'
XORWF PORTB
GOTO SON
SON 
BCF INTCON,0
RETFIE














ANA
BANKSEL TRISB 
MOVLW H'F0'
MOVWF TRISB
;BANKSEL PORTB
;CLRF PORTB
BANKSEL INTCON
MOVLW B'11001000'
MOVWF INTCON
DONGU 
GOTO DONGU
END
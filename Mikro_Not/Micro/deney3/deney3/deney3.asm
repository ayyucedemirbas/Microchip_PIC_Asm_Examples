list p=16f877a
#include <p16F877A.inc>
SAYAC1 EQU 0x23
SAYAC2 EQU 0x24
SAYAC3 EQU 0x25
ORG 0
GOTO ANA
ORG 4
GOTO KESME
KESME:
RETFIE
ANA:
BANKSEL TRISC 
CLRF TRISC
BANKSEL PORTC
CLRF PORTC
BANKSEL TRISA
MOVLW B'00000011'
MOVWF TRISA
BANKSEL PORTA 
CLRF PORTA
BANKSEL ADCON1
MOVLW H'06'
MOVWF ADCON1
BANKSEL CCP1CON
MOVLW B'00001100'
MOVWF CCP1CON
BANKSEL INTCON
MOVLW B'11000000'
MOVWF INTCON
BANKSEL T2CON
MOVLW B'00000101'
MOVWF T2CON

BANKSEL PR2
MOVLW D'249'
MOVWF PR2
BANKSEL CCPR1L
MOVLW H'7B'
MOVWF CCPR1L
BANKSEL SAYAC1
MOVLW H'19'
MOVWF SAYAC1

DONGU:
BTFSS PORTA,0
GOTO ART
BTFSS PORTA,1
GOTO AZALT
GOTO DONGU
ART:
BANKSEL SAYAC1
MOVF SAYAC1,W
ADDWF CCPR1L,F
CALL GECIK
GOTO DONGU
AZALT:
BANKSEL SAYAC1
MOVF SAYAC1,W
SUBWF CCPR1L,F
CALL GECIK
GOTO DONGU
GECIK:
MOVLW H'FF'
MOVWF SAYAC2
DON:
MOVLW H'FF'
MOVWF SAYAC3
DON1:
DECFSZ SAYAC2,F
GOTO DON1
DECFSZ SAYAC3,F
GOTO DON
RETURN
END
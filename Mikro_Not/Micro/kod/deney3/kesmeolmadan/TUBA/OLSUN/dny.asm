list p=16f877a
#include <p16f877a.inc>
 SAYAC0 EQU 0x24 
SAYAC1 EQU 0x25
TEMP EQU 0x26
org 0
goto ana
org 4
goto kesme
kesme:
RETFIE
ana:
BANKSEL TRISD
MOVLW H'FF'
MOVWF TRISD
BANKSEL PORTD
CLRF PORTD
BANKSEL TRISC
CLRF TRISC
BANKSEL PORTC
CLRF PORTC 
BANKSEL PR2
MOVLW D'249'
MOVWF PR2

BANKSEL CCP1CON
MOVLW B'00001100'
MOVWF CCP1CON
BANKSEL T2CON

MOVLW B'00000101';prescaler=4 tmr2 on aktif ettim
MOVWF T2CON
BANKSEL CCPR1L
MOVLW H'7D'
MOVWF CCPR1L
BANKSEL TEMP
MOVLW D'5'
MOVWF TEMP
DONGU 
CALL GECIK
BTFSS PORTD,1
GOTO ARTIR
BTFSS PORTD,0
GOTO AZALT
CALL GECIK
GOTO DONGU

ARTIR:
BANKSEL TEMP
MOVF TEMP,0
BANKSEL CCPR1L
 ADDWF CCPR1L,1
GOTO DONGU
AZALT:
BANKSEL TEMP
MOVF TEMP,0

BANKSEL CCPR1L
 SUBWF CCPR1L,1
GOTO DONGU
GECIK:
MOVLW H'FF'
MOVWF SAYAC0
DON1:
MOVLW H'FF'
MOVWF SAYAC1
DON2:
DECFSZ SAYAC1,F
GOTO DON2
DECFSZ SAYAC0,F
GOTO DON1
RETURN
END
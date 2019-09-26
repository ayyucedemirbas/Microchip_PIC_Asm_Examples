list p=16f877a
#include <p16f877a.inc>
ORG 0X00
SAYAC5 EQU 0X20
SAYAC EQU 0X21
GOTO ANA_PROGRAM
ORG 0X04
KESME
BANKSEL PIR2
BTFSS PIR2,EEIF
GOTO ATLA
BCF PIR2,EEIF
GOTO KESME_SON
ATLA
BTFSS INTCON,RBIF
GOTO KESME_SON
BCF INTCON,0
BTFSS PORTB,4
GOTO YAZBIR
BTFSS PORTB,5
GOTO YAZIKI
BTFSS PORTB,6
GOTO YAZUC
BTFSS PORTB,7
GOTO YAZDORT
RETFIE

ANA_PROGRAM
CALL �LK_�SLEMLER
DONGU
BTFSC SAYAC5,2
CLRF SAYAC5
GOTO DONGU

YAZDORT
BCF STATUS,RP0
INCF SAYAC5,F
MOVF SAYAC5,W
BCF PORTC,0
BANKSEL EEADR
MOVWF EEADR

BANKSEL EEDATA
;MOVLW B'10011001'
MOVLW B'01100110'
MOVWF EEDATA
CALL YAZ
CALL GECIK
BCF INTCON,0
RETFIE

YAZUC
BCF STATUS,RP0
INCF SAYAC5,F
MOVF SAYAC5,W
BCF PORTC,1
BANKSEL EEADR
MOVWF EEADR

BANKSEL EEDATA
MOVLW B'01001111'
MOVWF EEDATA
CALL YAZ
CALL GECIK
BCF INTCON,0
RETFIE

YAZIKI
BCF STATUS,RP0
INCF SAYAC5,F
MOVF SAYAC5,W
BCF PORTC,2
BANKSEL EEADR
MOVWF EEADR

BANKSEL EEDATA
MOVLW B'01011011'
MOVWF EEDATA
BCF INTCON,0
CALL YAZ
CALL GECIK
RETFIE

YAZBIR
BCF STATUS,RP0
INCF SAYAC5,F
MOVF SAYAC5,W
BCF PORTC,3
BANKSEL EEADR
MOVWF EEADR

BANKSEL EEDATA
MOVLW B'00000110'
MOVWF EEDATA
CALL YAZ
CALL GECIK
BCF INTCON,0
RETFIE

�LK_�SLEMLER
BSF STATUS,RP0
MOVLW H'F0'
MOVWF TRISB
CLRF TRISC
MOVLW B'01010000'
MOVWF OPTION_REG
BCF STATUS,RP0
CLRF SAYAC5
CLRF SAYAC
CLRF PORTB
MOVLW H'0F'
MOVWF PORTC
MOVLW B'11011000'
MOVWF INTCON
BANKSEL PIE2
BCF PIE2,EEIE
RETURN

YAZ
BANKSEL EECON1
BCF EECON1,EEPGD
BSF EECON1,WREN
BCF INTCON,GIE

MOVLW 55h
MOVWF EECON2
MOVLW H'AA'
MOVWF EECON2
BSF EECON1,WR

BEKLE
BTFSC EECON1,WR
GOTO BEKLE
BSF INTCON,GIE
RETURN

KESME_SON
BCF PIR2,EEIF
BCF INTCON,RBIF
RETFIE

GECIK
MOVLW D'250'
MOVWF SAYAC
DON
NOP
NOP
DECFSZ SAYAC,F
GOTO DON
RETURN


END
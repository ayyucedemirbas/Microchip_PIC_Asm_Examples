list p=16f877a
#INCLUDE <P16F877A.INC>
SAYAC1 EQU 0x23
SAYAC2 EQU 0x24
SAYAC EQU 0x25
SAYAC4 EQU 0x26

ORG 0
GOTO ANA
ORG 4
GOTO KESME
KESME:
BTFSS INTCON,0
RETFIE
BCF INTCON,0
BTFSS PORTB,4
GOTO YAZ23
BTFSS PORTB,5
GOTO YAZ40
RETFIE
YAZ23:

BCF INTCON,0
BANKSEL SAYAC
MOVLW D'0'
MOVWF SAYAC
BANKSEL SAYAC
MOVLW D'1'
MOVWF SAYAC4
RETFIE
YAZ40:

BCF INTCON,0
BANKSEL SAYAC
MOVLW D'2'
MOVWF SAYAC
BANKSEL SAYAC
MOVLW D'3'
MOVWF SAYAC4
RETFIE





TABLO:
ADDWF PCL,F
RETLW H'4F'
RETLW H'5B'
RETLW  H'3F'
RETLW  H'66'
GECIK:
MOVLW H'FF'
MOVWF SAYAC1
DON:
MOVLW H'FF'
MOVWF SAYAC2
DON1:
DECFSZ SAYAC2,F
GOTO DON1
DECFSZ SAYAC1,F
GOTO DON
RETURN





ANA:
BANKSEL TRISA
CLRF TRISA
BANKSEL PORTA
MOVLW H'00'
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
MOVLW B'11001000'
MOVWF INTCON
BANKSEL OPTION_REG
MOVLW H'00'
MOVWF OPTION_REG

BANKSEL SAYAC1
CLRF SAYAC1
CLRF SAYAC2
MOVLW D'6'
MOVWF SAYAC4
MOVWF SAYAC

DONGU:
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
BANKSEL SAYAC
MOVF SAYAC,0
CALL TABLO
BANKSEL PORTD
MOVWF PORTD
MOVWF PORTD

CLRF PORTD

BANKSEL PORTA
MOVLW H'02'
MOVWF PORTA
BANKSEL SAYAC4
MOVF SAYAC4,0
CALL TABLO
BANKSEL PORTD
MOVWF PORTD
MOVWF PORTD

CLRF PORTD
GOTO DONGU 

END

list p=16f877a
#include <P16F877A.inc>
SAYAC EQU 0x23 
SAYAC1 EQU 0x24
SAYAC2 EQU 0x25
ORG 0
GOTO ANA 
ORG 4
GOTO KESME
KESME:
BTFSS INTCON,1
RETFIE
BCF INTCON,1
BANKSEL PORTA
MOVLW H'01'
MOVWF PORTA
BANKSEL SAYAC
MOVF SAYAC,0
CALL TABLO
MOVWF PORTD
MOVWF PORTD

CALL GECIK
BANKSEL SAYAC
INCF SAYAC,F
RETFIE
TABLO
	
	ADDWF PCL,F	
	NOP ; 9 DAN SONRA SIFIRLAYINCA 1 DEN DEVM ED�YO BUNU YAZMASAN
	RETLW b'00111111';0             
	RETLW b'00000110';1
	retlw b'01011011';2
	retlw b'01001111';3
	retlw b'01100110';4
	retlw b'01101101';5
	retlw b'01111101';6
	retlw b'00000111';7
	retlw b'01111111';8
		CLRF SAYAC ;9 DAN SONRA SIFIRLASIN D�YE
	retlw b'01100111';9

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
CLRF PORTA
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
MOVLW B'10010000'
MOVWF INTCON
BANKSEL SAYAC 
CLRF SAYAC
DONGU
GOTO DONGU
END
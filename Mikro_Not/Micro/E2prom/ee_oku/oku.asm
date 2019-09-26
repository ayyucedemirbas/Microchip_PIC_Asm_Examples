list P=16F877A
#include <p16f877a.inc>

SAYAC EQU 0X20
TEMP EQU 0X21
TEMP1 EQU 0X23
TEMP2 EQU 0X24
TEMP3 EQU 0X25
SAYAC2 EQU 0X22
org 0x00
GOTO ana_program
ORG 0x04
RETFIE
ana_program
	BSF STATUS,RP0
	CLRF TRISD
	CLRF TRISA
	BCF STATUS,RP0
	CLRF PORTA
	CLRF PORTD
	CLRF SAYAC
	CLRF TEMP
	CLRF TEMP1
	CLRF TEMP2
	CLRF TEMP3
	CLRF SAYAC2

	CALL OKU
	BANKSEL TEMP
	MOVWF TEMP
	CALL OKU
	BANKSEL TEMP1
	MOVWF TEMP1
	CALL OKU
	BANKSEL TEMP2
	MOVWF TEMP2
	CALL OKU
	BANKSEL TEMP3
	MOVWF TEMP3
	GOTO DISPYAZ
OKU
	INCF SAYAC,F
	MOVF SAYAC,W
	BANKSEL EEADR
	MOVWF EEADR
	BANKSEL EECON1
	BSF EECON1,RD
	BANKSEL SAYAC
	BTFSC SAYAC,2
	CLRF SAYAC
	BANKSEL EEDATA
	MOVF EEDATA,W
	RETURN

DISPYAZ	
	BCF STATUS,RP0
	MOVLW B'00000001'
	MOVWF PORTA
	MOVF TEMP,W
	CALL tablo
	MOVWF PORTD
	CALL GECIK
	
	MOVLW B'00000010'
	MOVWF PORTA
	MOVF TEMP1,W
    CALL tablo
	MOVWF PORTD
	CALL GECIK

	MOVLW B'00000100'
	MOVWF PORTA
	MOVF TEMP2,W
    CALL tablo
	MOVWF PORTD
	CALL GECIK

	MOVLW B'00001000'
	MOVWF PORTA
	MOVF TEMP3,W
	CALL tablo
	MOVWF PORTD
	CALL GECIK

	GOTO DISPYAZ
GECIK
	MOVLW D'250'
	MOVWF SAYAC2
DON1	
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ SAYAC2,F
	GOTO DON1
	MOVLW D'250'
	MOVWF SAYAC2
DON2
	NOP
	NOP
	NOP
	NOP
	NOP
	DECFSZ SAYAC2,F
	GOTO DON2
	RETURN
tablo
	addwf	PCL, F
	retlw	0x3F		; 0 rakam� i�in segment de�eri.
	retlw	0x06		; 1 rakam� i�in segment de�eri.
	retlw	0x5B		; 2 rakam� i�in segment de�eri.
	retlw	0x4F		; 3 rakam� i�in segment de�eri.
	retlw	0x66		; 4 rakam� i�in segment de�eri.
	retlw	0x6D		; 5 rakam� i�in segment de�eri.
	retlw	0x7D		; 6 rakam� i�in segment de�eri.
	retlw	0x07		; 7 rakam� i�in segment de�eri.
	retlw	0x7F		; 8 rakam� i�in segment de�eri.
	retlw	0x6F		; 9 rakam� i�in segment de�eri.
	END
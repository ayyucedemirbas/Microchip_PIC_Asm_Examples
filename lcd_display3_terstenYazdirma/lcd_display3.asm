	LIST P=16F877A
	#INCLUDE <P16F877A.INC>
	DEGER EQU 0X20
	DEGER2 EQU 0X21
	TEMP EQU 0X22
	ORG 0X00
	GOTO MAIN
MAIN
	BANKSEL TRISB
	CLRF TRISB
	BANKSEL PORTB
	CLRF PORTB
	CALL TEMIZLE
	CALL KARAKTER_GIR
LOOP
	GOTO LOOP



TEMIZLE
	MOVLW 0X02
	CALL KOMUT_YAZ

	MOVLW 0X28
	CALL KOMUT_YAZ

	MOVLW 0X0C
	CALL KOMUT_YAZ

	MOVLW 0X88
	CALL KOMUT_YAZ

	MOVLW 0X04
	CALL KOMUT_YAZ
	RETURN

KOMUT_YAZ
	MOVWF TEMP
	SWAPF TEMP,W
	CALL KOMUT_GONDER
	MOVF TEMP,W
	CALL KOMUT_GONDER
	RETURN


KOMUT_GONDER
	ANDLW 0X0F
	MOVWF PORTB
	BANKSEL PORTB
	BCF PORTB,4
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	RETURN


KARAKTER_GIR
	
	MOVLW 'Y'
	CALL KARAKTER_YAZ
	MOVLW 'U'
	CALL KARAKTER_YAZ
	MOVLW 'C'
	CALL KARAKTER_YAZ
	MOVLW 'E'
	CALL KARAKTER_YAZ
	MOVLW 'L'
	CALL KARAKTER_YAZ
	
	MOVLW 0X06
	CALL KOMUT_YAZ
	CALL SATIR2
	MOVLW 'A'
	CALL KARAKTER_YAZ
	MOVLW 'Y'
	CALL KARAKTER_YAZ
	RETURN
SATIR2
	MOVLW 0XC0
	CALL KOMUT_YAZ
	MOVLW 0X14
	CALL KOMUT_YAZ
	MOVLW 0X14
	CALL KOMUT_YAZ
	MOVLW 0X14
	CALL KOMUT_YAZ

	RETURN

KARAKTER_YAZ
	MOVWF TEMP
	SWAPF TEMP,W
	CALL KARAKTER_GONDER
	MOVF TEMP,W
	CALL KARAKTER_GONDER
	RETURN

KARAKTER_GONDER
	ANDLW 0X0F
	MOVWF PORTB
	BANKSEL PORTB
	BSF PORTB,4
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	RETURN



GECIKME 
	MOVLW 0XFF
	MOVWF DEGER
DONGU
	MOVLW 0XFF
	MOVWF DEGER2
DONGU2
	DECFSZ DEGER2,F
	GOTO DONGU2
	DECFSZ DEGER,F
	GOTO DONGU
	RETURN
END
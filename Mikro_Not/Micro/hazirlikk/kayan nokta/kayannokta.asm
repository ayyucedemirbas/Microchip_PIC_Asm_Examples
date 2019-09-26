list p=16F877A
INCLUDE<P16F877A.INC>
SONUC EQU 0X25
SAYAC1 EQU 0X26
SAYAC2 EQU 0X27

ORG 0X00
GOTO ANAPROGRAM

ANAPROGRAM
	BSF STATUS,RP0
	CLRF TRISB
	BCF STATUS,RP0
	MOVLW 0XFF
	MOVLW SAYAC1
	MOVLW 0XFF
	MOVLW SAYAC2

	MOVLW B'00000001'
	MOVWF SONUC
	MOVLW B'00000001'
	MOVWF PORTB

DONGU
	RLF SONUC,1
	MOVF SONUC,W
	MOVWF PORTB
	CALL GECIKME1
	CALL GECIKME1
	GOTO DONGU

GECIKME1
	DECFSZ SAYAC1,1
	GOTO GECIKME2
	RETURN	
GECIKME2
	DECFSZ SAYAC2,1
	GOTO GECIKME2
	GOTO GECIKME1	
END

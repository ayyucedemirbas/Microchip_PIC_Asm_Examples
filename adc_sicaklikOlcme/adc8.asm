	LIST P=16F877A
	#INCLUDE <P16F877A.INC>
	DEGER EQU 0X20
	DEGER2 EQU 0X21
	TEMP EQU 0X22
	BIRLER EQU 0X23
	ONLAR EQU 0X24
	YUZLER EQU 0X25
	OKUNAN_DEGER EQU 0X26
	ORG 0X00
	GOTO MAIN
MAIN
	BANKSEL TRISB
	CLRF TRISB
	CLRF TRISC	

	BANKSEL ADCON0
	MOVLW B'11000001'
	MOVWF ADCON0

	BANKSEL ADCON1
	MOVLW B'10001000'
	MOVWF ADCON1

	BANKSEL TRISA
	MOVLW 0XFF
	MOVWF TRISA

	BANKSEL PORTB
	CLRF PORTB
	CLRF PORTC
	CLRF PORTA

TEMIZLE
	MOVLW 0X02
	CALL KOMUT_YAZ
	MOVLW 0X0C
	CALL KOMUT_YAZ
	MOVLW 0X80
	CALL KOMUT_YAZ

DONUSTUR
	BANKSEL ADCON0
	BSF ADCON0,GO
	CALL GECIKME
KONTROL
	BTFSC ADCON0,GO
	GOTO KONTROL
	BANKSEL ADRESL
	MOVF ADRESL,W
	BCF STATUS,RP0
	MOVWF OKUNAN_DEGER
		
LOOP

	CALL OKU
	MOVLW 0X01
	CALL KOMUT_YAZ
	
	MOVLW A'S'
	CALL VERI_YAZ
	MOVLW A'I'
	CALL VERI_YAZ
	MOVLW A'C'
	CALL VERI_YAZ
	MOVLW A'A'
	CALL VERI_YAZ
	MOVLW A'K'
	CALL VERI_YAZ
	MOVLW A'L'
	CALL VERI_YAZ
	MOVLW A'I'
	CALL VERI_YAZ
	MOVLW A'K'
	CALL VERI_YAZ
	MOVLW A':'
	CALL VERI_YAZ
	MOVF YUZLER,W
	CALL VERI_YAZ
	MOVF ONLAR,W
	CALL VERI_YAZ
	MOVF BIRLER,W
	CALL VERI_YAZ
	MOVLW A' '
	CALL VERI_YAZ
	MOVLW 0XDF
	CALL VERI_YAZ
	MOVLW A'C'
	CALL VERI_YAZ
	CALL GECIKME2


	GOTO DONUSTUR


OKU
	CLRF YUZLER
	CLRF ONLAR
	CLRF BIRLER
	CLRF PORTB

	MOVF OKUNAN_DEGER,W
	BANKSEL PORTC
	MOVWF PORTC
	MOVWF OKUNAN_DEGER
	
	
YUZLER_ARTIR
	MOVLW D'100'
	SUBWF OKUNAN_DEGER,0
	BTFSS STATUS,C
	GOTO ONLAR_ARTIR
	MOVWF OKUNAN_DEGER
	INCF YUZLER,1
	GOTO YUZLER_ARTIR
ONLAR_ARTIR
	MOVLW D'10'
	SUBWF OKUNAN_DEGER,0
	BTFSS STATUS,C
	GOTO BIRLER_ARTIR
	MOVWF OKUNAN_DEGER
	INCF ONLAR,1
	GOTO ONLAR_ARTIR
BIRLER_ARTIR
	MOVF OKUNAN_DEGER,0
	MOVWF BIRLER
	
	MOVLW 0X30
	IORWF YUZLER,F
	IORWF ONLAR,F
	IORWF BIRLER,F
RETURN


KOMUT_YAZ
	MOVWF TEMP
	SWAPF TEMP,W
	CALL KOMUT_GONDER
	MOVF TEMP,W
	CALL KOMUT_GONDER
	RETURN

KOMUT_GONDER
	ANDWF 0X0F
	MOVWF PORTB
	BCF PORTB,4
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	RETURN

VERI_YAZ
	MOVWF TEMP
	SWAPF TEMP,W
	CALL VERI_GONDER
	MOVF TEMP,W
	CALL VERI_GONDER
	RETURN

VERI_GONDER
	ANDWF 0X0F
	MOVWF PORTB
	BSF PORTB,4
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	RETURN
	

GECIKME2
	MOVLW 0XFF
	MOVWF DEGER
	GOTO DON
GECIKME
	MOVLW 0X04
	MOVWF DEGER
DON
	MOVLW 0X8F
	MOVWF DEGER2
DON2
	DECFSZ DEGER2,1
	GOTO DON2
	DECFSZ DEGER,1
	GOTO DON
	RETURN
END
	
	LIST P=16F877
	INCLUDE "P16F877.INC"

		SAYAC_GECIK		EQU	H'0031'
		SAYAC_GECIK2	EQU	H'0033'
		LCD_DATA		EQU H'0037'
		
		ORG 0X00
	ANA_PROGRAM:
		BANKSEL TRISB	
		CLRF TRISB		
		BANKSEL PORTB
		CLRF PORTB			
		MOVLW	H'02'
		CALL KOMUT_YAZ
		MOVLW	H'0C'
		CALL	KOMUT_YAZ
	
		MOVLW	A'M'
		CALL	VERI_YAZ	
		MOVLW	A'E'
		CALL	VERI_YAZ
		MOVLW	A'S'
		CALL	VERI_YAZ
		MOVLW	A'U'
		CALL	VERI_YAZ
		MOVLW	A'T'
		CALL	VERI_YAZ
		goto $


	VERI_YAZ:					;LCD'ye karakter g�ndermek i�in 
		MOVWF LCD_DATA			;Komutu ge�ici de�i�kene al.
		SWAPF LCD_DATA, W		;En de�erli 4 bit�i g�nder.
		CALL LCD_VERI_GONDER
		MOVF LCD_DATA, W		;En de�ersiz 4 bit�i g�nder.
		CALL LCD_VERI_GONDER
		RETURN

	LCD_VERI_GONDER:                     
		ANDLW 0x0F				;En de�ersiz 4 bit W'de
		MOVWF PORTB 			;PortB'e transfer ediliyor.
		BANKSEL PORTB 			
		BSF PORTB,4				;Karakter Yaz�laca�� belirtiliyor
		BSF	PORTB,5 			;LCD'i�in 1 yap�l�r
		CALL GECIKME
		BCF	PORTB,5				;LCD i�in d��en kenar �retiyorz
		RETURN

	KOMUT_YAZ: 	         	
		MOVWF LCD_DATA		 	;Komutu ge�ici de�i�kene al.
		SWAPF LCD_DATA, W   	;En de�erli 4 bit�i g�nder.
		CALL LCD_KOMUT_GONDER
		MOVF LCD_DATA, W		;En de�ersiz 4 bit�i g�nder.
		CALL LCD_KOMUT_GONDER		
		RETURN

	LCD_KOMUT_GONDER:                     
		ANDLW	0x0F			;En de�ersiz 4 bit W'de,
		MOVWF PORTB 			;PortB'ye transfer ediliyor.
		BANKSEL PORTB 			
		BSF	PORTB,5				;Lcd ye d��en kenar �retmek i�in 
		CALL GECIKME
		BCF	PORTB,5				;LCD i�in d��en kenar �retiyorz
		RETURN

GECIKME
		MOVLW	H'FF'
		MOVWF	SAYAC_GECIK
DON1
		MOVLW	H'FF'
		MOVWF	SAYAC_GECIK2
DON2
		DECFSZ	SAYAC_GECIK2,F
		GOTO	DON2
		DECFSZ	SAYAC_GECIK,F
		GOTO	DON1
		RETURN
	
	END
	 

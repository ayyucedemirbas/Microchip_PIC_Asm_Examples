	list p=16F877A	 
	include "p16F877A.inc"

	LCDVERI EQU H'24'
	SAYAC1 EQU H'25'
	SAYAC2 EQU H'26'

	ORG 0X00
	GOTO ANAPROGRAM

	ORG 0X04
	GOTO KESME

KOMUTYAZ
	MOVWF LCDVERI
	SWAPF LCDVERI,W
	CALL KOMUTGONDER
	MOVF LCDVERI,W
	CALL KOMUTGONDER
	RETURN

KOMUTGONDER
	ANDLW H'0F'
	MOVWF PORTB
	BANKSEL PORTB 
	BCF PORTB,4
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	RETURN

KARAKTERYAZ
    
	MOVWF LCDVERI
	SWAPF LCDVERI,W
	CALL KARAKTERGONDER
	MOVF LCDVERI,W
	CALL KARAKTERGONDER
	RETURN

KARAKTERGONDER
	ANDLW H'0F'
	MOVWF PORTB
	BANKSEL PORTB 
	BSF PORTB,4
	BSF PORTB,5
	CALL GECIKME
	BCF PORTB,5
	RETURN

LCDHAZIRLA
	movlw   h'80'
	call    KOMUTYAZ
	MOVLW	H'02'    ;1.sat�r 1.s�tun
	CALL 	KOMUTYAZ
	MOVLW	H'0C'    ;1.sat�r 1.s�tun
	CALL 	KOMUTYAZ
	movlw   h'06'
	call    KOMUTYAZ
	MOVLW	H'0E'     
	CALL	KOMUTYAZ
	MOVLW	H'01'     ;temizler
	CALL	KOMUTYAZ
	MOVLW	H'28'      ;4 bitlik al�naca��n� belirtir
	CALL	KOMUTYAZ
	RETURN


ANAPROGRAM
	banksel TRISC
	movlw b'10000000'
	movwf TRISC
	banksel PIE1
	bsf PIE1,RCIE
	banksel TRISB
	clrf TRISB
	movlw b'11000000'
	movwf INTCON
	banksel TXSTA
	movlw b'00000010'
	movwf TXSTA
	banksel RCSTA
	movlw b'10011000'
	movwf RCSTA
	banksel RCREG
	clrf RCREG
	movlw d'12'
	banksel SPBRG
	movwf SPBRG
	BANKSEL PORTB
	CALL LCDHAZIRLA
	
DONGU 
	GOTO DONGU		
	
KESME
	banksel PIR1
	BTFSS PIR1,RCIF
	retfie
	bcf PIR1,RCIF
	banksel RCREG
	movf RCREG,0
	call KARAKTERYAZ
	retfie
	
GECIKME
	movlw H'FF'
	movwf SAYAC1

DON
	movlw H'FF'
	movwf SAYAC2

DON2
	DECFSZ SAYAC2,1
	GOTO DON2
	DECFSZ SAYAC1,1
	GOTO DON
	return	
	END
;*******************************************************************
;	Dosya Adý		: 9_1.asm
;	Programýn Amacý		:eeprom belleðe veri yazma
;	PIC DK2.1a 		: PORTC Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F39' 		;Tüm program sigortalarý kapalý, 
					;Osilatör XT ve 4Mhz
say	equ		0x20
dur	equ		0x24
	ORG 	0			;Reset vektör adresi.
	clrf 	PCLATH			;0. Program sayfasý seçildi.
	goto 	ana_program		;ana_programa'a git.
	
	ORG	4			;Kesme vektör adresi.
Kesmeler
	banksel PIR2
    btfsc PIR2,EEIF	
	bcf PIR2,EEIF								
	btfss INTCON,0
	goto bitir
	bcf INTCON, 0
	btfsc PORTB,4	
	goto bir111
	btfsc PORTB,5	
	goto iki222
	btfsc PORTB,6	
	goto uc333
	btfsc PORTB,7	
	goto dort444
bitir	
	bcf INTCON,0
	movlw D'4'
	subwf say,W
	btfsc STATUS,Z
	bcf INTCON,3
	bsf	INTCON,GIE
	bcf PIR2,EEIF
	retfie
bir111
	banksel EEADR
	incf EEADR,F		
	movlw	D'1'			
	movwf	EEDATA	
	call EEPROM_yaz
	banksel PORTC
	incf say,F
	rrf PORTC
    call bekle
	bcf INTCON,0
	goto bitir
iki222
   	banksel EEADR
	incf EEADR,F		
	movlw	D'2'			
	movwf	EEDATA	
	call EEPROM_yaz
	banksel PORTC
	incf say,F
	rrf PORTC
    call bekle
	bcf INTCON,0
	goto bitir
uc333
	banksel EEADR
	incf EEADR,F		
	movlw	D'3'			
	movwf	EEDATA	
	call EEPROM_yaz
	banksel PORTC
	incf say,F
	rrf PORTC
    call bekle
	bcf INTCON,0
	goto bitir
dort444
	banksel EEADR
	incf EEADR,F		
	movlw	D'4'			
	movwf	EEDATA	
	call EEPROM_yaz
	banksel PORTC
	incf say,F
	rrf PORTC
    call bekle
	bcf INTCON,0
	goto bitir
EEPROM_yaz
	banksel EECON1			;EECON1'in bulunduðu BANK seçildi.
    bcf	INTCON, GIE
	bsf	EECON1, WREN		;Yazma etkinleþtirme bit’i set edildi.
    movlw	0x55			;Yazma için buradan itibaren 5 satýr aynen korunmalý.
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR		;Yaz komutu verildi.
	goto ee_j1
ee_j1
	btfsc 	EECON1, WR		;Yazma iþlemi tamamlanana kadar bekle (WR=0 olana kadar).
	goto  ee_j1
	bcf 	EECON1, WREN	;Yazma izni kaldýrýldý.
	banksel PORTB
	return 
bekle
	nop
	nop
	decfsz dur,F
	goto bekle
	movlw D'250'
	movwf dur
	return
ana_program
	bsf STATUS,RP0
	clrf	TRISC
	movlw b'11110000'
	movwf TRISB	
	bcf PIE2,4
	movlw b'10000000'
	movwf OPTION_REG
	movlw b'11001000'
	movwf INTCON
	banksel PORTC
	movlw h'0F'
	movwf PORTC
	clrf say
    movlw	0x00			;Yazýlacak Dahili EEPROM adresi
	banksel EEADR			;EEADR kaydedicisi için BANK seçildi.
	movwf 	EEADR
	banksel PORTB
ana_j1
	goto	ana_j1			;Sistem kapatýlana yada resetlenenekadar boþ döngü.
	END
;*******************************************************************

;*******************************************************************
;	Dosya Ad�		: 6_7.asm
;	Program�n Amac�		: USART Mod�l� �le Asenkron Seri Veri
;				  �leti�imi.
;	PIC DK 2.1 		: PORTC<6:7> RS232 kablosuyla PC�ye
;				: XT ==> 20 Mhz
;******************************************************************* 
	list p=16F877A	 
	include "p16F877A.inc"	
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20 Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlar�
;-------------------------------------------------------------------
RS232_Data	equ	0x20
	org	0
	clrf	PCLATH
	goto	Ana_program
	org	4
;-------------------------------------------------------------------
; Kesme alt program�: Varsa istenen kesmelerin i�lenmesinde 
; kullan�labilir.
;-------------------------------------------------------------------
interrupt
	;Bu k�s�mda gerekirse usart mod�l�nden veri alma ya da 
	;g�nderme kesmeleri, A/D kesmesi, TRM0, TMR1, TMR2, CCP1IF, 
	;CCP2IF kesmeleri i�lenebilir. Kesmelerin i�lenmesindeki 
	;�ncelik s�ralar� belirlenebilir. �rne�imizde veri g�nderme 
	;ve almada kesme alt program�na girmeden yaln�zca kesme 
	;bayraklar� kontrol edilerek usart birimine ait asenkron veri 
	;ileti�imi ger�ekle�tirilmi�tir.
	retfie				;Kesmeden ��k��
;-------------------------------------------------------------------
; RS232 portunda 1 byte veri yazar. Yaz�lacak veri RS232_Data 
; de�i�kenine y�klenmelidir.
;-------------------------------------------------------------------
RS232_Karakter_Gonder
	banksel PIR1
	btfss	PIR1, TXIF
	goto	$ - 1			;Daha �nceden bir veri g�nderilmi� 
					;ise aktar�lana kadar bekle.
	bcf	PIR1, TXIF		;Veri g�nderme kesme bayra��n� sil.
	movf	RS232_Data, W	
	banksel TXREG
	movwf	TXREG			;RS232_Data de�i�kenindeki veriyi 
					;TXREG kaydedicisine y�kle. B�ylece 
					;veri ��k�� buffer'�na yaz�lm�� olur.	
	return				;Alt programdan ��k��.
;-------------------------------------------------------------------
; RS232 portundan 1 byte veri al�r.
;-------------------------------------------------------------------
RS232_Karakter_Al
	banksel PIR1
	btfss	PIR1, RCIF	;Bilgi al�nd� ise bir komut atla.
	goto	$ - 1		;Bir komut geriye gel.
	bcf	PIR1, RCIF	;Alma ger�ekle�ti kesme bayra��n� sil.
	movf	RCREG, W	;RCREG seri bilgi al�� buffer'�ndaki 
				;veriyi W'ye y�kle.
	return			;RS232_Karakter_Al alt program�ndan ��k��.
;-------------------------------------------------------------------
; Usart mod�l�n�n asenkron ileti�imi i�in ilk ayarlar� 
; ger�ekle�tirir.
;-------------------------------------------------------------------
RS232_ilk_islemler
	banksel TRISC		;BANK1 se�ildi. TRISC bu bankta
	bcf	TRISC, 6	;TX ��k��a
	bsf	TRISC, 7	;RX giri�e y�nlendirildi
	movlw	0x81		;SPBRG = 129 Fosc = 20 MHz'de 9600 baud 
				;h�z i�in.
	movwf	SPBRG
	movlw	0x26
	movwf	TXSTA		;USART mod: asenkron, high speed, 8 bit 
				;ileti�im, TXEN set edildi.
	movlw	0x90
	bcf	STATUS, RP0	;BANK0 se�ildi RCSTA i�in.
	movwf	RCSTA		;Seri port etkin, 8 bit veri al��, CREN 
				;set : s�rekli al��. 
	bsf	STATUS, RP0
	bsf	PIE1, TXIE	;TXIE set edildi.
	bsf	PIE1, RCIE	;RCIE set edildi.
	bsf	INTCON, PEIE	;�evresel kesmelere izin verildi.
	return			;RS232_ilk_islemler alt program�ndan ��k��
;-------------------------------------------------------------------
; Ana program: RS232 seri portttan ald��� verileri tekrar seri porta
; g�nderir.
;-------------------------------------------------------------------
Ana_program
	call	RS232_ilk_islemler	;RS232 ileti�imi i�in ilk i�lemler.
	bcf	INTCON, GIE		;Kesme alt program� kullan�lmad��� 
					;i�in GIE = 0 yap.
Ana_j1
	call	RS232_Karakter_Al	;RS232 portundan 1 byte veri al.
	movwf	RS232_Data		;Al�nan veriyi RS232_Data 
					;de�i�kenine aktar.
	call	RS232_Karakter_Gonder	;RS232'deki veriyi RS232 
					;portuna g�nder.
	goto	Ana_j1			;Ayn� i�lemleri tekrarla.
	END
;*******************************************************************

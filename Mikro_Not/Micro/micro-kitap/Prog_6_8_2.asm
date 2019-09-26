;*****************************************************************
;	Dosya Ad�		: 6_8_2.asm
;	Program�n Amac�		: USART Mod�l� �le Asenkron Seri Veri
;				  �leti�imi (PIC16F877A ile PIC 16F628A 
;				  kullan�larak)
;	Notlar 			: XT ==> 20 Mhz
;******************************************************************* 
	list p=16F628A		
	include "p16F628A.inc"	
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20 Mhz.
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar� yap�l�yor.
;-------------------------------------------------------------------
F877_Data	equ	0x20		;16F877A i�lemcisine g�nderilecek 
					;veri de�i�keni.

	org	0			;Reset vekt�r adresi.
	clrf	PCLATH			;0. program sayfas� se�ildi.
	goto	Ana_program		;Ana programa git.

	org	4			;Kesme alt program� buradan ba�lar.

;-------------------------------------------------------------------
; Kesme alt program�: Varsa istenen kesmelerin i�lenmesinde 
; kullan�labilir.
;-------------------------------------------------------------------
interrupt
	banksel PIR1
	btfss	PIR1, RCIF	;Veri al�nd� ise bir komut atla.
	goto	int_sonu
	btfsc	RCREG, 0	;S�ND�R bilgisi geldi ise bir komut atla.
	goto	LED_YAK
	bcf	PORTB, 7	;LED s�nd�r.
	goto	int_sonu
LED_YAK
	bsf	PORTB, 7	;LED yak.
int_sonu
	bcf	PIR1, RCIF	
	retfie			;Kesmeden ��k��.
;-------------------------------------------------------------------
; 16F877A k�sm�na usart mod�l� ile asenkron mod kullanarak 1 byte 
; veri yazar. Yaz�lacak veri F877_Data de�i�kenine y�klenmelidir.
;-------------------------------------------------------------------
Karakter_Gonder
	Banksel PIR1
	btfss	PIR1, TXIF
	goto	$ - 1			;Daha �nceden bir veri g�nderilmi� 
					;ise aktar�lana kadar bekle.
	bcf	PIR1, TXIF		;Veri g�nderme kesme bayra��n� sil.
	movf	F877_Data, W	
	banksel	TXREG
	movwf	TXREG			;F877_Data de�i�kenindeki veriyi TXREG 
					;kaydedicisine y�kle. B�ylece veri ��k�� 
					;buffer'�na yaz�lm�� olur.	
	return				;Karakter_Gonder alt program�ndan ��k��.
;-------------------------------------------------------------------
; Usart mod�l�n�n asenkron ileti�imi i�in ilk ayarlar� yapar.
;-------------------------------------------------------------------
RcTx_ilk_islemler
	Banksel TRISB			;BANK1 se�ildi. TRISC bu bankta.
	bcf	TRISB, 2		;TX ��k��a
	bsf	TRISB, 1		;RX giri�e y�nlendirildi
	movlw	0x81			;SPBRG = 129 Fosc = 20 MHz'de (9600 
					;baud h�z i�in).
	movwf	SPBRG
	movlw	0x26
	movwf	TXSTA			;USART mod: asenkron, high speed, 8 
					;bit ileti�im, TXEN set edildi.
	movlw	0x90
	bcf	STATUS, RP0		;BANK0 se�ildi RCSTA i�in.
	movwf	RCSTA			;Seri port etkin, 8 bit veri al��,
					;CREN set: s�rekli al��. 
	bsf	STATUS, RP0
	bcf	PIE1, TXIE		;TXIE set edildi.
	bsf	PIE1, RCIE		;RCIE set edildi.
	bsf	INTCON, PEIE		;�evresel kesmelere izin verildi.
	return				;Alt programdan ��k��.

;-------------------------------------------------------------------
; �lk i�lemleri ger�ekle�tirir. Port y�nlendirme, Kar��la�t�rma 
; i�levini kapatma gibi.
;-------------------------------------------------------------------
Ilk_islemler
	banksel TRISA		;BANK1'e ge�. TRISA ve TRISB bu bankta
	movlw	0x03		;RA0 ve RA1 giri�, di�erleri ��k�� yap�ld�
	movwf	TRISA
	bcf	TRISB, 7	;RB7 LED i�in ��k�� yap�ld�.
	banksel PORTB		;PORTB ve CMCON BANK0'da.
	clrf	PORTB		;�lk anda LED s�n�k.
	movlw	0x07		
	movwf	CMCON		;PORTA'n�n comparator i�levi kapat�ld�.
	return
;-------------------------------------------------------------------
; Ana program: 16F877A ve 16F628A i�lemcileri aras�nda usart mod�l� 
; ile asenkron veri ileti�imi ve buna ba�l� LED�lerin kontrol�n� 
; ger�ekle�tirir.
;-------------------------------------------------------------------
Ana_program
	call	Ilk_islemler		;Ana programa ait ilk i�lemler 
					;yap�l�yor.
	call	RcTx_ilk_islemler	;Seri ileti�im i�in ilk i�lemler.
	bsf	INTCON, GIE		;Genel kesme denetimini etkinle�tir

YAK_KONTROL
	banksel	PORTA
	btfsc	PORTA, 0		;YAK butonuna bas�ld� ise 16F877A
					;ya LED'i yak bilgisi g�nder.
	goto	SONDUR_KONTROL		;YAK butonuna Bas�lmad� ise S�ND�R 
					;butonunu kontrol et.
	movlw	0x01			;LED'i yak bilgisi y�kleniyor.
	movwf	F877_Data
	call	Karakter_Gonder		;16F877A'ya LED'i yakmas� i�in 
					;bilgi g�nder.
SONDUR_KONTROL
	banksel PORTA
	btfsc	PORTA, 1		;S�ND�R butonuna bas�ld� ise 
					;16F877A�ya LED'i s�nd�r bilgisi 
					;g�nder.
	goto	YAK_KONTROL		;YAK butonunu kontrol et.
	clrf	F877_Data
	call	Karakter_Gonder 	;LED�i s�nd�rmek i�in 0 bilgisi g�nder.
	goto	YAK_KONTROL	   	;YAK butonunu kontrol et.
	END
;*******************************************************************

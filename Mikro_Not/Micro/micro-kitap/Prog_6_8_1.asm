;*******************************************************************
;	Dosya Ad�		: 6_8_1.asm
;	Program�n Amac�		: USART Mod�l� �le Asenkron Seri Veri
;				  �leti�imi (PIC16F877A ile PIC 16F628A 
;				  kullan�larak).
;	Notlar 			: XT ==> 20 Mhz
;******************************************************************* 
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20 Mhz.
;-------------------------------------------------------------------
; Genel tan�mlar
;-------------------------------------------------------------------
F628_Data	equ	0x20		;16F628A'ya g�nderilecek veri 
					;de�i�keni tan�mland�.
	org	0		 
	clrf	PCLATH			;0. program sayfas� se�ildi.
	goto	Ana_program		;Ana programa git.
	org	4			;Kesme vekt�r adresi. Kesme alt program� 
					;buradan ba�lar.
;-------------------------------------------------------------------
; Kesme alt program�: Varsa istenen kesmelerin i�lenmesinde 
; kullan�labilir.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;PIR1'in bulundu�u bank se�ildi.
	btfss	PIR1, RCIF	;Veri al�nd� ise bir komut atla.
	goto	int_sonu	;Kesme program� sonuna git.
	btfsc	RCREG, 0	;S�ND�R bilgisi geldi ise bir komut atla.
	goto	LED_YAK
	bcf	PORTD, 7	;LED s�nd�r.
	goto	int_sonu
LED_YAK
	bsf	PORTD, 7	;LED yak.
int_sonu
	bcf	PIR1, RCIF	;RCIF seri ileti�im veri alma durumunu 
				;bildiren kesme bayra��
				;yeni veri al�mlar� i�in s�f�rlanmal�.
	retfie			;Kesmeden ��k��.
;-------------------------------------------------------------------
; 16F628A k�sm�na usart mod�l� ile  asenkron mod kullanarak 1 byte 
; veri yazar. Yaz�lacak veri F628_Data de�i�kenine y�klenmelidir.
;-------------------------------------------------------------------
Karakter_Gonder
	banksel PIR1		;PIR1'in bulundu�u banka ge�.
	btfss	PIR1, TXIF		
	goto	$ - 1		;Daha �nceden bir veri g�nderilmi� ise 
				;aktar�lana kadar bekle.
	bcf	PIR1, TXIF	;Veri g�nderme kesme bayra��n� sil.
	movf	F628_Data, W	
	banksel TXREG
	movwf	TXREG		;F628_Data de�i�kenindeki veriyi TXREG 
				;kaydedicisine y�kle.
				;B�ylece veri ��k�� buffer'�na yaz�lm�� olur	
	return			;Karakter_Gonder alt program�ndan ��k��.
;-------------------------------------------------------------------
; Usart mod�l�n�n asenkron ileti�imi i�in ilk ayarlar� 
; ger�ekle�tirir.
;-------------------------------------------------------------------
RcTx_ilk_islemler
	banksel TRISC		;BANK1 se�ildi. TRISC bu bankta.
	bcf	TRISC, 6	;TX ��k��a
	bsf	TRISC, 7	;RX giri�e y�nlendirildi.
	movlw	0x81		;SPBRG = 129 Fosc = 20 MHz'de (9600 baud 
				;h�z i�in).
	movwf	SPBRG
	movlw	0x26
	movwf	TXSTA		;USART mod: asenkron, high speed, 8 bit 
				;ileti�im, TXEN set edildi.
	movlw	0x90
	bcf	STATUS, RP0		;BANK0 se�ildi RCSTA i�in.
	movwf	RCSTA			;Seri port etkin, 8 bit veri al��, 
					;CREN set: s�rekli al��. 
	bsf	STATUS, RP0
	bcf	PIE1, TXIE		;TXIE set edildi.
	bsf	PIE1, RCIE		;RCIE set edildi.
	bsf	INTCON, PEIE		;�evresel kesmelere izin verildi.
	return				;Alt programdan geri d�n.
;-------------------------------------------------------------------
; �lk i�lemleri ger�ekle�tirir. Portlar y�nlendiriliyor..
;-------------------------------------------------------------------
Ilk_islemler
	banksel TRISB		;BANK1'e ge�. TRISB bu bankta.
	movlw	0x03
	movwf	TRISB		;RB0 ve RB1 butonlar i�in giri�e, 
				;di�erleri ��k��a y�nlendirildi.
	clrf	TRISD		;LED i�in PORTB ��k��a y�nlendirildi.
	banksel PORTD		;BANK0'a ge�. PORTD bu bankta.
	clrf	PORTD		;LED ilk durumda s�n�k.
	return			;Alt programdan geri d�n.
;-------------------------------------------------------------------
; Ana program: 16F877A ve 16F628A i�lemcileri aras�nda usart mod�l� 
; ile asenkron veri ileti�imi ve buna ba�l� LED�lerin kontrol�n� 
; ger�ekle�tirir.
;-------------------------------------------------------------------
Ana_program
	call	Ilk_islemler		;�lk i�lemler alt program� 
					;�a�r�l�yor.
	call	RcTx_ilk_islemler	;Seri ileti�im i�in ilk i�lemler.
	bsf	INTCON, GIE		;Kesme alt program� kullan�lmad��� 
					;i�in GIE = 0 yap.
YAK_KONTROL
	banksel	PORTB
	btfsc	PORTB, 0		;YAK butonuna bas�ld� ise 16F628'e 
					;LED'i yak bilgisi g�nder.
	goto	SONDUR_KONTROL		;YAK butonuna Bas�lmad� ise S�ND�R 
					;butonunu kontrol et.
	movlw	0x01			;LED�i yak bilgisi y�kleniyor.
	movwf	F628_Data
	call	Karakter_Gonder		;16F628A'ya LED'i yakmas� i�in 1 
					;bilgisi g�nder.
SONDUR_KONTROL
	btfsc	PORTB, 1		;S�ND�R butonuna bas�ld� ise 
					;16F628'e LED'i s�nd�r bilgisi 
					;g�nder.
	goto	YAK_KONTROL		;YAK butonunu kontrol et.
	clrf	F628_Data
	call	Karakter_Gonder		;LED'i s�nd�rmek i�in 0 bilgisi 
					;g�nder.
	goto	YAK_KONTROL		;YAK butonunu kontrol et.

	END
;*******************************************************************

;*****************************************************************
;	Dosya Adý		: 6_8_2.asm
;	Programýn Amacý		: USART Modülü Ýle Asenkron Seri Veri
;				  Ýletiþimi (PIC16F877A ile PIC 16F628A 
;				  kullanýlarak)
;	Notlar 			: XT ==> 20 Mhz
;******************************************************************* 
	list p=16F628A		
	include "p16F628A.inc"	
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20 Mhz.
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý yapýlýyor.
;-------------------------------------------------------------------
F877_Data	equ	0x20		;16F877A iþlemcisine gönderilecek 
					;veri deðiþkeni.

	org	0			;Reset vektör adresi.
	clrf	PCLATH			;0. program sayfasý seçildi.
	goto	Ana_program		;Ana programa git.

	org	4			;Kesme alt programý buradan baþlar.

;-------------------------------------------------------------------
; Kesme alt programý: Varsa istenen kesmelerin iþlenmesinde 
; kullanýlabilir.
;-------------------------------------------------------------------
interrupt
	banksel PIR1
	btfss	PIR1, RCIF	;Veri alýndý ise bir komut atla.
	goto	int_sonu
	btfsc	RCREG, 0	;SÖNDÜR bilgisi geldi ise bir komut atla.
	goto	LED_YAK
	bcf	PORTB, 7	;LED söndür.
	goto	int_sonu
LED_YAK
	bsf	PORTB, 7	;LED yak.
int_sonu
	bcf	PIR1, RCIF	
	retfie			;Kesmeden çýkýþ.
;-------------------------------------------------------------------
; 16F877A kýsmýna usart modülü ile asenkron mod kullanarak 1 byte 
; veri yazar. Yazýlacak veri F877_Data deðiþkenine yüklenmelidir.
;-------------------------------------------------------------------
Karakter_Gonder
	Banksel PIR1
	btfss	PIR1, TXIF
	goto	$ - 1			;Daha önceden bir veri gönderilmiþ 
					;ise aktarýlana kadar bekle.
	bcf	PIR1, TXIF		;Veri gönderme kesme bayraðýný sil.
	movf	F877_Data, W	
	banksel	TXREG
	movwf	TXREG			;F877_Data deðiþkenindeki veriyi TXREG 
					;kaydedicisine yükle. Böylece veri çýkýþ 
					;buffer'ýna yazýlmýþ olur.	
	return				;Karakter_Gonder alt programýndan çýkýþ.
;-------------------------------------------------------------------
; Usart modülünün asenkron iletiþimi için ilk ayarlarý yapar.
;-------------------------------------------------------------------
RcTx_ilk_islemler
	Banksel TRISB			;BANK1 seçildi. TRISC bu bankta.
	bcf	TRISB, 2		;TX çýkýþa
	bsf	TRISB, 1		;RX giriþe yönlendirildi
	movlw	0x81			;SPBRG = 129 Fosc = 20 MHz'de (9600 
					;baud hýz için).
	movwf	SPBRG
	movlw	0x26
	movwf	TXSTA			;USART mod: asenkron, high speed, 8 
					;bit iletiþim, TXEN set edildi.
	movlw	0x90
	bcf	STATUS, RP0		;BANK0 seçildi RCSTA için.
	movwf	RCSTA			;Seri port etkin, 8 bit veri alýþ,
					;CREN set: sürekli alýþ. 
	bsf	STATUS, RP0
	bcf	PIE1, TXIE		;TXIE set edildi.
	bsf	PIE1, RCIE		;RCIE set edildi.
	bsf	INTCON, PEIE		;Çevresel kesmelere izin verildi.
	return				;Alt programdan çýkýþ.

;-------------------------------------------------------------------
; Ýlk iþlemleri gerçekleþtirir. Port yönlendirme, Karþýlaþtýrma 
; iþlevini kapatma gibi.
;-------------------------------------------------------------------
Ilk_islemler
	banksel TRISA		;BANK1'e geç. TRISA ve TRISB bu bankta
	movlw	0x03		;RA0 ve RA1 giriþ, diðerleri çýkýþ yapýldý
	movwf	TRISA
	bcf	TRISB, 7	;RB7 LED için çýkýþ yapýldý.
	banksel PORTB		;PORTB ve CMCON BANK0'da.
	clrf	PORTB		;Ýlk anda LED sönük.
	movlw	0x07		
	movwf	CMCON		;PORTA'nýn comparator iþlevi kapatýldý.
	return
;-------------------------------------------------------------------
; Ana program: 16F877A ve 16F628A iþlemcileri arasýnda usart modülü 
; ile asenkron veri iletiþimi ve buna baðlý LED’lerin kontrolünü 
; gerçekleþtirir.
;-------------------------------------------------------------------
Ana_program
	call	Ilk_islemler		;Ana programa ait ilk iþlemler 
					;yapýlýyor.
	call	RcTx_ilk_islemler	;Seri iletiþim için ilk iþlemler.
	bsf	INTCON, GIE		;Genel kesme denetimini etkinleþtir

YAK_KONTROL
	banksel	PORTA
	btfsc	PORTA, 0		;YAK butonuna basýldý ise 16F877A
					;ya LED'i yak bilgisi gönder.
	goto	SONDUR_KONTROL		;YAK butonuna Basýlmadý ise SÖNDÜR 
					;butonunu kontrol et.
	movlw	0x01			;LED'i yak bilgisi yükleniyor.
	movwf	F877_Data
	call	Karakter_Gonder		;16F877A'ya LED'i yakmasý için 
					;bilgi gönder.
SONDUR_KONTROL
	banksel PORTA
	btfsc	PORTA, 1		;SÖNDÜR butonuna basýldý ise 
					;16F877A’ya LED'i söndür bilgisi 
					;gönder.
	goto	YAK_KONTROL		;YAK butonunu kontrol et.
	clrf	F877_Data
	call	Karakter_Gonder 	;LED’i söndürmek için 0 bilgisi gönder.
	goto	YAK_KONTROL	   	;YAK butonunu kontrol et.
	END
;*******************************************************************

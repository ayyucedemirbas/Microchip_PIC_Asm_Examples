;*******************************************************************
;	Dosya Adý		: 6_8_1.asm
;	Programýn Amacý		: USART Modülü Ýle Asenkron Seri Veri
;				  Ýletiþimi (PIC16F877A ile PIC 16F628A 
;				  kullanýlarak).
;	Notlar 			: XT ==> 20 Mhz
;******************************************************************* 
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20 Mhz.
;-------------------------------------------------------------------
; Genel tanýmlar
;-------------------------------------------------------------------
F628_Data	equ	0x20		;16F628A'ya gönderilecek veri 
					;deðiþkeni tanýmlandý.
	org	0		 
	clrf	PCLATH			;0. program sayfasý seçildi.
	goto	Ana_program		;Ana programa git.
	org	4			;Kesme vektör adresi. Kesme alt programý 
					;buradan baþlar.
;-------------------------------------------------------------------
; Kesme alt programý: Varsa istenen kesmelerin iþlenmesinde 
; kullanýlabilir.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;PIR1'in bulunduðu bank seçildi.
	btfss	PIR1, RCIF	;Veri alýndý ise bir komut atla.
	goto	int_sonu	;Kesme programý sonuna git.
	btfsc	RCREG, 0	;SÖNDÜR bilgisi geldi ise bir komut atla.
	goto	LED_YAK
	bcf	PORTD, 7	;LED söndür.
	goto	int_sonu
LED_YAK
	bsf	PORTD, 7	;LED yak.
int_sonu
	bcf	PIR1, RCIF	;RCIF seri iletiþim veri alma durumunu 
				;bildiren kesme bayraðý
				;yeni veri alýmlarý için sýfýrlanmalý.
	retfie			;Kesmeden çýkýþ.
;-------------------------------------------------------------------
; 16F628A kýsmýna usart modülü ile  asenkron mod kullanarak 1 byte 
; veri yazar. Yazýlacak veri F628_Data deðiþkenine yüklenmelidir.
;-------------------------------------------------------------------
Karakter_Gonder
	banksel PIR1		;PIR1'in bulunduðu banka geç.
	btfss	PIR1, TXIF		
	goto	$ - 1		;Daha önceden bir veri gönderilmiþ ise 
				;aktarýlana kadar bekle.
	bcf	PIR1, TXIF	;Veri gönderme kesme bayraðýný sil.
	movf	F628_Data, W	
	banksel TXREG
	movwf	TXREG		;F628_Data deðiþkenindeki veriyi TXREG 
				;kaydedicisine yükle.
				;Böylece veri çýkýþ buffer'ýna yazýlmýþ olur	
	return			;Karakter_Gonder alt programýndan çýkýþ.
;-------------------------------------------------------------------
; Usart modülünün asenkron iletiþimi için ilk ayarlarý 
; gerçekleþtirir.
;-------------------------------------------------------------------
RcTx_ilk_islemler
	banksel TRISC		;BANK1 seçildi. TRISC bu bankta.
	bcf	TRISC, 6	;TX çýkýþa
	bsf	TRISC, 7	;RX giriþe yönlendirildi.
	movlw	0x81		;SPBRG = 129 Fosc = 20 MHz'de (9600 baud 
				;hýz için).
	movwf	SPBRG
	movlw	0x26
	movwf	TXSTA		;USART mod: asenkron, high speed, 8 bit 
				;iletiþim, TXEN set edildi.
	movlw	0x90
	bcf	STATUS, RP0		;BANK0 seçildi RCSTA için.
	movwf	RCSTA			;Seri port etkin, 8 bit veri alýþ, 
					;CREN set: sürekli alýþ. 
	bsf	STATUS, RP0
	bcf	PIE1, TXIE		;TXIE set edildi.
	bsf	PIE1, RCIE		;RCIE set edildi.
	bsf	INTCON, PEIE		;Çevresel kesmelere izin verildi.
	return				;Alt programdan geri dön.
;-------------------------------------------------------------------
; Ýlk iþlemleri gerçekleþtirir. Portlar yönlendiriliyor..
;-------------------------------------------------------------------
Ilk_islemler
	banksel TRISB		;BANK1'e geç. TRISB bu bankta.
	movlw	0x03
	movwf	TRISB		;RB0 ve RB1 butonlar için giriþe, 
				;diðerleri çýkýþa yönlendirildi.
	clrf	TRISD		;LED için PORTB çýkýþa yönlendirildi.
	banksel PORTD		;BANK0'a geç. PORTD bu bankta.
	clrf	PORTD		;LED ilk durumda sönük.
	return			;Alt programdan geri dön.
;-------------------------------------------------------------------
; Ana program: 16F877A ve 16F628A iþlemcileri arasýnda usart modülü 
; ile asenkron veri iletiþimi ve buna baðlý LED’lerin kontrolünü 
; gerçekleþtirir.
;-------------------------------------------------------------------
Ana_program
	call	Ilk_islemler		;Ýlk iþlemler alt programý 
					;çaðrýlýyor.
	call	RcTx_ilk_islemler	;Seri iletiþim için ilk iþlemler.
	bsf	INTCON, GIE		;Kesme alt programý kullanýlmadýðý 
					;için GIE = 0 yap.
YAK_KONTROL
	banksel	PORTB
	btfsc	PORTB, 0		;YAK butonuna basýldý ise 16F628'e 
					;LED'i yak bilgisi gönder.
	goto	SONDUR_KONTROL		;YAK butonuna Basýlmadý ise SÖNDÜR 
					;butonunu kontrol et.
	movlw	0x01			;LED’i yak bilgisi yükleniyor.
	movwf	F628_Data
	call	Karakter_Gonder		;16F628A'ya LED'i yakmasý için 1 
					;bilgisi gönder.
SONDUR_KONTROL
	btfsc	PORTB, 1		;SÖNDÜR butonuna basýldý ise 
					;16F628'e LED'i söndür bilgisi 
					;gönder.
	goto	YAK_KONTROL		;YAK butonunu kontrol et.
	clrf	F628_Data
	call	Karakter_Gonder		;LED'i söndürmek için 0 bilgisi 
					;gönder.
	goto	YAK_KONTROL		;YAK butonunu kontrol et.

	END
;*******************************************************************

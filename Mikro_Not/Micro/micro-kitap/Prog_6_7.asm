;*******************************************************************
;	Dosya Adý		: 6_7.asm
;	Programýn Amacý		: USART Modülü Ýle Asenkron Seri Veri
;				  Ýletiþimi.
;	PIC DK 2.1 		: PORTC<6:7> RS232 kablosuyla PC’ye
;				: XT ==> 20 Mhz
;******************************************************************* 
	list p=16F877A	 
	include "p16F877A.inc"	
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20 Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlarý
;-------------------------------------------------------------------
RS232_Data	equ	0x20
	org	0
	clrf	PCLATH
	goto	Ana_program
	org	4
;-------------------------------------------------------------------
; Kesme alt programý: Varsa istenen kesmelerin iþlenmesinde 
; kullanýlabilir.
;-------------------------------------------------------------------
interrupt
	;Bu kýsýmda gerekirse usart modülünden veri alma ya da 
	;gönderme kesmeleri, A/D kesmesi, TRM0, TMR1, TMR2, CCP1IF, 
	;CCP2IF kesmeleri iþlenebilir. Kesmelerin iþlenmesindeki 
	;öncelik sýralarý belirlenebilir. Örneðimizde veri gönderme 
	;ve almada kesme alt programýna girmeden yalnýzca kesme 
	;bayraklarý kontrol edilerek usart birimine ait asenkron veri 
	;iletiþimi gerçekleþtirilmiþtir.
	retfie				;Kesmeden çýkýþ
;-------------------------------------------------------------------
; RS232 portunda 1 byte veri yazar. Yazýlacak veri RS232_Data 
; deðiþkenine yüklenmelidir.
;-------------------------------------------------------------------
RS232_Karakter_Gonder
	banksel PIR1
	btfss	PIR1, TXIF
	goto	$ - 1			;Daha önceden bir veri gönderilmiþ 
					;ise aktarýlana kadar bekle.
	bcf	PIR1, TXIF		;Veri gönderme kesme bayraðýný sil.
	movf	RS232_Data, W	
	banksel TXREG
	movwf	TXREG			;RS232_Data deðiþkenindeki veriyi 
					;TXREG kaydedicisine yükle. Böylece 
					;veri çýkýþ buffer'ýna yazýlmýþ olur.	
	return				;Alt programdan çýkýþ.
;-------------------------------------------------------------------
; RS232 portundan 1 byte veri alýr.
;-------------------------------------------------------------------
RS232_Karakter_Al
	banksel PIR1
	btfss	PIR1, RCIF	;Bilgi alýndý ise bir komut atla.
	goto	$ - 1		;Bir komut geriye gel.
	bcf	PIR1, RCIF	;Alma gerçekleþti kesme bayraðýný sil.
	movf	RCREG, W	;RCREG seri bilgi alýþ buffer'ýndaki 
				;veriyi W'ye yükle.
	return			;RS232_Karakter_Al alt programýndan çýkýþ.
;-------------------------------------------------------------------
; Usart modülünün asenkron iletiþimi için ilk ayarlarý 
; gerçekleþtirir.
;-------------------------------------------------------------------
RS232_ilk_islemler
	banksel TRISC		;BANK1 seçildi. TRISC bu bankta
	bcf	TRISC, 6	;TX çýkýþa
	bsf	TRISC, 7	;RX giriþe yönlendirildi
	movlw	0x81		;SPBRG = 129 Fosc = 20 MHz'de 9600 baud 
				;hýz için.
	movwf	SPBRG
	movlw	0x26
	movwf	TXSTA		;USART mod: asenkron, high speed, 8 bit 
				;iletiþim, TXEN set edildi.
	movlw	0x90
	bcf	STATUS, RP0	;BANK0 seçildi RCSTA için.
	movwf	RCSTA		;Seri port etkin, 8 bit veri alýþ, CREN 
				;set : sürekli alýþ. 
	bsf	STATUS, RP0
	bsf	PIE1, TXIE	;TXIE set edildi.
	bsf	PIE1, RCIE	;RCIE set edildi.
	bsf	INTCON, PEIE	;Çevresel kesmelere izin verildi.
	return			;RS232_ilk_islemler alt programýndan çýkýþ
;-------------------------------------------------------------------
; Ana program: RS232 seri portttan aldýðý verileri tekrar seri porta
; gönderir.
;-------------------------------------------------------------------
Ana_program
	call	RS232_ilk_islemler	;RS232 iletiþimi için ilk iþlemler.
	bcf	INTCON, GIE		;Kesme alt programý kullanýlmadýðý 
					;için GIE = 0 yap.
Ana_j1
	call	RS232_Karakter_Al	;RS232 portundan 1 byte veri al.
	movwf	RS232_Data		;Alýnan veriyi RS232_Data 
					;deðiþkenine aktar.
	call	RS232_Karakter_Gonder	;RS232'deki veriyi RS232 
					;portuna gönder.
	goto	Ana_j1			;Ayný iþlemleri tekrarla.
	END
;*******************************************************************

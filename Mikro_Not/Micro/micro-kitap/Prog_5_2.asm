;*******************************************************************
;	Dosya Adý		: 5_2.asm
;	Programýn Amacý		: CCP1 compare modunun kullanýlmasý.
;	Notlar 			: PORTB<0> Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, diðerleri kapalý. 
	ORG 	0 
	pagesel Ana_program		;Ana programýn bulunduðu program 
					;sayfasý seçildi.
	goto 	Ana_program
	ORG 	4
;-------------------------------------------------------------------
; Kesme alt programý CCP1IF kesmesini iþleyerek RB0'a baðlý LED
; üzerinde durumun gözlenmesini saðlar.
;-------------------------------------------------------------------
interrupt
	pagesel	0		;0. program sayfasý seçildi.
	banksel	PIR1		;BANK0 seçildi. PIR1 bu bankta.
	btfss	PIR1, 2		;CCP1IF set ise bir komut atla.
	goto	Kesme_sonu	;Kesme sonuna git.
	bcf	PIR1, 2		;CCP1IF kesme bayraðýný sil.
	btfss	PORTB, 0	;LED yanýyormu? evet ise 1 komut atla
	goto	Led_yak		;LED'i yakma kýsmýna git.
	bcf	PORTB, 0	;LED'i söndür.
	goto	Kesme_sonu	;Kesme sonuna git.
Led_yak
	bsf	PORTB, 0	;LED'i yak.
Kesme_sonu
	retfie			;Kesmeden çýkýþ.

;-------------------------------------------------------------------
; Compare alt programý: Timer1'i 1:8 prescaler deðerde RC0'dan gelen 
; senkronizeli yükselen kenar tetiklemesinde artacak þekilde 
; ayarlýyor. Ayrýca CCP1 modülünü özel olay tetiklemeli compare moda 
; ayarlýyor.
;-------------------------------------------------------------------
Compare_Ilk_Islemler
	Banksel T1CON		;BANK0 seçildi T1CON bu bankta.
	bcf	T1CON, 0	;Timer1 modülü ilk anda kapalý tutuluyor.
	clrf	TMR1L		;Timer1'in düþük byte'ý sýfýrlandý.
	clrf	TMR1H		;Timer1'in yüksek byte'ý sýfýrlandý.
	movlw	0x33		;TMR1 1:8 prescaler deðere ve 
				;RC0/T1OSO/T1CKI giriþinden 
	movwf 	T1CON		;gelen yükselen 8.darbe kenarýnda artacak 
				;þekilde ayarlandý.
	bcf 	T1CON, 2	;Senkronize external clock giriþi seçildi.
	bcf	T1CON, 3	;Osilatör kapatýldý (extenal clock 
				;seçildiði için).
	clrf	CCPR1H
	movlw	0x04
	movwf	CCPR1L		;Karþýlaþtýrma deðeri yükleniyor. 
				;Gözlemlemede kolaylýk için 
				;küçük deðer seçildi.
	movlw	0x0B		;Karþýlaþtýrma sonucu eþit ise yazýlým 
				;kesmesi oluþtur. (CCP1IF set)
	movwf	CCP1CON		;Ayrýca Timer1 resetlenir. Özel olay 
				;tetiklemeli mod.
	bsf	STATUS, RP0	;BANK1 seçildi.
	bsf	PIE1, 2		;CCP1 modülü kesmesi CCP1IE set edildi.
	return
;-------------------------------------------------------------------
; Ýlk iþlemler alt programý: PORTB'nin çýkýþa yönlendirilmesinde 
; kullanýlýyor.
;-------------------------------------------------------------------
Ilk_islemler
	banksel TRISB		;BANK1 seçildi.
	clrf	TRISB		;PORTB çýkýþa yönlendirildi.
	bcf	STATUS, RP0	;BANK0 seçildi.
	clrf 	PORTB		;Ýlk durumda LED sönük.
	return
;-------------------------------------------------------------------
; Ana program bloðu: Ýlk iþlemler için alt programlarý çaðýrma ve 
; sonsuz boþ döngüden oluþuyor.
;-------------------------------------------------------------------
Ana_program
	call	Ilk_islemler		;Ýlk iþlemler alt programý 
					;çaðrýlýyor.
	call	Compare_Ilk_Islemler	;Compare ile ilgili ilk 
					;iþlemler gerçekleþtiriliyor
	bsf	INTCON, PEIE		;PEIE set edildi, Çevresel birim 
					;kesmeleri aktif.
	bsf	INTCON, GIE		;Etkinleþtirilen kesmelere genel 
					;izin verildi.
	bcf	STATUS, RP0		;BANK0 seçildi.
	bsf	T1CON, 0		;Timer1 modülü çalýþmaya baþladý.
Ana_j1
	goto	Ana_j1			;Sistem kapatýlana kadar ya da 
					;resetlenene kadar boþ döngü.
	END				;Program sonu.
;*******************************************************************

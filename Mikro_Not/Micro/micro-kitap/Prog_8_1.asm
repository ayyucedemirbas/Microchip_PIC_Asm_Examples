;*******************************************************************
;	Dosya Adý		: 8_1.asm
;	Programýn Amacý		: Komparatör modülünün iki baðýmsýz 
;                       	karþýlaþtýrýcý olarak kullanýlmasý
;	PIC DK2.1a 		: PORTB<0:1> Çýkýþ ==> LED
;				: A/D anahtarý RA1, RA2 ve RA3 A konumunda
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F31'		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Program baþlangýç adresi belirleniyor.
;-------------------------------------------------------------------
	ORG 	0			
	goto 	ana_program		
	ORG 	4			;Kesme alt programý bu adresten 
					;baþlýyor.
	goto	kesme
;-------------------------------------------------------------------
; Kesme programý karþýlaþtýrýcý çýkýþlarýndaki deðiþimlerde 
; çalýþýyor ve karþýlaþtýrýcý çýkýþlarýný kontrol ederek ilgili 
; LED’leri yakýyor yada söndürüyor.
;-------------------------------------------------------------------
kesme
	btfss	PIR1, CMIF		;Kesme kaynaðý karþýlaþtýrýcý 
					;çýkýþlarýndan kaynaklanýyorsa bir 
					;komut atla,
	goto	kesme_sonu		;deðilse kesmeden çýk.
	btfss	CMCON, C1OUT		;1. karþýlaþtýrýcý çýkýþý set ise 
					;komut atla ve LED’i söndür.
	goto	kesme_1			;1. karþýlaþtýrýcý çýkýþý 0 
					;olduðundan LED yakma kýsmýna git.
	bcf	PORTB, 0		;RB0'a baðlý LED’i söndür.
	goto	kesme_2
kesme_1
	bsf	PORTB, 0		;RB0'a baðlý LED’i yak.
kesme_2
	btfss	CMCON, C2OUT		;2. karþýlaþtýrýcý çýkýþý set ise 
					;komut atla ve LED’i söndür.
	goto	kesme_3			;2. karþýlaþtýrýcý çýkýþý 0 
					;olduðundan LED yakma kýsmýna git.
	bcf	PORTB, 1		;RB1'a baðlý LED’i söndür.
	goto	kesme_4
kesme_3
	bsf	PORTB, 1		;RB1'a baðlý LED’i yak.
kesme_4
	bcf	PIR1, CMIF		;Karþýlaþtýrýcý kesme bayraðýný 
					;yeni kesmeler için sil.
kesme_sonu	
	retfie				;Kesme alt programýndan çýkýþ.
;-------------------------------------------------------------------
; Ana program port yönlendirmeleri ve karþýlaþtýrýcý mod ayarlarýný 
; yaptýktan sonra sonsuz döngüye giriyor. Bu durumda sadece kesme 
; oluþtuðunda ana programdan kesme alt programýna gidiliyor.
;-------------------------------------------------------------------
ana_program
	banksel TRISB			;TRISB'nin bulunduðu banka geç, 
					;PIE de bu bankta.
	clrf	TRISB			;PORTB'yi çýkýþa yönlendir.
	bsf	PIE1, CMIE		;Karþýlaþtýrýcý kesmelerine izin 
					;ver.
	banksel PORTB			;Bank0' a geç.
	clrf	PORTB			;LED’ler ilk durumda sönük.
	movlw	0x04			;Karþýlaþtýrýcý çýkýþlarý normal, 
					;iki baðýmsýz karþýlaþtýrýcý modu 
					;seçildi.
	movwf	CMCON			;ve CMCON karþýlaþtýrýcý kontrol 
					;kaydedicisine yüklendi.
	bsf	INTCON, PEIE		;Çevresel kesmeler etkinleþtirildi.
	bsf	INTCON, GIE		;Etkinleþtirilen kesmelere izin 
					;verildi.
bekle
	goto	bekle			;Boþ döngü, karþýlaþtýrýcý 
					;çýkýþlarý deðiþtikçe kesme oluþur.
	end
;*******************************************************************

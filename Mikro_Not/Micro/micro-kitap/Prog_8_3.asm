;*******************************************************************
;	Dosya Adý		: 8_3.asm
;	Programýn Amacý		: Komparatörün ortak referanslý PORTA 
;                     		çýkýþlý iki karþýlaþtýrýcý olarak kullanýlmasý
;	PIC DK2.1a 		: PORTA<3:4> Çýkýþ ==> LED
;				: A/D seçim anahtarý RA1, RA2 ve RA3
;				  A konumunda.
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A			
	include "p16F877A.inc"	
	__config H'3F31'		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
;Program baþlangýç adresi belirleniyor.
;-------------------------------------------------------------------
	ORG 	0			
	goto 	ana_program
;-------------------------------------------------------------------
; Ana program port yönlendirmeleri ve karþýlaþtýrýcý mod ayarlarýný 
; yaptýktan sonra sonsuz döngüye giriyor. Bu durumda sadece kesme 
; oluþtuðunda ana programdan kesme alt programýna gidiliyor.
;-------------------------------------------------------------------
ana_program
	banksel TRISA			;TRISA'nin bulunduðu banka geç.
	clrf	TRISA			;Karþýlaþtýrýcý çýkýþlarý için 
					;çýkýþa yönlendiriliyor.
	banksel PORTA			;Bank0'a geç.
	clrf	PORTA			;LED’ler ilk durumda sönük.
	movlw	0x06			;Karþýlaþtýrýcý çýkýþlarý normal, 
					;iki baðýmsýz karþýlaþtýrýcý modu 
					;seçildi.
	movwf	CMCON			;ve CMCON karþýlaþtýrýcý kontrol 
					;kaydedicisine yüklendi.
bekle
	goto	bekle			;Boþ döngü, Karþýlaþtýrýcý 
					;çýkýþlarý deðiþtikçe RA3 ve RA4'e 
					;baðlý LED'ler üzerinde görünür
	end
;*******************************************************************

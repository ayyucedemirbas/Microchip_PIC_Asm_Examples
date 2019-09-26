;*******************************************************************
;	Dosya Adý		: 8_2.asm
;	Programýn Amacý		: Komparatör modülünün dahili ortak 
;				referanslý 4 giriþten seçimli iki 
;				karþýlaþtýrýcý modunda kullanýlmasý.
;	PIC DK2.1a 		: PORTB<0:3> Çýkýþ ==> LED
;				: A/D anahtarý RA1, RA2 ve RA3 A konumunda
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
	ORG 	4			;Kesme alt programý bu adresten 
					;baþlýyor.
	goto	kesme			;kesme alt programýna git.
;-------------------------------------------------------------------
; Kesme programý karþýlaþtýrýcý çýkýþlarýndaki deðiþimlerde 
; çalýþýyor ve karþýlaþtýrýcý çýkýþlarýný 
; kontrol ederek ilgili LED’leri yakýyor yada söndürüyor.
;-------------------------------------------------------------------
kesme
	btfss	PIR1, CMIF		;Kesme kaynaðý karþýlaþtýrýcý 
					;çýkýþlarýndan kaynaklanýyorsa bir 
					;komut atla.
	goto	kesme_sonu		;deðilse kesmeden çýk.
	
	btfsc	CMCON, CIS		;RA0 ve RA1 giriþleri 
					;karþýlaþtýrýcý için seçildiyse 
					;komut atla.
	goto	kesme_5			;RA3 ve RA2 giriþleri
					;karþýlaþtýrýcý için seçildiyse 
					;kesme_5 etiketine git.
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
					;yeni kesmeler için sil,
	goto	kesme_sonu		;deðilse kesmeden çýk.	
kesme_5
	btfss	CMCON, C1OUT		;1. karþýlaþtýrýcý çýkýþý set ise 
					;komut atla ve LED’i söndür.
	goto	kesme_6			;1. karþýlaþtýrýcý çýkýþý 0 
					;olduðundan LED yakma kýsmýna git.
	bcf	PORTB, 3		;RB3'a baðlý LED’i söndür.
	goto	kesme_7
kesme_6
	bsf	PORTB, 3		;RB3'a baðlý LED’i yak.
kesme_7
	btfss	CMCON, C2OUT		;2. karþýlaþtýrýcý çýkýþý set ise 
					;komut atla ve LED’i söndür.
	goto	kesme_8			;2. karþýlaþtýrýcý çýkýþý 0 
					;olduðundan LED yakma kýsmýna git.
	bcf	PORTB, 2		;RB2'a baðlý LED’i söndür.
	goto	kesme_9
kesme_8
	bsf	PORTB, 2		;RB2'a baðlý LED’i yak.
kesme_9
	bcf	PIR1, CMIF		;Karþýlaþtýrýcý kesme bayraðýný 
					;yeni kesmeler için sil.
kesme_sonu	
	retfie				;Kesme alt programýndan çýkýþ.
;-------------------------------------------------------------------
; Ana program port yönlendirmeleri ve karþýlaþtýrýcý mod ayarlarýný 
; yaptýktan sonra karþýlaþtýrýcý giriþleri sürekli deðiþtirilerek 
; kesme oluþtuðunda giriþler ve karþýlaþtýrma sonuçlarý 
; deðerlendirilerek sonuçlar PORTB üzerindeki LED'lerde 
; görüntülenmektedir.Bu durum sistem kapatýlana dek devam eder.
;-------------------------------------------------------------------
ana_program
	banksel TRISB			;TRISB'nin bulunduðu banka geç, 
					;PIE de bu bankta.
	clrf	TRISB			;PORTB'yi çýkýþa yönlendir.
	bsf	PIE1, CMIE		;Karþýlaþtýrýcý kesmelerine izin 
					;ver.
	banksel PORTB			;Bank0’a geç.
	clrf	PORTB			;LED’ler ilk durumda sönük.
	movlw	0x02			;Dahili ortak referanslý 4 giriþten 
					;seçimli iki karþýlaþtýrýcý mod 
					;seçildi
	movwf	CMCON			;ve CMCON karþýlaþtýrýcý kontrol 
					;kaydedicisine yüklendi.
	movlw	0xA5			;0’dan 0.75 CVRSRC  ile CVRSRC/24 
					;adým aralýðý yani, referans 
					;gerilimi seçildi.
	banksel CVRCON			;Bank1 seçildi. CVRCON bu bankta.
	movwf	CVRCON			;CVRCON'a seçilen durum yüklendi ve 
					;VREF açýldý.
	banksel CMCON			;Bank0 seçildi.
	bsf	INTCON, PEIE		;Çevresel kesmeler etkinleþtirildi.
	bsf	INTCON, GIE		;Etkinleþtirilen kesmelere izin 
					;verildi.
ana_dongu
	bcf	CMCON, CIS		;Karþýlaþtýrýcý giriþleri için RA0 
					;ve RA1 seçildi.
	nop				;Karþýlaþtýrýcý giriþ deðiþimi için 
					;kýsa bir süre bekle.
	bsf	CMCON, CIS
goto	ana_dongu

	end
;*******************************************************************

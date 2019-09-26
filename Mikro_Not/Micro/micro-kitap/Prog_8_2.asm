;*******************************************************************
;	Dosya Ad�		: 8_2.asm
;	Program�n Amac�		: Komparat�r mod�l�n�n dahili ortak 
;				referansl� 4 giri�ten se�imli iki 
;				kar��la�t�r�c� modunda kullan�lmas�.
;	PIC DK2.1a 		: PORTB<0:3> ��k�� ==> LED
;				: A/D anahtar� RA1, RA2 ve RA3 A konumunda
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A			
	include "p16F877A.inc"	
	__config H'3F31'		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
;Program ba�lang�� adresi belirleniyor.
;-------------------------------------------------------------------
	ORG 	0				
	goto 	ana_program		
	ORG 	4			;Kesme alt program� bu adresten 
					;ba�l�yor.
	goto	kesme			;kesme alt program�na git.
;-------------------------------------------------------------------
; Kesme program� kar��la�t�r�c� ��k��lar�ndaki de�i�imlerde 
; �al���yor ve kar��la�t�r�c� ��k��lar�n� 
; kontrol ederek ilgili LED�leri yak�yor yada s�nd�r�yor.
;-------------------------------------------------------------------
kesme
	btfss	PIR1, CMIF		;Kesme kayna�� kar��la�t�r�c� 
					;��k��lar�ndan kaynaklan�yorsa bir 
					;komut atla.
	goto	kesme_sonu		;de�ilse kesmeden ��k.
	
	btfsc	CMCON, CIS		;RA0 ve RA1 giri�leri 
					;kar��la�t�r�c� i�in se�ildiyse 
					;komut atla.
	goto	kesme_5			;RA3 ve RA2 giri�leri
					;kar��la�t�r�c� i�in se�ildiyse 
					;kesme_5 etiketine git.
	btfss	CMCON, C1OUT		;1. kar��la�t�r�c� ��k��� set ise 
					;komut atla ve LED�i s�nd�r.
	goto	kesme_1			;1. kar��la�t�r�c� ��k��� 0 
					;oldu�undan LED yakma k�sm�na git.
	bcf	PORTB, 0		;RB0'a ba�l� LED�i s�nd�r.
	goto	kesme_2
kesme_1
	bsf	PORTB, 0		;RB0'a ba�l� LED�i yak.
kesme_2
	btfss	CMCON, C2OUT		;2. kar��la�t�r�c� ��k��� set ise 
					;komut atla ve LED�i s�nd�r.
	goto	kesme_3			;2. kar��la�t�r�c� ��k��� 0 
					;oldu�undan LED yakma k�sm�na git.
	bcf	PORTB, 1		;RB1'a ba�l� LED�i s�nd�r.
	goto	kesme_4
kesme_3
	bsf	PORTB, 1		;RB1'a ba�l� LED�i yak.
kesme_4
	bcf	PIR1, CMIF		;Kar��la�t�r�c� kesme bayra��n� 
					;yeni kesmeler i�in sil,
	goto	kesme_sonu		;de�ilse kesmeden ��k.	
kesme_5
	btfss	CMCON, C1OUT		;1. kar��la�t�r�c� ��k��� set ise 
					;komut atla ve LED�i s�nd�r.
	goto	kesme_6			;1. kar��la�t�r�c� ��k��� 0 
					;oldu�undan LED yakma k�sm�na git.
	bcf	PORTB, 3		;RB3'a ba�l� LED�i s�nd�r.
	goto	kesme_7
kesme_6
	bsf	PORTB, 3		;RB3'a ba�l� LED�i yak.
kesme_7
	btfss	CMCON, C2OUT		;2. kar��la�t�r�c� ��k��� set ise 
					;komut atla ve LED�i s�nd�r.
	goto	kesme_8			;2. kar��la�t�r�c� ��k��� 0 
					;oldu�undan LED yakma k�sm�na git.
	bcf	PORTB, 2		;RB2'a ba�l� LED�i s�nd�r.
	goto	kesme_9
kesme_8
	bsf	PORTB, 2		;RB2'a ba�l� LED�i yak.
kesme_9
	bcf	PIR1, CMIF		;Kar��la�t�r�c� kesme bayra��n� 
					;yeni kesmeler i�in sil.
kesme_sonu	
	retfie				;Kesme alt program�ndan ��k��.
;-------------------------------------------------------------------
; Ana program port y�nlendirmeleri ve kar��la�t�r�c� mod ayarlar�n� 
; yapt�ktan sonra kar��la�t�r�c� giri�leri s�rekli de�i�tirilerek 
; kesme olu�tu�unda giri�ler ve kar��la�t�rma sonu�lar� 
; de�erlendirilerek sonu�lar PORTB �zerindeki LED'lerde 
; g�r�nt�lenmektedir.Bu durum sistem kapat�lana dek devam eder.
;-------------------------------------------------------------------
ana_program
	banksel TRISB			;TRISB'nin bulundu�u banka ge�, 
					;PIE de bu bankta.
	clrf	TRISB			;PORTB'yi ��k��a y�nlendir.
	bsf	PIE1, CMIE		;Kar��la�t�r�c� kesmelerine izin 
					;ver.
	banksel PORTB			;Bank0�a ge�.
	clrf	PORTB			;LED�ler ilk durumda s�n�k.
	movlw	0x02			;Dahili ortak referansl� 4 giri�ten 
					;se�imli iki kar��la�t�r�c� mod 
					;se�ildi
	movwf	CMCON			;ve CMCON kar��la�t�r�c� kontrol 
					;kaydedicisine y�klendi.
	movlw	0xA5			;0�dan 0.75 CVRSRC  ile CVRSRC/24 
					;ad�m aral��� yani, referans 
					;gerilimi se�ildi.
	banksel CVRCON			;Bank1 se�ildi. CVRCON bu bankta.
	movwf	CVRCON			;CVRCON'a se�ilen durum y�klendi ve 
					;VREF a��ld�.
	banksel CMCON			;Bank0 se�ildi.
	bsf	INTCON, PEIE		;�evresel kesmeler etkinle�tirildi.
	bsf	INTCON, GIE		;Etkinle�tirilen kesmelere izin 
					;verildi.
ana_dongu
	bcf	CMCON, CIS		;Kar��la�t�r�c� giri�leri i�in RA0 
					;ve RA1 se�ildi.
	nop				;Kar��la�t�r�c� giri� de�i�imi i�in 
					;k�sa bir s�re bekle.
	bsf	CMCON, CIS
goto	ana_dongu

	end
;*******************************************************************

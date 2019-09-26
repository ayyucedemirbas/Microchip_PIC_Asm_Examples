;*******************************************************************
;	Dosya Ad�		: 8_1.asm
;	Program�n Amac�		: Komparat�r mod�l�n�n iki ba��ms�z 
;                       	kar��la�t�r�c� olarak kullan�lmas�
;	PIC DK2.1a 		: PORTB<0:1> ��k�� ==> LED
;				: A/D anahtar� RA1, RA2 ve RA3 A konumunda
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F31'		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Program ba�lang�� adresi belirleniyor.
;-------------------------------------------------------------------
	ORG 	0			
	goto 	ana_program		
	ORG 	4			;Kesme alt program� bu adresten 
					;ba�l�yor.
	goto	kesme
;-------------------------------------------------------------------
; Kesme program� kar��la�t�r�c� ��k��lar�ndaki de�i�imlerde 
; �al���yor ve kar��la�t�r�c� ��k��lar�n� kontrol ederek ilgili 
; LED�leri yak�yor yada s�nd�r�yor.
;-------------------------------------------------------------------
kesme
	btfss	PIR1, CMIF		;Kesme kayna�� kar��la�t�r�c� 
					;��k��lar�ndan kaynaklan�yorsa bir 
					;komut atla,
	goto	kesme_sonu		;de�ilse kesmeden ��k.
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
					;yeni kesmeler i�in sil.
kesme_sonu	
	retfie				;Kesme alt program�ndan ��k��.
;-------------------------------------------------------------------
; Ana program port y�nlendirmeleri ve kar��la�t�r�c� mod ayarlar�n� 
; yapt�ktan sonra sonsuz d�ng�ye giriyor. Bu durumda sadece kesme 
; olu�tu�unda ana programdan kesme alt program�na gidiliyor.
;-------------------------------------------------------------------
ana_program
	banksel TRISB			;TRISB'nin bulundu�u banka ge�, 
					;PIE de bu bankta.
	clrf	TRISB			;PORTB'yi ��k��a y�nlendir.
	bsf	PIE1, CMIE		;Kar��la�t�r�c� kesmelerine izin 
					;ver.
	banksel PORTB			;Bank0' a ge�.
	clrf	PORTB			;LED�ler ilk durumda s�n�k.
	movlw	0x04			;Kar��la�t�r�c� ��k��lar� normal, 
					;iki ba��ms�z kar��la�t�r�c� modu 
					;se�ildi.
	movwf	CMCON			;ve CMCON kar��la�t�r�c� kontrol 
					;kaydedicisine y�klendi.
	bsf	INTCON, PEIE		;�evresel kesmeler etkinle�tirildi.
	bsf	INTCON, GIE		;Etkinle�tirilen kesmelere izin 
					;verildi.
bekle
	goto	bekle			;Bo� d�ng�, kar��la�t�r�c� 
					;��k��lar� de�i�tik�e kesme olu�ur.
	end
;*******************************************************************

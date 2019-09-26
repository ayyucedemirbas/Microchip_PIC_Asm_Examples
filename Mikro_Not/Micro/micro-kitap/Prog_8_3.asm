;*******************************************************************
;	Dosya Ad�		: 8_3.asm
;	Program�n Amac�		: Komparat�r�n ortak referansl� PORTA 
;                     		��k��l� iki kar��la�t�r�c� olarak kullan�lmas�
;	PIC DK2.1a 		: PORTA<3:4> ��k�� ==> LED
;				: A/D se�im anahtar� RA1, RA2 ve RA3
;				  A konumunda.
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
;-------------------------------------------------------------------
; Ana program port y�nlendirmeleri ve kar��la�t�r�c� mod ayarlar�n� 
; yapt�ktan sonra sonsuz d�ng�ye giriyor. Bu durumda sadece kesme 
; olu�tu�unda ana programdan kesme alt program�na gidiliyor.
;-------------------------------------------------------------------
ana_program
	banksel TRISA			;TRISA'nin bulundu�u banka ge�.
	clrf	TRISA			;Kar��la�t�r�c� ��k��lar� i�in 
					;��k��a y�nlendiriliyor.
	banksel PORTA			;Bank0'a ge�.
	clrf	PORTA			;LED�ler ilk durumda s�n�k.
	movlw	0x06			;Kar��la�t�r�c� ��k��lar� normal, 
					;iki ba��ms�z kar��la�t�r�c� modu 
					;se�ildi.
	movwf	CMCON			;ve CMCON kar��la�t�r�c� kontrol 
					;kaydedicisine y�klendi.
bekle
	goto	bekle			;Bo� d�ng�, Kar��la�t�r�c� 
					;��k��lar� de�i�tik�e RA3 ve RA4'e 
					;ba�l� LED'ler �zerinde g�r�n�r
	end
;*******************************************************************

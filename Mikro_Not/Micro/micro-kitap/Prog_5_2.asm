;*******************************************************************
;	Dosya Ad�		: 5_2.asm
;	Program�n Amac�		: CCP1 compare modunun kullan�lmas�.
;	Notlar 			: PORTB<0> ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, di�erleri kapal�. 
	ORG 	0 
	pagesel Ana_program		;Ana program�n bulundu�u program 
					;sayfas� se�ildi.
	goto 	Ana_program
	ORG 	4
;-------------------------------------------------------------------
; Kesme alt program� CCP1IF kesmesini i�leyerek RB0'a ba�l� LED
; �zerinde durumun g�zlenmesini sa�lar.
;-------------------------------------------------------------------
interrupt
	pagesel	0		;0. program sayfas� se�ildi.
	banksel	PIR1		;BANK0 se�ildi. PIR1 bu bankta.
	btfss	PIR1, 2		;CCP1IF set ise bir komut atla.
	goto	Kesme_sonu	;Kesme sonuna git.
	bcf	PIR1, 2		;CCP1IF kesme bayra��n� sil.
	btfss	PORTB, 0	;LED yan�yormu? evet ise 1 komut atla
	goto	Led_yak		;LED'i yakma k�sm�na git.
	bcf	PORTB, 0	;LED'i s�nd�r.
	goto	Kesme_sonu	;Kesme sonuna git.
Led_yak
	bsf	PORTB, 0	;LED'i yak.
Kesme_sonu
	retfie			;Kesmeden ��k��.

;-------------------------------------------------------------------
; Compare alt program�: Timer1'i 1:8 prescaler de�erde RC0'dan gelen 
; senkronizeli y�kselen kenar tetiklemesinde artacak �ekilde 
; ayarl�yor. Ayr�ca CCP1 mod�l�n� �zel olay tetiklemeli compare moda 
; ayarl�yor.
;-------------------------------------------------------------------
Compare_Ilk_Islemler
	Banksel T1CON		;BANK0 se�ildi T1CON bu bankta.
	bcf	T1CON, 0	;Timer1 mod�l� ilk anda kapal� tutuluyor.
	clrf	TMR1L		;Timer1'in d���k byte'� s�f�rland�.
	clrf	TMR1H		;Timer1'in y�ksek byte'� s�f�rland�.
	movlw	0x33		;TMR1 1:8 prescaler de�ere ve 
				;RC0/T1OSO/T1CKI giri�inden 
	movwf 	T1CON		;gelen y�kselen 8.darbe kenar�nda artacak 
				;�ekilde ayarland�.
	bcf 	T1CON, 2	;Senkronize external clock giri�i se�ildi.
	bcf	T1CON, 3	;Osilat�r kapat�ld� (extenal clock 
				;se�ildi�i i�in).
	clrf	CCPR1H
	movlw	0x04
	movwf	CCPR1L		;Kar��la�t�rma de�eri y�kleniyor. 
				;G�zlemlemede kolayl�k i�in 
				;k���k de�er se�ildi.
	movlw	0x0B		;Kar��la�t�rma sonucu e�it ise yaz�l�m 
				;kesmesi olu�tur. (CCP1IF set)
	movwf	CCP1CON		;Ayr�ca Timer1 resetlenir. �zel olay 
				;tetiklemeli mod.
	bsf	STATUS, RP0	;BANK1 se�ildi.
	bsf	PIE1, 2		;CCP1 mod�l� kesmesi CCP1IE set edildi.
	return
;-------------------------------------------------------------------
; �lk i�lemler alt program�: PORTB'nin ��k��a y�nlendirilmesinde 
; kullan�l�yor.
;-------------------------------------------------------------------
Ilk_islemler
	banksel TRISB		;BANK1 se�ildi.
	clrf	TRISB		;PORTB ��k��a y�nlendirildi.
	bcf	STATUS, RP0	;BANK0 se�ildi.
	clrf 	PORTB		;�lk durumda LED s�n�k.
	return
;-------------------------------------------------------------------
; Ana program blo�u: �lk i�lemler i�in alt programlar� �a��rma ve 
; sonsuz bo� d�ng�den olu�uyor.
;-------------------------------------------------------------------
Ana_program
	call	Ilk_islemler		;�lk i�lemler alt program� 
					;�a�r�l�yor.
	call	Compare_Ilk_Islemler	;Compare ile ilgili ilk 
					;i�lemler ger�ekle�tiriliyor
	bsf	INTCON, PEIE		;PEIE set edildi, �evresel birim 
					;kesmeleri aktif.
	bsf	INTCON, GIE		;Etkinle�tirilen kesmelere genel 
					;izin verildi.
	bcf	STATUS, RP0		;BANK0 se�ildi.
	bsf	T1CON, 0		;Timer1 mod�l� �al��maya ba�lad�.
Ana_j1
	goto	Ana_j1			;Sistem kapat�lana kadar ya da 
					;resetlenene kadar bo� d�ng�.
	END				;Program sonu.
;*******************************************************************

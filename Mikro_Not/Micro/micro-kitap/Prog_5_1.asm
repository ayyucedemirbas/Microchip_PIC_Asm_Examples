;*******************************************************************
;	Dosya Ad�		: 5_1.asm
;	Program�n Amac�		: CCP1 capture modunun kullan�lmas�.
;	Notlar 			: PORTB ��k�� ==> LED�ler.
;				: RC0�a ba�l� buton Timer1 sayma kayna��.
;				: RC2�ye ba�l� buton CCP1 olay kayna��.
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc" 
	__config H'3F3A' 	;T�m program sigortalar� kapal�, 
				;Osilat�r HS ve 20Mhz
	ORG 	0 
	Pagesel  ana_program	;Ana program�n bulundu�u program 
				;sayfas� se�ildi.
	goto 	ana_program	;Ana programa git.
	ORG 	4			
;-------------------------------------------------------------------
; Kesme alt program�: Her Capture (yakalama) olay�nda kesme olu�ur 
; ve PORTB ��k��� bir artar.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;0. bank se�ildi. PIR1 bu bankta.
	btfss 	PIR1, 2		;CCP1IF set ise bir komut atla.
	goto 	int_j1		;Kesmeden ��k��a git.
	bcf 	PIR1, 2		;CCP1IF kesme bayra��n� sil.
	incf 	PORTB, F	;PORTB ��k�� kaydedicisi de�eri bir art�r.
int_j1
	retfie
;-------------------------------------------------------------------
; Capture (yakalama) mod ilk i�lemler: TMR1 1:8 prescaler de�ere 
;ayarlan�r. CCP1 Her y�kselen 4. darbe kenar� olay�na ayarlan�r.
;-------------------------------------------------------------------
Capture_Ilk_Islemler
	Banksel TMR1L		;0. bank se�ildi. TMR1 bu bankta
	clrf 	TMR1L		;TMR1 s�f�rland�
	clrf 	TMR1H
	movlw 	0x33
	movwf 	T1CON		;TMR1 1:8 prescaler de�ere ayarland� ve 
				;RC0/T1OSO/T1CKI giri�inden gelen her 8. 
				;y�kselen darbe kenar�nda ;de�erinin 1 
				;artmas� sa�land�.
	movlw 	0x06		;Her y�kselen 4. darbe kenar�n� yakala.
	movwf 	CCP1CON
	banksel TRISC		;1. bank se�ildi TRISC ve PIE1 bu bankta
	bsf 	TRISC, 2	;RC2/CCP1 pin giri�e ayarland�.
	bsf 	PIE1, 2		;Capture kesmesi aktif hale getirildi.
	return
;-------------------------------------------------------------------
; Ana program ilk i�lemler:Port y�nlendirme i�lemleri.
;-------------------------------------------------------------------
ilk_islemler
	banksel TRISB			;1. bank se�ildi. TRISB bu bankta.
	clrf 	TRISB			;PORTB ��k��a y�nlendirildi.
	bcf 	STATUS, RP0		;0. bank se�ildi. PORTB bu bankta.
	clrf 	PORTB			;PORTB'nin ilk ��k�� de�eri s�f�r 
					;olarak set edildi.
	return				;Alt programdan ��k��.


;-------------------------------------------------------------------
; Ana program: Bu k�s�mda ilk i�lemler yap�ld�ktan sonra kesmeler 
; aktif hale getirilip kesmeler bekleniyor.
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler	      	;�lk i�lemler alt program� �a�r�ld�.
	call 	Capture_Ilk_Islemler	;Capture modun �al��ma 
					;ko�ullar� belirleniyor.
	bsf 	INTCON, 6		;PEIE set edildi, �evresel birim 
					;kesmeleri aktif.
	bsf 	INTCON, 7		;Genel kesme izni verildi.
	goto  	$			;Sistem kapat�lana ya da 
					;resetlenene kadar bo� d�ng�.

	END				;Program sonu
;*******************************************************************

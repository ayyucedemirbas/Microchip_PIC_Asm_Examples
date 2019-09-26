;*******************************************************************
;	Dosya Ad�		: 4_3.asm
;	Program�n Amac�		: Timer1�in Zamanlay�c� Olarak
; 				  Kullan�lmas� g�rmek.
;	PICDK2.1a 		: PORTB<0:7> ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************	
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tan�mlamalar� 
				;programa kat�l�yor.
	__config H'3F31' 	;PWRT on, di�erleri kapal�, 
				;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�
;-------------------------------------------------------------------
Counter	equ	0x20		;De�i�keninin RAM�deki yeri.

	ORG 	0		;Reset vekt�r adresi.
	clrf 	PCLATH		;0. program sayfas� se�ildi.
	goto 	ana_program	;Ana programa git.
	ORG 	4		;Kesme vekt�r adresi.
;-------------------------------------------------------------------
; Kesme program�: Kesme kayna�� sadece TMR1 se�ildi�i i�in ekstra 
; kontrol yap�lmad�. Timer1 zamanlay�c�s�nda ta�ma olu�tu�unda 
; Counter de�i�keni kesme adedini sayar.
;-------------------------------------------------------------------
interrupt
	incf 	Counter, F	;8 bit�lik Counter de�i�keni art�r�ld�.
	banksel  PIR1		;BANK1 se�ildi.
	bcf 	PIR1, 0		;TMR1IF=0
	retfie
;-------------------------------------------------------------------
; Ana program: Portlar�n y�nlendirilmesi, Timer1 zamanlay�c�s�n�n 
; kurulmas�, kesmelere izin verilmesi ve Kesme adedinin kontrol 
; edilmesi ile yakla��k 10 saniyede bir PORTB�nin komplementi 
; (1. t�mleyeni) al�narak PORTB�den ��k��a aktar�lmas�n� sa�lar.
;-------------------------------------------------------------------

ana_program
	banksel TRISB			;BANK1 se�ildi.
	clrf 	TRISB			;PORTD ��k��a ayarland�.
	movlw 	0x01
	banksel T1CON			;BANK0 se�ildi.
	movwf 	T1CON			;TMR1=ON internal clock, Fosc/4, 
					;prescale yok.
	bcf 	PIR1, TMR1IF
	banksel PIE1			;BANK1 se�ildi.
	bsf 	PIE1, TMR1IE		;TMRIE=1, Timer1 kesmesi aktif 
					;yap�ld�.
	movlw 	0xF0
	banksel PORTB			;BANK0 se�ildi.
	movwf 	PORTB			;PORTB'den 0xF0 bilgi ��k��� yap�ld�.
	clrf 	Counter			;8 bit�lik Counter de�i�keni s�f�rland�.
	movlw 	0xC0			
	movwf 	INTCON			;INTCON = 0xC0, GIE ve PEIE set edildi.
ana_j1					;Counter 152'ye ula�t� m�?
	movlw 	D'152'			;yakla��k 4 Mhz'de 10sn'lik bir zamanlama 
	subwf 	Counter, W		;(10 milyon komut �evrimi / 65536) = 
					;152.587...
	btfss 	STATUS, Z
	goto 	ana_j1			;Counter<152 ise ana_j1 etiketine git.
	comf 	PORTB, W		;PORTB ��k�� kaydedicisinin 1.Komplementi 
					;W'ye yaz�ld�.
	movwf	PORTB			;W i�eri�i PORTB'ye aktar�ld�.
	clrf 	Counter			;8 bit�lik Counter de�i�keni s�f�rland�.
	goto 	ana_j1			;Ayn� i�lemleri s�rekli yap.

	END				;Assembly program� sonu.
;******************************************************************

;*******************************************************************
;	Dosya Ad�		: 3_6.asm
;	Program�n Amac�	: RB4-RB7 u�lar�ndaki de�i�ikle uyku 
;				: modundan ��k��� g�stermek.
;	PICDK2.1a 		: PORTB<0:3> ��k�� ==> LED
;				: PORTB<4:7> Giri� ==> BUTON
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A			;List dosyas�n� 16F877A i�in 
					;olu�tur.
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, WDT off, di�erleri 
					;kapal�, Osilat�r XT ve 4Mhz
sayac1	   equ		0x20
sayac2	   equ		0x21
	org		0
	goto	ana_program
	org		4
	goto	kesme
ana_program_ilk_islemler
	clrf	PORTB			;�lk durumu LOW.
	banksel	TRISB			;TRISB'nin bulundu�u BANK0 se�ildi.
	movlw	0xF0
	movwf	TRISB			;RB0-RB3 ��k��, RB4-RB7 giri� 
					;yap�ld�.
	movlw	0xFF
	movwf	TRISA			;PORTA'n�n t�m pinleri giri�e 
					;y�nlendirildi.
	movlw	0x06			;Analog giri�ler kapat�ld�. 
	movwf	ADCON1
	bsf	INTCON, RBIE		;RB4-RB7 pin durumu de�i�imleri 
					;kesmesine izin ver.
	bsf	INTCON, GIE		;Genel kesmelere izin ver.
	return
delay
	movlw	0xFF
	movwf	sayac1			;sayac1'e 0xFF de�eri y�kle.
dongu1
	movlw	0xFF
	movwf	sayac2			;sayac2'e 0xFF de�eri y�kle.
dongu2
	decfsz	sayac2, F		;sayac2=0 olana kadar sayac� bir 
					;azalt, sayac2=0 ise bir komut atla
	goto	dongu2
	decfsz	sayac1, F		;sayac1=0 olana kadar sayac� bir 
					;azalt, sayac1=0 ise bir komut atla
	goto	dongu1
	return
uyu
	movf	PORTB, W		;PORTB'nin de�eri W'de korunuyor.
	clrf	PORTB			;LED'ler s�nd�r�ld�.
	sleep				;Uyu.
	nop				;Bir komut �evrimi bekle.
	movwf	PORTB			;Saymaya kald���n say�dan devam et.
	return
kesme
	bcf	INTCON, GIE		; T�m kesmeler iptal.
					;RB4-RB7 pin de�i�imlerinde 
					;yap�lacak i�lemler buraya yaz�l�r.
	bcf	INTCON, 0		;RBIF
	bsf	INTCON, GIE		; T�m kesmeleri tekrar ge�erli.
	retfie
ana_program
	call	ana_program_ilk_islemler	;Portlar y�nlendiriliyor.
	banksel   PORTA
RA1_test
	btfss	PORTA, 1		;RA1 butonuna bas�ld� m�? hay�r ise 
					; bir komut atla.
	call	uyu			; Uyu alt program�na git.
	incf	PORTB			; PORTB�yi �1� artt�r.
	call	delay			; Bir s�re gecikme yap.
	goto	RA1_test		; Butonu teste devam et.
	END
;*****************************************************************

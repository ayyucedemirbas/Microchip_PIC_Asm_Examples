;******************************************************************
;	Dosya Ad�		: 4_8.asm
;	Program�n Amac�		: WDT uygulamas�.
;	PICDK2.1a 		: PORTB<0:7> ��k�� ==> LED
;				: PORTA<1> Dijital Giri� <== BUTON
;				: PORTC<1> ��k�� ==> BUZZER
;				: XT ==> 4Mhz
;******************************************************************
	list p=16F877A		;List dosyas�n� 16F877A i�in 
				;olu�tur.
	include "p16F877A.inc"	
	__config H'3F35' 	;PWRT on, WDT on, di�erleri kapal�, 
				;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
sayac	equ	0x20
	org		0
	goto	ana_program

ana_program_ilk_islemler
	clrf	PORTB			;�lk durumu LOW.
	banksel	TRISB			;TRISB'nin bulundu�u BANK0 se�ildi.
	clrf	TRISB			;PORTB'nin t�m pinleri ��k��a 
					;y�nlendirildi.
	movlw	0xFF
	movwf	TRISA			;PORTA'n�n t�m pinleri giri�e 
					;y�nlendirildi.
	clrf	TRISC			;PORTC ��k��a y�nlendirildi.
	movlw	0x06			;Analog giri�ler kapat�ld�. 
	movwf	ADCON1
	banksel	PORTC
wdt_kontrol
	btfss	STATUS, 4
	goto	buzzer
	banksel  OPTION_REG		;OPTION_REG kaydedicisinin 
					;bulundu�u banka ge�iliyor.
	clrwdt				;WDT zamanlay�c�s� s�f�rland�, 
					;i�lemler yeni ba�l�yor..
	movlw	b'00001111'		;WDT=ON, prescaler=1/128
	movwf	OPTION_REG		;OPTION_REG kuruldu.
	return
buzzer
	clrwdt				;WDT zamanlay�c�s�n� s�f�rla.
	bsf	PORTC, 1		;PIC DK 2.1�de RC1'e ba�l� buzzer 
					;��k���n� HIGH yap.
	call	delay			;Gecikme alt program�n� �a��r.
	bcf	PORTC, 1		;PIC DK 2.1�de RC1'e ba�l� buzzer 
					;��k���n� LOW yap.
	call	delay			;Gecikme alt program�n� �a��r.
	goto	buzzer			;Sistem resetlenene kadar ses 
					;��karmaya devam et.
	return

delay
	movlw	0xFF
	movwf	sayac			;sayaca 0xFF de�eri y�kle.
	decfsz	sayac, F		;sayac=0 olana kadar sayac� bir 
					;azalt, saya=0 ise bir komut atla.
	goto	$-1
	return

ana_program
	call	ana_program_ilk_islemler	;Portlar y�nlendiriliyor.
	banksel  PORTA
RA1_test
	btfsc	PORTA, 1		;RA1 butonuna bas�ls� ise bir komut 
					;atla.
	goto	RA1_test		;Butona bas�lmad�, teste devam et.
	clrwdt				;Butona bas�ld�, WDT 
					;zamanlay�c�s�n� s�f�rla.
	incf	PORTB			;Butona her bas�ld���nda PORTB 
					;�zerinde LED'lerdeki binary say� 
					;artar.
	goto	RA1_test		;Butonu teste devam et.
	
	END
;*******************************************************************

;*******************************************************************
;	Dosya Ad�		: 11_3.asm
;	Program�n Amac�		: Buton kontrol�
;	PIC DK2.1a 		: PORTB<0:1> ��k�� ==> LED
;				: A/D se�im anahtar� RA1 ve RA2 D konumunda
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlar� yap�l�yor.
;-------------------------------------------------------------------
#define	LED1	PORTB, 0	;RB0'a ba�l� LED.
#define	LED2	PORTB, 1	;RB1'a ba�l� LED.
#define	BUTON1	PORTA, 1	;RA1'e ba�l� buton.
#define	BUTON2	PORTA, 2	;RA2'ye ba�l� buton.
	org	0 
	goto	ana_program
	org	4

kesme
	retfie
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
ana_program
banksel TRISA				;BANK1 se�ildi.
	movlw	0x06			;RA0, RA1 giri�, di�erleri ��k��.
	movwf	ADCON1			;0x06 de�eri y�klenerek ayn� 
					;zamanda analog giri�ler kapat�ld�.
	movwf	TRISA			;PORTA'n�n y�nlendirildi.
	clrf	TRISB			;PORTB ��k��a y�nlendirildi.
	banksel PORTB			;BANK0 se�ildi.
	clrf	PORTB			;LED'ler s�nd�r�ld�	.	
dongu
	btfss	BUTON1			;BT1'e bas�ld� ise bir komut atla. 
	goto	bt1basilidegil
	bsf	LED1			;BT1'e bas�l� ise LED1'i yak.
	goto	buton2kont
bt1basilidegil
	bcf	LED1			;BT1 bas�l� de�ilse LED1'i s�nd�r.
buton2kont
	btfsc	BUTON2			;BT2'e bas�ld� ise bir komut atla.
	goto	bt2basilidegil
	bsf	LED2			;BT2'e bas�l� ise LED2'i yak.
	goto	dongu
bt2basilidegil
	bcf	LED2			;BT2 bas�l� de�ilse LED2'i s�nd�r.
	goto	dongu

	end
;******************************************************************* 

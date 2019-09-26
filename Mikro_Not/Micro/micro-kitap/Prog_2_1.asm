;******************************************************************
;	Dosya ad�		: 2_1.asm
;	Program�n amac�	: 0-255 aras�nda ikilik d�zende say�c�
;	PIC DK V2.1		: PORTB ��k�� ==> LED
;				: XT ==> 4 Mhz	
;****************************************************************** 
list		p=16F877A		; derleyici i�in bilgi
	#include	<P16F877A.INC>	; 877A i�in gerekli isim-
 						; adres e�le�meleri	
__config H'3F31' 			;PWRT on, di�erleri kapal�, 
;Osilat�r XT ve 4Mhz

	ORG	0x000				; ba�lang�� Adresi
	goto	ana_program			; ana programa git
	ORG	0x004			; kesme Adresi
kesme
	clrf	PIR1			; kesme bayra��n� kapa	
	incf	PORTB,F	; PORTB�nin i�eri�ini artt�r.
	retfie			; kesmeden geri d�n			

ana_program
	movlw	b'11000000'	; kesme ve TMR1 sayac�n�n a��lmas� i�in
	movwf	INTCON		; gerekli de�i�iklikler yap�l�r
	movlw	b'11110001'
	movwf	T1CON
	bsf	STATUS,RP0	
	bsf	PIE1,0
	movlw	b'00000000'
	movwf	TRISB
	bcf	STATUS,RP0
dongu
	goto	dongu		; program burada oldu�u yerde tak�l�r 
	end			; kal�r. Fakat TMR1 kesmesi a��k oldu�u   
 				; i�in kesme geldi�inde PORTB bir   
 				; artt�r�l�r.
;*****************************************************************

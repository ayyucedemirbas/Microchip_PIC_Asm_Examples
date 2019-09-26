;******************************************************************
;	Dosya Ad�		: 3_2.asm
;	Program�n Amac�	: Kesmelerin genel 
;				  �zellikleri ve RB0 harici kesmesi.	 
;	PICDK2.1a 		: PORTB ��k�� ==> LED
;				: XT ==> 4Mhz
;******************************************************************
	list		p=16F877A		; Derleyici i�in bilgi.
	#include	<P16F877A.INC>	; 877A i�in gerekli isim-
						; adres e�le�meleri.	
	ORG	0x000		; Ba�lang�� Adresi.
	goto	ana_program	; Ana programa git.
	ORG	0x004		; Kesme vekt�r� adresi.
	bcf	INTCON, INTF	; Kesme bayra��n� indir.
	bsf	PORTB, 7	; PORTB�nin 7 bit�ine ba�l� LED�i yak.
	retfie			; Kesmeden geri d�n.
ana_program
	clrf	PORTB		; PORTB�yi temizle.
	movlw	b'10010000'	; RB0 kesmesini a�.
	movwf	INTCON
	bsf	STATUS,RP0	; 1. sayfaya ge�.
	clrf	OPTION_REG	; Kesme d��en kenarda.
	movlw	b'00000001'	; PORTB�nin 0.bit�i giri� di�erleri ��k��
	movwf	TRISB
	bcf	STATUS,RP0	; 0. sayfaya ge�.
dongu		
	goto	dongu		; D�ng�ye devam et.
	end
;****************************************************************	

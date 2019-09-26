;******************************************************************
;	Dosya Adý		: 3_2.asm
;	Programýn Amacý	: Kesmelerin genel 
;				  özellikleri ve RB0 harici kesmesi.	 
;	PICDK2.1a 		: PORTB Çýkýþ ==> LED
;				: XT ==> 4Mhz
;******************************************************************
	list		p=16F877A		; Derleyici için bilgi.
	#include	<P16F877A.INC>	; 877A için gerekli isim-
						; adres eþleþmeleri.	
	ORG	0x000		; Baþlangýç Adresi.
	goto	ana_program	; Ana programa git.
	ORG	0x004		; Kesme vektörü adresi.
	bcf	INTCON, INTF	; Kesme bayraðýný indir.
	bsf	PORTB, 7	; PORTB’nin 7 bit’ine baðlý LED’i yak.
	retfie			; Kesmeden geri dön.
ana_program
	clrf	PORTB		; PORTB’yi temizle.
	movlw	b'10010000'	; RB0 kesmesini aç.
	movwf	INTCON
	bsf	STATUS,RP0	; 1. sayfaya geç.
	clrf	OPTION_REG	; Kesme düþen kenarda.
	movlw	b'00000001'	; PORTB’nin 0.bit’i giriþ diðerleri çýkýþ
	movwf	TRISB
	bcf	STATUS,RP0	; 0. sayfaya geç.
dongu		
	goto	dongu		; Döngüye devam et.
	end
;****************************************************************	

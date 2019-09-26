;*******************************************************************
;	Dosya Ad�		: 3_1.asm
;	Program�n Amac�	: STATUS register�� i�eri�ine
;				  bakarak karar vermek.
;	PICDK2.1a 		: PORTB ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list		p=16F877A		; Derleyici i�in bilgi.
	#include	<P16F877A.INC>	

	ORG	0x000		; Ba�lang�� Adresi.
	goto	ana_program	; Ana programa git.

	ORG	0x004		; Kesme Adresi.
kesme				; Yanl��l�kla kesme gelirse
	retfie			; kesmeden geri d�n.			

ana_program
	bsf	STATUS,RP0	; Birinci banka ge�.
	clrf	TRISB		; PORTB'yi ��k�� yap.	
	bcf	STATUS,RP0	; S�f�r�nc� banka ge�.
duzen
	movlw	d'200'		; PORTB'nin i�ine 200
	movwf	PORTB		; y�kle.
dongu
	movlw	d'22'		; W reg'e 22 y�kle ve bu
	subwf	PORTB		; 22�yi her d�ng�de 200'den ��kar.
	btfss	STATUS,C	; ��karman�n sonucu pozitif ise C
	goto	$-1		; flag a��lacakt�r, ba�a d�n ve 
		goto	dongu	; d�ng�ye devam et. E�er sonu� 		
				; negatifse C flag 0 olur, o zaman 				
				; bu sat�rda tak�l.
end	
;******************************************************************

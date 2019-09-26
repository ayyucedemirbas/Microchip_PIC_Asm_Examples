;*******************************************************************
;	Dosya Adý		: 3_1.asm
;	Programýn Amacý	: STATUS register’ý içeriðine
;				  bakarak karar vermek.
;	PICDK2.1a 		: PORTB Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list		p=16F877A		; Derleyici için bilgi.
	#include	<P16F877A.INC>	

	ORG	0x000		; Baþlangýç Adresi.
	goto	ana_program	; Ana programa git.

	ORG	0x004		; Kesme Adresi.
kesme				; Yanlýþlýkla kesme gelirse
	retfie			; kesmeden geri dön.			

ana_program
	bsf	STATUS,RP0	; Birinci banka geç.
	clrf	TRISB		; PORTB'yi çýkýþ yap.	
	bcf	STATUS,RP0	; Sýfýrýncý banka geç.
duzen
	movlw	d'200'		; PORTB'nin içine 200
	movwf	PORTB		; yükle.
dongu
	movlw	d'22'		; W reg'e 22 yükle ve bu
	subwf	PORTB		; 22’yi her döngüde 200'den çýkar.
	btfss	STATUS,C	; Çýkarmanýn sonucu pozitif ise C
	goto	$-1		; flag açýlacaktýr, baþa dön ve 
		goto	dongu	; döngüye devam et. Eðer sonuç 		
				; negatifse C flag 0 olur, o zaman 				
				; bu satýrda takýl.
end	
;******************************************************************

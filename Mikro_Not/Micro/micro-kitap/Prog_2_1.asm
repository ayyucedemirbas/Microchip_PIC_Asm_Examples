;******************************************************************
;	Dosya adý		: 2_1.asm
;	Programýn amacý	: 0-255 arasýnda ikilik düzende sayýcý
;	PIC DK V2.1		: PORTB çýkýþ ==> LED
;				: XT ==> 4 Mhz	
;****************************************************************** 
list		p=16F877A		; derleyici için bilgi
	#include	<P16F877A.INC>	; 877A için gerekli isim-
 						; adres eþleþmeleri	
__config H'3F31' 			;PWRT on, diðerleri kapalý, 
;Osilatör XT ve 4Mhz

	ORG	0x000				; baþlangýç Adresi
	goto	ana_program			; ana programa git
	ORG	0x004			; kesme Adresi
kesme
	clrf	PIR1			; kesme bayraðýný kapa	
	incf	PORTB,F	; PORTB’nin içeriðini arttýr.
	retfie			; kesmeden geri dön			

ana_program
	movlw	b'11000000'	; kesme ve TMR1 sayacýnýn açýlmasý için
	movwf	INTCON		; gerekli deðiþiklikler yapýlýr
	movlw	b'11110001'
	movwf	T1CON
	bsf	STATUS,RP0	
	bsf	PIE1,0
	movlw	b'00000000'
	movwf	TRISB
	bcf	STATUS,RP0
dongu
	goto	dongu		; program burada olduðu yerde takýlýr 
	end			; kalýr. Fakat TMR1 kesmesi açýk olduðu   
 				; için kesme geldiðinde PORTB bir   
 				; arttýrýlýr.
;*****************************************************************

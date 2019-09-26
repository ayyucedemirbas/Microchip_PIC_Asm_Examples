;******************************************************************
;	Dosya Ad�		: 2_2.asm
;	Program�n Amac�	: 0-255 ikilik d�zende TMR0 ile
;				  d��ardan ald��� saat darbesi
;				  ile sayan say�c�
;	PICDK2.1a 	: PORTB ��k�� 	==> LED
;			: XT 			==> 4Mhz
;			: PORTA 		==> Dijital Giri�
;****************************************************************** 
list		p=16F877A		; Derleyici i�in bilgi.
	#include	<P16F877A.INC>	; 877A i�in gerekli isim-
 						; adres e�le�meleri.
__config H'3F31' 			;PWRT on, di�erleri kapal�, 
;Osilat�r XT ve 4Mhz.

ORG	0x000		; Ba�lang�� adresi.
	goto	ana_program	; Ana programa git.
	ORG	0x004		; Kesme adresi.
kesme				; Hatayla kesme olu�ursa, 
	retfie			; bir �ey yapmadan kesmeden geri d�n.			
ana_program
	clrf	INTCON		; Gerekli de�i�iklikler yap�l�r.
	bsf	STATUS,RP0	; Bank1�e ge�	.
	movlw	b'00111000'	; TMR0 sayac� d��ar�dan saat darbesi
	movwf	OPTION_REG	; alacak �ekilde atand�.
	movlw	b'00000000'	; PORTB ��k��.
	movwf	TRISB
	movlw	b'11111111'	; PORTA giri�.
	movwf	TRISA		
	movlw	b'00000111'	; PORTA dijital giri�.
	movwf	ADCON1		; olacak �ekilde ADCON1 ayarland�.
	bcf	STATUS,RP0	; Bank0�a ge�.
dongu
	movfw	TMR0		; TMR0��n i�eri�ini W ye y�kle ve
	movwf	PORTB		; bu de�eri PORTB�de g�r�nt�le.
	goto	dongu		; D�ng�ye geri d�n.
	end	
;*******************************************************************
;******************************************************************
;	Dosya Adý		: 2_2.asm
;	Programýn Amacý	: 0-255 ikilik düzende TMR0 ile
;				  dýþardan aldýðý saat darbesi
;				  ile sayan sayýcý
;	PICDK2.1a 	: PORTB Çýkýþ 	==> LED
;			: XT 			==> 4Mhz
;			: PORTA 		==> Dijital Giriþ
;****************************************************************** 
list		p=16F877A		; Derleyici için bilgi.
	#include	<P16F877A.INC>	; 877A için gerekli isim-
 						; adres eþleþmeleri.
__config H'3F31' 			;PWRT on, diðerleri kapalý, 
;Osilatör XT ve 4Mhz.

ORG	0x000		; Baþlangýç adresi.
	goto	ana_program	; Ana programa git.
	ORG	0x004		; Kesme adresi.
kesme				; Hatayla kesme oluþursa, 
	retfie			; bir þey yapmadan kesmeden geri dön.			
ana_program
	clrf	INTCON		; Gerekli deðiþiklikler yapýlýr.
	bsf	STATUS,RP0	; Bank1’e geç	.
	movlw	b'00111000'	; TMR0 sayacý dýþarýdan saat darbesi
	movwf	OPTION_REG	; alacak þekilde atandý.
	movlw	b'00000000'	; PORTB çýkýþ.
	movwf	TRISB
	movlw	b'11111111'	; PORTA giriþ.
	movwf	TRISA		
	movlw	b'00000111'	; PORTA dijital giriþ.
	movwf	ADCON1		; olacak þekilde ADCON1 ayarlandý.
	bcf	STATUS,RP0	; Bank0’a geç.
dongu
	movfw	TMR0		; TMR0’ýn içeriðini W ye yükle ve
	movwf	PORTB		; bu deðeri PORTB’de görüntüle.
	goto	dongu		; Döngüye geri dön.
	end	
;*******************************************************************
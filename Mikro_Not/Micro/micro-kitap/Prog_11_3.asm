;*******************************************************************
;	Dosya Adý		: 11_3.asm
;	Programýn Amacý		: Buton kontrolü
;	PIC DK2.1a 		: PORTB<0:1> Çýkýþ ==> LED
;				: A/D seçim anahtarý RA1 ve RA2 D konumunda
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlarý yapýlýyor.
;-------------------------------------------------------------------
#define	LED1	PORTB, 0	;RB0'a baðlý LED.
#define	LED2	PORTB, 1	;RB1'a baðlý LED.
#define	BUTON1	PORTA, 1	;RA1'e baðlý buton.
#define	BUTON2	PORTA, 2	;RA2'ye baðlý buton.
	org	0 
	goto	ana_program
	org	4

kesme
	retfie
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
ana_program
banksel TRISA				;BANK1 seçildi.
	movlw	0x06			;RA0, RA1 giriþ, diðerleri çýkýþ.
	movwf	ADCON1			;0x06 deðeri yüklenerek ayný 
					;zamanda analog giriþler kapatýldý.
	movwf	TRISA			;PORTA'nýn yönlendirildi.
	clrf	TRISB			;PORTB çýkýþa yönlendirildi.
	banksel PORTB			;BANK0 seçildi.
	clrf	PORTB			;LED'ler söndürüldü	.	
dongu
	btfss	BUTON1			;BT1'e basýldý ise bir komut atla. 
	goto	bt1basilidegil
	bsf	LED1			;BT1'e basýlý ise LED1'i yak.
	goto	buton2kont
bt1basilidegil
	bcf	LED1			;BT1 basýlý deðilse LED1'i söndür.
buton2kont
	btfsc	BUTON2			;BT2'e basýldý ise bir komut atla.
	goto	bt2basilidegil
	bsf	LED2			;BT2'e basýlý ise LED2'i yak.
	goto	dongu
bt2basilidegil
	bcf	LED2			;BT2 basýlý deðilse LED2'i söndür.
	goto	dongu

	end
;******************************************************************* 

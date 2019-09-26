;*****************************************************************
;	Dosya Adý		: 11_1.asm
;	Programýn Amacý		: 7 segment display uygulamasý
;	Notlar 			: Proteus programý simülasyonu
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý.
;-------------------------------------------------------------------
#define	DISPLAY1	PORTB
#define	DISPLAY2	PORTD
#define 	BUTON		PORTA, 1	; RA1'e baðlý buton.
sayac		equ		0x20		; Sayaç deðiþkeni için 
						; RAM'de yer ayrýlýyor.
	org	0
	goto	ana_program
	org	4
kesme
	retfie
;-------------------------------------------------------------------
; Ortak anot display için rakamlarýn segment bilgileri.
;-------------------------------------------------------------------
ortak_anot
	addwf	PCL, F
	retlw	0x40		; 0 rakamý için segment deðeri.
	retlw	0x79		; 1 rakamý için segment deðeri.
	retlw	0x24		; 2 rakamý için segment deðeri.
	retlw	0x30		; 3 rakamý için segment deðeri.
	retlw	0x19		; 4 rakamý için segment deðeri.
	retlw	0x12		; 5 rakamý için segment deðeri.
	retlw	0x02		; 6 rakamý için segment deðeri.
	retlw	0x78		; 7 rakamý için segment deðeri.
	retlw	0x00		; 8 rakamý için segment deðeri.
	retlw	0x10		; 9 rakamý için segment deðeri.
;-------------------------------------------------------------------
; Ortak katot display için rakamlarýn segment bilgileri.
;-------------------------------------------------------------------
ortak_katot
	addwf	PCL, F
	retlw	0x3F		; 0 rakamý için segment deðeri.
	retlw	0x06		; 1 rakamý için segment deðeri.
	retlw	0x5B		; 2 rakamý için segment deðeri.
	retlw	0x4F		; 3 rakamý için segment deðeri.
	retlw	0x66		; 4 rakamý için segment deðeri.
	retlw	0x6D		; 5 rakamý için segment deðeri.
	retlw	0x7D		; 6 rakamý için segment deðeri.
	retlw	0x07		; 7 rakamý için segment deðeri.
	retlw	0x7F		; 8 rakamý için segment deðeri.
	retlw	0x6F		; 9 rakamý için segment deðeri.
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
ana_program
	banksel TRISB		; BANK1 seçildi.
	movlw	0x06		;
	movwf	ADCON1		; Analog giriþler kapatýldý.
	movwf	TRISA		; RA1 ve RA2 giriþe ayarlandý, diðerleri 
				; çýkýþ.
	clrf	TRISB		; PORTB çýkýþa yönlendirildi.
	clrf	TRISD		; PORTD çýkýþ yapýldý.
	banksel PORTB		; BANK0 seçildi.
	clrf	sayac		; Sayaç sýfýrlandý.
dongu
	movf	sayac, W	; Sayaç deðeri alýnýyor.
	call	ortak_anot	; Sayaçtaki rakamýn ortak anot display 
				; için segment bilgisi alýnýyor.
	movwf	DISPLAY1	; Elde edilen segment deðerini DISPLAY1'de 
				; görüntüle.
	movf	sayac, W	; Sayaç deðeri alýnýyor.
	call	ortak_katot	; Sayaçtaki rakamýn ortak katot display 
				; için segment bilgisi alýnýyor.
	movwf	DISPLAY2	; Elde edilen segment deðerini DISPLAY2'de 
				; görüntüle.
	btfsc	BUTON		; BUTON basýlana kadar bekle.
	goto	$-1
	btfss	BUTON		; BUTON býrakýlana kadar bekle.
	goto	$-1
	incf	sayac		; Sayacý bir artýr.
	movlw	.10
	subwf	sayac ,W
	btfsc	STATUS, Z	; Sayacý 10 ile karþýlaþtýr. Farklý ise 
				; bir komut atla.
	clrf	sayac		; sayaç = 10 ise sayacý sýfýrla, deðilse 
				; bir þey yapmadan geri dön.
	goto	dongu

	end
;******************************************************************* 

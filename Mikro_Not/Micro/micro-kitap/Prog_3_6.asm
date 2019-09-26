;*******************************************************************
;	Dosya Adý		: 3_6.asm
;	Programýn Amacý	: RB4-RB7 uçlarýndaki deðiþikle uyku 
;				: modundan çýkýþý göstermek.
;	PICDK2.1a 		: PORTB<0:3> Çýkýþ ==> LED
;				: PORTB<4:7> Giriþ ==> BUTON
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A			;List dosyasýný 16F877A için 
					;oluþtur.
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, WDT off, diðerleri 
					;kapalý, Osilatör XT ve 4Mhz
sayac1	   equ		0x20
sayac2	   equ		0x21
	org		0
	goto	ana_program
	org		4
	goto	kesme
ana_program_ilk_islemler
	clrf	PORTB			;Ýlk durumu LOW.
	banksel	TRISB			;TRISB'nin bulunduðu BANK0 seçildi.
	movlw	0xF0
	movwf	TRISB			;RB0-RB3 çýkýþ, RB4-RB7 giriþ 
					;yapýldý.
	movlw	0xFF
	movwf	TRISA			;PORTA'nýn tüm pinleri giriþe 
					;yönlendirildi.
	movlw	0x06			;Analog giriþler kapatýldý. 
	movwf	ADCON1
	bsf	INTCON, RBIE		;RB4-RB7 pin durumu deðiþimleri 
					;kesmesine izin ver.
	bsf	INTCON, GIE		;Genel kesmelere izin ver.
	return
delay
	movlw	0xFF
	movwf	sayac1			;sayac1'e 0xFF deðeri yükle.
dongu1
	movlw	0xFF
	movwf	sayac2			;sayac2'e 0xFF deðeri yükle.
dongu2
	decfsz	sayac2, F		;sayac2=0 olana kadar sayacý bir 
					;azalt, sayac2=0 ise bir komut atla
	goto	dongu2
	decfsz	sayac1, F		;sayac1=0 olana kadar sayacý bir 
					;azalt, sayac1=0 ise bir komut atla
	goto	dongu1
	return
uyu
	movf	PORTB, W		;PORTB'nin deðeri W'de korunuyor.
	clrf	PORTB			;LED'ler söndürüldü.
	sleep				;Uyu.
	nop				;Bir komut çevrimi bekle.
	movwf	PORTB			;Saymaya kaldýðýn sayýdan devam et.
	return
kesme
	bcf	INTCON, GIE		; Tüm kesmeler iptal.
					;RB4-RB7 pin deðiþimlerinde 
					;yapýlacak iþlemler buraya yazýlýr.
	bcf	INTCON, 0		;RBIF
	bsf	INTCON, GIE		; Tüm kesmeleri tekrar geçerli.
	retfie
ana_program
	call	ana_program_ilk_islemler	;Portlar yönlendiriliyor.
	banksel   PORTA
RA1_test
	btfss	PORTA, 1		;RA1 butonuna basýldý mý? hayýr ise 
					; bir komut atla.
	call	uyu			; Uyu alt programýna git.
	incf	PORTB			; PORTB’yi “1” arttýr.
	call	delay			; Bir süre gecikme yap.
	goto	RA1_test		; Butonu teste devam et.
	END
;*****************************************************************

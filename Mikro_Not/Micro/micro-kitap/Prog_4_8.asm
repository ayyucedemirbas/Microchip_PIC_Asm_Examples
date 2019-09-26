;******************************************************************
;	Dosya Adý		: 4_8.asm
;	Programýn Amacý		: WDT uygulamasý.
;	PICDK2.1a 		: PORTB<0:7> Çýkýþ ==> LED
;				: PORTA<1> Dijital Giriþ <== BUTON
;				: PORTC<1> çýkýþ ==> BUZZER
;				: XT ==> 4Mhz
;******************************************************************
	list p=16F877A		;List dosyasýný 16F877A için 
				;oluþtur.
	include "p16F877A.inc"	
	__config H'3F35' 	;PWRT on, WDT on, diðerleri kapalý, 
				;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
sayac	equ	0x20
	org		0
	goto	ana_program

ana_program_ilk_islemler
	clrf	PORTB			;Ýlk durumu LOW.
	banksel	TRISB			;TRISB'nin bulunduðu BANK0 seçildi.
	clrf	TRISB			;PORTB'nin tüm pinleri çýkýþa 
					;yönlendirildi.
	movlw	0xFF
	movwf	TRISA			;PORTA'nýn tüm pinleri giriþe 
					;yönlendirildi.
	clrf	TRISC			;PORTC çýkýþa yönlendirildi.
	movlw	0x06			;Analog giriþler kapatýldý. 
	movwf	ADCON1
	banksel	PORTC
wdt_kontrol
	btfss	STATUS, 4
	goto	buzzer
	banksel  OPTION_REG		;OPTION_REG kaydedicisinin 
					;bulunduðu banka geçiliyor.
	clrwdt				;WDT zamanlayýcýsý sýfýrlandý, 
					;iþlemler yeni baþlýyor..
	movlw	b'00001111'		;WDT=ON, prescaler=1/128
	movwf	OPTION_REG		;OPTION_REG kuruldu.
	return
buzzer
	clrwdt				;WDT zamanlayýcýsýný sýfýrla.
	bsf	PORTC, 1		;PIC DK 2.1’de RC1'e baðlý buzzer 
					;çýkýþýný HIGH yap.
	call	delay			;Gecikme alt programýný çaðýr.
	bcf	PORTC, 1		;PIC DK 2.1’de RC1'e baðlý buzzer 
					;çýkýþýný LOW yap.
	call	delay			;Gecikme alt programýný çaðýr.
	goto	buzzer			;Sistem resetlenene kadar ses 
					;çýkarmaya devam et.
	return

delay
	movlw	0xFF
	movwf	sayac			;sayaca 0xFF deðeri yükle.
	decfsz	sayac, F		;sayac=0 olana kadar sayacý bir 
					;azalt, saya=0 ise bir komut atla.
	goto	$-1
	return

ana_program
	call	ana_program_ilk_islemler	;Portlar yönlendiriliyor.
	banksel  PORTA
RA1_test
	btfsc	PORTA, 1		;RA1 butonuna basýlsý ise bir komut 
					;atla.
	goto	RA1_test		;Butona basýlmadý, teste devam et.
	clrwdt				;Butona basýldý, WDT 
					;zamanlayýcýsýný sýfýrla.
	incf	PORTB			;Butona her basýldýðýnda PORTB 
					;üzerinde LED'lerdeki binary sayý 
					;artar.
	goto	RA1_test		;Butonu teste devam et.
	
	END
;*******************************************************************

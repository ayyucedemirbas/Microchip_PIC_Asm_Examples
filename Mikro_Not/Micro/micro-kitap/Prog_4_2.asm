;*******************************************************************
;	Dosya Adý		: 4_2.asm
;	Programýn Amacý		: Timer0’ýn Harici Tetikleme (RB0/INT) Ýle
;				  Sayýcý Olarak Kullanýlmasý.
;	PIC DK2.1a 		: PORTB<0:3> Çýkýþ ==> LED
;				: PORTA<4> Dijital Giriþ ==> BUTON
;				: XT ==> 4Mhz
;******************************************************************* 
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tanýmlamalarý 
				;programa katýlýyor.
	__config H'3F31' 	;PWRT on, diðerleri kapalý, 
				;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Sayaç tanýmlamalarý
;-------------------------------------------------------------------
Counter	equ 0x25
	ORG 0				;Reset vektör adresi. Program bu 
					;adresten baþlar.
	clrf 	PCLATH			;0. Program sayfasý seçildi.
	goto 	ana_program		;Ana program bloðuna git.
	ORG 4
;-------------------------------------------------------------------
; Kesme alt program bloðu
;-------------------------------------------------------------------
interrupt
	btfss	INTCON, 5 	;TMR0 kesmesine izin verilmiþ mi? 
				;( TOIE = 1 mi? )
	goto	int_j1		;HAYIR ise interrupt sonu.
	btfss 	INTCON, 2 	;TMR0 kesmesi oluþtu mu? ( TOIF = 1 mi? )
	goto	int_j1		;HAYIR ise interrupt sonu.
	movlw	0xFF		;TMR0'a ilk deðer yükleniyor.
	movwf	TMR0
	bcf	INTCON, 2	;TMR0 taþma kesme bayraðý siliniyor.
	incf 	Counter, F	;Kesme sayacý artýrýlýyor.
	movf 	Counter, W	;Sayaç W register’ine aktarýlýyor.
	sublw 	D'15'		;W içeriði dolayýsýyle sayaç 15'ten büyük 
				;ise sayacý sýfýrla.
	btfss 	STATUS, C
	clrf 	Counter
	movf 	Counter, W	;Sayaç içeriðini W'ye aktar.
	movwf 	PORTB 		;Sayaç içeriðini LED’lerde göster.
int_j1
	retfie
;-------------------------------------------------------------------
; Ýlk iþlemler bloðu:
; Port yönlendirmeleri, ilk durum atamalarý yapýlýyor. Kesmeler 
; aktif hale getiriliyor.
;-------------------------------------------------------------------
ilk_islemler
	movlw 	b'11100001'
	banksel OPTION_REG
	movwf 	OPTION_REG
	movlw 	0xFF
	movwf 	TRISA
	clrf 	PORTB
	bcf 	STATUS, RP0
	clrf 	PORTB
	movlw 	0xFF
	movwf 	TMR0
	clrf 	Counter
	bsf 	INTCON, TMR0IE
	bsf 	INTCON, PEIE
	bsf 	INTCON, GIE
	return
;-------------------------------------------------------------------
; Ana program bloðu: 
; Ýlk iþlemler yapýldýktan sonra boþ döngü. Yalnýzca kesmeler 
; iþleniyor.
;-------------------------------------------------------------------
ana_program
	call	ilk_islemler	;Port yönlendirme, ilk çýkýþlar, ilk 
				;zamanlama, kesme ayar ve baþlatma
				;iþlemleri alt programý çaðrýlýyor.
ana_j1
	goto 	ana_j1		;Sonsuz boþ döngü iþletiliyor.

	END			;Assembly programý sonu.
;*******************************************************************

;*******************************************************************
;	Dosya Ad�		: 4_2.asm
;	Program�n Amac�		: Timer0��n Harici Tetikleme (RB0/INT) �le
;				  Say�c� Olarak Kullan�lmas�.
;	PIC DK2.1a 		: PORTB<0:3> ��k�� ==> LED
;				: PORTA<4> Dijital Giri� ==> BUTON
;				: XT ==> 4Mhz
;******************************************************************* 
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tan�mlamalar� 
				;programa kat�l�yor.
	__config H'3F31' 	;PWRT on, di�erleri kapal�, 
				;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Saya� tan�mlamalar�
;-------------------------------------------------------------------
Counter	equ 0x25
	ORG 0				;Reset vekt�r adresi. Program bu 
					;adresten ba�lar.
	clrf 	PCLATH			;0. Program sayfas� se�ildi.
	goto 	ana_program		;Ana program blo�una git.
	ORG 4
;-------------------------------------------------------------------
; Kesme alt program blo�u
;-------------------------------------------------------------------
interrupt
	btfss	INTCON, 5 	;TMR0 kesmesine izin verilmi� mi? 
				;( TOIE = 1 mi? )
	goto	int_j1		;HAYIR ise interrupt sonu.
	btfss 	INTCON, 2 	;TMR0 kesmesi olu�tu mu? ( TOIF = 1 mi? )
	goto	int_j1		;HAYIR ise interrupt sonu.
	movlw	0xFF		;TMR0'a ilk de�er y�kleniyor.
	movwf	TMR0
	bcf	INTCON, 2	;TMR0 ta�ma kesme bayra�� siliniyor.
	incf 	Counter, F	;Kesme sayac� art�r�l�yor.
	movf 	Counter, W	;Saya� W register�ine aktar�l�yor.
	sublw 	D'15'		;W i�eri�i dolay�s�yle saya� 15'ten b�y�k 
				;ise sayac� s�f�rla.
	btfss 	STATUS, C
	clrf 	Counter
	movf 	Counter, W	;Saya� i�eri�ini W'ye aktar.
	movwf 	PORTB 		;Saya� i�eri�ini LED�lerde g�ster.
int_j1
	retfie
;-------------------------------------------------------------------
; �lk i�lemler blo�u:
; Port y�nlendirmeleri, ilk durum atamalar� yap�l�yor. Kesmeler 
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
; Ana program blo�u: 
; �lk i�lemler yap�ld�ktan sonra bo� d�ng�. Yaln�zca kesmeler 
; i�leniyor.
;-------------------------------------------------------------------
ana_program
	call	ilk_islemler	;Port y�nlendirme, ilk ��k��lar, ilk 
				;zamanlama, kesme ayar ve ba�latma
				;i�lemleri alt program� �a�r�l�yor.
ana_j1
	goto 	ana_j1		;Sonsuz bo� d�ng� i�letiliyor.

	END			;Assembly program� sonu.
;*******************************************************************

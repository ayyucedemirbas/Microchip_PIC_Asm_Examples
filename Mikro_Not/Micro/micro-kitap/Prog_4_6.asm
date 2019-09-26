;*******************************************************************
;	Dosya Adý		: 4_6.asm
;	Programýn Amacý		: Timer2’nin Zamanlayýcý Olarak
; 				  Kullanýlmasý.
;	PIC DK2.1 		: PORTB<0:7> Çýkýþ ==> LED
;				: XT ==> 4 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F39' 		;Tüm program sigortalarý kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý.
;-------------------------------------------------------------------
Counter equ	0x20

	ORG 	0
	clrf 	PCLATH		
	goto 	ana_program	
	ORG 	4
;-------------------------------------------------------------------
; Kesme alt programý:TMR2’ye ait her kesmede Counter kesme adedini sayar
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;BANK0 seçildi.
	btfss	PIR1, 1		;TMR2IF=1? Kesme kaynaðý TMR2'mi?
	goto	int_j1		;Hayýr ise kesme sonuna git.
	incf 	Counter, F	;sayacý artýr.
	bcf 	PIR1, 1		;TMR2IF=0
int_j1
	retfie
;-------------------------------------------------------------------
; Ana program: Port yönlendirme, Zamanlayýcý ayarý ve ana program 
; döngüsü burada.
;-------------------------------------------------------------------
ana_program
	banksel TRISB		;BANK1 seçildi.
	clrf 	TRISB		;PORTB çýkýþa ayarlandý.
	bcf 	STATUS, RP0	;BANK0 seçildi.
	clrf 	PORTB		;PORTB çýkýþ kaydedicisi sýfýrlandý.
	clrf 	Counter
	movlw	0xFF
	movwf 	T2CON		;TMR2=ON, 1:16 postscale, TMR2ON
	clrf	TMR2		;TMR2 zamanlayýcýsý resetlendi.
	bsf 	STATUS, RP0	;BANK1 seçildi.
	bsf	PIE1, 1		;TMR2 kesmesi etkinleþtirildi.
	movlw	0xC0		;PEIE kesmeleri ve GIE Kesme izni 
				;aktifleþtirildi.
	movwf	INTCON
ana_j1
	movf 	Counter, W
	sublw 	D'30'
	btfsc 	STATUS, C	;Counter>30 ise bir komut atla (30 
				;kez kesme oluþtu.)
	goto 	ana_j1
	bcf 	STATUS, RP0
	bcf 	STATUS, RP1	;BANK0 seçildi.
	comf 	PORTB, W	;POTRB'deki bilginin 1. komplementi 
				;alýndý ve 
				;W register’ine aktarýldý.
	movwf 	PORTB		;W’deki bilgi PORTB'ye aktarýldý.
	clrf 	Counter		;Sayac sýfýrlandý.
	goto 	ana_j1		;Ana program döngüsüne devam et.

	END			;Assembly programý sonu.
;******************************************************************

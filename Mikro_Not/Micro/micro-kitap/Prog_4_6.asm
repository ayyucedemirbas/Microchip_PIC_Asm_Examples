;*******************************************************************
;	Dosya Ad�		: 4_6.asm
;	Program�n Amac�		: Timer2�nin Zamanlay�c� Olarak
; 				  Kullan�lmas�.
;	PIC DK2.1 		: PORTB<0:7> ��k�� ==> LED
;				: XT ==> 4 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F39' 		;T�m program sigortalar� kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�.
;-------------------------------------------------------------------
Counter equ	0x20

	ORG 	0
	clrf 	PCLATH		
	goto 	ana_program	
	ORG 	4
;-------------------------------------------------------------------
; Kesme alt program�:TMR2�ye ait her kesmede Counter kesme adedini sayar
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;BANK0 se�ildi.
	btfss	PIR1, 1		;TMR2IF=1? Kesme kayna�� TMR2'mi?
	goto	int_j1		;Hay�r ise kesme sonuna git.
	incf 	Counter, F	;sayac� art�r.
	bcf 	PIR1, 1		;TMR2IF=0
int_j1
	retfie
;-------------------------------------------------------------------
; Ana program: Port y�nlendirme, Zamanlay�c� ayar� ve ana program 
; d�ng�s� burada.
;-------------------------------------------------------------------
ana_program
	banksel TRISB		;BANK1 se�ildi.
	clrf 	TRISB		;PORTB ��k��a ayarland�.
	bcf 	STATUS, RP0	;BANK0 se�ildi.
	clrf 	PORTB		;PORTB ��k�� kaydedicisi s�f�rland�.
	clrf 	Counter
	movlw	0xFF
	movwf 	T2CON		;TMR2=ON, 1:16 postscale, TMR2ON
	clrf	TMR2		;TMR2 zamanlay�c�s� resetlendi.
	bsf 	STATUS, RP0	;BANK1 se�ildi.
	bsf	PIE1, 1		;TMR2 kesmesi etkinle�tirildi.
	movlw	0xC0		;PEIE kesmeleri ve GIE Kesme izni 
				;aktifle�tirildi.
	movwf	INTCON
ana_j1
	movf 	Counter, W
	sublw 	D'30'
	btfsc 	STATUS, C	;Counter>30 ise bir komut atla (30 
				;kez kesme olu�tu.)
	goto 	ana_j1
	bcf 	STATUS, RP0
	bcf 	STATUS, RP1	;BANK0 se�ildi.
	comf 	PORTB, W	;POTRB'deki bilginin 1. komplementi 
				;al�nd� ve 
				;W register�ine aktar�ld�.
	movwf 	PORTB		;W�deki bilgi PORTB'ye aktar�ld�.
	clrf 	Counter		;Sayac s�f�rland�.
	goto 	ana_j1		;Ana program d�ng�s�ne devam et.

	END			;Assembly program� sonu.
;******************************************************************

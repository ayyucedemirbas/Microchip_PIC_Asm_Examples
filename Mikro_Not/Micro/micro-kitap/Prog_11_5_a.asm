;*******************************************************************
;	Dosya Ad�		: 11_5_a.asm
;	Program�n Amac�		: 4x4 tu� tak�m� ile USART senkron ileti�im
;	PIC DK2.1a 		: PORTB<1:2> ��k�� ==> PIC16F628A
;				: XT ==> 4Mhz
;*******************************************************************
	list      p=16f628A
	#include <p16F628A.inc>
	__CONFIG   	_CP_OFF & _DATA_CP_OFF & _LVP_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT
;-------------------------------------------------------------------
; De�i�ken tan�mlama
;-------------------------------------------------------------------
tus		equ	0x20
tus_old		equ	0x21

	ORG     0x000
	goto	main
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
main
	call	initial 		;PIC 16F84��n portlar�n� ayarla.
tekrar		
	call	tus_tara		;Hangi tu�a bas�ld���n� bul.
	call	snkMasterWrite		;RB1, RB2'den senkron seri olarak 
	goto	tekrar			;g�nder.

initial
	movlw	b'00000111'
	movwf	CMCON			;Kar��la�t�rma giri�leri kapat�ld�.
	bsf	STATUS,RP0		;BANK0 se�ildi.
	movlw 	b'11110000'		
	movwf	TRISA			;PORTA(RA0-RA3=��k��,RA4-RA7=giri�)
	movlw	b'00000000'
	movwf	TRISB			;PORTB ��k�� yap�ld�.

	movlw	0x09			;(Synchronous) Baud Rate = Fosc/(4(X+1))
					;Baud Rate 	= 4.000.000/(4*(9+1))
					;      = 4.000.000/40 =100.000 Hz
	banksel SPBRG
	movwf	SPBRG			;Baud Rate de�eri SPBRG 
					;kaydedicisine y�klendi.
	banksel TXSTA
	bsf	TXSTA, SYNC		;Senkron ileti�im se�ildi.	
	bsf	TXSTA, CSRC		;Clock kayna�� se�me bit�i set 
					;edildi.Kaynak: BRG registeri
	bsf	PIE1, TXIE		;Veri g�nderme kesmesi 
					;etkinle�tirildi.
	bcf	TXSTA, TX9		;TX9 kullan�lm�yor, 8 bit veri 
					;ileti�imi.
	bsf	TXSTA, TXEN		;Veri g�nderme etkinle�tirildi.
	banksel RCSTA			;BANK0 se�ildi.
	bcf	RCSTA, SREN		;Veri okuma olay� yok.
	bsf	RCSTA, SPEN		;Senkron master seri port aktif 
					;hale getirildi.
	return

tus_tara
sutun0
	movlw	b'00000001'
	movwf	PORTA			;0. sutun aktif.
sifir					;sutun=0, sat�r=0
	btfsc	PORTA, 4		;0. sat�rdaki tu�a bas�l� m�?
	retlw	d'0'
dort					;sutun=0, sat�r=1
	btfsc	PORTA, 5		;1. sat�rdaki tu�a bas�l� m�?
	retlw	d'4'
sekiz					;sutun=0, sat�r=2
	btfsc	PORTA, 6		;2. sat�rdaki tu�a bas�l� m�?
	retlw	d'8'
oniki					;sutun=0, sat�r=3
	btfsc	PORTA, 7		;3. sat�rdaki tu�a bas�l� m�?
	retlw	d'12'
sutun1
	movlw	b'000000010'
	movwf	PORTA			;1. sutun aktif
bir					;sutun=1, sat�r=0
	btfsc	PORTA, 4		;0. sat�rdaki tu�a bas�l� m�?
	retlw	d'1'
bes					;sutun=1, sat�r=1
	btfsc	PORTA, 5		;1. sat�rdaki tu�a bas�l� m�?
	retlw	d'5'
dokuz					;sutun=1, sat�r=2
	btfsc	PORTA, 6		;2. sat�rdaki tu�a bas�l� m�?
	retlw	d'9'
onuc					;sutun=1, sat�r=3
	btfsc	PORTA, 7		;3. sat�rdaki tu�a bas�l� m�?
	retlw	d'13'
sutun2
	movlw	b'00000100'
	movwf	PORTA			;2. sutun aktif
iki					;sutun=2, sat�r=0
	btfsc	PORTA, 4		;0. sat�rdaki tu�a bas�l� m�?
	retlw	d'2'
alti					;sutun=2, sat�r=1
	btfsc	PORTA, 5		;1. sat�rdaki tu�a bas�l� m�?
	retlw	d'6'
on					;sutun=2, sat�r=2
	btfsc	PORTA, 6		;2. sat�rdaki tu�a bas�l� m�?
	retlw	d'10'
ondort					;sutun=2, sat�r=3
	btfsc	PORTA, 7		;3. sat�rdaki tu�a bas�l� m�?
	retlw	d'14'
sutun3
	movlw	b'00001000'
	movwf	PORTA			;3. sutun aktif
uc					;sutun=3, sat�r=0
	btfsc	PORTA, 4		;0. sat�rdaki tu�a bas�l� m�?
	retlw	d'3'
yedi					;sutun=3, sat�r=1
	btfsc	PORTA, 5		;1. sat�rdaki tu�a bas�l� m�?
	retlw	d'7'
onbir					;sutun=3, sat�r=2
	btfsc	PORTA, 6		;2. sat�rdaki tu�a bas�l� m�?
	retlw	d'11'
onbes					;sutun=3, sat�r=3
	btfsc	PORTA, 7		;3. sat�rdaki tu�a bas�l� m�?
	retlw	d'15'
	retlw	d'255'			;Herhangi bir tu�a bas�lmad� ise 
					;0xFF d�nd�r.
	return

snkMasterWrite
	movwf	tus
	movfw	tus_old
	xorwf	tus, W			
	btfsc	STATUS, Z	    	;Bas�lan tu� �nceki tustan farkl� m�?
	return				;De�il ise ��k.
	movf	tus, W			;farkl�.
	banksel TXREG			;TXREG kaydedicisinin bulundu�u 
					;bank se�ildi.
	movwf	TXREG
	banksel PIR1;			;PIR1 kaydedicisinin bulundu�u bank 
					;se�ildi.
	btfss	PIR1, TXIF		;set ise veri transfer edilmi� 
					;demektir, bir komut atla.
	goto	$-1			;bir geriye. Tekrar kontrol et.
	bcf	PIR1, TXIF		;Veri g�nderme kesme bayra��n� sil.
	movfw	tus					
	movwf	tus_old			;tus_old <- tus
	return

	END
;*******************************************************************

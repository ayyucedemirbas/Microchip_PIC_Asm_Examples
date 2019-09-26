;*******************************************************************
;	Dosya Adý		: 11_5_a.asm
;	Programýn Amacý		: 4x4 tuþ takýmý ile USART senkron iletiþim
;	PIC DK2.1a 		: PORTB<1:2> Çýkýþ ==> PIC16F628A
;				: XT ==> 4Mhz
;*******************************************************************
	list      p=16f628A
	#include <p16F628A.inc>
	__CONFIG   	_CP_OFF & _DATA_CP_OFF & _LVP_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT
;-------------------------------------------------------------------
; Deðiþken tanýmlama
;-------------------------------------------------------------------
tus		equ	0x20
tus_old		equ	0x21

	ORG     0x000
	goto	main
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
main
	call	initial 		;PIC 16F84’ün portlarýný ayarla.
tekrar		
	call	tus_tara		;Hangi tuþa basýldýðýný bul.
	call	snkMasterWrite		;RB1, RB2'den senkron seri olarak 
	goto	tekrar			;gönder.

initial
	movlw	b'00000111'
	movwf	CMCON			;Karþýlaþtýrma giriþleri kapatýldý.
	bsf	STATUS,RP0		;BANK0 seçildi.
	movlw 	b'11110000'		
	movwf	TRISA			;PORTA(RA0-RA3=çýkýþ,RA4-RA7=giriþ)
	movlw	b'00000000'
	movwf	TRISB			;PORTB çýkýþ yapýldý.

	movlw	0x09			;(Synchronous) Baud Rate = Fosc/(4(X+1))
					;Baud Rate 	= 4.000.000/(4*(9+1))
					;      = 4.000.000/40 =100.000 Hz
	banksel SPBRG
	movwf	SPBRG			;Baud Rate deðeri SPBRG 
					;kaydedicisine yüklendi.
	banksel TXSTA
	bsf	TXSTA, SYNC		;Senkron iletiþim seçildi.	
	bsf	TXSTA, CSRC		;Clock kaynaðý seçme bit’i set 
					;edildi.Kaynak: BRG registeri
	bsf	PIE1, TXIE		;Veri gönderme kesmesi 
					;etkinleþtirildi.
	bcf	TXSTA, TX9		;TX9 kullanýlmýyor, 8 bit veri 
					;iletiþimi.
	bsf	TXSTA, TXEN		;Veri gönderme etkinleþtirildi.
	banksel RCSTA			;BANK0 seçildi.
	bcf	RCSTA, SREN		;Veri okuma olayý yok.
	bsf	RCSTA, SPEN		;Senkron master seri port aktif 
					;hale getirildi.
	return

tus_tara
sutun0
	movlw	b'00000001'
	movwf	PORTA			;0. sutun aktif.
sifir					;sutun=0, satýr=0
	btfsc	PORTA, 4		;0. satýrdaki tuþa basýlý mý?
	retlw	d'0'
dort					;sutun=0, satýr=1
	btfsc	PORTA, 5		;1. satýrdaki tuþa basýlý mý?
	retlw	d'4'
sekiz					;sutun=0, satýr=2
	btfsc	PORTA, 6		;2. satýrdaki tuþa basýlý mý?
	retlw	d'8'
oniki					;sutun=0, satýr=3
	btfsc	PORTA, 7		;3. satýrdaki tuþa basýlý mý?
	retlw	d'12'
sutun1
	movlw	b'000000010'
	movwf	PORTA			;1. sutun aktif
bir					;sutun=1, satýr=0
	btfsc	PORTA, 4		;0. satýrdaki tuþa basýlý mý?
	retlw	d'1'
bes					;sutun=1, satýr=1
	btfsc	PORTA, 5		;1. satýrdaki tuþa basýlý mý?
	retlw	d'5'
dokuz					;sutun=1, satýr=2
	btfsc	PORTA, 6		;2. satýrdaki tuþa basýlý mý?
	retlw	d'9'
onuc					;sutun=1, satýr=3
	btfsc	PORTA, 7		;3. satýrdaki tuþa basýlý mý?
	retlw	d'13'
sutun2
	movlw	b'00000100'
	movwf	PORTA			;2. sutun aktif
iki					;sutun=2, satýr=0
	btfsc	PORTA, 4		;0. satýrdaki tuþa basýlý mý?
	retlw	d'2'
alti					;sutun=2, satýr=1
	btfsc	PORTA, 5		;1. satýrdaki tuþa basýlý mý?
	retlw	d'6'
on					;sutun=2, satýr=2
	btfsc	PORTA, 6		;2. satýrdaki tuþa basýlý mý?
	retlw	d'10'
ondort					;sutun=2, satýr=3
	btfsc	PORTA, 7		;3. satýrdaki tuþa basýlý mý?
	retlw	d'14'
sutun3
	movlw	b'00001000'
	movwf	PORTA			;3. sutun aktif
uc					;sutun=3, satýr=0
	btfsc	PORTA, 4		;0. satýrdaki tuþa basýlý mý?
	retlw	d'3'
yedi					;sutun=3, satýr=1
	btfsc	PORTA, 5		;1. satýrdaki tuþa basýlý mý?
	retlw	d'7'
onbir					;sutun=3, satýr=2
	btfsc	PORTA, 6		;2. satýrdaki tuþa basýlý mý?
	retlw	d'11'
onbes					;sutun=3, satýr=3
	btfsc	PORTA, 7		;3. satýrdaki tuþa basýlý mý?
	retlw	d'15'
	retlw	d'255'			;Herhangi bir tuþa basýlmadý ise 
					;0xFF döndür.
	return

snkMasterWrite
	movwf	tus
	movfw	tus_old
	xorwf	tus, W			
	btfsc	STATUS, Z	    	;Basýlan tuþ önceki tustan farklý mý?
	return				;Deðil ise çýk.
	movf	tus, W			;farklý.
	banksel TXREG			;TXREG kaydedicisinin bulunduðu 
					;bank seçildi.
	movwf	TXREG
	banksel PIR1;			;PIR1 kaydedicisinin bulunduðu bank 
					;seçildi.
	btfss	PIR1, TXIF		;set ise veri transfer edilmiþ 
					;demektir, bir komut atla.
	goto	$-1			;bir geriye. Tekrar kontrol et.
	bcf	PIR1, TXIF		;Veri gönderme kesme bayraðýný sil.
	movfw	tus					
	movwf	tus_old			;tus_old <- tus
	return

	END
;*******************************************************************

;*******************************************************************
;	Dosya Adý		: 4_3.asm
;	Programýn Amacý		: Timer1’in Zamanlayýcý Olarak
; 				  Kullanýlmasý görmek.
;	PICDK2.1a 		: PORTB<0:7> Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************	
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tanýmlamalarý 
				;programa katýlýyor.
	__config H'3F31' 	;PWRT on, diðerleri kapalý, 
				;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý
;-------------------------------------------------------------------
Counter	equ	0x20		;Deðiþkeninin RAM’deki yeri.

	ORG 	0		;Reset vektör adresi.
	clrf 	PCLATH		;0. program sayfasý seçildi.
	goto 	ana_program	;Ana programa git.
	ORG 	4		;Kesme vektör adresi.
;-------------------------------------------------------------------
; Kesme programý: Kesme kaynaðý sadece TMR1 seçildiði için ekstra 
; kontrol yapýlmadý. Timer1 zamanlayýcýsýnda taþma oluþtuðunda 
; Counter deðiþkeni kesme adedini sayar.
;-------------------------------------------------------------------
interrupt
	incf 	Counter, F	;8 bit’lik Counter deðiþkeni artýrýldý.
	banksel  PIR1		;BANK1 seçildi.
	bcf 	PIR1, 0		;TMR1IF=0
	retfie
;-------------------------------------------------------------------
; Ana program: Portlarýn yönlendirilmesi, Timer1 zamanlayýcýsýnýn 
; kurulmasý, kesmelere izin verilmesi ve Kesme adedinin kontrol 
; edilmesi ile yaklaþýk 10 saniyede bir PORTB’nin komplementi 
; (1. tümleyeni) alýnarak PORTB’den çýkýþa aktarýlmasýný saðlar.
;-------------------------------------------------------------------

ana_program
	banksel TRISB			;BANK1 seçildi.
	clrf 	TRISB			;PORTD çýkýþa ayarlandý.
	movlw 	0x01
	banksel T1CON			;BANK0 seçildi.
	movwf 	T1CON			;TMR1=ON internal clock, Fosc/4, 
					;prescale yok.
	bcf 	PIR1, TMR1IF
	banksel PIE1			;BANK1 seçildi.
	bsf 	PIE1, TMR1IE		;TMRIE=1, Timer1 kesmesi aktif 
					;yapýldý.
	movlw 	0xF0
	banksel PORTB			;BANK0 seçildi.
	movwf 	PORTB			;PORTB'den 0xF0 bilgi çýkýþý yapýldý.
	clrf 	Counter			;8 bit’lik Counter deðiþkeni sýfýrlandý.
	movlw 	0xC0			
	movwf 	INTCON			;INTCON = 0xC0, GIE ve PEIE set edildi.
ana_j1					;Counter 152'ye ulaþtý mý?
	movlw 	D'152'			;yaklaþýk 4 Mhz'de 10sn'lik bir zamanlama 
	subwf 	Counter, W		;(10 milyon komut çevrimi / 65536) = 
					;152.587...
	btfss 	STATUS, Z
	goto 	ana_j1			;Counter<152 ise ana_j1 etiketine git.
	comf 	PORTB, W		;PORTB çýkýþ kaydedicisinin 1.Komplementi 
					;W'ye yazýldý.
	movwf	PORTB			;W içeriði PORTB'ye aktarýldý.
	clrf 	Counter			;8 bit’lik Counter deðiþkeni sýfýrlandý.
	goto 	ana_j1			;Ayný iþlemleri sürekli yap.

	END				;Assembly programý sonu.
;******************************************************************

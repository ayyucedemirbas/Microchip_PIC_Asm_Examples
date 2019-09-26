;*****************************************************************
;	Dosya Adý		: 6_11_1.asm
;	Programýn Amacý		: USART Modülü Ýle Ýki Mikrodenetleyici
;		 		Arasýnda Master/Slave Senkron Seri Veri Ýletiþimi
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
list      p=16f877A
	#include <p16F877A.inc>
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4 Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlama
;-------------------------------------------------------------------
delay_ms_data	 equ 0x20	;delay_ms için 2 byte'lýk deðiþken 
				;tanýmý yapýlýyor.
sayac		 equ 0x22

	ORG    0x000
	goto	main
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
main
	call	initial 		;PIC 16F877A’nýn portlarýný ayarla.
tekrar		
	incf	sayac			;sayac deðerini bir artýr.
	movf	sayac, W		;sayac deðeri W'de.
	call	snkMasterWrite		;RC7, RC6'den senkron seri olarak
					;gönder.
	movlw	D'250'			;250 ms deðerini delay_ms_data
					;deðiþkenine yaz.
	movwf	delay_ms_data	;
	call	delay_ms		;250 ms bekle.
	goto	tekrar
;-------------------------------------------------------------------
; Ýlk iþlemler bölümü.
;-------------------------------------------------------------------
initial
	bsf	STATUS,RP0		;BANK1 seçildi.
	clrf	TRISC			;PORTC çýkýþ yapýldý.
	movlw	0x09			;Baud Rate = Fosc/(4(X+1))
					;Baud Rate = 4.000.000/(4*(9+1))
					; = 4.000.000/40 =100.000 Hz.
	banksel	SPBRG
	movwf	SPBRG			;Baud Rate deðeri SPBRG 
					;kaydedicisine yüklendi.
	banksel TXSTA
	bsf	TXSTA, SYNC		;Senkron iletiþim seçildi.	
	bsf	TXSTA, CSRC		;Clock kaynaðý seçme bit’i set 
					;edildi.Kaynak: BRG kaydedicisi.
	bsf	PIE1, TXIE		;Veri gönderme kesmesi 
					;etkinleþtirildi
	bcf	TXSTA, TX9		;TX9 kullanýlmýyor, 8 bit veri 
					;iletiþimi.
	bsf	TXSTA, TXEN		;Veri gönderme etkinleþtirildi.
	banksel RCSTA			;BANK0 seçildi.
	bcf	RCSTA, SREN		;Veri okuma olayý yok.
	bsf	RCSTA, SPEN		;Senkron master seri port aktif 
					;hale getirildi.
	clrf	sayac
	return
;-------------------------------------------------------------------
; delay_ms alt programý 1-255 ms arasýnda deðiþken bekleme süresi 
; saðlar. delay_ms_data yüksek byte deðiþkenine yüklenecek deðer 
; kadar ms olarak gecikme saðlar
;-------------------------------------------------------------------
delay_ms
delay_j0
	movlw	D'142'			;1 ms gecikme için taban deðer.
	movwf	delay_ms_data+1		;delay parametresinin düþük
					;byte'ýna yüklendi.
	nop				;2 us bekle.
	nop
delay_j1
	nop				;4 us gecikme.
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F	;delay parametresinin düþük 
					;byte'ýný azalt sýfýrsa bir komut 
					;atla.
	goto	delay_j1		;Henüz 1 ms gecikme saðlanamadý, 
					;düþük byte'ý azaltmaya devam et.
	nop				;1 us bekle.
	decfsz	delay_ms_data, F	;delay parametresinin yüksek 
					;byte'ýný azalt sýfýrsa bir komut 
					;atla.
	goto	delay_j0		;1 ms beklemeyi tekrarla.
	nop				;1 us bekle.
	return				;Alt programdan çýkýþ.

snkMasterWrite
	banksel TXREG			;TXREG kaydedicisinin bulunduðu 
					;bank seçildi.
	movwf	TXREG
	banksel PIR1			;PIR1 kaydedicisinin bulunduðu bank 
					;seçildi.
	btfss	PIR1, TXIF		;set ise veri transfer edilmiþ 
					;demektir, bir komut atla.
	goto	$-1			;Bir geriye git, tekrar kontrol et.
	bcf	PIR1, TXIF		;Veri gönderme kesme bayraðýný sil.
	return

	END
;*******************************************************************

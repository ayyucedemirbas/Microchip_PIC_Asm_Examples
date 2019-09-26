;*****************************************************************
;	Dosya Ad�		: 6_11_1.asm
;	Program�n Amac�		: USART Mod�l� �le �ki Mikrodenetleyici
;		 		Aras�nda Master/Slave Senkron Seri Veri �leti�imi
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
list      p=16f877A
	#include <p16F877A.inc>
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4 Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlama
;-------------------------------------------------------------------
delay_ms_data	 equ 0x20	;delay_ms i�in 2 byte'l�k de�i�ken 
				;tan�m� yap�l�yor.
sayac		 equ 0x22

	ORG    0x000
	goto	main
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
main
	call	initial 		;PIC 16F877A�n�n portlar�n� ayarla.
tekrar		
	incf	sayac			;sayac de�erini bir art�r.
	movf	sayac, W		;sayac de�eri W'de.
	call	snkMasterWrite		;RC7, RC6'den senkron seri olarak
					;g�nder.
	movlw	D'250'			;250 ms de�erini delay_ms_data
					;de�i�kenine yaz.
	movwf	delay_ms_data	;
	call	delay_ms		;250 ms bekle.
	goto	tekrar
;-------------------------------------------------------------------
; �lk i�lemler b�l�m�.
;-------------------------------------------------------------------
initial
	bsf	STATUS,RP0		;BANK1 se�ildi.
	clrf	TRISC			;PORTC ��k�� yap�ld�.
	movlw	0x09			;Baud Rate = Fosc/(4(X+1))
					;Baud Rate = 4.000.000/(4*(9+1))
					; = 4.000.000/40 =100.000 Hz.
	banksel	SPBRG
	movwf	SPBRG			;Baud Rate de�eri SPBRG 
					;kaydedicisine y�klendi.
	banksel TXSTA
	bsf	TXSTA, SYNC		;Senkron ileti�im se�ildi.	
	bsf	TXSTA, CSRC		;Clock kayna�� se�me bit�i set 
					;edildi.Kaynak: BRG kaydedicisi.
	bsf	PIE1, TXIE		;Veri g�nderme kesmesi 
					;etkinle�tirildi
	bcf	TXSTA, TX9		;TX9 kullan�lm�yor, 8 bit veri 
					;ileti�imi.
	bsf	TXSTA, TXEN		;Veri g�nderme etkinle�tirildi.
	banksel RCSTA			;BANK0 se�ildi.
	bcf	RCSTA, SREN		;Veri okuma olay� yok.
	bsf	RCSTA, SPEN		;Senkron master seri port aktif 
					;hale getirildi.
	clrf	sayac
	return
;-------------------------------------------------------------------
; delay_ms alt program� 1-255 ms aras�nda de�i�ken bekleme s�resi 
; sa�lar. delay_ms_data y�ksek byte de�i�kenine y�klenecek de�er 
; kadar ms olarak gecikme sa�lar
;-------------------------------------------------------------------
delay_ms
delay_j0
	movlw	D'142'			;1 ms gecikme i�in taban de�er.
	movwf	delay_ms_data+1		;delay parametresinin d���k
					;byte'�na y�klendi.
	nop				;2 us bekle.
	nop
delay_j1
	nop				;4 us gecikme.
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F	;delay parametresinin d���k 
					;byte'�n� azalt s�f�rsa bir komut 
					;atla.
	goto	delay_j1		;Hen�z 1 ms gecikme sa�lanamad�, 
					;d���k byte'� azaltmaya devam et.
	nop				;1 us bekle.
	decfsz	delay_ms_data, F	;delay parametresinin y�ksek 
					;byte'�n� azalt s�f�rsa bir komut 
					;atla.
	goto	delay_j0		;1 ms beklemeyi tekrarla.
	nop				;1 us bekle.
	return				;Alt programdan ��k��.

snkMasterWrite
	banksel TXREG			;TXREG kaydedicisinin bulundu�u 
					;bank se�ildi.
	movwf	TXREG
	banksel PIR1			;PIR1 kaydedicisinin bulundu�u bank 
					;se�ildi.
	btfss	PIR1, TXIF		;set ise veri transfer edilmi� 
					;demektir, bir komut atla.
	goto	$-1			;Bir geriye git, tekrar kontrol et.
	bcf	PIR1, TXIF		;Veri g�nderme kesme bayra��n� sil.
	return

	END
;*******************************************************************

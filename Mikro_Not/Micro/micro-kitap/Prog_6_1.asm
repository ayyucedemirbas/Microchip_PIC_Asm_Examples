;*******************************************************************
;	Dosya Ad�		: 6_1.asm
;	Program�n Amac�		: SFR�siz Asenkron Seri veri �leti�imi.
;	PIC DK2.1a 		: ��k�� ==> RS232�den PC�ye
;				: XT ==> 20Mhz
;*******************************************************************
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F3A' 	;T�m program sigortalar� kapal�, 
				;Osilat�r HS ve 20Mhz
;-------------------------------------------------------------------
; PORT tan�mlamalar� ve de�i�ken tan�mlar� yap�l�yor.
;-------------------------------------------------------------------
#define RS_Port PORTC
#define RS_Tris TRISC
#define RS_TX   6
#define RS_RX   7

rs232_data	equ	0x20		;Rs232'den okunan verinin 
					;kaydedildi�i ve g�nderilirken ;kullan�lan de�i�ken.
sayac		equ	0x21		;8 bit sayac�.
delay_sayac	equ	0x22		;delay sayac�.

	org	0
	goto	ana_program
;-------------------------------------------------------------------
; 9600 baud rate ileti�im h�z�nda her bir bit�in s�resi 104.2 us'dir. 
; 20MHz'de 104.2 us gecikme sa�lar.
;-------------------------------------------------------------------
rs232_delay1
	movlw	.171		
	banksel	delay_sayac
	movwf	delay_sayac
	decfsz	delay_sayac, F
	goto	$-1
	nop
	return
;-------------------------------------------------------------------
; 9600 baud rate ileti�im h�z�nda 20MHz'de 50 us gecikme sa�lar.
;-------------------------------------------------------------------
rs232_delay2
	movlw	.81
	banksel	delay_sayac
	movwf	delay_sayac
	decfsz	delay_sayac, F
	goto	$-1
	return
;-------------------------------------------------------------------
; Port y�nlendirme ve TX i�in ilk durum belirleme i�in kullan�ld�.
;-------------------------------------------------------------------
rs232_init
	banksel RS_Tris
    	bcf	RS_Tris, RS_TX       ;TX pini ��k��a,
    	bsf	RS_Tris, RS_RX       ;RX pini giri�e y�nlendirildi.
	banksel RS_Port
    	bsf	RS_Port, RS_TX       ;TX pininin ilk durumu HIGH.
	return
;-------------------------------------------------------------------
; LOW seviyesi olu�turmak i�in kullan�ld�. 
;-------------------------------------------------------------------
low_level
    	bcf	RS_Port, RS_TX       ;TX = 0
	call	rs232_delay1
	return
;-------------------------------------------------------------------
; HIGH seviyesi olu�turmak i�in kullan�ld�.
;-------------------------------------------------------------------
high_level
    	bsf	RS_Port, RS_TX       ;TX = 1
	call	rs232_delay1
	return
;-------------------------------------------------------------------
; rs232'den veri okumak i�in kullan�ld�.
;-------------------------------------------------------------------
rs232_read
	btfsc	RS_Port, RS_RX		;START bit�i gelene kadar bekle.
	goto	rs232_read
	call	rs232_delay2		;50 us bekle (start bit�inin 
					;ortas�na konumlan).
	movlw	0x08
	movwf	sayac			;8 bit al�m� i�in sayac� kur.
rs_read_tekrar
    	call	rs232_delay1		;104 us bekle (ilk anda 0. bit�in 
					;ortas�na konumlan (hata ihtimalini 
					;en aza indirmek i�in bit zaman�n�n 
					;ortas�nda �rnekleme yap).
	bcf	STATUS, C		;rrf komutunda verinin MSB bit�ine
					;0 aktarmak i�in C bit�ini s�f�rla.
	btfsc	RS_Port, RS_RX		;0 bilgisi geldi ise komut atla, 
					;de�ilse..
	bsf	STATUS, C		;rrf komutunda verinin MSB bit�ine
					; 1 aktarmak i�in C bit�ini set et.
	rrf	rs232_data, F		;Veriyi sa�a 1 bit kayd�r 
					;(MSB'de ELDE bit�i var).
	decfsz	sayac, F		;Sayac� bir azalt, 8 bit�te al�nd� 
					;ise d�ng�den ��k.
	goto	rs_read_tekrar		;T�m bit�ler okunana kadar i�leme 
					;devam et.
    	return				;Veri al�nd�, alt programdan ��k.
;-------------------------------------------------------------------
; rs232'ye veri yazmak i�in kullan�ld�.
;-------------------------------------------------------------------
rs232_write
	movlw	0x08
	movwf	sayac			;8 bit yazma i�in sayac� kur.
	call	low_level		;Start bit�i olu�turuldu 
					;(104 us'lik low seviye).
rs_write_tekrar
	btfsc	rs232_data, 0		;Veriyi LSB bit�i 0 ise komut atla, 
					;de�ilse..
	call	high_level		;HIGH seviyesi olu�tur (lojik 1).
	btfss	rs232_data, 0		;Veriyi LSB bit�i 1 ise komut atla, 
					;de�ilse..
	call	low_level		;LOW seviyesi olu�tur (lojik 0).
	rrf	rs232_data, F		;Verinin t�m bit�lerini kayd�rarak 
					;sonraki bit�i LSB'ye al.
	decfsz	sayac, F		;8 bit�te transfer edilene kadar 
					;i�leme devam et.
	goto	rs_write_tekrar
	call	high_level		;Stop bit�i olu�tur 
					;(104 us'lik high seviye).
	return
;-------------------------------------------------------------------
; Ana program blo�u RS232 �zerinden ald��� veriyi tekrar 
; RS232 �zerinden terminale g�nderir.
;-------------------------------------------------------------------
ana_program
	call	rs232_init		;SFR'siz asenkron ileti�im ilk 
					;i�lemleri �a��r.
devam
	call	rs232_read		;RS232 portundan veri oku, okunan 
					;veri rs232_data de�i�keninde.
	call	rs232_write		;rs232_data de�i�kenindeki daha 
					;�nce okunan veriyi tekrar RS232 
					;terminaline g�nder.
	goto	devam			;Sonsuz d�ng� kuruldu.

	END				;Program sonu.
;*******************************************************************

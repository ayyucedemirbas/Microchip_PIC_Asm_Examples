;*******************************************************************
;	Dosya Ad�		: 6_4.asm
;	Program�n Amac�		: MSSP mod�l�n�n ile SPI master modunda
;				  veri ileti�imi 74HC595 kullanarak).
;	PIC DK 2.1 		: PORTC<0:3:5> ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************

	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 	;PWRT on, di�erler sigortalar� 
				;kapal�, Osilat�r XT ve 4Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlamalar� 
;-------------------------------------------------------------------
MSpi_Veri	equ 0x20 	;Master SPI ileti�imde veriyi tutar.
HC595_data	equ 0x21 	;74HC595'e ait kaydedici adres byte'�.

	ORG 	0		;Reset vekt�r�, Program bu adresten 
				;�al��maya ba�lar.
	clrf 	PCLATH		;0. program sayfas� se�ildi. �lk 2 KByte'� 
				;kulland�k.
	goto 	ana_program	;Ana programa git.
;-------------------------------------------------------------------
; Master SPI ileti�ime kurma alt program�: 
; MSSP mod�l�n� Master SPI olarak ileti�ime haz�rlar ve pinleri 
; y�nlendirir.
;-------------------------------------------------------------------
Master_Spi_Kur
	Banksel TRISC		;BANK1'e ge� SSPSTAT, TRISC bu bankta.
	movlw	0xC5		;SPI ileti�imi i�in gereken pinler d���nda 
				;kalanlar oldu�u
	andwf	TRISC, F	;gibi b�rak�ld�.
	movlw	0x10			
	iorwf	TRISC, F	;RC4/SDI/SDA giri�e ayarland�. Di�er 
				;SPI pinleri ��k��. 
	movlw	0x40
	movwf	SSPSTAT	;SMP = 0; Veri giri�i �rneklemesi veri 
				;��k�� zaman�n�n ortas�nda,
				;CKE = 1; SPI master ileti�imde y�kselen 
				;clock kenar� se�ildi.
	bcf	STATUS, RP0	;BANK0 se�ildi.
	clrf	SSPCON		;SPI Master mod se�ildi.
	bsf	SSPCON, 5	;SPI ileti�imi ba�lat.
	return
;-------------------------------------------------------------------
; SPI �zerinden bir byte veri g�nderir.
;-------------------------------------------------------------------
Master_Spi_Yaz
	movf	MSpi_Veri, W		;Veri SSPBUF kaydedicisine 
					;ta��n�yor.
	Banksel SSPBUF
	movwf	SSPBUF
	banksel SSPSTAT
MSpi_Yaz_j1
	btfss	SSPSTAT, BF		;Verinin g�nderimi tamamlanana 
					;kadar bekle.
	goto	MSpi_Yaz_j1
	return

;-------------------------------------------------------------------
; 74HC595 entegresine bir byte veri yazar.
;-------------------------------------------------------------------
HC595_Yaz
	Banksel PORTC		;PORTC�nin bulundu�u bank se�ildi (bank0).
	bsf	PORTC,0		;74HC595�in Shift Register Clock ucu HIGH 
				;yap�ld�. 

movf	HC595_data, W		;HC595_data de�i�kenindeki de�er 
				;W kaydedicisi �zerinden 
movwf	MSpi_Veri		;Master_Spi_Yaz alt program�na ait 
				;MSpi_Veri de�i�kenine y�klendi.
call	Master_Spi_Yaz		;Master_Spi_Yaz alt program� ile 
				;veri 74HC595 kaydedicisi �zerinde.
	Banksel PORTC
	bcf	PORTC, 0	;Kaydedici �zerindeki verinin ��k�� 
				;kaydedicisine transferi
	bsf	PORTC, 0	;y�kselen darbe kenar� ile 
				;ger�ekle�tirildi. Art�k veri 
				;74HC595 entegre ��k��lar�nda. 
return
;-------------------------------------------------------------------
; ANA PROGRAM: MSSP mod�l� Master SPI ileti�imini kullanarak 
; 74HC595�e veri g�nderir.
;-------------------------------------------------------------------
ana_program
	call	Master_Spi_Kur	;MSSP mod�l� Master SPI ileti�ime 
				;kuruldu.
	Banksel PORTC
	clrf	PORTC		;PORTC'nin ilk durumu belirlendi.
	movlw	0x57		;0x57 bilgisi 74HC595�e transfer 
				;edilecek.
	movwf	HC595_data	;Veri HC595_data de�i�kenine aktar�ld�.
	call	HC595_Yaz	;HC595_Yaz altprogram� ile veri 74HC595 
				;��k��lar�na aktar�ld�.
ana_j1	goto	ana_j1		;Sistem kapat�lana ya da resetlenene kadar 
				;bo� d�ng�.

	END
;*******************************************************************

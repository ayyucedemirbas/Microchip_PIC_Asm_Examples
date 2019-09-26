;*******************************************************************
;	Dosya Ad�		: 6_5.asm
;	Program�n Amac�		: MSSP mod�l� SPI master ileti�im 
;				  (MAX7219 kullanarak).
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, di�erler sigortalar� 
					;kapal�, Osilat�r XT ve 4Mhz.


;-------------------------------------------------------------------
; De�i�ken tan�mlamalar� 
;-------------------------------------------------------------------
MSpi_Veri	equ 0x20 	;Master SPI ileti�imde veriyi tutan 
				;de�i�ken.
Max7219_Data1	equ 0x21 	;MAX7219'a ait kaydedici adres 
				;byte'�.
Max7219_Data2	equ 0x22 	;MAX7219'a ait se�ilen kaydediciye 
				;y�klenen veri.
i		equ 0x23 	;Ge�ici saya� de�i�keni.

	ORG 	0			;Reset vekt�r�.
	clrf 	PCLATH			;0. program sayfas� se�ildi. �lk 2 
					;KByte'� kulland�k.
	goto 	ana_program		;Ana programa git.
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
	iorwf	TRISC, F	;RC4/SDI/SDA giri�e ayarland�. Di�erleri 
				;SPI pinleri ��k��. 
	movlw	0x40
	movwf	SSPSTAT	;SMP = 0; Veri giri�i �rneklemesi veri 
				;��k�� zaman�n�n ortas�nda CKE = 1; SPI 
				;master ileti�imde y�kselen saat kenar� 
				;se�ildi.
	bcf	STATUS, RP0	;BANK0 se�ildi.
	clrf	SSPCON		;Spi Master mod se�ildi.
	bsf	SSPCON, 5	;SPI ileti�imi ba�lat.
	return
;-------------------------------------------------------------------
; SPI �zerinden bir byte veri g�nderir.
;-------------------------------------------------------------------
Master_Spi_Yaz
	movf	MSpi_Veri, W	;Veri SSPBUF kaydedicisine ta��n�yor.
	Banksel SSPBUF
	movwf	SSPBUF
MSpi_Yaz_j1
	Banksel SSPSTAT
	btfss	SSPSTAT, BF	;Verinin g�nderimi tamamlanana kadar bekle
	goto	MSpi_Yaz_j1
	return
;-------------------------------------------------------------------
; SPI �zerinden MAX7219'un se�ilen kaydedicisine bir byte veri yazar.
;-------------------------------------------------------------------
Max7219_Yaz
	Banksel PORTC			;BANK0 se�ildi.
	bsf	PORTC, 1		;Max7219 se�ildi (CS=1'de aktif).
	movf	Max7219_Data1, W	;Max7219 kaydedicisi se�iliyor ve 
					;SPI ileti�imi �zerinden
	movwf	MSpi_Veri		;bu veri MAX7219'a 
					;transfer ediliyor.
	call	Master_Spi_Yaz
	movf	Max7219_Data2, W	;Max7219 i�in kaydediciye 
					;y�klenecek veri y�kleniyor
	movwf	MSpi_Veri		;ve SPI ileti�imi �zerinden 
					;bu veri MAX7219'a 
	call 	Master_Spi_Yaz		;transfer ediliyor.
	bcf	STATUS, RP0		;BANK0 se�ildi.
	bcf	PORTC, 1		;Max7219 pasif hale 
					;getirildi(LOAD=0'da pasif).
	return
;-------------------------------------------------------------------
; MAX7219 entegresi �al��ma ko�ullar� ayarlan�yor.
;-------------------------------------------------------------------
Max7219_Kur
	movlw	0x09
	movwf	Max7219_Data1		;BCD Kod ��zme modu kaydedicisi 
					;se�ildi. 
	movlw	0xFF
	movwf	Max7219_Data2		;Kod ��zme i�lemi 8 dijit i�in 
					;yap�lacak.
	call	Max7219_Yaz
	movlw	0x0A
	movwf	Max7219_Data1		;Intensity kaydedicisi se�ildi 
					;(parlakl�k i�in).
	movlw	0x0F
	movwf	Max7219_Data2		;Duty cycle (parlakl�k) maksimum. 
	call 	Max7219_Yaz
	movlw	0x0B			;Taranacak display say�s�n� 
					;belirtti�imiz kaydedici se�ildi.
	movwf	Max7219_Data1		;
	movlw	0x07			;0-7'ye kadar olan t�m display�ler 
					;taranacak.
	movwf	Max7219_Data2		
	call	Max7219_Yaz
	movlw	0x0C		
	movwf	Max7219_Data1		;Shutdown kaydedicisi se�ildi.
	movlw	0x01			;Bu kaydediciye 0x01 y�klenerek 
					;normal �al��ma
	movwf	Max7219_Data2		;modu se�im bilgisi y�klendi.
	call	Max7219_Yaz
	clrf	Max7219_Data1		;No_Op kaydedicisi se�ildi.
	movlw	0xFF	
	movwf	Max7219_Data2		;Normal operasyon modu se�ildi.
	call	Max7219_Yaz
	movlw	0x0F
	movwf	Max7219_Data1		;Display test kaydedicisi se�ildi.
	clrf	Max7219_Data2		;0=off, 1=on. Test i�lemi kapal�.
	call	Max7219_Yaz
	return
;-------------------------------------------------------------------
; ANA PROGRAM: 
; 8 Dijit g�r�nt� birimine SPI �zerinden veri yazma i�lemini 
; ger�ekle�tirir.
;-------------------------------------------------------------------
ana_program
	call	Master_Spi_Kur		;MSSP mod�l� Master SPI ileti�ime 
					;kuruldu.
	call	Max7219_Kur		;MAX7219 8 Dijit LED Driver �al��ma 
					;ko�ullar� ayarland�.
	banksel PORTC
	clrf	PORTC			;PORTC'nin ilk durumu belirlendi.
	clrf	i			;sayac de�i�kenine ilk de�er 
					;atamas� yap�ld�.
ana_j1					;Buradan itibaren 1-8' kadar d�ng� 
					;a��larak 1. Dijite 1, 2.sine 2,.. 
					;8.sine 8 rakam� yaz�ld�.
	incf	i, F			;sayac� art�r.
	movf	i, W
	movwf	Max7219_Data1		;Dijit se�me bilgisini y�kle.
	movwf	Max7219_Data2		;Se�ilen dijite g�nderilecek veriyi 
					;y�kle.
	call	Max7219_Yaz		;Max7219'a kaydedici se�me ve 
					;i�erik bilgisini yaz.
	movf	i, W			;sayac W kaydedicisine ta��n�yor.
	sublw	0x08			
	btfsc	STATUS, C		;sayac >= 8 ise i�lem tamamd�r.
	goto	ana_j1			;sayac < 8 ise i�leme devam.
ana_j2
	goto	ana_j2			;Sistem kapat�lana ya da 
					;resetlenene kadar bo� d�ng�.
	END
;******************************************************************* 

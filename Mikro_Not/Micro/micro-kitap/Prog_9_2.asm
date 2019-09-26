;*******************************************************************
;	Dosya Ad�		: 9_2.asm
;	Program�n Amac�		: Flash program belle�ini okuma ve yazma
;	Notlar 			: Proteus program� sim�lasyonu.
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3B32'	;PWRT on, WRT Enable, di�er 
				;sigortalar kapal�, Osilat�r HS ve 
				;20Mhz.
;-------------------------------------------------------------------
; Buton ve de�i�ken tan�mlamalar� yap�l�yor.
;-------------------------------------------------------------------
#define ADRESARTIR	1	;Adres art�rma butonu.
#define PROGRAMSIL	2	;Program silme butonu.

FlashAdresL	equ	0x20	;Flash adresinin en de�ersiz byte 
;de�i�keni.
FlashAdresH	equ	0x21	;Flash adresinin en de�erli byte 
;de�i�keni.
FlashDataL	equ	0x22	;Flash'a yaz�lan ya da okunan 
				;verinin en de�ersiz byte de�i�keni
FlashDataH	equ	0x23	;Flash'a yaz�lan ya da okunan 
				;verinin en de�erli byte de�i�keni.
	org	0
	goto	ana_program
	
	org	4
	goto	kesme
;-------------------------------------------------------------------
; Kesme alt program�.
;-------------------------------------------------------------------
kesme
	retfie
;-------------------------------------------------------------------
; Ana program portlar� y�nlendirir ve ilk durumlar� y�kler. 
; ADRESARTIR butonuna her bas�ld���nda 0. adresten ba�layarak Flash 
; program belle�ini okuyarak PORTB ve PORTC �zerinde g�r�nt�ler. 
; ADRESARTIR butonu b�rak�lana kadar ikinci bir g�r�nt�leme yapmaz. 
; PROGRAMSIL butonuna bas�ld��� zaman 0. adresten itibaren program� 
; imha eden alt program �al���r.
;-------------------------------------------------------------------
ana_program
	banksel TRISB				;Bank0 se�ildi.
	clrf	TRISB				;PORTB ��k��a ayarland�.
	clrf	TRISC				;PORTC ��k��a ayarland�.
	movlw	0x06	
	movwf	ADCON1				;PORTA dijital I/O ayarland�
	movlw	0xFF
	movwf	TRISA				;PORTA t�m bit�leri giri�. 
	banksel PORTB
	clrf	PORTB				;�lk anda 0. 
	clrf	PORTC				;�lk anda 0.
	clrf	FlashAdresL			;0. adresten itibaren Flash 
						;program belle�i okunacak.
	clrf	FlashAdresH
	movlw	0x07
	movwf	CMCON				;Komparat�r giri�leri 
						;kapat�ld�.
ana_j1
	banksel PORTA				;Bank0'a ge�ildi.
	btfss	PORTA, PROGRAMSIL
	call	Program_Sil	
	btfsc	PORTA, ADRESARTIR		;Bir sonraki adresin 
						;i�eri�ini g�r�nt�lemek i�in 
						;devam et.
	goto	ana_j1				;Butonlara bas�l�p 
						;bas�lmad���n� kontrole 
						;devam et.
	call	Flash_Read			;Flash program belle�inin 
						;ilgili adresini oku.
	banksel PORTB				;Bank0'a ge�ildi.
	movf	FlashDataH, W		
	movwf	PORTB				;Okunan verinin en de�erli 
						;byte'� PORTB ��k��lar�nda.
	movf	FlashDataL, W
	movwf	PORTC				;Okunan verinin en de�ersiz 
						;byte'� PORTC ��k��lar�nda.
	btfss	PORTA, ADRESARTIR		;ARTIR'ma butonu b�rak�lana 
						;kadar bo� d�ng�.
	goto	$-1
	incf	FlashAdresL, F			;Adresin yaln�zca en 
						;de�ersiz byte'�n� art�r.
	goto	ana_j1				
;-------------------------------------------------------------------
; Flash program belle�ine 2 byte veri yazan alt program.
; Adres = FlashAdresH:FlashAdresL,   Veri = FlashDataH:FlashDataL
;-------------------------------------------------------------------
Flash_Write 
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulundu�u banka ge�.
	movf	FlashAdresL, W			;Adresin en de�ersiz byte'� 
						;EEADR'ye y�kleniyor.
	banksel EEADR				;EEADR kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	EEADR				;EEADR = FlashAdresL
	banksel FlashAdresH			;FlashAdresH kaydedicisinin 
						;bulundu�u banka ge�.
	movf	FlashAdresH, W			;Adresin en de�erli byte'� 
						;EEADRH'a y�kleniyor.
	banksel EEADRH				;EEADRH kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	EEADRH				;EEADRH = FlashAdresH
	banksel FlashDataL			;FlashDataL kaydedicisinin 
						;bulundu�u banka ge�.
	movf	FlashDataL, W			;Verinin en de�ersiz byte'� 
						;EEDATA kaydedicisine 
						;y�kleniyor.
	banksel EEDATA				;EEDATA kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	EEDATA				;EEDATA = FlashDataL
	banksel FlashDataH			;FlashDataH kaydedicisinin 
						;bulundu�u banka ge�.
	movf	FlashDataH, W			;Verinin en de�erli byte'� 
						;EEDATH laydedicisine 
						;y�kleniyor.
	banksel EEDATH				;EEDATH kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	EEDATH				;EEDATH = FlashDataH
	banksel EECON1				;EECON1 kaydedicisinin 
						;bulundu�u banka ge�.
	bsf	EECON1, EEPGD			;Program haf�zas�na eri�im etkin
	bsf	EECON1, WREN			;Yazmay� etkinle�tir.
	bcf	INTCON, GIE			;Kesmelere izin verme
	movlw	0x55				;Bu de�erler EECON 
						;kaydedicisine s�ral� 
						;y�klenmeli.
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR			;Yaz komutu veriliyor.
	nop					;��lemin tamamlanmas� i�in 2 
						;komut �evrimi bekle.
	nop
	bsf	INTCON, GIE			;Kesmelere izin ver.
	bcf	EECON1, WREN			;Yazmay� pasif hale getir.	
	return					;Alt programdan ��k.
;-------------------------------------------------------------------
; Flash program belle�inden 2 byte veri okuyan alt program.
; Adres = FlashAdresH:FlashAdresL,   Veri = FlashDataH:FlashDataL
;-------------------------------------------------------------------
Flash_Read
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulundu�u banka ge�.
	movf	FlashAdresL, W			;Adresin en de�ersiz byte'� 
						;EEADR'ye y�kleniyor.
	banksel EEADR				;EEADR kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	EEADR				;EEADR = FlashAdresL
	banksel FlashAdresH			;FlashAdresH kaydedicisinin 
						;bulundu�u banka ge�.	
	movf	FlashAdresH, W			;Adresin en de�erli byte'� 
						;EEADRH'a y�kleniyor.
	banksel EEADRH				;EEADRH kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	EEADRH				;EEADRH = FlashAdresH
	banksel EECON1				;EECON1 kaydedicisinin 
						;bulundu�u banka ge�.
	bsf	EECON1, EEPGD			;Program haf�zas�na eri�im 
						;etkin.
	bsf	EECON1, RD			;Okumay� etkinle�tir.
	nop					;��lemin tamamlanmas� i�in 2 
						;komut �evrimi bekle.
	nop
	banksel EEDATA				;EEDATA kaydedicisinin 
						;bulundu�u banka ge�.
	movf	EEDATA, W			;EEDATA W arac�l��� ile 
						;FlashDataL kaydedicisine 
						;aktar�lacak.
	banksel FlashDataL			;FlashDataL kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	FlashDataL			;FlashDataL = EEDATA
	banksel EEDATH				;EEDATH kaydedicisinin 
						;bulundu�u banka ge�.
	movf	EEDATH, W			;EEDATH W arac�l��� ile 
						;FlashDataL kaydedicisine 
						;aktar�lacak.
	banksel FlashDataH			;FlashDataH kaydedicisinin 
						;bulundu�u banka ge�.
	movwf	FlashDataH			;FlashDataH = EEDATH
	return					;Alt programdan ��k.
;-------------------------------------------------------------------
; Flash program belle�inin 0x0000-0x00FF adres b�lgesini 0x00 
; bilgileri ile doldurarak program� siler Program� silerken 
; Flash_Write alt program�n�n bulundu�u adres b�lgesinde program 
; i�leyi�i kontrolden ��kmaktad�r. Bunun nedeni kendisini imha 
; ederken bir sonraki veriyi silmeye �al��t���nda hatal� kodlar ile 
; kar��la�mas�d�r.
;-------------------------------------------------------------------
Program_Sil
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulundu�u banka ge�.
	clrf	FlashAdresL			;FlashAdresL = 0
	clrf	FlashAdresH			;FlashAdresH = 0
	clrf	FlashDataL			;FlashDataL = 0
	clrf	FlashDataH			;FlashDataH = 0
sil
	call	Flash_Write			;Flash program belle�ine 
						;veriyi yaz.
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulundu�u banka ge�.
	incfsz	FlashAdresL			;FlashAdresL'yi bir art�r, 
						;sonu� s�f�rsa bir komut atla.
	goto	sil				;Silme i�lemine devam et.
	return					;Alt programdan ��k.
	END
;*******************************************************************

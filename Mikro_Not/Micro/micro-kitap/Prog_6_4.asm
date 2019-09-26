;*******************************************************************
;	Dosya Adý		: 6_4.asm
;	Programýn Amacý		: MSSP modülünün ile SPI master modunda
;				  veri iletiþimi 74HC595 kullanarak).
;	PIC DK 2.1 		: PORTC<0:3:5> Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************

	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 	;PWRT on, diðerler sigortalarý 
				;kapalý, Osilatör XT ve 4Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlamalarý 
;-------------------------------------------------------------------
MSpi_Veri	equ 0x20 	;Master SPI iletiþimde veriyi tutar.
HC595_data	equ 0x21 	;74HC595'e ait kaydedici adres byte'ý.

	ORG 	0		;Reset vektörü, Program bu adresten 
				;çalýþmaya baþlar.
	clrf 	PCLATH		;0. program sayfasý seçildi. Ýlk 2 KByte'ý 
				;kullandýk.
	goto 	ana_program	;Ana programa git.
;-------------------------------------------------------------------
; Master SPI iletiþime kurma alt programý: 
; MSSP modülünü Master SPI olarak iletiþime hazýrlar ve pinleri 
; yönlendirir.
;-------------------------------------------------------------------
Master_Spi_Kur
	Banksel TRISC		;BANK1'e geç SSPSTAT, TRISC bu bankta.
	movlw	0xC5		;SPI iletiþimi için gereken pinler dýþýnda 
				;kalanlar olduðu
	andwf	TRISC, F	;gibi býrakýldý.
	movlw	0x10			
	iorwf	TRISC, F	;RC4/SDI/SDA giriþe ayarlandý. Diðer 
				;SPI pinleri çýkýþ. 
	movlw	0x40
	movwf	SSPSTAT	;SMP = 0; Veri giriþi örneklemesi veri 
				;çýkýþ zamanýnýn ortasýnda,
				;CKE = 1; SPI master iletiþimde yükselen 
				;clock kenarý seçildi.
	bcf	STATUS, RP0	;BANK0 seçildi.
	clrf	SSPCON		;SPI Master mod seçildi.
	bsf	SSPCON, 5	;SPI iletiþimi baþlat.
	return
;-------------------------------------------------------------------
; SPI üzerinden bir byte veri gönderir.
;-------------------------------------------------------------------
Master_Spi_Yaz
	movf	MSpi_Veri, W		;Veri SSPBUF kaydedicisine 
					;taþýnýyor.
	Banksel SSPBUF
	movwf	SSPBUF
	banksel SSPSTAT
MSpi_Yaz_j1
	btfss	SSPSTAT, BF		;Verinin gönderimi tamamlanana 
					;kadar bekle.
	goto	MSpi_Yaz_j1
	return

;-------------------------------------------------------------------
; 74HC595 entegresine bir byte veri yazar.
;-------------------------------------------------------------------
HC595_Yaz
	Banksel PORTC		;PORTC’nin bulunduðu bank seçildi (bank0).
	bsf	PORTC,0		;74HC595’in Shift Register Clock ucu HIGH 
				;yapýldý. 

movf	HC595_data, W		;HC595_data deðiþkenindeki deðer 
				;W kaydedicisi üzerinden 
movwf	MSpi_Veri		;Master_Spi_Yaz alt programýna ait 
				;MSpi_Veri deðiþkenine yüklendi.
call	Master_Spi_Yaz		;Master_Spi_Yaz alt programý ile 
				;veri 74HC595 kaydedicisi üzerinde.
	Banksel PORTC
	bcf	PORTC, 0	;Kaydedici üzerindeki verinin çýkýþ 
				;kaydedicisine transferi
	bsf	PORTC, 0	;yükselen darbe kenarý ile 
				;gerçekleþtirildi. Artýk veri 
				;74HC595 entegre çýkýþlarýnda. 
return
;-------------------------------------------------------------------
; ANA PROGRAM: MSSP modülü Master SPI iletiþimini kullanarak 
; 74HC595’e veri gönderir.
;-------------------------------------------------------------------
ana_program
	call	Master_Spi_Kur	;MSSP modülü Master SPI iletiþime 
				;kuruldu.
	Banksel PORTC
	clrf	PORTC		;PORTC'nin ilk durumu belirlendi.
	movlw	0x57		;0x57 bilgisi 74HC595’e transfer 
				;edilecek.
	movwf	HC595_data	;Veri HC595_data deðiþkenine aktarýldý.
	call	HC595_Yaz	;HC595_Yaz altprogramý ile veri 74HC595 
				;çýkýþlarýna aktarýldý.
ana_j1	goto	ana_j1		;Sistem kapatýlana ya da resetlenene kadar 
				;boþ döngü.

	END
;*******************************************************************

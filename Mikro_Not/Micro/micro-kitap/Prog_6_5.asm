;*******************************************************************
;	Dosya Adý		: 6_5.asm
;	Programýn Amacý		: MSSP modülü SPI master iletiþim 
;				  (MAX7219 kullanarak).
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, diðerler sigortalarý 
					;kapalý, Osilatör XT ve 4Mhz.


;-------------------------------------------------------------------
; Deðiþken tanýmlamalarý 
;-------------------------------------------------------------------
MSpi_Veri	equ 0x20 	;Master SPI iletiþimde veriyi tutan 
				;deðiþken.
Max7219_Data1	equ 0x21 	;MAX7219'a ait kaydedici adres 
				;byte'ý.
Max7219_Data2	equ 0x22 	;MAX7219'a ait seçilen kaydediciye 
				;yüklenen veri.
i		equ 0x23 	;Geçici sayaç deðiþkeni.

	ORG 	0			;Reset vektörü.
	clrf 	PCLATH			;0. program sayfasý seçildi. Ýlk 2 
					;KByte'ý kullandýk.
	goto 	ana_program		;Ana programa git.
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
	iorwf	TRISC, F	;RC4/SDI/SDA giriþe ayarlandý. Diðerleri 
				;SPI pinleri çýkýþ. 
	movlw	0x40
	movwf	SSPSTAT	;SMP = 0; Veri giriþi örneklemesi veri 
				;çýkýþ zamanýnýn ortasýnda CKE = 1; SPI 
				;master iletiþimde yükselen saat kenarý 
				;seçildi.
	bcf	STATUS, RP0	;BANK0 seçildi.
	clrf	SSPCON		;Spi Master mod seçildi.
	bsf	SSPCON, 5	;SPI iletiþimi baþlat.
	return
;-------------------------------------------------------------------
; SPI üzerinden bir byte veri gönderir.
;-------------------------------------------------------------------
Master_Spi_Yaz
	movf	MSpi_Veri, W	;Veri SSPBUF kaydedicisine taþýnýyor.
	Banksel SSPBUF
	movwf	SSPBUF
MSpi_Yaz_j1
	Banksel SSPSTAT
	btfss	SSPSTAT, BF	;Verinin gönderimi tamamlanana kadar bekle
	goto	MSpi_Yaz_j1
	return
;-------------------------------------------------------------------
; SPI üzerinden MAX7219'un seçilen kaydedicisine bir byte veri yazar.
;-------------------------------------------------------------------
Max7219_Yaz
	Banksel PORTC			;BANK0 seçildi.
	bsf	PORTC, 1		;Max7219 seçildi (CS=1'de aktif).
	movf	Max7219_Data1, W	;Max7219 kaydedicisi seçiliyor ve 
					;SPI iletiþimi üzerinden
	movwf	MSpi_Veri		;bu veri MAX7219'a 
					;transfer ediliyor.
	call	Master_Spi_Yaz
	movf	Max7219_Data2, W	;Max7219 için kaydediciye 
					;yüklenecek veri yükleniyor
	movwf	MSpi_Veri		;ve SPI iletiþimi üzerinden 
					;bu veri MAX7219'a 
	call 	Master_Spi_Yaz		;transfer ediliyor.
	bcf	STATUS, RP0		;BANK0 seçildi.
	bcf	PORTC, 1		;Max7219 pasif hale 
					;getirildi(LOAD=0'da pasif).
	return
;-------------------------------------------------------------------
; MAX7219 entegresi çalýþma koþullarý ayarlanýyor.
;-------------------------------------------------------------------
Max7219_Kur
	movlw	0x09
	movwf	Max7219_Data1		;BCD Kod çözme modu kaydedicisi 
					;seçildi. 
	movlw	0xFF
	movwf	Max7219_Data2		;Kod çözme iþlemi 8 dijit için 
					;yapýlacak.
	call	Max7219_Yaz
	movlw	0x0A
	movwf	Max7219_Data1		;Intensity kaydedicisi seçildi 
					;(parlaklýk için).
	movlw	0x0F
	movwf	Max7219_Data2		;Duty cycle (parlaklýk) maksimum. 
	call 	Max7219_Yaz
	movlw	0x0B			;Taranacak display sayýsýný 
					;belirttiðimiz kaydedici seçildi.
	movwf	Max7219_Data1		;
	movlw	0x07			;0-7'ye kadar olan tüm display’ler 
					;taranacak.
	movwf	Max7219_Data2		
	call	Max7219_Yaz
	movlw	0x0C		
	movwf	Max7219_Data1		;Shutdown kaydedicisi seçildi.
	movlw	0x01			;Bu kaydediciye 0x01 yüklenerek 
					;normal çalýþma
	movwf	Max7219_Data2		;modu seçim bilgisi yüklendi.
	call	Max7219_Yaz
	clrf	Max7219_Data1		;No_Op kaydedicisi seçildi.
	movlw	0xFF	
	movwf	Max7219_Data2		;Normal operasyon modu seçildi.
	call	Max7219_Yaz
	movlw	0x0F
	movwf	Max7219_Data1		;Display test kaydedicisi seçildi.
	clrf	Max7219_Data2		;0=off, 1=on. Test iþlemi kapalý.
	call	Max7219_Yaz
	return
;-------------------------------------------------------------------
; ANA PROGRAM: 
; 8 Dijit görüntü birimine SPI üzerinden veri yazma iþlemini 
; gerçekleþtirir.
;-------------------------------------------------------------------
ana_program
	call	Master_Spi_Kur		;MSSP modülü Master SPI iletiþime 
					;kuruldu.
	call	Max7219_Kur		;MAX7219 8 Dijit LED Driver çalýþma 
					;koþullarý ayarlandý.
	banksel PORTC
	clrf	PORTC			;PORTC'nin ilk durumu belirlendi.
	clrf	i			;sayac deðiþkenine ilk deðer 
					;atamasý yapýldý.
ana_j1					;Buradan itibaren 1-8' kadar döngü 
					;açýlarak 1. Dijite 1, 2.sine 2,.. 
					;8.sine 8 rakamý yazýldý.
	incf	i, F			;sayacý artýr.
	movf	i, W
	movwf	Max7219_Data1		;Dijit seçme bilgisini yükle.
	movwf	Max7219_Data2		;Seçilen dijite gönderilecek veriyi 
					;yükle.
	call	Max7219_Yaz		;Max7219'a kaydedici seçme ve 
					;içerik bilgisini yaz.
	movf	i, W			;sayac W kaydedicisine taþýnýyor.
	sublw	0x08			
	btfsc	STATUS, C		;sayac >= 8 ise iþlem tamamdýr.
	goto	ana_j1			;sayac < 8 ise iþleme devam.
ana_j2
	goto	ana_j2			;Sistem kapatýlana ya da 
					;resetlenene kadar boþ döngü.
	END
;******************************************************************* 

;*******************************************************************
;	Dosya Adý		: 9_2.asm
;	Programýn Amacý		: Flash program belleðini okuma ve yazma
;	Notlar 			: Proteus programý simülasyonu.
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3B32'	;PWRT on, WRT Enable, diðer 
				;sigortalar kapalý, Osilatör HS ve 
				;20Mhz.
;-------------------------------------------------------------------
; Buton ve deðiþken tanýmlamalarý yapýlýyor.
;-------------------------------------------------------------------
#define ADRESARTIR	1	;Adres artýrma butonu.
#define PROGRAMSIL	2	;Program silme butonu.

FlashAdresL	equ	0x20	;Flash adresinin en deðersiz byte 
;deðiþkeni.
FlashAdresH	equ	0x21	;Flash adresinin en deðerli byte 
;deðiþkeni.
FlashDataL	equ	0x22	;Flash'a yazýlan ya da okunan 
				;verinin en deðersiz byte deðiþkeni
FlashDataH	equ	0x23	;Flash'a yazýlan ya da okunan 
				;verinin en deðerli byte deðiþkeni.
	org	0
	goto	ana_program
	
	org	4
	goto	kesme
;-------------------------------------------------------------------
; Kesme alt programý.
;-------------------------------------------------------------------
kesme
	retfie
;-------------------------------------------------------------------
; Ana program portlarý yönlendirir ve ilk durumlarý yükler. 
; ADRESARTIR butonuna her basýldýðýnda 0. adresten baþlayarak Flash 
; program belleðini okuyarak PORTB ve PORTC üzerinde görüntüler. 
; ADRESARTIR butonu býrakýlana kadar ikinci bir görüntüleme yapmaz. 
; PROGRAMSIL butonuna basýldýðý zaman 0. adresten itibaren programý 
; imha eden alt program çalýþýr.
;-------------------------------------------------------------------
ana_program
	banksel TRISB				;Bank0 seçildi.
	clrf	TRISB				;PORTB çýkýþa ayarlandý.
	clrf	TRISC				;PORTC çýkýþa ayarlandý.
	movlw	0x06	
	movwf	ADCON1				;PORTA dijital I/O ayarlandý
	movlw	0xFF
	movwf	TRISA				;PORTA tüm bit’leri giriþ. 
	banksel PORTB
	clrf	PORTB				;Ýlk anda 0. 
	clrf	PORTC				;Ýlk anda 0.
	clrf	FlashAdresL			;0. adresten itibaren Flash 
						;program belleði okunacak.
	clrf	FlashAdresH
	movlw	0x07
	movwf	CMCON				;Komparatör giriþleri 
						;kapatýldý.
ana_j1
	banksel PORTA				;Bank0'a geçildi.
	btfss	PORTA, PROGRAMSIL
	call	Program_Sil	
	btfsc	PORTA, ADRESARTIR		;Bir sonraki adresin 
						;içeriðini görüntülemek için 
						;devam et.
	goto	ana_j1				;Butonlara basýlýp 
						;basýlmadýðýný kontrole 
						;devam et.
	call	Flash_Read			;Flash program belleðinin 
						;ilgili adresini oku.
	banksel PORTB				;Bank0'a geçildi.
	movf	FlashDataH, W		
	movwf	PORTB				;Okunan verinin en deðerli 
						;byte'ý PORTB çýkýþlarýnda.
	movf	FlashDataL, W
	movwf	PORTC				;Okunan verinin en deðersiz 
						;byte'ý PORTC çýkýþlarýnda.
	btfss	PORTA, ADRESARTIR		;ARTIR'ma butonu býrakýlana 
						;kadar boþ döngü.
	goto	$-1
	incf	FlashAdresL, F			;Adresin yalnýzca en 
						;deðersiz byte'ýný artýr.
	goto	ana_j1				
;-------------------------------------------------------------------
; Flash program belleðine 2 byte veri yazan alt program.
; Adres = FlashAdresH:FlashAdresL,   Veri = FlashDataH:FlashDataL
;-------------------------------------------------------------------
Flash_Write 
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulunduðu banka geç.
	movf	FlashAdresL, W			;Adresin en deðersiz byte'ý 
						;EEADR'ye yükleniyor.
	banksel EEADR				;EEADR kaydedicisinin 
						;bulunduðu banka geç.
	movwf	EEADR				;EEADR = FlashAdresL
	banksel FlashAdresH			;FlashAdresH kaydedicisinin 
						;bulunduðu banka geç.
	movf	FlashAdresH, W			;Adresin en deðerli byte'ý 
						;EEADRH'a yükleniyor.
	banksel EEADRH				;EEADRH kaydedicisinin 
						;bulunduðu banka geç.
	movwf	EEADRH				;EEADRH = FlashAdresH
	banksel FlashDataL			;FlashDataL kaydedicisinin 
						;bulunduðu banka geç.
	movf	FlashDataL, W			;Verinin en deðersiz byte'ý 
						;EEDATA kaydedicisine 
						;yükleniyor.
	banksel EEDATA				;EEDATA kaydedicisinin 
						;bulunduðu banka geç.
	movwf	EEDATA				;EEDATA = FlashDataL
	banksel FlashDataH			;FlashDataH kaydedicisinin 
						;bulunduðu banka geç.
	movf	FlashDataH, W			;Verinin en deðerli byte'ý 
						;EEDATH laydedicisine 
						;yükleniyor.
	banksel EEDATH				;EEDATH kaydedicisinin 
						;bulunduðu banka geç.
	movwf	EEDATH				;EEDATH = FlashDataH
	banksel EECON1				;EECON1 kaydedicisinin 
						;bulunduðu banka geç.
	bsf	EECON1, EEPGD			;Program hafýzasýna eriþim etkin
	bsf	EECON1, WREN			;Yazmayý etkinleþtir.
	bcf	INTCON, GIE			;Kesmelere izin verme
	movlw	0x55				;Bu deðerler EECON 
						;kaydedicisine sýralý 
						;yüklenmeli.
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR			;Yaz komutu veriliyor.
	nop					;Ýþlemin tamamlanmasý için 2 
						;komut çevrimi bekle.
	nop
	bsf	INTCON, GIE			;Kesmelere izin ver.
	bcf	EECON1, WREN			;Yazmayý pasif hale getir.	
	return					;Alt programdan çýk.
;-------------------------------------------------------------------
; Flash program belleðinden 2 byte veri okuyan alt program.
; Adres = FlashAdresH:FlashAdresL,   Veri = FlashDataH:FlashDataL
;-------------------------------------------------------------------
Flash_Read
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulunduðu banka geç.
	movf	FlashAdresL, W			;Adresin en deðersiz byte'ý 
						;EEADR'ye yükleniyor.
	banksel EEADR				;EEADR kaydedicisinin 
						;bulunduðu banka geç.
	movwf	EEADR				;EEADR = FlashAdresL
	banksel FlashAdresH			;FlashAdresH kaydedicisinin 
						;bulunduðu banka geç.	
	movf	FlashAdresH, W			;Adresin en deðerli byte'ý 
						;EEADRH'a yükleniyor.
	banksel EEADRH				;EEADRH kaydedicisinin 
						;bulunduðu banka geç.
	movwf	EEADRH				;EEADRH = FlashAdresH
	banksel EECON1				;EECON1 kaydedicisinin 
						;bulunduðu banka geç.
	bsf	EECON1, EEPGD			;Program hafýzasýna eriþim 
						;etkin.
	bsf	EECON1, RD			;Okumayý etkinleþtir.
	nop					;Ýþlemin tamamlanmasý için 2 
						;komut çevrimi bekle.
	nop
	banksel EEDATA				;EEDATA kaydedicisinin 
						;bulunduðu banka geç.
	movf	EEDATA, W			;EEDATA W aracýlýðý ile 
						;FlashDataL kaydedicisine 
						;aktarýlacak.
	banksel FlashDataL			;FlashDataL kaydedicisinin 
						;bulunduðu banka geç.
	movwf	FlashDataL			;FlashDataL = EEDATA
	banksel EEDATH				;EEDATH kaydedicisinin 
						;bulunduðu banka geç.
	movf	EEDATH, W			;EEDATH W aracýlýðý ile 
						;FlashDataL kaydedicisine 
						;aktarýlacak.
	banksel FlashDataH			;FlashDataH kaydedicisinin 
						;bulunduðu banka geç.
	movwf	FlashDataH			;FlashDataH = EEDATH
	return					;Alt programdan çýk.
;-------------------------------------------------------------------
; Flash program belleðinin 0x0000-0x00FF adres bölgesini 0x00 
; bilgileri ile doldurarak programý siler Programý silerken 
; Flash_Write alt programýnýn bulunduðu adres bölgesinde program 
; iþleyiþi kontrolden çýkmaktadýr. Bunun nedeni kendisini imha 
; ederken bir sonraki veriyi silmeye çalýþtýðýnda hatalý kodlar ile 
; karþýlaþmasýdýr.
;-------------------------------------------------------------------
Program_Sil
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulunduðu banka geç.
	clrf	FlashAdresL			;FlashAdresL = 0
	clrf	FlashAdresH			;FlashAdresH = 0
	clrf	FlashDataL			;FlashDataL = 0
	clrf	FlashDataH			;FlashDataH = 0
sil
	call	Flash_Write			;Flash program belleðine 
						;veriyi yaz.
	banksel FlashAdresL			;FlashAdresL kaydedicisinin 
						;bulunduðu banka geç.
	incfsz	FlashAdresL			;FlashAdresL'yi bir artýr, 
						;sonuç sýfýrsa bir komut atla.
	goto	sil				;Silme iþlemine devam et.
	return					;Alt programdan çýk.
	END
;*******************************************************************

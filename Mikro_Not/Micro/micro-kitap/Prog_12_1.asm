;*******************************************************************
;	Dosya Adý		: 12_1.asm
;	Programýn Amacý		: 4-bit arabirim modunda LCD kullanýmý
;	PIC DK2.1a 		: PORTB Çýkýþ ==> LCD display
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Deðiþken tanýmlarý yapýlýyor: Her bir deðiþken baþlangýç 
; adresinden itibaren birbirinin peþi sýra 1 byte yer kaplar.
;-------------------------------------------------------------------
	CBLOCK	0x20	;16F877A'nýn RAM baþlangýç adresi, 
	sayacH		;sayacýn yüksek byte'ý.
	sayacL		;sayacýn düþük byte'ý.

	LCD_data	;LCD için geçici veri deðiþkeni.
	LCD_tmp0	;LCD için geçici veri deðiþkeni.
	LCD_tmp1	;LCD için geçici veri deðiþkeni.
	LCD_line	;LCD için satýr bilgisini tutan deðiþken.
	LCD_pos		;LCD için sütun bilgisi tutan deðiþken.

	HexMSB		;Desimale çevrilecek sayýnýn en deðerli byte'ý.
	HexLSB		;Desimale çevrilecek sayýnýn en deðersiz byte'ý.
	binler		;Desimale çevrilen sayýnýn binler basamaðý.	
	yuzler		;Desimale çevrilen sayýnýn yüzler basamaðý.	
	onlar		;Desimale çevrilen sayýnýn onlar basamaðý.	
	birler		;Desimale çevrilen sayýnýn birler basamaðý. 

	delay_s_data	;Gecikme alt programlarý için veri deðiþkeni.	
	delay_data	;Gecikme alt programlarý için veri deðiþkeni.
	ENDC

	ORG 	0 
	pagesel Ana_program	 
	goto 	Ana_program	;Ana programa git.

	ORG 	4		;Kesme alt programý bu adresten baþlýyor.
	goto	kesme
;-------------------------------------------------------------------
; LCD ile ilgili temel tanýmlamalar ve mesajlar.
;-------------------------------------------------------------------
; LCD'nin baðlý olduðu port tanýmlarý yapýlýyor.
#define LCD_DataPort PORTB		;Data pinlerinin baðlý olduðu port 
					;(D7-D4  -> RB3-RB0 ).
#define LCD_CtrlPort PORTB		;Kontrol pinlerinin baðlandýðý port

; LCD'nin kontrol pinlerinin baðlý olduðu mikrodenetleyici pinleri 
; tanýmlanýyor.
#define LCD_RS	4		;LCD RS pini RB4'e baðlý.
#define LCD_EN	5		;LCD E pini RB5'e baðlý.
#define LCD_RW	6		;LCD RW pini RB6'ya baðlý.

mesajlar			;LCD'ye gönderilecek mesajlar buraya yazýlýyor.
	addwf	PCL, F			;mesaj adresini yükle.
msg0	dt	"Merhaba ", 0		;0 sonlandýrma karakteri.
msg1	dt	"DUNYA!..", 0
msg2	dt	"HEX:", 0
msg3	dt	"DEC:", 0
;-------------------------------------------------------------------
; LCD ile ilgili macro tanýmlarý:
;-------------------------------------------------------------------
LCD_RS_HIGH	macro			;LCD'nin RS giriþini HIGH yaparak 
	banksel LCD_CtrlPort		;veri alma modu seçilir.
	bsf	LCD_CtrlPort, LCD_RS
	endm

LCD_RS_LOW	macro			;LCD'nin RS giriþini LOW yaparak 
	banksel LCD_CtrlPort		;komut alma modu seçilir.
	bcf	LCD_CtrlPort, LCD_RS	
	endm

LCD_EStrobe macro			;LCD'ye veri ya da komut 
	banksel LCD_CtrlPort		;gönderildiðinde LCD'nin 
	bsf	LCD_CtrlPort, LCD_EN	;bunu iþlemesini saðlar.
	movlw	.20			;20us kadar bekle. 
	call	delay_us
	bcf	LCD_CtrlPort, LCD_EN
	endm

LCD_Locate	macro	line, pos
  	movlw 	line			;Satýr bilgisini yükle.
	movwf	LCD_line	
 	movlw 	pos			;Sütun bilgisini yükle.
	movwf	LCD_pos				
	call	LCD_SetPos		;Kursörü konumlandýr.
	endm

; ----------------LCD ile ilgili fonksiyonlar.---------------------
;-------------------------------------------------------------------
; 4 bit iletiþim modunda LCD'ye veri transferi yapar.
;-------------------------------------------------------------------
LCD_NybbleOut                       
	andlw	0x0F			;En deðersiz 4 bit W'de,
	movwf	LCD_tmp0		;geçici deðiþkene alýnýyor.
	movf	LCD_DataPort,W		;LCD'nin data pinlerinin baðlý 
					;olduðu port bilgisi W'de.
	andlw	0xF0			;Port bilgisinin en deðerli 4 bit’i 
					;korunuyor.
	iorwf	LCD_tmp0, W		;Korunan bilgi ile veri 
					;birleþtiriliyor.
	movwf	LCD_DataPort		;PortA transfer ediliyor.
	LCD_EStrobe			;LCD'nin veriyi almasý saðlanýyor.
	movlw	.255			;250us kadar bekle. Bu süre LCD 
					;içerisindeki iþlemlerin tamamlanmasý
	call	delay_us		;için gerekli ( en az 160us kadar ).
	return
;-------------------------------------------------------------------
; LCD'ye 1 byte komut transfer eder.
;-------------------------------------------------------------------
LCD_SendCmd         	         	
	movwf	LCD_data	 	;Komutu geçici deðiþkene al.
	swapf	LCD_data, W   		;En deðerli 4 bit’i gönder.
	LCD_RS_LOW			;RS = 0 (komut modu)
call	LCD_NybbleOut
	movf	LCD_data, W		;En deðersiz 4 bit’i gönder.
	LCD_RS_LOW			;RS = 0 (komut modu)
	call	LCD_NybbleOut			
	return
;-------------------------------------------------------------------
; LCD'ye bir rakam ya da bir karakter göndermek için kullanýlýr.
;-------------------------------------------------------------------
LCD_SendASCII						
	addlw	'0'			;LCD'ye rakamý ASCII koda 
					;dönüþtürerek göndermek için.
LCD_SendCHAR				;LCD'ye karakter göndermek için 
					;çaðrýlacak.
	movwf	LCD_data		;Komutu geçici deðiþkene al.
	swapf	LCD_data, W		;En deðerli 4 bit’i gönder.
	LCD_RS_HIGH			;RS = 1 ( veri gönderme modu )
	call	LCD_NybbleOut
	movf	LCD_data, W		;En deðersiz 4 bit’i gönder.
	LCD_RS_HIGH			;RS = 1 ( veri gönderme modu )
	call	LCD_NybbleOut
	return
;-------------------------------------------------------------------
; 1 byte veriyi hexadesimal formda LCD'ye yazar.
;-------------------------------------------------------------------
LCD_SendHEX	
	movwf	LCD_tmp1
	sublw	0x9F			;sayý > 0x9F mi? 
	btfss	STATUS, C		;hayýr ise bir komut atla.
	goto	LCD_HEX_j0
	swapf	LCD_tmp1, W
	andlw	0x0F			;En deðerli 4 bit W'nin en 
	call	LCD_SendASCII		;deðersiz 4 bit’inde.
	goto	LCD_HEX_j1
LCD_HEX_j0
	swapf	LCD_tmp1, W
	andlw	0x0F			;En deðerli 4 bit W'nin en 
	addlw	.55			;deðersiz 4 bit’inde.
	call	LCD_SendCHAR
LCD_HEX_j1
	movf	LCD_tmp1, W
	andlw	0x0F			;En deðersiz 4 bit W'nin en 
	movwf	LCD_tmp1		;deðersiz 4 bit’inde.
	sublw	0x09			;sayý > 0x09 mi? 
	btfss	STATUS, C		;hayýr ise bir komut atla.
	goto	LCD_HEX_j2
	movf	LCD_tmp1, W	
	call	LCD_SendASCII
	return
LCD_HEX_j2
	movf	LCD_tmp1, W
	addlw	.55
	call	LCD_SendCHAR
	return
;-------------------------------------------------------------------
; 1 byte veriyi binary formda LCD'ye yazar.
;-------------------------------------------------------------------
LCD_SendBIN
	movwf	LCD_tmp1		;Geçici deðiþkene al.
	movlw	.0
	btfss	LCD_tmp1, 7		;7. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 7		;7. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.

	movlw	.0
	btfss	LCD_tmp1, 6		;6. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 6		;6. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.

	movlw	.0
	btfss	LCD_tmp1, 5		;5. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 5		;5. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.

	movlw	.0
	btfss	LCD_tmp1, 4		;4. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 4		;4. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.

	movlw	.0
	btfss	LCD_tmp1, 3		;3. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 3		;3. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.
	movlw	.0
	btfss	LCD_tmp1, 2		;2. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 2		;2. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.

	movlw	.0
	btfss	LCD_tmp1, 1		;1. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 1		;1. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.
	
	movlw	.0
	btfss	LCD_tmp1, 0		;0. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazdýr.
	movlw	.1
	btfsc	LCD_tmp1, 0		;0. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazdýr.
	return
;-------------------------------------------------------------------
; LCD ekran belleðini siler.
;-------------------------------------------------------------------
LCD_Clear
	movlw	0x01			;LCD görüntü belleðini sil, 
					;dolayýsý ile 
	call	LCD_SendCmd		;LCD'de görünen bilgileri de sil.
	movlw	.5
	call	delay_ms
	return
;-------------------------------------------------------------------
; Kursörü göster
;-------------------------------------------------------------------
LCD_CursorOn
	movlw	0x0F			;Display'i aç, kursörü göster. 
	call	LCD_SendCmd		;Blink ON.
	return

;-------------------------------------------------------------------
; Kursörü gizle
;-------------------------------------------------------------------
LCD_CursorOff
	movlw	0x0C			;Display'i aç, kursörü gizle,
	call	LCD_SendCmd		;Blink OFF.
	return
;-------------------------------------------------------------------
; LCD ekraný kullanýma hazýrlar.
;-------------------------------------------------------------------
LCD_init
	bsf	STATUS, RP0		;BANK1 seçildi. Yönlendirme 
					;kaydedicileri bu bankta.
	movf	LCD_DataPort, W
	andlw	0xF0			;Portun en deðersiz 
					;dörtlüsü çýkýþ yapýldý.
	movwf	LCD_DataPort		;Port yönlendirildi.
	bcf	LCD_CtrlPort, LCD_EN	;LCD_CtrlPort'un LCD_EN 
					;pini çýkýþa yönlendirildi.
	bcf	LCD_CtrlPort, LCD_RS	;LCD_RS pini çýkýþ yapýldý. 
	bcf	LCD_CtrlPort, LCD_RW	;LCD_RW pini çýkýþ yapýldý.
	bcf	STATUS, RP0		;BANK0 seçildi.
	clrf	LCD_DataPort

	movlw	.50
	call	delay_ms		;40-50 ms kadar bekle.
	LCD_RS_LOW
	movlw	0x03			;8 bit iletiþim komutu verildi.
	call	LCD_NybbleOut	
	
	movlw	.5			;LCD'nin hazýr olmasý için 
					;bekleniyor.
	call delay_ms

	LCD_EStrobe			;8 bit iletiþim için komut 
					;yinelendi.
	movlw	.255			;160-255us kadar bekle. 
	call	delay_us
	
	LCD_EStrobe			;8 bit iletiþim için komut 
					;yinelendi.
	movlw	.255			;160-255us kadar bekle. 
	call	delay_us

	LCD_RS_LOW
	movlw	0x02			;LCD, 4 Bit iletiþim moduna alýndý.
	call	LCD_NybbleOut	

	movlw	.255			;160-255us kadar bekle. 
	call	delay_us

	movlw	0x28			;4 bit iletiþim, 2 satýr LCD, 5x7 
call	LCD_SendCmd			;font seçildi.
	movlw	0x10			;LCD'de yazýnýn kaymasý engellendi.
	call	LCD_SendCmd
	movlw	0x01			;LCD görüntü belleðini sil.
	call	LCD_SendCmd

	movlw	.5			;5 ms bekle.
	call	delay_ms

	movlw	0x06			;Kursör her karakter yazýmýnda bir 
	call	LCD_SendCmd		;ilerlesin.
	movlw	0x0C			;Display'i aç, kursörü gizle.
	call	LCD_SendCmd
	return
;-------------------------------------------------------------------
; Mesaj etiketi (adresi) W’ye yüklenen mesajý LCD ekranda görüntüler                       
;-------------------------------------------------------------------
LCD_SendMessage
	Movwf	FSR		;Ýlk karaktere iþaret et (onun adresini 
LCD_SMsg:			;tut).
	Movf	FSR, W		;Ýþaret edilen karakter sýrasýný W'ye al.
	incf	FSR, F		;Bir sonraki karaktere konumlan.
	Call	mesajlar	;Mesajlardan ilgili karakteri al.
	iorlw  0		;Mesaj sonu mu? 0 bilgisi alýndý ise 
				;mesaj sonu demektir.
	btfsc  STATUS, Z	;Mesaj sonu deðil ise bir komut atla.
	return			;Mesaj sonu ise alt programdan çýk.
	call   LCD_SendCHAR	;Karakteri LCD'ye yazdýr.
	goto   LCD_SMsg		;Bir sonraki karakter için 
				;iþlemleri tekrarla.
;-------------------------------------------------------------------
; Kursörü LCD'de istenilen satýr ve sütuna konumlandýrýr. Text'in 
; nereye yazýlacaðýný belirler. 1 - 2 satýr olan LCD'ler için 
; yazýldýðýna dikkat ediniz. 4 satýr LCD'ler için LCD_line deðerinin
; 0, 1, 2 veya 3 olmasý durumuna göre DDRAM baþlangýç adresleri 
; tespit edilmelidir.
;-------------------------------------------------------------------
LCD_SetPos
	movlw	0x80		;0. satýr için DDRAM adres baþlangýç 
	movf	LCD_line, F	;deðeri.
	btfss	STATUS, Z	;0. satýr ise bir komut atla.
	movlw	0xC0		;1. satýr için 0x80 adresine ilave 
				;edilecek deðer.
	addwf	LCD_pos, W	;Kursör pozisyonu da ilave edilerek 
				;DDRAM'deki adres bulunuyor.
	call	LCD_SendCmd
	return
;-------------------------------------------------------------------
; 2 byte binary veriyi bcd'ye dönüþtürür. Sonuç binler, yüzler, 
; onlar ve birler  deðiþkenlerinde saklanýr.
;-------------------------------------------------------------------
HexTODec
	clrf binler			;binler = 0
	clrf yuzler			;yuzler = 0
	clrf onlar			;onlar = 0
	clrf birler			;birler = 0
binler_kont
	movlw	04h			;W'ye 1024 (0x0400) sayýsýnýn en 
					;deðerli byte'ýný yükle.
	subwf	HexMSB, W		;HexMSB'den 1024 çýkart.
	btfss	STATUS, C		;HexMSB > 1024'mü?
	goto	yuzler_kont2		;hayýr ise yüzleri kontrol et.
	incf	binler, F		;evet ise binleri bir artýr.
	movlw	04h			;W'ye 0x04 yükle.
	subwf	HexMSB, F		;HexMSB'den 1000 çýkart.
	movlw	18h			;W'ye 0x18 yükle.
	addwf	HexLSB, F		;HexLSB'ye (0x18 = 24) ekle 
	btfsc	STATUS, C		;elde var mý?
	incf	HexMSB, F		;evet ise bir artýr.
	goto	binler_kont		;binleri yeniden kontrol et
yuzler_kont2
	movlw	0x01			;256 (0x0100)
	subwf	HexMSB, W		;HexMSB'den 200 çýkart ve sonucu 
					;W'ye sakla.
	btfss	STATUS, C		;sonuç >=256'mý?
	goto	yuzler_kont1		;Hayýr ise 100'ün katlarýný
					;kontrol et.
	movlw	0x02			;deðilse,
	addwf	yuzler, F		;yuzler'e 2 ekle
	movlw	0x01			;W = 1
	subwf	HexMSB, F		;HexMSB'den 200 çýkart.
	movlw	0x38			;W =0x38 (256'nýn 56 lýk kýsmý)
	addwf	HexLSB, F		;HexLSB'ye 56'yý ekle.
	btfsc	STATUS, C		;elde var mý?
	incf	HexMSB, F		;evet ise HexMSB'yi bir artýr.
	movlw	0x0A			;W = 10
	subwf	yuzler, W		;yuzler = 1000 olup olmadýðýný 
					;kontrol et.
	btfss	STATUS, Z		;sonuç sýfýr mý?
	goto	yuzler_kont2		;hayýr ise yuzleri yeniden kontrol 
	clrf	yuzler			;et. yuzler = 0
	incf	binler, F		;binler'i artýr.
	goto	yuzler_kont2		;yuzler'i 200 ya da daha büyük 
					;sayý için yeniden kontrol et.
yuzler_kont1 
	movlw	0x64			;W = 0x64
	subwf	HexLSB, W		;HexLSB'den 100 çýkart.
	btfss	STATUS, C		;sonuç >= 100 mü?
	goto	onlar_kont		;hayýr ise onlarý kontrol et.
	incf	yuzler, F		;evet ise yuzler'i bir artýr.
	movlw	0x64			;W = 0x64 (100)
	subwf	HexLSB, F		;HexLSB'yi 100 azalt.
	movlw	0x0A			;W = 0x0A (10)
	subwf	yuzler, W		;yuzler = 1000 kontrolü yap.
	btfss	STATUS, Z		;sonuç = 0 mý?
	goto	yuzler_kont1		;hayýr ise 100 için yuzler'i 
					;yeniden kontrol et.
	clrf	yuzler			;yuzler = 0
	incf	binler, F		;binleri bir artýr.
	goto	yuzler_kont1		;100 ya da daha büyük olma durumu 
					;için yüzleri yeniden kontrol et.
onlar_kont
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, W		;HexLSB'den 10 çýkart.
	btfss	STATUS, C		;sonuç >= 10 mu?
	goto	birler_kont		;hayýr ise birleri kontrol et.
	incf	onlar, F		;evet ise onlarý bir artýr.
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, F		;HexLSB'den 10 çýkart.
	goto	onlar_kont		;onlar'ý yeniden kontrol et.
birler_kont
	movf	HexLSB, W		;W = HexLSB
	movwf	birler			;birler = W, dönüþüm iþlemi tamam
	return				;alt programdan çýk.
;-------------------------------------------------------------------
; 1-255 sn arasýnda gecikme saðlayan alt program.
;-------------------------------------------------------------------
delay_s
	movwf	delay_s_data
delay_s_j0:
	movlw	.250			;4 * 250 = 1000 ms bekle,
	call	delay_ms		;her çevrim 1 sn.
	movlw	.250
	call	delay_ms
	movlw	.250					
	call	delay_ms
	movlw	.250
	call	delay_ms
	decfsz	delay_s_data
	goto	delay_s_j0
	return

;-------------------------------------------------------------------
; 1-255 ms arasýnda gecikme saðlayan alt program.
;-------------------------------------------------------------------
delay_ms
	movwf	delay_data
delay_ms_j0
	movlw	.142
	movwf	delay_data+1
	nop
	nop
delay_ms_j1
	nop
	nop
	nop
	nop
	decfsz	delay_data+1, F
	goto	delay_ms_j1
	nop
	decfsz	delay_data, F
	goto	delay_ms_j0
	nop
	return
;-------------------------------------------------------------------
; 16-255 µs gecikme saðlayan alt program.
;-------------------------------------------------------------------
delay_us
	movwf	delay_data
	rrf	delay_data, F
	rrf	delay_data, F
	movlw	.63
	andwf	delay_data, F
	movlw	.3
	subwf	delay_data, F
	nop
	decfsz	delay_data, F
	goto	$ - 2
	nop
	return
;-------------------------------------------------------------------
; Kesme programý (kullanýlacak ise LCD ya da zamanlamanýn önemli
; olduðu cihazlarla çalýþýrken iletiþimin kesilmemesine dikkat 
; ediniz).
;-------------------------------------------------------------------
kesme
	retfie
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
Ana_program
	call	LCD_init		;LCD’yi kullanýma hazýrlar.
Ana_j0:
	call	LCD_Clear		;LCD'deki bilgileri sil.
	call	LCD_CursorOff		;Kursörü gizle.
	clrf	sayacH			;sayac = 0
	clrf	sayacL

	LCD_Locate	0, 0		;0. satýr, 0. sütuna konumlan.
	movlw	msg0-6			;mesaj0 yaz (adresi 6 eksiði).
call	LCD_SendMessage
	LCD_Locate	1, 0		;1. satýr, 0. sütuna konumlan
	movlw	msg1-6			;mesaj1 yaz.
    	call	LCD_SendMessage

	movlw	.10
	call	delay_s			;10 saniye bekle.

Ana_j1:
	call	LCD_Clear		;LCD'deki bilgileri sil.

					;sayac deðerini hexadesimal formda 0. satýra yaz.		
	LCD_Locate	0, 0		;0. satýr, 0. sütuna konumlan.	
	movlw	msg2-6			;mesaj2 yaz.
	call	LCD_SendMessage
	movf	sayacH, W
	call	LCD_SendHEX
	movf	sayacL, W
	call	LCD_SendHEX

;sayaç deðerini desimal formda 1. satýra yaz.		
	LCD_Locate	1, 0		;0. satýr, 0. sütuna konumlan.	
	movlw	msg3-6			;mesaj2 yaz.
	call	LCD_SendMessage
	movf	sayacH, W		;HexMSB = sayacH
	movwf	HexMSB
	movf	sayacL, W		;HexLSB = sayacL
	movwf	HexLSB
	call	HexTODec		;Desimale dönüþtür.
	movf	binler, W		;binler basamaðýný yaz.
	call	LCD_SendASCII
	movf	yuzler, W		;yüzler basamaðýný yaz.
	call	LCD_SendASCII
	movf	onlar, W		;onlar basamaðýný yaz.
	call	LCD_SendASCII
	movf	birler, W		;birler basamaðýný yaz.
	call	LCD_SendASCII

	movlw	.1			;1 sn bekle.	
	call	delay_s

; sayacL deðerini binary formda 1. satýra yaz (0. satýrda ayný 
; sayýnýn HEX deðeri var).		
	LCD_Locate	1, 0		;0. satýr, 0. sütuna konumlan.	
	movf	sayacL, W
	call	LCD_SendBIN		;sayacL deðerini binary formda 
					;göster.
; sayaç deðerini 10000 olana kadar bir artýr, 10000 ise en baþa dön
	incf	sayacL, F		;sayacL'yi bir artýr.
	btfsc	STATUS, Z		;sayacL sýfýrdan farklý ise bir 
					;komut atla.
	incf	sayacH, F		;sayacH'i bir artýr.
	movlw	0x27
 	subwf	sayacH, W
	btfss	STATUS, Z		;sayacH = 0x27 ise bir komut atla.
	goto	Ana_j2			;sayac henüz 10000'e ulaþmadý, o 
					;halde devam et.
	movlw	0x10
 	subwf	sayacL, W
	btfss	STATUS, Z		;sayacL = 0x10 ise bir komut atla.
	goto	Ana_j2			;sayac henüz 10000'e ulaþmadý, o 
					;halde devam et.
	goto	Ana_j0			;En baþa dönerek iþlemleri tekrar 
Ana_j2:				;et.
	movlw	.1			;1 sn bekle.
	call	delay_s
	goto	Ana_j1			;sayma iþlemine devam.
	
	end
;*******************************************************************

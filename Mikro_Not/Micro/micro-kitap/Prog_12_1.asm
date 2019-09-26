;*******************************************************************
;	Dosya Ad�		: 12_1.asm
;	Program�n Amac�		: 4-bit arabirim modunda LCD kullan�m�
;	PIC DK2.1a 		: PORTB ��k�� ==> LCD display
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc" 
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; De�i�ken tan�mlar� yap�l�yor: Her bir de�i�ken ba�lang�� 
; adresinden itibaren birbirinin pe�i s�ra 1 byte yer kaplar.
;-------------------------------------------------------------------
	CBLOCK	0x20	;16F877A'n�n RAM ba�lang�� adresi, 
	sayacH		;sayac�n y�ksek byte'�.
	sayacL		;sayac�n d���k byte'�.

	LCD_data	;LCD i�in ge�ici veri de�i�keni.
	LCD_tmp0	;LCD i�in ge�ici veri de�i�keni.
	LCD_tmp1	;LCD i�in ge�ici veri de�i�keni.
	LCD_line	;LCD i�in sat�r bilgisini tutan de�i�ken.
	LCD_pos		;LCD i�in s�tun bilgisi tutan de�i�ken.

	HexMSB		;Desimale �evrilecek say�n�n en de�erli byte'�.
	HexLSB		;Desimale �evrilecek say�n�n en de�ersiz byte'�.
	binler		;Desimale �evrilen say�n�n binler basama��.	
	yuzler		;Desimale �evrilen say�n�n y�zler basama��.	
	onlar		;Desimale �evrilen say�n�n onlar basama��.	
	birler		;Desimale �evrilen say�n�n birler basama��. 

	delay_s_data	;Gecikme alt programlar� i�in veri de�i�keni.	
	delay_data	;Gecikme alt programlar� i�in veri de�i�keni.
	ENDC

	ORG 	0 
	pagesel Ana_program	 
	goto 	Ana_program	;Ana programa git.

	ORG 	4		;Kesme alt program� bu adresten ba�l�yor.
	goto	kesme
;-------------------------------------------------------------------
; LCD ile ilgili temel tan�mlamalar ve mesajlar.
;-------------------------------------------------------------------
; LCD'nin ba�l� oldu�u port tan�mlar� yap�l�yor.
#define LCD_DataPort PORTB		;Data pinlerinin ba�l� oldu�u port 
					;(D7-D4  -> RB3-RB0 ).
#define LCD_CtrlPort PORTB		;Kontrol pinlerinin ba�land��� port

; LCD'nin kontrol pinlerinin ba�l� oldu�u mikrodenetleyici pinleri 
; tan�mlan�yor.
#define LCD_RS	4		;LCD RS pini RB4'e ba�l�.
#define LCD_EN	5		;LCD E pini RB5'e ba�l�.
#define LCD_RW	6		;LCD RW pini RB6'ya ba�l�.

mesajlar			;LCD'ye g�nderilecek mesajlar buraya yaz�l�yor.
	addwf	PCL, F			;mesaj adresini y�kle.
msg0	dt	"Merhaba ", 0		;0 sonland�rma karakteri.
msg1	dt	"DUNYA!..", 0
msg2	dt	"HEX:", 0
msg3	dt	"DEC:", 0
;-------------------------------------------------------------------
; LCD ile ilgili macro tan�mlar�:
;-------------------------------------------------------------------
LCD_RS_HIGH	macro			;LCD'nin RS giri�ini HIGH yaparak 
	banksel LCD_CtrlPort		;veri alma modu se�ilir.
	bsf	LCD_CtrlPort, LCD_RS
	endm

LCD_RS_LOW	macro			;LCD'nin RS giri�ini LOW yaparak 
	banksel LCD_CtrlPort		;komut alma modu se�ilir.
	bcf	LCD_CtrlPort, LCD_RS	
	endm

LCD_EStrobe macro			;LCD'ye veri ya da komut 
	banksel LCD_CtrlPort		;g�nderildi�inde LCD'nin 
	bsf	LCD_CtrlPort, LCD_EN	;bunu i�lemesini sa�lar.
	movlw	.20			;20us kadar bekle. 
	call	delay_us
	bcf	LCD_CtrlPort, LCD_EN
	endm

LCD_Locate	macro	line, pos
  	movlw 	line			;Sat�r bilgisini y�kle.
	movwf	LCD_line	
 	movlw 	pos			;S�tun bilgisini y�kle.
	movwf	LCD_pos				
	call	LCD_SetPos		;Kurs�r� konumland�r.
	endm

; ----------------LCD ile ilgili fonksiyonlar.---------------------
;-------------------------------------------------------------------
; 4 bit ileti�im modunda LCD'ye veri transferi yapar.
;-------------------------------------------------------------------
LCD_NybbleOut                       
	andlw	0x0F			;En de�ersiz 4 bit W'de,
	movwf	LCD_tmp0		;ge�ici de�i�kene al�n�yor.
	movf	LCD_DataPort,W		;LCD'nin data pinlerinin ba�l� 
					;oldu�u port bilgisi W'de.
	andlw	0xF0			;Port bilgisinin en de�erli 4 bit�i 
					;korunuyor.
	iorwf	LCD_tmp0, W		;Korunan bilgi ile veri 
					;birle�tiriliyor.
	movwf	LCD_DataPort		;PortA transfer ediliyor.
	LCD_EStrobe			;LCD'nin veriyi almas� sa�lan�yor.
	movlw	.255			;250us kadar bekle. Bu s�re LCD 
					;i�erisindeki i�lemlerin tamamlanmas�
	call	delay_us		;i�in gerekli ( en az 160us kadar ).
	return
;-------------------------------------------------------------------
; LCD'ye 1 byte komut transfer eder.
;-------------------------------------------------------------------
LCD_SendCmd         	         	
	movwf	LCD_data	 	;Komutu ge�ici de�i�kene al.
	swapf	LCD_data, W   		;En de�erli 4 bit�i g�nder.
	LCD_RS_LOW			;RS = 0 (komut modu)
call	LCD_NybbleOut
	movf	LCD_data, W		;En de�ersiz 4 bit�i g�nder.
	LCD_RS_LOW			;RS = 0 (komut modu)
	call	LCD_NybbleOut			
	return
;-------------------------------------------------------------------
; LCD'ye bir rakam ya da bir karakter g�ndermek i�in kullan�l�r.
;-------------------------------------------------------------------
LCD_SendASCII						
	addlw	'0'			;LCD'ye rakam� ASCII koda 
					;d�n��t�rerek g�ndermek i�in.
LCD_SendCHAR				;LCD'ye karakter g�ndermek i�in 
					;�a�r�lacak.
	movwf	LCD_data		;Komutu ge�ici de�i�kene al.
	swapf	LCD_data, W		;En de�erli 4 bit�i g�nder.
	LCD_RS_HIGH			;RS = 1 ( veri g�nderme modu )
	call	LCD_NybbleOut
	movf	LCD_data, W		;En de�ersiz 4 bit�i g�nder.
	LCD_RS_HIGH			;RS = 1 ( veri g�nderme modu )
	call	LCD_NybbleOut
	return
;-------------------------------------------------------------------
; 1 byte veriyi hexadesimal formda LCD'ye yazar.
;-------------------------------------------------------------------
LCD_SendHEX	
	movwf	LCD_tmp1
	sublw	0x9F			;say� > 0x9F mi? 
	btfss	STATUS, C		;hay�r ise bir komut atla.
	goto	LCD_HEX_j0
	swapf	LCD_tmp1, W
	andlw	0x0F			;En de�erli 4 bit W'nin en 
	call	LCD_SendASCII		;de�ersiz 4 bit�inde.
	goto	LCD_HEX_j1
LCD_HEX_j0
	swapf	LCD_tmp1, W
	andlw	0x0F			;En de�erli 4 bit W'nin en 
	addlw	.55			;de�ersiz 4 bit�inde.
	call	LCD_SendCHAR
LCD_HEX_j1
	movf	LCD_tmp1, W
	andlw	0x0F			;En de�ersiz 4 bit W'nin en 
	movwf	LCD_tmp1		;de�ersiz 4 bit�inde.
	sublw	0x09			;say� > 0x09 mi? 
	btfss	STATUS, C		;hay�r ise bir komut atla.
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
	movwf	LCD_tmp1		;Ge�ici de�i�kene al.
	movlw	.0
	btfss	LCD_tmp1, 7		;7. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 7		;7. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.

	movlw	.0
	btfss	LCD_tmp1, 6		;6. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 6		;6. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.

	movlw	.0
	btfss	LCD_tmp1, 5		;5. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 5		;5. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.

	movlw	.0
	btfss	LCD_tmp1, 4		;4. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 4		;4. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.

	movlw	.0
	btfss	LCD_tmp1, 3		;3. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 3		;3. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.
	movlw	.0
	btfss	LCD_tmp1, 2		;2. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 2		;2. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.

	movlw	.0
	btfss	LCD_tmp1, 1		;1. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 1		;1. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.
	
	movlw	.0
	btfss	LCD_tmp1, 0		;0. bit 1 ise bir komut atla.
	call	LCD_SendASCII		;0 yazd�r.
	movlw	.1
	btfsc	LCD_tmp1, 0		;0. bit 0 ise bir komut atla.
	call	LCD_SendASCII		;1 yazd�r.
	return
;-------------------------------------------------------------------
; LCD ekran belle�ini siler.
;-------------------------------------------------------------------
LCD_Clear
	movlw	0x01			;LCD g�r�nt� belle�ini sil, 
					;dolay�s� ile 
	call	LCD_SendCmd		;LCD'de g�r�nen bilgileri de sil.
	movlw	.5
	call	delay_ms
	return
;-------------------------------------------------------------------
; Kurs�r� g�ster
;-------------------------------------------------------------------
LCD_CursorOn
	movlw	0x0F			;Display'i a�, kurs�r� g�ster. 
	call	LCD_SendCmd		;Blink ON.
	return

;-------------------------------------------------------------------
; Kurs�r� gizle
;-------------------------------------------------------------------
LCD_CursorOff
	movlw	0x0C			;Display'i a�, kurs�r� gizle,
	call	LCD_SendCmd		;Blink OFF.
	return
;-------------------------------------------------------------------
; LCD ekran� kullan�ma haz�rlar.
;-------------------------------------------------------------------
LCD_init
	bsf	STATUS, RP0		;BANK1 se�ildi. Y�nlendirme 
					;kaydedicileri bu bankta.
	movf	LCD_DataPort, W
	andlw	0xF0			;Portun en de�ersiz 
					;d�rtl�s� ��k�� yap�ld�.
	movwf	LCD_DataPort		;Port y�nlendirildi.
	bcf	LCD_CtrlPort, LCD_EN	;LCD_CtrlPort'un LCD_EN 
					;pini ��k��a y�nlendirildi.
	bcf	LCD_CtrlPort, LCD_RS	;LCD_RS pini ��k�� yap�ld�. 
	bcf	LCD_CtrlPort, LCD_RW	;LCD_RW pini ��k�� yap�ld�.
	bcf	STATUS, RP0		;BANK0 se�ildi.
	clrf	LCD_DataPort

	movlw	.50
	call	delay_ms		;40-50 ms kadar bekle.
	LCD_RS_LOW
	movlw	0x03			;8 bit ileti�im komutu verildi.
	call	LCD_NybbleOut	
	
	movlw	.5			;LCD'nin haz�r olmas� i�in 
					;bekleniyor.
	call delay_ms

	LCD_EStrobe			;8 bit ileti�im i�in komut 
					;yinelendi.
	movlw	.255			;160-255us kadar bekle. 
	call	delay_us
	
	LCD_EStrobe			;8 bit ileti�im i�in komut 
					;yinelendi.
	movlw	.255			;160-255us kadar bekle. 
	call	delay_us

	LCD_RS_LOW
	movlw	0x02			;LCD, 4 Bit ileti�im moduna al�nd�.
	call	LCD_NybbleOut	

	movlw	.255			;160-255us kadar bekle. 
	call	delay_us

	movlw	0x28			;4 bit ileti�im, 2 sat�r LCD, 5x7 
call	LCD_SendCmd			;font se�ildi.
	movlw	0x10			;LCD'de yaz�n�n kaymas� engellendi.
	call	LCD_SendCmd
	movlw	0x01			;LCD g�r�nt� belle�ini sil.
	call	LCD_SendCmd

	movlw	.5			;5 ms bekle.
	call	delay_ms

	movlw	0x06			;Kurs�r her karakter yaz�m�nda bir 
	call	LCD_SendCmd		;ilerlesin.
	movlw	0x0C			;Display'i a�, kurs�r� gizle.
	call	LCD_SendCmd
	return
;-------------------------------------------------------------------
; Mesaj etiketi (adresi) W�ye y�klenen mesaj� LCD ekranda g�r�nt�ler                       
;-------------------------------------------------------------------
LCD_SendMessage
	Movwf	FSR		;�lk karaktere i�aret et (onun adresini 
LCD_SMsg:			;tut).
	Movf	FSR, W		;��aret edilen karakter s�ras�n� W'ye al.
	incf	FSR, F		;Bir sonraki karaktere konumlan.
	Call	mesajlar	;Mesajlardan ilgili karakteri al.
	iorlw  0		;Mesaj sonu mu? 0 bilgisi al�nd� ise 
				;mesaj sonu demektir.
	btfsc  STATUS, Z	;Mesaj sonu de�il ise bir komut atla.
	return			;Mesaj sonu ise alt programdan ��k.
	call   LCD_SendCHAR	;Karakteri LCD'ye yazd�r.
	goto   LCD_SMsg		;Bir sonraki karakter i�in 
				;i�lemleri tekrarla.
;-------------------------------------------------------------------
; Kurs�r� LCD'de istenilen sat�r ve s�tuna konumland�r�r. Text'in 
; nereye yaz�laca��n� belirler. 1 - 2 sat�r olan LCD'ler i�in 
; yaz�ld���na dikkat ediniz. 4 sat�r LCD'ler i�in LCD_line de�erinin
; 0, 1, 2 veya 3 olmas� durumuna g�re DDRAM ba�lang�� adresleri 
; tespit edilmelidir.
;-------------------------------------------------------------------
LCD_SetPos
	movlw	0x80		;0. sat�r i�in DDRAM adres ba�lang�� 
	movf	LCD_line, F	;de�eri.
	btfss	STATUS, Z	;0. sat�r ise bir komut atla.
	movlw	0xC0		;1. sat�r i�in 0x80 adresine ilave 
				;edilecek de�er.
	addwf	LCD_pos, W	;Kurs�r pozisyonu da ilave edilerek 
				;DDRAM'deki adres bulunuyor.
	call	LCD_SendCmd
	return
;-------------------------------------------------------------------
; 2 byte binary veriyi bcd'ye d�n��t�r�r. Sonu� binler, y�zler, 
; onlar ve birler  de�i�kenlerinde saklan�r.
;-------------------------------------------------------------------
HexTODec
	clrf binler			;binler = 0
	clrf yuzler			;yuzler = 0
	clrf onlar			;onlar = 0
	clrf birler			;birler = 0
binler_kont
	movlw	04h			;W'ye 1024 (0x0400) say�s�n�n en 
					;de�erli byte'�n� y�kle.
	subwf	HexMSB, W		;HexMSB'den 1024 ��kart.
	btfss	STATUS, C		;HexMSB > 1024'm�?
	goto	yuzler_kont2		;hay�r ise y�zleri kontrol et.
	incf	binler, F		;evet ise binleri bir art�r.
	movlw	04h			;W'ye 0x04 y�kle.
	subwf	HexMSB, F		;HexMSB'den 1000 ��kart.
	movlw	18h			;W'ye 0x18 y�kle.
	addwf	HexLSB, F		;HexLSB'ye (0x18 = 24) ekle 
	btfsc	STATUS, C		;elde var m�?
	incf	HexMSB, F		;evet ise bir art�r.
	goto	binler_kont		;binleri yeniden kontrol et
yuzler_kont2
	movlw	0x01			;256 (0x0100)
	subwf	HexMSB, W		;HexMSB'den 200 ��kart ve sonucu 
					;W'ye sakla.
	btfss	STATUS, C		;sonu� >=256'm�?
	goto	yuzler_kont1		;Hay�r ise 100'�n katlar�n�
					;kontrol et.
	movlw	0x02			;de�ilse,
	addwf	yuzler, F		;yuzler'e 2 ekle
	movlw	0x01			;W = 1
	subwf	HexMSB, F		;HexMSB'den 200 ��kart.
	movlw	0x38			;W =0x38 (256'n�n 56 l�k k�sm�)
	addwf	HexLSB, F		;HexLSB'ye 56'y� ekle.
	btfsc	STATUS, C		;elde var m�?
	incf	HexMSB, F		;evet ise HexMSB'yi bir art�r.
	movlw	0x0A			;W = 10
	subwf	yuzler, W		;yuzler = 1000 olup olmad���n� 
					;kontrol et.
	btfss	STATUS, Z		;sonu� s�f�r m�?
	goto	yuzler_kont2		;hay�r ise yuzleri yeniden kontrol 
	clrf	yuzler			;et. yuzler = 0
	incf	binler, F		;binler'i art�r.
	goto	yuzler_kont2		;yuzler'i 200 ya da daha b�y�k 
					;say� i�in yeniden kontrol et.
yuzler_kont1 
	movlw	0x64			;W = 0x64
	subwf	HexLSB, W		;HexLSB'den 100 ��kart.
	btfss	STATUS, C		;sonu� >= 100 m�?
	goto	onlar_kont		;hay�r ise onlar� kontrol et.
	incf	yuzler, F		;evet ise yuzler'i bir art�r.
	movlw	0x64			;W = 0x64 (100)
	subwf	HexLSB, F		;HexLSB'yi 100 azalt.
	movlw	0x0A			;W = 0x0A (10)
	subwf	yuzler, W		;yuzler = 1000 kontrol� yap.
	btfss	STATUS, Z		;sonu� = 0 m�?
	goto	yuzler_kont1		;hay�r ise 100 i�in yuzler'i 
					;yeniden kontrol et.
	clrf	yuzler			;yuzler = 0
	incf	binler, F		;binleri bir art�r.
	goto	yuzler_kont1		;100 ya da daha b�y�k olma durumu 
					;i�in y�zleri yeniden kontrol et.
onlar_kont
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, W		;HexLSB'den 10 ��kart.
	btfss	STATUS, C		;sonu� >= 10 mu?
	goto	birler_kont		;hay�r ise birleri kontrol et.
	incf	onlar, F		;evet ise onlar� bir art�r.
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, F		;HexLSB'den 10 ��kart.
	goto	onlar_kont		;onlar'� yeniden kontrol et.
birler_kont
	movf	HexLSB, W		;W = HexLSB
	movwf	birler			;birler = W, d�n���m i�lemi tamam
	return				;alt programdan ��k.
;-------------------------------------------------------------------
; 1-255 sn aras�nda gecikme sa�layan alt program.
;-------------------------------------------------------------------
delay_s
	movwf	delay_s_data
delay_s_j0:
	movlw	.250			;4 * 250 = 1000 ms bekle,
	call	delay_ms		;her �evrim 1 sn.
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
; 1-255 ms aras�nda gecikme sa�layan alt program.
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
; 16-255 �s gecikme sa�layan alt program.
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
; Kesme program� (kullan�lacak ise LCD ya da zamanlaman�n �nemli
; oldu�u cihazlarla �al���rken ileti�imin kesilmemesine dikkat 
; ediniz).
;-------------------------------------------------------------------
kesme
	retfie
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
Ana_program
	call	LCD_init		;LCD�yi kullan�ma haz�rlar.
Ana_j0:
	call	LCD_Clear		;LCD'deki bilgileri sil.
	call	LCD_CursorOff		;Kurs�r� gizle.
	clrf	sayacH			;sayac = 0
	clrf	sayacL

	LCD_Locate	0, 0		;0. sat�r, 0. s�tuna konumlan.
	movlw	msg0-6			;mesaj0 yaz (adresi 6 eksi�i).
call	LCD_SendMessage
	LCD_Locate	1, 0		;1. sat�r, 0. s�tuna konumlan
	movlw	msg1-6			;mesaj1 yaz.
    	call	LCD_SendMessage

	movlw	.10
	call	delay_s			;10 saniye bekle.

Ana_j1:
	call	LCD_Clear		;LCD'deki bilgileri sil.

					;sayac de�erini hexadesimal formda 0. sat�ra yaz.		
	LCD_Locate	0, 0		;0. sat�r, 0. s�tuna konumlan.	
	movlw	msg2-6			;mesaj2 yaz.
	call	LCD_SendMessage
	movf	sayacH, W
	call	LCD_SendHEX
	movf	sayacL, W
	call	LCD_SendHEX

;saya� de�erini desimal formda 1. sat�ra yaz.		
	LCD_Locate	1, 0		;0. sat�r, 0. s�tuna konumlan.	
	movlw	msg3-6			;mesaj2 yaz.
	call	LCD_SendMessage
	movf	sayacH, W		;HexMSB = sayacH
	movwf	HexMSB
	movf	sayacL, W		;HexLSB = sayacL
	movwf	HexLSB
	call	HexTODec		;Desimale d�n��t�r.
	movf	binler, W		;binler basama��n� yaz.
	call	LCD_SendASCII
	movf	yuzler, W		;y�zler basama��n� yaz.
	call	LCD_SendASCII
	movf	onlar, W		;onlar basama��n� yaz.
	call	LCD_SendASCII
	movf	birler, W		;birler basama��n� yaz.
	call	LCD_SendASCII

	movlw	.1			;1 sn bekle.	
	call	delay_s

; sayacL de�erini binary formda 1. sat�ra yaz (0. sat�rda ayn� 
; say�n�n HEX de�eri var).		
	LCD_Locate	1, 0		;0. sat�r, 0. s�tuna konumlan.	
	movf	sayacL, W
	call	LCD_SendBIN		;sayacL de�erini binary formda 
					;g�ster.
; saya� de�erini 10000 olana kadar bir art�r, 10000 ise en ba�a d�n
	incf	sayacL, F		;sayacL'yi bir art�r.
	btfsc	STATUS, Z		;sayacL s�f�rdan farkl� ise bir 
					;komut atla.
	incf	sayacH, F		;sayacH'i bir art�r.
	movlw	0x27
 	subwf	sayacH, W
	btfss	STATUS, Z		;sayacH = 0x27 ise bir komut atla.
	goto	Ana_j2			;sayac hen�z 10000'e ula�mad�, o 
					;halde devam et.
	movlw	0x10
 	subwf	sayacL, W
	btfss	STATUS, Z		;sayacL = 0x10 ise bir komut atla.
	goto	Ana_j2			;sayac hen�z 10000'e ula�mad�, o 
					;halde devam et.
	goto	Ana_j0			;En ba�a d�nerek i�lemleri tekrar 
Ana_j2:				;et.
	movlw	.1			;1 sn bekle.
	call	delay_s
	goto	Ana_j1			;sayma i�lemine devam.
	
	end
;*******************************************************************

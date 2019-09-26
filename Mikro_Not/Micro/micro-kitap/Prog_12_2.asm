;*******************************************************************
;	Dosya Adý		: 12_2.asm
;	Programýn Amacý		: Seri LCD kullanýmý
;	Notlar 			: Proteus programý simülasyonu
;				: XT ==> 4Mhz
;*******************************************************************

           LIST    p=16F877A
           #include "P16F877A.INC"
;-------------------------------------------------------------------
; Deðiþken tanýmlarý.
;-------------------------------------------------------------------
	cblock 0x20
		char, cmd, lc1, lc2;
		sLCD_line, sLCD_pos;
	endc

		org     0
		goto    ana_program
		
		org     4
		goto    kesme
;-------------------------------------------------------------------
; Kesme alt programý.
;-------------------------------------------------------------------
kesme
	retfie	   	           
;-------------------------------------------------------------------
; LCD'ye gönderilecek mesajlar buraya yazýlýyor.
;-------------------------------------------------------------------
mesajlar		                
	addwf  PCL, F               ; mesajlar kýsmý
msg0	dt	"MERHABA DUNYA!... ", 0
;-------------------------------------------------------------------
; Delay alt programý (W = gecikme zamaný).
;-------------------------------------------------------------------
delay
	movwf	lc2
delay_1
	movlw	0xFF
	movwf	lc1
delay_2
	nop
	decfsz	lc1, F
	goto	delay_2
	decfsz  lc2, F
	goto	delay_1
	return
;-------------------------------------------------------------------
; Seri porttan 1 byte alana kadar bekler, alýnan karakter W'de.
;-------------------------------------------------------------------
getc	
	bcf	STATUS, RP0		;Bank0 seçildi.
getc_1
	btfss	PIR1, RCIF		;RCIF bayraðý set ise komut atla 
					;(karakter alýnana kadar bekle).
	goto	getc_1			;Tekrar dene.
	movf	RCREG, W		;Alýnan karakteri W'ye al.
	bcf	PIR1, RCIF		;RCIF bayraðýný sil.
	return
;-------------------------------------------------------------------
; Seri porta ( burada seri LCD  baðlý )bir byte gönderir, gönderme 
; iþlemi tamamlanana kadar bekler. Bu alt program gönderilecek 
; karakter W'ye yüklendikten sonra çaðrýlmalýdýr.
;-------------------------------------------------------------------
sLCD_SendCHAR
	bcf	STATUS, RP0		;Bank0 seçildi.
	movwf	TXREG			;Gönderilecek karakteri TXREG 
					;kaydedicisine al.
	bsf	STATUS, RP0		;Bank1 seçildi.
	movf	TXSTA, W		;Gönderme durum bilgisini W’ al.
sLCD_SendCHAR_1
	btfss	TXSTA, 1		;TXbuffer boþ ise komut atla.
	goto	sLCD_SendCHAR_1		;Tekrar dene.
	bcf	STATUS, RP0		;Bank0 seçildi.
	return
;-------------------------------------------------------------------
; Seri LCD birimine 1 byte komut gönderir.
;-------------------------------------------------------------------
sLCD_SendCmd
	movwf	cmd			;Komutu sakla.
	movlw	0xFE			;Komut göndermek istediðimizi seri 
	call	sLCD_SendCHAR		;LCD'ye bildir.
	movf	cmd, W			;Komut kodunu yaz.
	goto	sLCD_SendCHAR
	return
;-------------------------------------------------------------------
; Kursörü LCD'de istenilen satýr ve sütuna konumlandýrýr. Text'in 
; nereye yazýlacaðýný belirler. 1 - 2 satýr olan LCD'ler için 
; yazýldýðýna dikkat ediniz. 4 satýr LCD'ler için LCD_line deðerinin
; 0, 1, 2 veya 3 olmasý durumuna göre DDRAM baþlangýç adresleri 
; tespit edilmelidir.
;-------------------------------------------------------------------
sLCD_SetPos
	movlw	0x80			;0. satýr için DDRAM adres 
	movf	sLCD_line, F		;baþlangýç deðeri.
	btfss	STATUS, Z		;0. satýr ise bir komut atla.
	movlw	0xC0			;1. satýr için 0x80 adresine ilave 
					;edilecek deðer.
	addwf	sLCD_pos, W		;Kursör pozisyonu da ilave edilerek 
call	sLCD_SendCmd			;DDRAM'deki adres bulunuyor.
	return

sLCD_Locate	macro	line, pos
  	movlw 	line			;Satýr bilgisini yükle.
	movwf	sLCD_line	
 	movlw 	pos			;Sütun bilgisini yükle.
	movwf	sLCD_pos				
	call	sLCD_SetPos		;Kursörü konumlandýr.
	endm

;-------------------------------------------------------------------
; Mesaj etiketi (adresi) W'ye yüklenen mesajý LCD ekranda görüntüler                       
;-------------------------------------------------------------------
sLCD_SendMessage
	sublw	.7		;Mesaj adresine giderken araya giren ilave 
				;komutlarý bertaraf eder.
	movwf	FSR		;Ýlk karaktere iþaret et (onun adresini 
				;tut).
sLCD_SMsg:
	movf	FSR, W		;Ýþaret edilen karakter sýrasýný W'ye al.
	incf	FSR, F		;Bir sonraki karaktere konumlan.
	call	mesajlar	;Mesajlardan ilgili karakteri al.
	iorlw	0		;Mesaj sonu mu? 0 bilgisi alýndý ise mesaj 
;sonu demektir.
	btfsc	STATUS, Z	;Mesaj sonu deðil ise bir komut atla.
	return			;Mesaj sonu ise alt programdan çýk.
	call	sLCD_SendCHAR	;Karakteri LCD'ye yazdýr.
	goto	sLCD_SMsg	;Bir sonraki karakter için 
				;iþlemleri tekrarla.
;-------------------------------------------------------------------
; Display'de imleci görüntüle.
;-------------------------------------------------------------------
sLCD_CursorON
	movlw	0x0D 		   	;Kursörü göster.
	call	sLCD_SendCmd
	return
;-------------------------------------------------------------------
; LCD'yi siler.
;-------------------------------------------------------------------
sLCD_Clear
	movlw	0x01			;Silme komutunu yaz.
	call	sLCD_SendCmd
	return        
;-------------------------------------------------------------------
; LCD üzerinde imleci bir geriye alýr ve oradaki karakteri siler.
;-------------------------------------------------------------------
sLCD_BSpace
	movlw	0x10			;backspace komutunu yaz.
	call	sLCD_SendCmd
	clrw 
	call	sLCD_SendCHAR
	movlw	0x10			;backspace komutunu yaz.
	call	sLCD_SendCmd
	return
;-------------------------------------------------------------------
; Ana program: Usart biriminden aldýðý karakterleri 2. satýrda seri 
; LCD üzerinde görüntüler.
;-------------------------------------------------------------------
ana_program
;Seri iletiþim ayarlarý yapýlýyor.
	bcf	STATUS, RP0		;Bank0 seçildi.
	bsf	RCSTA, SPEN		;USART etkinleþtirildi.
	bsf	RCSTA, CREN		;USART biriminden veri alma 
					;etkinleþtirildi.
	bsf	STATUS, RP0		;Bank1 seçildi.
	movlw	.103			;Fosc 4MHz ve 2400 baud rate için 
					;BRG deðeri W'ye yüklendi.
	movwf	SPBRG			;Baud rate deðeri SPBRG 
					;kaydedicisinde.
	movlw	0xA4			;CSRC/TXEN (dahili clock, 8-bit 
					;mod, Async iletiþim, High Speed 
					;iletiþim).
	movwf	TXSTA			;TX kontrol kaydedicisine yükle.

	movlw	255			;Güç verildikten sonra LCD hazýr
					;olana kadar bekle (ortalama 500ms 
call	delay				;kadar).
	movlw	255
	call	delay
	movlw	255			
	call	delay
	movlw	255
	call	delay

	sLCD_Locate	0, 0		;0. satýr, 0. sütuna konumlan.
	movlw	msg0			;mesaj0 yaz.
call	sLCD_SendMessage

	sLCD_Locate	1, 0		;1. satýr, 0. sütuna konumlan.
	call	sLCD_CursorON		;Seri LCD'de imleci göster.

tekrar
	call	getc                                  
	movwf	char           
	sublw	.27			;ESC ise LCD'yi sil ve 0’ýncý satýr
					;0’ýncý sütuna git.
	btfss	STATUS, Z
	goto	ana_1
	call 	sLCD_Clear
	goto	tekrar
ana_1
	movf 	char, W
	sublw	.8			;BACKSPACE ise bir karakter geriye sil
	btfss	STATUS, Z
	goto	ana_2
	call	sLCD_BSpace
	goto	tekrar
ana_2
	movf 	char, W
	sublw	.13			;ENTER ise üst satýrda ise alt 
	btfss	STATUS, Z		;satýra geç.
	goto	ana_3
	sLCD_Locate	1, 0		;1. satýr, 0. sütuna konumlan.
	goto	tekrar
ana_3
	movf	char, W
	call	sLCD_SendCHAR		;ASCII karakteri LCD'ye gönder.
	goto	tekrar

	END
;*******************************************************************

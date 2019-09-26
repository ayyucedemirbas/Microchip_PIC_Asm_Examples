;*******************************************************************
;	Dosya Ad�		: 12_2.asm
;	Program�n Amac�		: Seri LCD kullan�m�
;	Notlar 			: Proteus program� sim�lasyonu
;				: XT ==> 4Mhz
;*******************************************************************

           LIST    p=16F877A
           #include "P16F877A.INC"
;-------------------------------------------------------------------
; De�i�ken tan�mlar�.
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
; Kesme alt program�.
;-------------------------------------------------------------------
kesme
	retfie	   	           
;-------------------------------------------------------------------
; LCD'ye g�nderilecek mesajlar buraya yaz�l�yor.
;-------------------------------------------------------------------
mesajlar		                
	addwf  PCL, F               ; mesajlar k�sm�
msg0	dt	"MERHABA DUNYA!... ", 0
;-------------------------------------------------------------------
; Delay alt program� (W = gecikme zaman�).
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
; Seri porttan 1 byte alana kadar bekler, al�nan karakter W'de.
;-------------------------------------------------------------------
getc	
	bcf	STATUS, RP0		;Bank0 se�ildi.
getc_1
	btfss	PIR1, RCIF		;RCIF bayra�� set ise komut atla 
					;(karakter al�nana kadar bekle).
	goto	getc_1			;Tekrar dene.
	movf	RCREG, W		;Al�nan karakteri W'ye al.
	bcf	PIR1, RCIF		;RCIF bayra��n� sil.
	return
;-------------------------------------------------------------------
; Seri porta ( burada seri LCD  ba�l� )bir byte g�nderir, g�nderme 
; i�lemi tamamlanana kadar bekler. Bu alt program g�nderilecek 
; karakter W'ye y�klendikten sonra �a�r�lmal�d�r.
;-------------------------------------------------------------------
sLCD_SendCHAR
	bcf	STATUS, RP0		;Bank0 se�ildi.
	movwf	TXREG			;G�nderilecek karakteri TXREG 
					;kaydedicisine al.
	bsf	STATUS, RP0		;Bank1 se�ildi.
	movf	TXSTA, W		;G�nderme durum bilgisini W� al.
sLCD_SendCHAR_1
	btfss	TXSTA, 1		;TXbuffer bo� ise komut atla.
	goto	sLCD_SendCHAR_1		;Tekrar dene.
	bcf	STATUS, RP0		;Bank0 se�ildi.
	return
;-------------------------------------------------------------------
; Seri LCD birimine 1 byte komut g�nderir.
;-------------------------------------------------------------------
sLCD_SendCmd
	movwf	cmd			;Komutu sakla.
	movlw	0xFE			;Komut g�ndermek istedi�imizi seri 
	call	sLCD_SendCHAR		;LCD'ye bildir.
	movf	cmd, W			;Komut kodunu yaz.
	goto	sLCD_SendCHAR
	return
;-------------------------------------------------------------------
; Kurs�r� LCD'de istenilen sat�r ve s�tuna konumland�r�r. Text'in 
; nereye yaz�laca��n� belirler. 1 - 2 sat�r olan LCD'ler i�in 
; yaz�ld���na dikkat ediniz. 4 sat�r LCD'ler i�in LCD_line de�erinin
; 0, 1, 2 veya 3 olmas� durumuna g�re DDRAM ba�lang�� adresleri 
; tespit edilmelidir.
;-------------------------------------------------------------------
sLCD_SetPos
	movlw	0x80			;0. sat�r i�in DDRAM adres 
	movf	sLCD_line, F		;ba�lang�� de�eri.
	btfss	STATUS, Z		;0. sat�r ise bir komut atla.
	movlw	0xC0			;1. sat�r i�in 0x80 adresine ilave 
					;edilecek de�er.
	addwf	sLCD_pos, W		;Kurs�r pozisyonu da ilave edilerek 
call	sLCD_SendCmd			;DDRAM'deki adres bulunuyor.
	return

sLCD_Locate	macro	line, pos
  	movlw 	line			;Sat�r bilgisini y�kle.
	movwf	sLCD_line	
 	movlw 	pos			;S�tun bilgisini y�kle.
	movwf	sLCD_pos				
	call	sLCD_SetPos		;Kurs�r� konumland�r.
	endm

;-------------------------------------------------------------------
; Mesaj etiketi (adresi) W'ye y�klenen mesaj� LCD ekranda g�r�nt�ler                       
;-------------------------------------------------------------------
sLCD_SendMessage
	sublw	.7		;Mesaj adresine giderken araya giren ilave 
				;komutlar� bertaraf eder.
	movwf	FSR		;�lk karaktere i�aret et (onun adresini 
				;tut).
sLCD_SMsg:
	movf	FSR, W		;��aret edilen karakter s�ras�n� W'ye al.
	incf	FSR, F		;Bir sonraki karaktere konumlan.
	call	mesajlar	;Mesajlardan ilgili karakteri al.
	iorlw	0		;Mesaj sonu mu? 0 bilgisi al�nd� ise mesaj 
;sonu demektir.
	btfsc	STATUS, Z	;Mesaj sonu de�il ise bir komut atla.
	return			;Mesaj sonu ise alt programdan ��k.
	call	sLCD_SendCHAR	;Karakteri LCD'ye yazd�r.
	goto	sLCD_SMsg	;Bir sonraki karakter i�in 
				;i�lemleri tekrarla.
;-------------------------------------------------------------------
; Display'de imleci g�r�nt�le.
;-------------------------------------------------------------------
sLCD_CursorON
	movlw	0x0D 		   	;Kurs�r� g�ster.
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
; LCD �zerinde imleci bir geriye al�r ve oradaki karakteri siler.
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
; Ana program: Usart biriminden ald��� karakterleri 2. sat�rda seri 
; LCD �zerinde g�r�nt�ler.
;-------------------------------------------------------------------
ana_program
;Seri ileti�im ayarlar� yap�l�yor.
	bcf	STATUS, RP0		;Bank0 se�ildi.
	bsf	RCSTA, SPEN		;USART etkinle�tirildi.
	bsf	RCSTA, CREN		;USART biriminden veri alma 
					;etkinle�tirildi.
	bsf	STATUS, RP0		;Bank1 se�ildi.
	movlw	.103			;Fosc 4MHz ve 2400 baud rate i�in 
					;BRG de�eri W'ye y�klendi.
	movwf	SPBRG			;Baud rate de�eri SPBRG 
					;kaydedicisinde.
	movlw	0xA4			;CSRC/TXEN (dahili clock, 8-bit 
					;mod, Async ileti�im, High Speed 
					;ileti�im).
	movwf	TXSTA			;TX kontrol kaydedicisine y�kle.

	movlw	255			;G�� verildikten sonra LCD haz�r
					;olana kadar bekle (ortalama 500ms 
call	delay				;kadar).
	movlw	255
	call	delay
	movlw	255			
	call	delay
	movlw	255
	call	delay

	sLCD_Locate	0, 0		;0. sat�r, 0. s�tuna konumlan.
	movlw	msg0			;mesaj0 yaz.
call	sLCD_SendMessage

	sLCD_Locate	1, 0		;1. sat�r, 0. s�tuna konumlan.
	call	sLCD_CursorON		;Seri LCD'de imleci g�ster.

tekrar
	call	getc                                  
	movwf	char           
	sublw	.27			;ESC ise LCD'yi sil ve 0��nc� sat�r
					;0��nc� s�tuna git.
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
	sublw	.13			;ENTER ise �st sat�rda ise alt 
	btfss	STATUS, Z		;sat�ra ge�.
	goto	ana_3
	sLCD_Locate	1, 0		;1. sat�r, 0. s�tuna konumlan.
	goto	tekrar
ana_3
	movf	char, W
	call	sLCD_SendCHAR		;ASCII karakteri LCD'ye g�nder.
	goto	tekrar

	END
;*******************************************************************

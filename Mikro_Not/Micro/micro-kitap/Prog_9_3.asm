;*****************************************************************
;	Dosya Adý		: 9_3.asm
;	Programýn Amacý		: Seri eeprom ile iletiþim.
;	PIC DK2.1a 		: PORTB Çýkýþ ==> 7 Segment Display
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20Mhz.
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý.
;-------------------------------------------------------------------
#define	OKU	1		;Okuma butonunun baðlý olduðu pin.
#define	YAZ	2		;Yazma butonunun baðlý olduðu pin.
#define	WP	3		;Seri EEPROM yazma korumasý için 
				;iþlemci çýkýþ pini.
delay_ms_data	equ 	0x70 	;Delay için 2 byte'lýk deðiþken.
I2CSend_Data	equ 	0x72	;Geçici deðiþken.
I2C_Device	equ 	0x73	;I2C cihazý donaným adresi 
				;deðiþkeni (0-7).
I2C_AdrH	equ 	0x74	;I2C cihazý veri adresinin üst 
				;byte'ý.
I2C_AdrL	equ 	0x75	;I2C cihazý veri adresinin alt 
				;byte'ý.
I2C_Data	equ 	0x76	;I2C cihazý veri deðiþkeni.

	ORG	0
	clrf	PCLATH
	goto	Ana_Program
;-------------------------------------------------------------------
; MSSP modülünü I2C Master iletiþim için hazýrlar.
;-------------------------------------------------------------------
I2C_init
	banksel   SSPSTAT		;BANK1
	clrf	SSPSTAT			;Tüm durum bit’leri siliniyor.
	bsf 	SSPSTAT, SMP		;SMP = 1 SLEW Rate Control pasif, 
					;Standart speed mod.
	movlw	B'00110001'		;Fosc = 20MHz için BitRate = 100kHz 
					;seçersek formülden
	movwf	SSPADD			;SSPADD=49 bulunur.
	clrf	SSPCON2			;Kontrol bit’lerini sil.
	movlw	B'10011000'		;Usart için RX ve I2C için SCL ve 
					;SDA giriþe ayarlandý.
	movwf	TRISC			
	movlw	B'00101000'		;SSPEN=1, I2C Master Fosc based 
					;clock mod seçiliyor.
	bcf 	STATUS, RP0		;BANK0
	movwf	SSPCON
	clrf	PORTC
	return
;-------------------------------------------------------------------
; I2C Start bit’i gönderen alt program.
;-------------------------------------------------------------------
I2CStart
	banksel PIR1			;BANK0
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	bsf	STATUS, RP0		;BANK1
	bsf	SSPCON2, SEN		;Start bit Enable edildi.
I2CStart_j1
	btfsc	SSPCON2, SEN		;SEN bit’i silinene kadar bekle.
	goto	I2CStart_j1
	banksel PIR1			;BANK0
I2CStart_j2
	btfss	PIR1, SSPIF
	goto	I2CStart_j2		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	return
;-------------------------------------------------------------------
; I2C ReStart bit’i gönderen alt program.
;-------------------------------------------------------------------
I2CReStart
	nop
	nop
	nop
	nop
	nop				;Kýsa bir süre bekle.
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, RSEN		;ReStart bit Enable edildi.
I2CReStart_j1
	btfsc	SSPCON2, RSEN		;ReStart bit silinene kadar bekle.
	goto	I2CReStart_j1
	return
;-------------------------------------------------------------------
; I2C cihazýna SSPBUF kaydedicisindeki veriyi gönderen alt program.
;-------------------------------------------------------------------
I2CSend
	banksel PIR1			;BANK0
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	movf	I2CSend_Data, W
	movwf	SSPBUF			;Gönderilecek byte SSP buffer 
					;kaydedicisine yüklendi.
	return
;-------------------------------------------------------------------
; I2C cihazýndan SSPBUF kaydedicisine veri okuma alt programý.
;-------------------------------------------------------------------
I2CRead
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, RCEN		;Receive Enable bit’i set edildi.
I2CRead_j1
	btfsc	SSPCON2, RCEN		;Receive Enable bit’i silinene
goto	I2CRead_j1 			;kadar bekle.

	banksel PIR1			;BANK0
I2CRead_j2
	btfss	PIR1, SSPIF
	goto	I2CRead_j2		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	movf	SSPBUF, W		;Okunan veri SSPBUF'den W 
					;kaydedisine aktarýldý.
	return
;-------------------------------------------------------------------
; I2C Stop bit’i gönderen alt program.
;-------------------------------------------------------------------
I2CStop
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, PEN		;Stop bit enable yapýldý.
I2CStop_j1
	btfsc	SSPCON2, PEN	
	goto	I2CStop_j1		;Stop bit’i silinene (gönderilene) 
					;kadar bekle.
	banksel PIR1			;BANK0
I2CStop_j2
	btfss	PIR1, SSPIF		
	goto	I2CStop_j2		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	return
;-------------------------------------------------------------------
; I2C cihazýndan Ack bilgisi alan alt program.
;-------------------------------------------------------------------
I2CAck
	banksel SSPCON2			;BANK1
	bcf	SSPCON2, ACKDT		;ACK bilgisi için LOW seviye 
					;seçiliyor.
	bsf	SSPCON2, ACKSTAT	;ACKSTAT set ediliyor. Bu bit I2C 
					;cihazý tarafýndan
I2CAck_j1				;silindiðinde ACK LOW bilgisi 
					;gelmiþ ve iþlem I2C
	btfsc	SSPCON2, ACKSTAT	;cihazý tarafýndan onaylanmýþ 
					;demektir.
	goto	I2CAck_j1		;ACKSTAT LOW olana kadar bekle (ACK 
					;gelene kadar).
	banksel PIR1			;BANK0
I2CAck_j2
	btfss	PIR1, SSPIF
	goto	I2CAck_j2		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	return
;-------------------------------------------------------------------
; I2C cihazýndan Not Ack bilgisi alan alt program.
;-------------------------------------------------------------------
I2CNak
	banksel SSPCON2			;BANK1
	bsf 	SSPCON2, ACKDT		;NOT ACK bilgisi için HIGH seviye 
					;seçiliyor.
I2CNak_j1						
	btfsc	SSPCON2, ACKSTAT	;ACKSTAT LOW olana kadar bekle (NOT 
					;ACK gelene kadar).
	goto	I2CNak_j1
	bsf	SSPCON2, ACKEN		;ACKEN set edilir.
	bcf	STATUS, RP0		;BANK0
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
I2CNak_j2
	banksel SSPCON2			;BANK1
	btfsc	SSPCON2, ACKEN		;ACKEN silinene kadar bekle.
	goto	I2CNak_j2
	banksel PIR1			;BANK0
I2CNak_j3
	btfss	PIR1, SSPIF
	goto	I2CNak_j3		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	return
;-------------------------------------------------------------------
; Seri EEPROM'a I2C_Data deðiþkenindeki veriyi yazan alt program.
;-------------------------------------------------------------------
I2C_WriteEE
	call	I2CStart		;Start bilgisi gönderiliyor.
	rlf	I2C_Device, W		;EEPROM donaným adresi (A2,A1,A0) 
					;ayarlanýyor.
	andlw	0xFE
	iorlw	0xA0			;Donaným adresi ile kontrol byte'ý 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;birleþtiriliyor ve I2CSend 
					;fonksiyonuna ait
	call	I2CSend			;parametreye yükleniyor ve 
					;gönderiliyor.
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	movf	I2C_AdrH, W
	movwf	I2CSend_Data		;Adresin yüksek byte'ý gönderiliyor
	call	I2CSend
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	movf	I2C_AdrL, W	
	movwf	I2CSend_Data		;Adresin alçak byte'ý gönderiliyor.
	call	I2CSend
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	movf	I2C_Data, W
	movwf	I2CSend_Data		;Yazýlacak veri gönderiliyor.
	call	I2CSend
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	call	I2CStop			;Stop bilgisi gönderiliyor.
	return
;-------------------------------------------------------------------
; Seri EEPROM'dan I2C_Data deðiþkenindeki veri okuyan alt program.
;-------------------------------------------------------------------
I2C_ReadEE
	call	I2CStart		;Start bilgisi gönderiliyor
	rlf	I2C_Device, W		;EEPROM donaným adresi (A2,A1,A0) 
					;ayarlanýyor.
	andlw	0xFE
	iorlw	0xA0			;Donaným adresi ile kontrol byte'ý 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;birleþtiriliyor ve I2CSend 
					;fonksiyonuna ait parametreye
	call	I2CSend			;yükleniyor ve gönderiliyor.
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	movf	I2C_AdrH, W
	movwf	I2CSend_Data		;Adresin yüksek byte'ý gönderiliyor
	call	I2CSend
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	movf	I2C_AdrL, W	
	movwf	I2CSend_Data		;Adresin alçak byte'ý gönderiliyor	
	call	I2CSend
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	call	I2CReStart		;Restart bilgisi gönderiliyor.
					;(okuma için gerekli)
	rlf	I2C_Device,	W	;EEPROM donaným adresi (A2,A1,A0) 
					;ayarlanýyor.
	andlw	0xFE
	iorlw	0xA1			;Donaným adresi ile kontrol bayte'ý 
					;ve oku bilgisi
	movwf	I2CSend_Data		;birleþtiriliyor ve I2CSend 
					;fonksiyonuna ait parametreye
	call	I2CSend			;yükleniyor ve gönderiliyor.
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	call	I2CRead			;Okuma fonsiyonu ile OKU bilgisi 
					;gönderiliyor.
	movwf	I2C_Data		;Okunan veri Work register (W) de.
	call	I2CNak			;Ýþlemin tamamlandýðýna dair bilgi 
					;alýnýyor.
	call	I2CStop			;Stop bilgisi gönderiliyor.
	return
;-------------------------------------------------------------------
; 20MHz de 1 ms'lik temel gecikme saðlar.
; delay_ms_data = 1-255 ms arasýnda ayarlanarak istenilen gecikme 
; elde edilir. Örneðin: delay_ms_data = 10 yapýldýðýnda 10 ms'lik 
; gecikme elde edilir.
;-------------------------------------------------------------------
delay_ms
delay_j1
	movlw	D'185'
	movwf	delay_ms_data+1
	nop
delay_j2
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F
	goto	delay_j2
	nop
	decfsz	delay_ms_data, F
	goto	delay_j1
	nop
	return
;-------------------------------------------------------------------
; Ana Program
;-------------------------------------------------------------------
Ana_Program
	
	movlw	0x06			;Analog giriþler kapalý, PORTA 
					;dijital giriþe ayarlandý.
	banksel ADCON1
	movwf	ADCON1			;Analog giriþler kapalý, PORTA 
					;dijital giriþe ayarlandý.
	movwf	TRISA			;RA2 ve RA1 dijital giriþ, 
					;diðerleri çýkýþa ayarlandý
	clrf	TRISB			;PORTB çýkýþa ayarlandý.
	banksel PORTA			;BANK0 seçildi.
	movlw	0x08			
	movwf	PORTA			;Seri EEPROM yazma korumasý aktif 
					;hale getiriliyor.
	clrf	PORTB			;LED’ler ilk durumda sönükler.

	call	I2C_init		;I2C modülü ilk iþlemleri yapýlýyor

Ana_Prog_Oku
	btfsc	PORTA, OKU		;RA1'e basýldý ise (Seri EEPROM 
					;okuma kontrol butonu).
	goto	Ana_Prog_Yaz		;RA1 butonuna basýlmadý ise RA2'i 
					;kontrol et.
	clrf	I2C_Device		;24C32 Donaným adresi 0
	clrf	I2C_AdrH		;AdresHigh = 0
	movlw	0x1A			;Okumak istediðimiz adresin düþük 
					;byte'ý.
	movwf	I2C_AdrL		;AdresLow  = 0x1A; Adres = 0x001A
	call	I2C_ReadEE		;Okuma alt programý çaðrýlýyor.
	movwf	PORTB			;Okunan deðeri PORTB'deki LED’lerde 
					;göster.
	movlw	0x0A
	movwf	delay_ms_data		;10ms beklemek için 1ms Delay 
					;parametresine 10 deðeri yükleniyor
	call	delay_ms		;ve delay_ms çaðrýlýyor.
	goto	Ana_Prog_Sonu

Ana_Prog_Yaz
	btfsc	PORTA, YAZ		;RA2'e basýldý ise (Seri EEPROM 
					;yazma kontrol butonu).
	goto	Ana_Prog_Oku		;RA2 butonuna basýlmadý ise RA1'i 
					;kontrol et.
	bcf	PORTA, WP		;EEPROM yazma korumasý kaldýrýlýyor
	clrf	I2C_Device		;24C32 Donaným adresi 0
	clrf	I2C_AdrH		;AdresHigh = 0
	movlw	0x1A			;Yazmak istediðimiz adresin düþük 
					;byte'ý.
	movwf	I2C_AdrL		;AdresLow  = 0x1A; Adres = 0x001A
	movlw	0xC9			;Yazmak istediðimiz veri.
	movwf	I2C_Data		;Örneðimizde bu veri 0xC9
	call	I2C_WriteEE		;Yazma alt programý çaðrýlýyor.
	bsf	PORTA, WP		;EEPROM yazma korumasý aktif hale 
					;getiriliyor.
	movlw	0x0A
	movwf	delay_ms_data		;10ms beklemek için 1ms Delay 
					;parametresine 10 deðeri yükleniyor
	call	delay_ms		;ve delay_ms çaðrýlýyor.

Ana_Prog_Sonu
	goto	Ana_Prog_Sonu		;Sistem kapatýlana ya da 
					;resetlenene kadar boþ döngü.
	END
;*******************************************************************

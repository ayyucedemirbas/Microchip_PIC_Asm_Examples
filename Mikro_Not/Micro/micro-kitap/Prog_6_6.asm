;*******************************************************************
;	Dosya Adý		: 6_6.asm
;	Programýn Amacý		: I²C Protokolü ile Seri Veri Ýletiþimi
;				 (PCF8574 kullanýlarak).
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20 Mhz.
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý
;-------------------------------------------------------------------
delay_ms_data		equ 0x70 	;Delay için 2 byte'lýk deðiþken.
I2CSend_Data		equ 0x72	;Geçici deðiþken.
I2C_Data		equ 0x73	;I2C cihazý veri deðiþkeni.
pcf8574_data		equ 0x74

	ORG	0
	clrf	PCLATH
	goto	Ana_Program
;-------------------------------------------------------------------
; MSSP modülünü I2C Master iletiþim için hazýrlar.
;-------------------------------------------------------------------
I2C_init
	banksel SSPSTAT			;BANK1’e geçildi.
	clrf	SSPSTAT			;Tüm durum bit’leri siliniyor.
	bsf 	SSPSTAT, SMP		;SMP = 1 SLEW Rate Control pasif. 
					;(Standart speed mod)
	movlw	B'00110001'		;Fosc = 20MHz için BitRate = 100kHz 
					;seçersek formülden
	movwf	SSPADD			;SSPADD=49 bulunur.
	clrf	SSPCON2			;Kontrol bit’lerini sil.
	movlw	B'10011000'		;Usart için RX ve I2C için SCL ve 
					;SDA giriþe ayarlandý.
	movwf	TRISC			
	movlw	B'00101000'		;SSPEN=1, I2C Master Fosc based 
					;clock mod seçiliyor.
	bcf 	STATUS, RP0		;BANK0’a geçildi.
	movwf	SSPCON
	clrf	PORTC
	return
;-------------------------------------------------------------------
; I2C Start bit’i gönderen alt program
;-------------------------------------------------------------------
I2CStart
	banksel PIR1			;BANK0’a geçildi.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	bsf	STATUS, RP0		;BANK1’e geçildi.
	bsf	SSPCON2, SEN		;Start bit Enable edildi.
I2CStart_j1
	btfsc	SSPCON2, SEN		;SEN bit’i silinene kadar bekle.
	goto	I2CStart_j1
	banksel PIR1			;BANK0’a geçildi.
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
	banksel SSPCON2			;BANK1’e geçildi.
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
	banksel SSPSTAT
	btfss	SSPSTAT,BF
	goto	$-1
	bcf	STATUS,RP0
	return
;-------------------------------------------------------------------
; I2C cihazýndan SSPBUF kaydedicisine veri okuma alt programý.
;-------------------------------------------------------------------
I2CRead
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, RCEN		;Receive Enable bit’i set edildi.
I2CRead_j1
	btfsc	SSPCON2, RCEN		;Receive Enable bit’i silinene
					;kadar bekle.
	goto	I2CRead_j1
	banksel PIR1			;BANK0
I2CRead_j2
	btfss	PIR1, SSPIF
	goto	I2CRead_j2		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	movf	SSPBUF, W		;Okunan veri SSPBUF'den W 
					;kaydedicisine aktarýldý.
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
	banksel PIR1			;BANK0.
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
	banksel SSPCON2			;BANK1.
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
	banksel PIR1			;BANK0.
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
	banksel SSPCON2			;BANK1.
	bsf 	SSPCON2, ACKDT		;NOT ACK bilgisi için HIGH seviye 
					;seçiliyor.
I2CNak_j1						
	btfsc	SSPCON2, ACKSTAT	;ACKSTAT LOW olana kadar bekle (NOT 
					;ACK gelene kadar).
	goto	I2CNak_j1
	bsf	SSPCON2, ACKEN		;ACKEN set edilir.
	bcf	STATUS, RP0		;BANK0.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
I2CNak_j2
	banksel SSPCON2			;BANK1.
	btfsc	SSPCON2, ACKEN		;ACKEN silinene kadar bekle.
	goto	I2CNak_j2
	banksel	PIR1			;BANK0.
I2CNak_j3
	btfss	PIR1, SSPIF
	goto	I2CNak_j3		;Ýþlemin tamamlandýðýna dair kesme 
					;oluþana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayraðýný sil.
	return
;-------------------------------------------------------------------
; PCF8574 entegresine veri yazar
;-------------------------------------------------------------------
I2C_Write_pcf8574
	call	I2CStart		;Start bilgisi gönderiliyor.
	movlw	0x42			;Donaným adresi ile kontrol bayte'ý 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;birleþtiriliyor ve I2CSend 
					;fonksiyonuna ait
	call	I2CSend			;parametreye yükleniyor ve 
					;gönderiliyor.		
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	movf	I2C_Data, W	
	movwf	I2CSend_Data		;Adresin alçak byte'ý gönderiliyor.
	call	I2CSend
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	call	I2CStop			;Stop bilgisi gönderiliyor.
	return
;-------------------------------------------------------------------
; pcf8574'den bilgi okuma.
;-------------------------------------------------------------------
I2C_Read_pcf8574
	call	I2CStart		;Start bilgisi gönderiliyor.
	movlw	0x40			;Donaným adresi ile kontrol bayte'ý 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;I2CSend fonksiyonuna ait 
					;parametreye yükleniyor ve 
	call	I2CSend			;gönderiliyor.
	call	I2CAck			;Alýndý bilgisi bekleniyor.
	call	I2CReStart		;Yeniden baþlatma bilgisi 
					;gönderiliyor.
	movlw	0x41			;Okuma kodu gönderiliyor
	movwf	I2CSend_Data		;parametreye yükleniyor
	call	I2CSend			;ve gönderiliyor.
	call	I2CAck			;Onay bilgisi bekleniyor.
	call	I2CRead			;Isýnýn yüksek bayte'ýný oku (sonuç 
					;W'de).
	movwf	pcf8574_data
	call	I2CNak			;Onay bilgisi bekleniyor.
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
	call	I2C_init		;I2C modülü ilk iþlemleri yapýlýyor
Ana_Prog_Oku
	call	I2C_Read_pcf8574	;pcf8574'den veri okunuyor.
	movf	pcf8574_data, W
	movwf	I2C_Data
	call	I2C_Write_pcf8574	;Yazma alt programý çaðrýlýyor.
	movlw	0x0A
	movwf	delay_ms_data		;10ms beklemek için 1ms Delay.
					;parametresine 10 
	call	delay_ms		;deðeri yükleniyor ve delay_ms 
					;çaðrýlýyor.
	goto	Ana_Prog_Oku		;Sistem kapatýlana ya da 
					;resetlenene kadar boþ döngü.

	END
;*******************************************************************

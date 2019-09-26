;*****************************************************************
;	Dosya Ad�		: 9_3.asm
;	Program�n Amac�		: Seri eeprom ile ileti�im.
;	PIC DK2.1a 		: PORTB ��k�� ==> 7 Segment Display
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20Mhz.
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�.
;-------------------------------------------------------------------
#define	OKU	1		;Okuma butonunun ba�l� oldu�u pin.
#define	YAZ	2		;Yazma butonunun ba�l� oldu�u pin.
#define	WP	3		;Seri EEPROM yazma korumas� i�in 
				;i�lemci ��k�� pini.
delay_ms_data	equ 	0x70 	;Delay i�in 2 byte'l�k de�i�ken.
I2CSend_Data	equ 	0x72	;Ge�ici de�i�ken.
I2C_Device	equ 	0x73	;I2C cihaz� donan�m adresi 
				;de�i�keni (0-7).
I2C_AdrH	equ 	0x74	;I2C cihaz� veri adresinin �st 
				;byte'�.
I2C_AdrL	equ 	0x75	;I2C cihaz� veri adresinin alt 
				;byte'�.
I2C_Data	equ 	0x76	;I2C cihaz� veri de�i�keni.

	ORG	0
	clrf	PCLATH
	goto	Ana_Program
;-------------------------------------------------------------------
; MSSP mod�l�n� I2C Master ileti�im i�in haz�rlar.
;-------------------------------------------------------------------
I2C_init
	banksel   SSPSTAT		;BANK1
	clrf	SSPSTAT			;T�m durum bit�leri siliniyor.
	bsf 	SSPSTAT, SMP		;SMP = 1 SLEW Rate Control pasif, 
					;Standart speed mod.
	movlw	B'00110001'		;Fosc = 20MHz i�in BitRate = 100kHz 
					;se�ersek form�lden
	movwf	SSPADD			;SSPADD=49 bulunur.
	clrf	SSPCON2			;Kontrol bit�lerini sil.
	movlw	B'10011000'		;Usart i�in RX ve I2C i�in SCL ve 
					;SDA giri�e ayarland�.
	movwf	TRISC			
	movlw	B'00101000'		;SSPEN=1, I2C Master Fosc based 
					;clock mod se�iliyor.
	bcf 	STATUS, RP0		;BANK0
	movwf	SSPCON
	clrf	PORTC
	return
;-------------------------------------------------------------------
; I2C Start bit�i g�nderen alt program.
;-------------------------------------------------------------------
I2CStart
	banksel PIR1			;BANK0
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	bsf	STATUS, RP0		;BANK1
	bsf	SSPCON2, SEN		;Start bit Enable edildi.
I2CStart_j1
	btfsc	SSPCON2, SEN		;SEN bit�i silinene kadar bekle.
	goto	I2CStart_j1
	banksel PIR1			;BANK0
I2CStart_j2
	btfss	PIR1, SSPIF
	goto	I2CStart_j2		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	return
;-------------------------------------------------------------------
; I2C ReStart bit�i g�nderen alt program.
;-------------------------------------------------------------------
I2CReStart
	nop
	nop
	nop
	nop
	nop				;K�sa bir s�re bekle.
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, RSEN		;ReStart bit Enable edildi.
I2CReStart_j1
	btfsc	SSPCON2, RSEN		;ReStart bit silinene kadar bekle.
	goto	I2CReStart_j1
	return
;-------------------------------------------------------------------
; I2C cihaz�na SSPBUF kaydedicisindeki veriyi g�nderen alt program.
;-------------------------------------------------------------------
I2CSend
	banksel PIR1			;BANK0
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	movf	I2CSend_Data, W
	movwf	SSPBUF			;G�nderilecek byte SSP buffer 
					;kaydedicisine y�klendi.
	return
;-------------------------------------------------------------------
; I2C cihaz�ndan SSPBUF kaydedicisine veri okuma alt program�.
;-------------------------------------------------------------------
I2CRead
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, RCEN		;Receive Enable bit�i set edildi.
I2CRead_j1
	btfsc	SSPCON2, RCEN		;Receive Enable bit�i silinene
goto	I2CRead_j1 			;kadar bekle.

	banksel PIR1			;BANK0
I2CRead_j2
	btfss	PIR1, SSPIF
	goto	I2CRead_j2		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	movf	SSPBUF, W		;Okunan veri SSPBUF'den W 
					;kaydedisine aktar�ld�.
	return
;-------------------------------------------------------------------
; I2C Stop bit�i g�nderen alt program.
;-------------------------------------------------------------------
I2CStop
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, PEN		;Stop bit enable yap�ld�.
I2CStop_j1
	btfsc	SSPCON2, PEN	
	goto	I2CStop_j1		;Stop bit�i silinene (g�nderilene) 
					;kadar bekle.
	banksel PIR1			;BANK0
I2CStop_j2
	btfss	PIR1, SSPIF		
	goto	I2CStop_j2		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	return
;-------------------------------------------------------------------
; I2C cihaz�ndan Ack bilgisi alan alt program.
;-------------------------------------------------------------------
I2CAck
	banksel SSPCON2			;BANK1
	bcf	SSPCON2, ACKDT		;ACK bilgisi i�in LOW seviye 
					;se�iliyor.
	bsf	SSPCON2, ACKSTAT	;ACKSTAT set ediliyor. Bu bit I2C 
					;cihaz� taraf�ndan
I2CAck_j1				;silindi�inde ACK LOW bilgisi 
					;gelmi� ve i�lem I2C
	btfsc	SSPCON2, ACKSTAT	;cihaz� taraf�ndan onaylanm�� 
					;demektir.
	goto	I2CAck_j1		;ACKSTAT LOW olana kadar bekle (ACK 
					;gelene kadar).
	banksel PIR1			;BANK0
I2CAck_j2
	btfss	PIR1, SSPIF
	goto	I2CAck_j2		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	return
;-------------------------------------------------------------------
; I2C cihaz�ndan Not Ack bilgisi alan alt program.
;-------------------------------------------------------------------
I2CNak
	banksel SSPCON2			;BANK1
	bsf 	SSPCON2, ACKDT		;NOT ACK bilgisi i�in HIGH seviye 
					;se�iliyor.
I2CNak_j1						
	btfsc	SSPCON2, ACKSTAT	;ACKSTAT LOW olana kadar bekle (NOT 
					;ACK gelene kadar).
	goto	I2CNak_j1
	bsf	SSPCON2, ACKEN		;ACKEN set edilir.
	bcf	STATUS, RP0		;BANK0
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
I2CNak_j2
	banksel SSPCON2			;BANK1
	btfsc	SSPCON2, ACKEN		;ACKEN silinene kadar bekle.
	goto	I2CNak_j2
	banksel PIR1			;BANK0
I2CNak_j3
	btfss	PIR1, SSPIF
	goto	I2CNak_j3		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	return
;-------------------------------------------------------------------
; Seri EEPROM'a I2C_Data de�i�kenindeki veriyi yazan alt program.
;-------------------------------------------------------------------
I2C_WriteEE
	call	I2CStart		;Start bilgisi g�nderiliyor.
	rlf	I2C_Device, W		;EEPROM donan�m adresi (A2,A1,A0) 
					;ayarlan�yor.
	andlw	0xFE
	iorlw	0xA0			;Donan�m adresi ile kontrol byte'� 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;birle�tiriliyor ve I2CSend 
					;fonksiyonuna ait
	call	I2CSend			;parametreye y�kleniyor ve 
					;g�nderiliyor.
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	movf	I2C_AdrH, W
	movwf	I2CSend_Data		;Adresin y�ksek byte'� g�nderiliyor
	call	I2CSend
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	movf	I2C_AdrL, W	
	movwf	I2CSend_Data		;Adresin al�ak byte'� g�nderiliyor.
	call	I2CSend
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	movf	I2C_Data, W
	movwf	I2CSend_Data		;Yaz�lacak veri g�nderiliyor.
	call	I2CSend
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	call	I2CStop			;Stop bilgisi g�nderiliyor.
	return
;-------------------------------------------------------------------
; Seri EEPROM'dan I2C_Data de�i�kenindeki veri okuyan alt program.
;-------------------------------------------------------------------
I2C_ReadEE
	call	I2CStart		;Start bilgisi g�nderiliyor
	rlf	I2C_Device, W		;EEPROM donan�m adresi (A2,A1,A0) 
					;ayarlan�yor.
	andlw	0xFE
	iorlw	0xA0			;Donan�m adresi ile kontrol byte'� 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;birle�tiriliyor ve I2CSend 
					;fonksiyonuna ait parametreye
	call	I2CSend			;y�kleniyor ve g�nderiliyor.
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	movf	I2C_AdrH, W
	movwf	I2CSend_Data		;Adresin y�ksek byte'� g�nderiliyor
	call	I2CSend
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	movf	I2C_AdrL, W	
	movwf	I2CSend_Data		;Adresin al�ak byte'� g�nderiliyor	
	call	I2CSend
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	call	I2CReStart		;Restart bilgisi g�nderiliyor.
					;(okuma i�in gerekli)
	rlf	I2C_Device,	W	;EEPROM donan�m adresi (A2,A1,A0) 
					;ayarlan�yor.
	andlw	0xFE
	iorlw	0xA1			;Donan�m adresi ile kontrol bayte'� 
					;ve oku bilgisi
	movwf	I2CSend_Data		;birle�tiriliyor ve I2CSend 
					;fonksiyonuna ait parametreye
	call	I2CSend			;y�kleniyor ve g�nderiliyor.
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	call	I2CRead			;Okuma fonsiyonu ile OKU bilgisi 
					;g�nderiliyor.
	movwf	I2C_Data		;Okunan veri Work register (W) de.
	call	I2CNak			;��lemin tamamland���na dair bilgi 
					;al�n�yor.
	call	I2CStop			;Stop bilgisi g�nderiliyor.
	return
;-------------------------------------------------------------------
; 20MHz de 1 ms'lik temel gecikme sa�lar.
; delay_ms_data = 1-255 ms aras�nda ayarlanarak istenilen gecikme 
; elde edilir. �rne�in: delay_ms_data = 10 yap�ld���nda 10 ms'lik 
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
	
	movlw	0x06			;Analog giri�ler kapal�, PORTA 
					;dijital giri�e ayarland�.
	banksel ADCON1
	movwf	ADCON1			;Analog giri�ler kapal�, PORTA 
					;dijital giri�e ayarland�.
	movwf	TRISA			;RA2 ve RA1 dijital giri�, 
					;di�erleri ��k��a ayarland�
	clrf	TRISB			;PORTB ��k��a ayarland�.
	banksel PORTA			;BANK0 se�ildi.
	movlw	0x08			
	movwf	PORTA			;Seri EEPROM yazma korumas� aktif 
					;hale getiriliyor.
	clrf	PORTB			;LED�ler ilk durumda s�n�kler.

	call	I2C_init		;I2C mod�l� ilk i�lemleri yap�l�yor

Ana_Prog_Oku
	btfsc	PORTA, OKU		;RA1'e bas�ld� ise (Seri EEPROM 
					;okuma kontrol butonu).
	goto	Ana_Prog_Yaz		;RA1 butonuna bas�lmad� ise RA2'i 
					;kontrol et.
	clrf	I2C_Device		;24C32 Donan�m adresi 0
	clrf	I2C_AdrH		;AdresHigh = 0
	movlw	0x1A			;Okumak istedi�imiz adresin d���k 
					;byte'�.
	movwf	I2C_AdrL		;AdresLow  = 0x1A; Adres = 0x001A
	call	I2C_ReadEE		;Okuma alt program� �a�r�l�yor.
	movwf	PORTB			;Okunan de�eri PORTB'deki LED�lerde 
					;g�ster.
	movlw	0x0A
	movwf	delay_ms_data		;10ms beklemek i�in 1ms Delay 
					;parametresine 10 de�eri y�kleniyor
	call	delay_ms		;ve delay_ms �a�r�l�yor.
	goto	Ana_Prog_Sonu

Ana_Prog_Yaz
	btfsc	PORTA, YAZ		;RA2'e bas�ld� ise (Seri EEPROM 
					;yazma kontrol butonu).
	goto	Ana_Prog_Oku		;RA2 butonuna bas�lmad� ise RA1'i 
					;kontrol et.
	bcf	PORTA, WP		;EEPROM yazma korumas� kald�r�l�yor
	clrf	I2C_Device		;24C32 Donan�m adresi 0
	clrf	I2C_AdrH		;AdresHigh = 0
	movlw	0x1A			;Yazmak istedi�imiz adresin d���k 
					;byte'�.
	movwf	I2C_AdrL		;AdresLow  = 0x1A; Adres = 0x001A
	movlw	0xC9			;Yazmak istedi�imiz veri.
	movwf	I2C_Data		;�rne�imizde bu veri 0xC9
	call	I2C_WriteEE		;Yazma alt program� �a�r�l�yor.
	bsf	PORTA, WP		;EEPROM yazma korumas� aktif hale 
					;getiriliyor.
	movlw	0x0A
	movwf	delay_ms_data		;10ms beklemek i�in 1ms Delay 
					;parametresine 10 de�eri y�kleniyor
	call	delay_ms		;ve delay_ms �a�r�l�yor.

Ana_Prog_Sonu
	goto	Ana_Prog_Sonu		;Sistem kapat�lana ya da 
					;resetlenene kadar bo� d�ng�.
	END
;*******************************************************************

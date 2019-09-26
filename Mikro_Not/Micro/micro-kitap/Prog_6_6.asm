;*******************************************************************
;	Dosya Ad�		: 6_6.asm
;	Program�n Amac�		: I�C Protokol� ile Seri Veri �leti�imi
;				 (PCF8574 kullan�larak).
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20 Mhz.
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�
;-------------------------------------------------------------------
delay_ms_data		equ 0x70 	;Delay i�in 2 byte'l�k de�i�ken.
I2CSend_Data		equ 0x72	;Ge�ici de�i�ken.
I2C_Data		equ 0x73	;I2C cihaz� veri de�i�keni.
pcf8574_data		equ 0x74

	ORG	0
	clrf	PCLATH
	goto	Ana_Program
;-------------------------------------------------------------------
; MSSP mod�l�n� I2C Master ileti�im i�in haz�rlar.
;-------------------------------------------------------------------
I2C_init
	banksel SSPSTAT			;BANK1�e ge�ildi.
	clrf	SSPSTAT			;T�m durum bit�leri siliniyor.
	bsf 	SSPSTAT, SMP		;SMP = 1 SLEW Rate Control pasif. 
					;(Standart speed mod)
	movlw	B'00110001'		;Fosc = 20MHz i�in BitRate = 100kHz 
					;se�ersek form�lden
	movwf	SSPADD			;SSPADD=49 bulunur.
	clrf	SSPCON2			;Kontrol bit�lerini sil.
	movlw	B'10011000'		;Usart i�in RX ve I2C i�in SCL ve 
					;SDA giri�e ayarland�.
	movwf	TRISC			
	movlw	B'00101000'		;SSPEN=1, I2C Master Fosc based 
					;clock mod se�iliyor.
	bcf 	STATUS, RP0		;BANK0�a ge�ildi.
	movwf	SSPCON
	clrf	PORTC
	return
;-------------------------------------------------------------------
; I2C Start bit�i g�nderen alt program
;-------------------------------------------------------------------
I2CStart
	banksel PIR1			;BANK0�a ge�ildi.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	bsf	STATUS, RP0		;BANK1�e ge�ildi.
	bsf	SSPCON2, SEN		;Start bit Enable edildi.
I2CStart_j1
	btfsc	SSPCON2, SEN		;SEN bit�i silinene kadar bekle.
	goto	I2CStart_j1
	banksel PIR1			;BANK0�a ge�ildi.
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
	banksel SSPCON2			;BANK1�e ge�ildi.
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
	banksel SSPSTAT
	btfss	SSPSTAT,BF
	goto	$-1
	bcf	STATUS,RP0
	return
;-------------------------------------------------------------------
; I2C cihaz�ndan SSPBUF kaydedicisine veri okuma alt program�.
;-------------------------------------------------------------------
I2CRead
	banksel SSPCON2			;BANK1
	bsf	SSPCON2, RCEN		;Receive Enable bit�i set edildi.
I2CRead_j1
	btfsc	SSPCON2, RCEN		;Receive Enable bit�i silinene
					;kadar bekle.
	goto	I2CRead_j1
	banksel PIR1			;BANK0
I2CRead_j2
	btfss	PIR1, SSPIF
	goto	I2CRead_j2		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	movf	SSPBUF, W		;Okunan veri SSPBUF'den W 
					;kaydedicisine aktar�ld�.
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
	banksel PIR1			;BANK0.
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
	banksel SSPCON2			;BANK1.
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
	banksel PIR1			;BANK0.
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
	banksel SSPCON2			;BANK1.
	bsf 	SSPCON2, ACKDT		;NOT ACK bilgisi i�in HIGH seviye 
					;se�iliyor.
I2CNak_j1						
	btfsc	SSPCON2, ACKSTAT	;ACKSTAT LOW olana kadar bekle (NOT 
					;ACK gelene kadar).
	goto	I2CNak_j1
	bsf	SSPCON2, ACKEN		;ACKEN set edilir.
	bcf	STATUS, RP0		;BANK0.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
I2CNak_j2
	banksel SSPCON2			;BANK1.
	btfsc	SSPCON2, ACKEN		;ACKEN silinene kadar bekle.
	goto	I2CNak_j2
	banksel	PIR1			;BANK0.
I2CNak_j3
	btfss	PIR1, SSPIF
	goto	I2CNak_j3		;��lemin tamamland���na dair kesme 
					;olu�ana kadar bekle.
	bcf	PIR1, SSPIF		;SSPIF kesme bayra��n� sil.
	return
;-------------------------------------------------------------------
; PCF8574 entegresine veri yazar
;-------------------------------------------------------------------
I2C_Write_pcf8574
	call	I2CStart		;Start bilgisi g�nderiliyor.
	movlw	0x42			;Donan�m adresi ile kontrol bayte'� 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;birle�tiriliyor ve I2CSend 
					;fonksiyonuna ait
	call	I2CSend			;parametreye y�kleniyor ve 
					;g�nderiliyor.		
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	movf	I2C_Data, W	
	movwf	I2CSend_Data		;Adresin al�ak byte'� g�nderiliyor.
	call	I2CSend
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	call	I2CStop			;Stop bilgisi g�nderiliyor.
	return
;-------------------------------------------------------------------
; pcf8574'den bilgi okuma.
;-------------------------------------------------------------------
I2C_Read_pcf8574
	call	I2CStart		;Start bilgisi g�nderiliyor.
	movlw	0x40			;Donan�m adresi ile kontrol bayte'� 
					;ve yaz bilgisi
	movwf	I2CSend_Data		;I2CSend fonksiyonuna ait 
					;parametreye y�kleniyor ve 
	call	I2CSend			;g�nderiliyor.
	call	I2CAck			;Al�nd� bilgisi bekleniyor.
	call	I2CReStart		;Yeniden ba�latma bilgisi 
					;g�nderiliyor.
	movlw	0x41			;Okuma kodu g�nderiliyor
	movwf	I2CSend_Data		;parametreye y�kleniyor
	call	I2CSend			;ve g�nderiliyor.
	call	I2CAck			;Onay bilgisi bekleniyor.
	call	I2CRead			;Is�n�n y�ksek bayte'�n� oku (sonu� 
					;W'de).
	movwf	pcf8574_data
	call	I2CNak			;Onay bilgisi bekleniyor.
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
	call	I2C_init		;I2C mod�l� ilk i�lemleri yap�l�yor
Ana_Prog_Oku
	call	I2C_Read_pcf8574	;pcf8574'den veri okunuyor.
	movf	pcf8574_data, W
	movwf	I2C_Data
	call	I2C_Write_pcf8574	;Yazma alt program� �a�r�l�yor.
	movlw	0x0A
	movwf	delay_ms_data		;10ms beklemek i�in 1ms Delay.
					;parametresine 10 
	call	delay_ms		;de�eri y�kleniyor ve delay_ms 
					;�a�r�l�yor.
	goto	Ana_Prog_Oku		;Sistem kapat�lana ya da 
					;resetlenene kadar bo� d�ng�.

	END
;*******************************************************************

;*******************************************************************
;	Dosya Adý		: 6_1.asm
;	Programýn Amacý		: SFR’siz Asenkron Seri veri Ýletiþimi.
;	PIC DK2.1a 		: Çýkýþ ==> RS232’den PC’ye
;				: XT ==> 20Mhz
;*******************************************************************
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F3A' 	;Tüm program sigortalarý kapalý, 
				;Osilatör HS ve 20Mhz
;-------------------------------------------------------------------
; PORT tanýmlamalarý ve deðiþken tanýmlarý yapýlýyor.
;-------------------------------------------------------------------
#define RS_Port PORTC
#define RS_Tris TRISC
#define RS_TX   6
#define RS_RX   7

rs232_data	equ	0x20		;Rs232'den okunan verinin 
					;kaydedildiði ve gönderilirken ;kullanýlan deðiþken.
sayac		equ	0x21		;8 bit sayacý.
delay_sayac	equ	0x22		;delay sayacý.

	org	0
	goto	ana_program
;-------------------------------------------------------------------
; 9600 baud rate iletiþim hýzýnda her bir bit’in süresi 104.2 us'dir. 
; 20MHz'de 104.2 us gecikme saðlar.
;-------------------------------------------------------------------
rs232_delay1
	movlw	.171		
	banksel	delay_sayac
	movwf	delay_sayac
	decfsz	delay_sayac, F
	goto	$-1
	nop
	return
;-------------------------------------------------------------------
; 9600 baud rate iletiþim hýzýnda 20MHz'de 50 us gecikme saðlar.
;-------------------------------------------------------------------
rs232_delay2
	movlw	.81
	banksel	delay_sayac
	movwf	delay_sayac
	decfsz	delay_sayac, F
	goto	$-1
	return
;-------------------------------------------------------------------
; Port yönlendirme ve TX için ilk durum belirleme için kullanýldý.
;-------------------------------------------------------------------
rs232_init
	banksel RS_Tris
    	bcf	RS_Tris, RS_TX       ;TX pini çýkýþa,
    	bsf	RS_Tris, RS_RX       ;RX pini giriþe yönlendirildi.
	banksel RS_Port
    	bsf	RS_Port, RS_TX       ;TX pininin ilk durumu HIGH.
	return
;-------------------------------------------------------------------
; LOW seviyesi oluþturmak için kullanýldý. 
;-------------------------------------------------------------------
low_level
    	bcf	RS_Port, RS_TX       ;TX = 0
	call	rs232_delay1
	return
;-------------------------------------------------------------------
; HIGH seviyesi oluþturmak için kullanýldý.
;-------------------------------------------------------------------
high_level
    	bsf	RS_Port, RS_TX       ;TX = 1
	call	rs232_delay1
	return
;-------------------------------------------------------------------
; rs232'den veri okumak için kullanýldý.
;-------------------------------------------------------------------
rs232_read
	btfsc	RS_Port, RS_RX		;START bit’i gelene kadar bekle.
	goto	rs232_read
	call	rs232_delay2		;50 us bekle (start bit’inin 
					;ortasýna konumlan).
	movlw	0x08
	movwf	sayac			;8 bit alýmý için sayacý kur.
rs_read_tekrar
    	call	rs232_delay1		;104 us bekle (ilk anda 0. bit’in 
					;ortasýna konumlan (hata ihtimalini 
					;en aza indirmek için bit zamanýnýn 
					;ortasýnda örnekleme yap).
	bcf	STATUS, C		;rrf komutunda verinin MSB bit’ine
					;0 aktarmak için C bit’ini sýfýrla.
	btfsc	RS_Port, RS_RX		;0 bilgisi geldi ise komut atla, 
					;deðilse..
	bsf	STATUS, C		;rrf komutunda verinin MSB bit’ine
					; 1 aktarmak için C bit’ini set et.
	rrf	rs232_data, F		;Veriyi saða 1 bit kaydýr 
					;(MSB'de ELDE bit’i var).
	decfsz	sayac, F		;Sayacý bir azalt, 8 bit’te alýndý 
					;ise döngüden çýk.
	goto	rs_read_tekrar		;Tüm bit’ler okunana kadar iþleme 
					;devam et.
    	return				;Veri alýndý, alt programdan çýk.
;-------------------------------------------------------------------
; rs232'ye veri yazmak için kullanýldý.
;-------------------------------------------------------------------
rs232_write
	movlw	0x08
	movwf	sayac			;8 bit yazma için sayacý kur.
	call	low_level		;Start bit’i oluþturuldu 
					;(104 us'lik low seviye).
rs_write_tekrar
	btfsc	rs232_data, 0		;Veriyi LSB bit’i 0 ise komut atla, 
					;deðilse..
	call	high_level		;HIGH seviyesi oluþtur (lojik 1).
	btfss	rs232_data, 0		;Veriyi LSB bit’i 1 ise komut atla, 
					;deðilse..
	call	low_level		;LOW seviyesi oluþtur (lojik 0).
	rrf	rs232_data, F		;Verinin tüm bit’lerini kaydýrarak 
					;sonraki bit’i LSB'ye al.
	decfsz	sayac, F		;8 bit’te transfer edilene kadar 
					;iþleme devam et.
	goto	rs_write_tekrar
	call	high_level		;Stop bit’i oluþtur 
					;(104 us'lik high seviye).
	return
;-------------------------------------------------------------------
; Ana program bloðu RS232 üzerinden aldýðý veriyi tekrar 
; RS232 üzerinden terminale gönderir.
;-------------------------------------------------------------------
ana_program
	call	rs232_init		;SFR'siz asenkron iletiþim ilk 
					;iþlemleri çaðýr.
devam
	call	rs232_read		;RS232 portundan veri oku, okunan 
					;veri rs232_data deðiþkeninde.
	call	rs232_write		;rs232_data deðiþkenindeki daha 
					;önce okunan veriyi tekrar RS232 
					;terminaline gönder.
	goto	devam			;Sonsuz döngü kuruldu.

	END				;Program sonu.
;*******************************************************************

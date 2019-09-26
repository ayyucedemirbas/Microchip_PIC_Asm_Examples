;*****************************************************************
;	Dosya Adý		: 5_3.asm
;	Programýn Amacý		: PWM modülünün kullanýlmasý.
;	PIC DK2.1a 		: PORTA<1:4> Dijital giriþ ==> BUTON
;				: PORTC<2> çýkýþ ==> LED/OSÝLASKOP
;				: XT ==> 20 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F3A' 	;Tüm program sigortalarý kapalý, 
				;Osilatör HS ve 20Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý 
;-------------------------------------------------------------------
tmp	equ	0x20		;Geçici deðerler için 1 byte'lýk 
				;deðiþken.
delay_ms_tmp	equ	0x21 	;Delay için 2 byte'lýk deðiþken
PWM_Set_Degeri	equ	0x23 	;PWM Duty Cycle için 1 byte'lýk 
				;deðiþken.

	ORG 	0		;Derleyici bu adresinden itibaren 
				;kodlarý oluþturur.
	clrf 	PCLATH		;0. Program sayfasý seçildi.
	goto 	ana_program	;Ana programa git.
;-------------------------------------------------------------------
; PWM ilk iþlemler alt programý. 
;-------------------------------------------------------------------
PWM_Baslat
	movlw 	D'63'
	banksel PR2		;PR2 kaydedicisinin bulunduðu BANK 
				;seçildi.
	movwf 	PR2		;PR2'ye 63 deðeri atandý.
	movlw 	0x0C
	banksel CCP1CON	
	movwf 	CCP1CON		;PWM modunu baþlat.
	clrf 	CCPR1L		;ilk durumda Duty Cycle deðeri sýfýr.
	banksel TRISC
	bcf 	TRISC, 2	;PWM pini (RC2) çýkýþa ayarlanýyor.
	movlw 	D'4'
	banksel T2CON
	movwf 	T2CON		;TMR2 prescaler ve postscaler deðeri 1:1 
				;yapýldý ve TMR2 çalýþtýrýldý.
	return
;-------------------------------------------------------------------,
; PWM Duty Cycle (Görev Çevrimi) belirleme alt programý. 
;-------------------------------------------------------------------
PWM_Set
	Banksel PWM_Set_Degeri
	movf 	PWM_Set_Degeri, W
	andlw 	D'3'			;PWM_Set_Degeri'nin en deðersiz 2 
					;bit’i tmp'ye kaydet. 
	movwf 	tmp
	swapf 	tmp, W			;4 bit sola kaydýrma ile ayný iþlem  
	andlw 	0xF0		
	banksel CCP1CON			;CCP1CON kaydedicisinin bulunduðu 
					;BANK seçildi
	movwf 	CCP1CON			;ve CCP1CON kaydedicisine aktar.
	iorlw	0x0C			;CCP1CON'da PWM modu ayarý 
					;korunuyor.
	movwf 	CCP1CON
	movf 	PWM_Set_Degeri, W	
	movwf 	tmp
	rrf 	tmp, F
	rrf 	tmp, W			;PWM_Set_Degeri'nin deðersiz 2 
					;bit’ini atarak
	andlw 	0x3F			;deðerli 6 bit’ini elde et ve 
					;CCPR1L'e yükle.
	movwf 	CCPR1L			
	return
;-------------------------------------------------------------------
; PWM sonlandýrma alt programý.
;-------------------------------------------------------------------
PWM_Sonlandir
	Banksel T2CON			;0. bank seçildi, CCP1CON ve T2CON 
					;bu bankta.
	clrf	T2CON			;TMR2 prescaler ve postscaler 
					;deðeri 1:1, TMR2 durduruldu.
    	clrf	CCP1CON			;Capture/Compare/PWM modülü 
					;kapatýldý.
	return
;-------------------------------------------------------------------
; Ýlk iþlemlerin yapýldýðý alt program. 
;-------------------------------------------------------------------
ilk_islemler
	banksel TRISA			;1. bank seçildi (ADCON1, TRISA, 
					;INTCON bu bankta).
	movlw	D'6'			;Tüm analog giriþleri kapat ve 
					;dijital giriþe ayarla.
	movwf	ADCON1
	movlw 	0xFF
	movwf 	TRISA			;PORTA pinleri giriþe ayarlandý.

	return
;-------------------------------------------------------------------
; Fosc = 20MHz'de 1 ms'lik gecikme saðlayan alt program.
;-------------------------------------------------------------------
Delay_ms
delay_j1
	movlw 	.185
	movwf 	delay_ms_tmp+1
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
	decfsz	delay_ms_tmp+1, F
	goto 	delay_j2
	nop
	decfsz delay_ms_tmp, F
	goto 	delay_j1
	nop
	return
Delay_ms_Sonu
;-------------------------------------------------------------------
; ANA PROGRAM 
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler		;ilk iþlemler yapýlýyor.
	movlw 	D'127'
	banksel PWM_Set_Degeri    
	movwf 	PWM_Set_Degeri		;Duty Cycle %50 deðere set edildi.
ana_j1
	banksel PORTA
	btfsc	PORTA,4			;RA4'e baðlý baþlama butonuna 
					;basýldý ise bir komut atla.
	goto 	ana_j1			;Baþlama butonuna basýlana kadar bekle.
	call 	PWM_Baslat		;PWM ilk iþlemleri gerçekleþtirildi.
	call 	PWM_Set
ana_j2
	banksel	PORTA	
	btfsc	PORTA,3			;RA3'e baðlý Dur butonuna basýldý 
					;ise bir komut atla.
	goto 	ana_j3			;Dur butonuna basýlmadý ise diðer 
					;butonlarý kontrol et.
	call	PWM_Sonlandir		
	goto	ana_j1
ana_j3
	banksel	PORTA
	btfsc 	PORTA, 1		;RA1 pinine baðlý ARTIRMA butonuna 
					;basýldý ise bir komut atla.
	goto 	ana_j4			;Hayýr ise EKSÝLTME butonunu 
					;kontrol et.
	movlw 	0xFF
	subwf 	PWM_Set_Degeri, W		
	btfss 	STATUS, C		;PWM_Set_Degeri >= 0xFF ise bir 
					;komut atla.
	incf 	PWM_Set_Degeri, F	;PWM_Set_Degeri < 0xFF ise deðiþken 
					;içeriðini bir artýr.
	movlw 	D'10'			;Delay süresi Buton arkýný önlemek 
					;için deðiþtirilebilir.
	movwf 	delay_ms_tmp		;10ms deðerini Delay alt programý 
					;parametresine yükle.
	call 	Delay_ms		;Buton arkýný önlemek için 10ms 
					;bekle.
	call 	PWM_Set			;PWM çýkýþý PWM_Set_Degeri'ne göre 
					;ayarlanýyor.
ana_j4
	banksel	PORTA
	btfsc 	PORTA, 2		;RA2 pinine baðlý AZALTMA butonuna 
					;basýldý ise bir komut atla.
	goto 	ana_j2			;Hayýr ise ARTIRMA butonunu 
					;kontrol et.
	movf 	PWM_Set_Degeri, W
	sublw 	D'0'
	btfss 	STATUS, C		;PWM_Set_Deðeri = 0x00 ise bir 
					;komut atla.
	decf 	PWM_Set_Degeri, F	;PWM_Set_Deðeri > 0x00 ise deðiþken 
					;içeriðini bir azalt.
	movlw	D'10'			;Delay süresi Buton arkýný önlemek 
					;için deðiþtirilebilir.
	movwf 	delay_ms_tmp		;10ms deðerini Delay alt programý 
					;parametresine yükle.
	call 	Delay_ms		;Buton arkýný önlemek için 10ms 
					;bekle.
	call 	PWM_Set			;PWM çýkýþý PWM_Set_Deðeri'ne göre 
					;ayarlanýyor.
	goto 	ana_j2

	END				;Program sonu.
;*******************************************************************

;*****************************************************************
;	Dosya Ad�		: 5_3.asm
;	Program�n Amac�		: PWM mod�l�n�n kullan�lmas�.
;	PIC DK2.1a 		: PORTA<1:4> Dijital giri� ==> BUTON
;				: PORTC<2> ��k�� ==> LED/OS�LASKOP
;				: XT ==> 20 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F3A' 	;T�m program sigortalar� kapal�, 
				;Osilat�r HS ve 20Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar� 
;-------------------------------------------------------------------
tmp	equ	0x20		;Ge�ici de�erler i�in 1 byte'l�k 
				;de�i�ken.
delay_ms_tmp	equ	0x21 	;Delay i�in 2 byte'l�k de�i�ken
PWM_Set_Degeri	equ	0x23 	;PWM Duty Cycle i�in 1 byte'l�k 
				;de�i�ken.

	ORG 	0		;Derleyici bu adresinden itibaren 
				;kodlar� olu�turur.
	clrf 	PCLATH		;0. Program sayfas� se�ildi.
	goto 	ana_program	;Ana programa git.
;-------------------------------------------------------------------
; PWM ilk i�lemler alt program�. 
;-------------------------------------------------------------------
PWM_Baslat
	movlw 	D'63'
	banksel PR2		;PR2 kaydedicisinin bulundu�u BANK 
				;se�ildi.
	movwf 	PR2		;PR2'ye 63 de�eri atand�.
	movlw 	0x0C
	banksel CCP1CON	
	movwf 	CCP1CON		;PWM modunu ba�lat.
	clrf 	CCPR1L		;ilk durumda Duty Cycle de�eri s�f�r.
	banksel TRISC
	bcf 	TRISC, 2	;PWM pini (RC2) ��k��a ayarlan�yor.
	movlw 	D'4'
	banksel T2CON
	movwf 	T2CON		;TMR2 prescaler ve postscaler de�eri 1:1 
				;yap�ld� ve TMR2 �al��t�r�ld�.
	return
;-------------------------------------------------------------------,
; PWM Duty Cycle (G�rev �evrimi) belirleme alt program�. 
;-------------------------------------------------------------------
PWM_Set
	Banksel PWM_Set_Degeri
	movf 	PWM_Set_Degeri, W
	andlw 	D'3'			;PWM_Set_Degeri'nin en de�ersiz 2 
					;bit�i tmp'ye kaydet. 
	movwf 	tmp
	swapf 	tmp, W			;4 bit sola kayd�rma ile ayn� i�lem  
	andlw 	0xF0		
	banksel CCP1CON			;CCP1CON kaydedicisinin bulundu�u 
					;BANK se�ildi
	movwf 	CCP1CON			;ve CCP1CON kaydedicisine aktar.
	iorlw	0x0C			;CCP1CON'da PWM modu ayar� 
					;korunuyor.
	movwf 	CCP1CON
	movf 	PWM_Set_Degeri, W	
	movwf 	tmp
	rrf 	tmp, F
	rrf 	tmp, W			;PWM_Set_Degeri'nin de�ersiz 2 
					;bit�ini atarak
	andlw 	0x3F			;de�erli 6 bit�ini elde et ve 
					;CCPR1L'e y�kle.
	movwf 	CCPR1L			
	return
;-------------------------------------------------------------------
; PWM sonland�rma alt program�.
;-------------------------------------------------------------------
PWM_Sonlandir
	Banksel T2CON			;0. bank se�ildi, CCP1CON ve T2CON 
					;bu bankta.
	clrf	T2CON			;TMR2 prescaler ve postscaler 
					;de�eri 1:1, TMR2 durduruldu.
    	clrf	CCP1CON			;Capture/Compare/PWM mod�l� 
					;kapat�ld�.
	return
;-------------------------------------------------------------------
; �lk i�lemlerin yap�ld��� alt program. 
;-------------------------------------------------------------------
ilk_islemler
	banksel TRISA			;1. bank se�ildi (ADCON1, TRISA, 
					;INTCON bu bankta).
	movlw	D'6'			;T�m analog giri�leri kapat ve 
					;dijital giri�e ayarla.
	movwf	ADCON1
	movlw 	0xFF
	movwf 	TRISA			;PORTA pinleri giri�e ayarland�.

	return
;-------------------------------------------------------------------
; Fosc = 20MHz'de 1 ms'lik gecikme sa�layan alt program.
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
	call 	ilk_islemler		;ilk i�lemler yap�l�yor.
	movlw 	D'127'
	banksel PWM_Set_Degeri    
	movwf 	PWM_Set_Degeri		;Duty Cycle %50 de�ere set edildi.
ana_j1
	banksel PORTA
	btfsc	PORTA,4			;RA4'e ba�l� ba�lama butonuna 
					;bas�ld� ise bir komut atla.
	goto 	ana_j1			;Ba�lama butonuna bas�lana kadar bekle.
	call 	PWM_Baslat		;PWM ilk i�lemleri ger�ekle�tirildi.
	call 	PWM_Set
ana_j2
	banksel	PORTA	
	btfsc	PORTA,3			;RA3'e ba�l� Dur butonuna bas�ld� 
					;ise bir komut atla.
	goto 	ana_j3			;Dur butonuna bas�lmad� ise di�er 
					;butonlar� kontrol et.
	call	PWM_Sonlandir		
	goto	ana_j1
ana_j3
	banksel	PORTA
	btfsc 	PORTA, 1		;RA1 pinine ba�l� ARTIRMA butonuna 
					;bas�ld� ise bir komut atla.
	goto 	ana_j4			;Hay�r ise EKS�LTME butonunu 
					;kontrol et.
	movlw 	0xFF
	subwf 	PWM_Set_Degeri, W		
	btfss 	STATUS, C		;PWM_Set_Degeri >= 0xFF ise bir 
					;komut atla.
	incf 	PWM_Set_Degeri, F	;PWM_Set_Degeri < 0xFF ise de�i�ken 
					;i�eri�ini bir art�r.
	movlw 	D'10'			;Delay s�resi Buton ark�n� �nlemek 
					;i�in de�i�tirilebilir.
	movwf 	delay_ms_tmp		;10ms de�erini Delay alt program� 
					;parametresine y�kle.
	call 	Delay_ms		;Buton ark�n� �nlemek i�in 10ms 
					;bekle.
	call 	PWM_Set			;PWM ��k��� PWM_Set_Degeri'ne g�re 
					;ayarlan�yor.
ana_j4
	banksel	PORTA
	btfsc 	PORTA, 2		;RA2 pinine ba�l� AZALTMA butonuna 
					;bas�ld� ise bir komut atla.
	goto 	ana_j2			;Hay�r ise ARTIRMA butonunu 
					;kontrol et.
	movf 	PWM_Set_Degeri, W
	sublw 	D'0'
	btfss 	STATUS, C		;PWM_Set_De�eri = 0x00 ise bir 
					;komut atla.
	decf 	PWM_Set_Degeri, F	;PWM_Set_De�eri > 0x00 ise de�i�ken 
					;i�eri�ini bir azalt.
	movlw	D'10'			;Delay s�resi Buton ark�n� �nlemek 
					;i�in de�i�tirilebilir.
	movwf 	delay_ms_tmp		;10ms de�erini Delay alt program� 
					;parametresine y�kle.
	call 	Delay_ms		;Buton ark�n� �nlemek i�in 10ms 
					;bekle.
	call 	PWM_Set			;PWM ��k��� PWM_Set_De�eri'ne g�re 
					;ayarlan�yor.
	goto 	ana_j2

	END				;Program sonu.
;*******************************************************************

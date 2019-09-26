;*****************************************************************
;	Dosya Ad�		: 6_9.asm
;	Program�n Amac�		: USART Mod�l� �le Senkron Master Mod Veri
;				  �leti�imi (74HC165 kullanarak).
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, di�erler sigortalar� 
					;kapal�, Osilat�r XT ve 4 Mhz.
;-------------------------------------------------------------------
; De�i�kenler tan�mlan�yor ve derleyici direktifleri veriliyor.
; Kodun anla��lmas�n� kolayla�t�rmak i�in sembolik adlar kullan�ld�.
;-------------------------------------------------------------------
#define hc165_SHLD	PORTC, 0	;74HC165 entegresinin SH/LD' giri�i 
					;RC0'a ba�l�.
#define OKU_BUTONU	PORTB, 0	;OKU butonu i�in pin tan�m� yap�ld�.
hc165_data	equ	0x20		;hc165_Veri_Oku alt program 
					;de�i�keni.
	ORG	0
	clrf	PCLATH			;0. program sayfas� kullan�l�yor.
	goto	Ana_program		;Ana programa git.
;-------------------------------------------------------------------
; 74HC165, USART mod�l� senkron master modda ileti�im i�in haz�rlan�yor.
;-------------------------------------------------------------------
hc165_Ilk_islemler
	movlw	0x09		;(Synchronous) Baud Rate = Fosc/(4(X+1))
				;Baud Rate 	= 4.000.000/(4*(9+1))
				;	= 4.000.000/40 = 100.000 Hz.
	banksel SPBRG
	movwf	SPBRG		;Baud Rate de�eri SPBRG kaydedicisine 
				;y�klendi.
	bsf	TXSTA, SYNC	;Senkron ileti�im se�ildi.		
	bsf	TXSTA, CSRC	;Clock kayna�� se�me bit�i set 
				;edildi. Kaynak: BRG kaydedicisi.
	bcf	STATUS, RP0	;BANK0'a ge�. RCSTA bu bankta.
	bcf	RCSTA, CREN	;S�rekli okuma modu kapat�ld�.
	bcf	RCSTA, RX9	;RX9 kullan�lm�yor, 8 bit veri ileti�imi.
	bsf	RCSTA, SPEN	;Senkron master seri port aktif hale 
				;getirildi.
	return
;-------------------------------------------------------------------
; USART mod�l� Senkron master mod kullanarak veri 74HC165'ten 
; i�lemciye transfer ediliyor.
;-------------------------------------------------------------------
hc165_Veri_Oku
	bcf	STATUS,RP0		;BANK0'a ge�, RCSTA ve 74HC165'in 
					;SH/LD' aya��n�n ba�l� oldu�u port 
					;bu bankta.
	bcf	hc165_SHLD		;Entegre giri�lerden veri 
					;alabilmesi i�in LOAD y�kleme 
					;moduna al�n�yor.
	bsf	hc165_SHLD		;74HC165 Shift moduna al�n�yor. 
					;(Veri transferi i�in.)
	bsf	RCSTA,SREN		;Tek byte veri oku.
hc165_j1
	btfsc	RCSTA, SREN		;Reset ise veri okumu� demektir, 
					;bir komut atla.
	goto	hc165_j1		;Bir geriye git. Tekrar kontrol et. 
					;(goto $-1 ;kullan�labilir) 	
					;Alma i�lemi tamamland���nda SREN 
					;reset olur.
	movf	RCREG, W		;Okunan de�er W'ye al�n�yor
	movwf	hc165_data		;ve hc165_data de�i�kenine transfer 
					;ediliyor.
	return 
;-------------------------------------------------------------------
; Ana program USART mod�l� senkron master modu kullanarak
; 74HC165�ten i�lemciye veri transferini g�steriyor.
;-------------------------------------------------------------------
Ana_program
	banksel TRISB		;TRISB ve TRISC'nin bulundu�u bank se�ildi
	bsf	TRISB,0		;RB0 giri�e y�nlendirildi.
	movlw	0x80		;W = 0x80
	movwf	TRISC		;RC7/RX/DT pini giri� di�erleri ��k��.	
	clrf	TRISD		
				;PORTD sonu�lar� g�r�nt�lemek i�in ��k��a 
				;y�nlendirildi.
	bcf	STATUS, RP0	;BANK0'a ge�.
	clrf	PORTC		;PORTC'nin ilk durumda t�m pinleri LOW.	
	clrf	PORTD
call	hc165_Ilk_islemler	;74HC165 i�in USART mod�l� Senkron 
				;Master moda al�nd�.
Ana_j1
	btfsc	OKU_BUTONU	;Oku butonuna bas�ld� m�? Evet ise 
				;bir komut atla.
	goto	Ana_j1		;Bir komut geriye, kontrole devam.
	call	hc165_Veri_Oku	;74HC165 kaydedicisinden veri oku
	movf	hc165_data, W	;Okunan veriyi W'ye y�kle.
	movwf	PORTD		;Anahtar konumlar�n� PORTD'de 
				;g�r�nt�le.
	goto	Ana_j1		;��lemi s�rekli yap.

	END
;******************************************************************* 

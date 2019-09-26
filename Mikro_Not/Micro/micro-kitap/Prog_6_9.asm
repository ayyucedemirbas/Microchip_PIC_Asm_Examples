;*****************************************************************
;	Dosya Adý		: 6_9.asm
;	Programýn Amacý		: USART Modülü Ýle Senkron Master Mod Veri
;				  Ýletiþimi (74HC165 kullanarak).
;	Notlar 			: XT ==> 4Mhz
;******************************************************************* 
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, diðerler sigortalarý 
					;kapalý, Osilatör XT ve 4 Mhz.
;-------------------------------------------------------------------
; Deðiþkenler tanýmlanýyor ve derleyici direktifleri veriliyor.
; Kodun anlaþýlmasýný kolaylaþtýrmak için sembolik adlar kullanýldý.
;-------------------------------------------------------------------
#define hc165_SHLD	PORTC, 0	;74HC165 entegresinin SH/LD' giriþi 
					;RC0'a baðlý.
#define OKU_BUTONU	PORTB, 0	;OKU butonu için pin tanýmý yapýldý.
hc165_data	equ	0x20		;hc165_Veri_Oku alt program 
					;deðiþkeni.
	ORG	0
	clrf	PCLATH			;0. program sayfasý kullanýlýyor.
	goto	Ana_program		;Ana programa git.
;-------------------------------------------------------------------
; 74HC165, USART modülü senkron master modda iletiþim için hazýrlanýyor.
;-------------------------------------------------------------------
hc165_Ilk_islemler
	movlw	0x09		;(Synchronous) Baud Rate = Fosc/(4(X+1))
				;Baud Rate 	= 4.000.000/(4*(9+1))
				;	= 4.000.000/40 = 100.000 Hz.
	banksel SPBRG
	movwf	SPBRG		;Baud Rate deðeri SPBRG kaydedicisine 
				;yüklendi.
	bsf	TXSTA, SYNC	;Senkron iletiþim seçildi.		
	bsf	TXSTA, CSRC	;Clock kaynaðý seçme bit’i set 
				;edildi. Kaynak: BRG kaydedicisi.
	bcf	STATUS, RP0	;BANK0'a geç. RCSTA bu bankta.
	bcf	RCSTA, CREN	;Sürekli okuma modu kapatýldý.
	bcf	RCSTA, RX9	;RX9 kullanýlmýyor, 8 bit veri iletiþimi.
	bsf	RCSTA, SPEN	;Senkron master seri port aktif hale 
				;getirildi.
	return
;-------------------------------------------------------------------
; USART modülü Senkron master mod kullanarak veri 74HC165'ten 
; iþlemciye transfer ediliyor.
;-------------------------------------------------------------------
hc165_Veri_Oku
	bcf	STATUS,RP0		;BANK0'a geç, RCSTA ve 74HC165'in 
					;SH/LD' ayaðýnýn baðlý olduðu port 
					;bu bankta.
	bcf	hc165_SHLD		;Entegre giriþlerden veri 
					;alabilmesi için LOAD yükleme 
					;moduna alýnýyor.
	bsf	hc165_SHLD		;74HC165 Shift moduna alýnýyor. 
					;(Veri transferi için.)
	bsf	RCSTA,SREN		;Tek byte veri oku.
hc165_j1
	btfsc	RCSTA, SREN		;Reset ise veri okumuþ demektir, 
					;bir komut atla.
	goto	hc165_j1		;Bir geriye git. Tekrar kontrol et. 
					;(goto $-1 ;kullanýlabilir) 	
					;Alma iþlemi tamamlandýðýnda SREN 
					;reset olur.
	movf	RCREG, W		;Okunan deðer W'ye alýnýyor
	movwf	hc165_data		;ve hc165_data deðiþkenine transfer 
					;ediliyor.
	return 
;-------------------------------------------------------------------
; Ana program USART modülü senkron master modu kullanarak
; 74HC165’ten iþlemciye veri transferini gösteriyor.
;-------------------------------------------------------------------
Ana_program
	banksel TRISB		;TRISB ve TRISC'nin bulunduðu bank seçildi
	bsf	TRISB,0		;RB0 giriþe yönlendirildi.
	movlw	0x80		;W = 0x80
	movwf	TRISC		;RC7/RX/DT pini giriþ diðerleri çýkýþ.	
	clrf	TRISD		
				;PORTD sonuçlarý görüntülemek için çýkýþa 
				;yönlendirildi.
	bcf	STATUS, RP0	;BANK0'a geç.
	clrf	PORTC		;PORTC'nin ilk durumda tüm pinleri LOW.	
	clrf	PORTD
call	hc165_Ilk_islemler	;74HC165 için USART modülü Senkron 
				;Master moda alýndý.
Ana_j1
	btfsc	OKU_BUTONU	;Oku butonuna basýldý mý? Evet ise 
				;bir komut atla.
	goto	Ana_j1		;Bir komut geriye, kontrole devam.
	call	hc165_Veri_Oku	;74HC165 kaydedicisinden veri oku
	movf	hc165_data, W	;Okunan veriyi W'ye yükle.
	movwf	PORTD		;Anahtar konumlarýný PORTD'de 
				;görüntüle.
	goto	Ana_j1		;Ýþlemi sürekli yap.

	END
;******************************************************************* 

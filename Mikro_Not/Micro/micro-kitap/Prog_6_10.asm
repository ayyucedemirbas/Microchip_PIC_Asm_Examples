;*******************************************************************
;	Dosya Adý		: 6_10.asm
;	Programýn Amacý		: USART modülü ile senkron master mod veri
;				  iletiþimi(74HC595 kullanarak).
;	Notlar 			: XT ==> 4 Mhz
;******************************************************************* 
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, diðerler sigortalarý 
					;kapalý, Osilatör XT ve 4 Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlamalarý yapýlýyor.
;-------------------------------------------------------------------
hc595_data	equ	0x20		;hc595_Veri_Yaz alt program 
					;deðiþkeni.
	ORG	0
	clrf	PCLATH			;0. program sayfasý kullanýlýyor.
	goto	Ana_program		;Ana programa git.
;-------------------------------------------------------------------
; 74HC595, USART modülü senkron master modda iletiþim için 
; hazýrlanýyor.
;-------------------------------------------------------------------
hc595_Ilk_islemler
	movlw	0x09		;(Synchronous) Baud Rate = Fosc/(4(X+1))
				;Baud Rate 	= 4.000.000/(4*(9+1))
				;		= 4.000.000/40 = 100.000 Hz
banksel SPBRG
	movwf	SPBRG			;Baud Rate deðeri SPBRG 
					;kaydedicisine yüklendi.
	bsf	TXSTA, SYNC		;Senkron iletiþim seçildi.		
	bcf	STATUS, RP0		;BANK0'a geç. RCSTA bu bankta.
	bcf	RCSTA, SREN		;Veri okuma olayý yok.
	bsf	STATUS, RP0		;BANK1'e geç. TXSTA bu bankta.
	bsf	TXSTA, CSRC		;Clock kaynaðý seçme bit’i set 
					;edildi. Kaynak: BRG kaydedicisi.
	bcf	TXSTA, TX9		;TX9 kullanýlmýyor, 8 bit veri 
					;iletiþimi.
	bcf	STATUS, RP0		;BANK0'a geç. RCSTA bu bankta
	bsf	RCSTA, SPEN		;Senkron master seri port aktif 
					;hale getirildi.
	bsf	STATUS, RP0		;BANK1'e geç. TXSTA bu bankta.
	bsf	TXSTA, TXEN		;Veri gönderme etkinleþtirildi.
	return
;-------------------------------------------------------------------
; USART modülü Senkron master mod kullanarak veri 74HC595'e transfer 
; ediliyor.
;-------------------------------------------------------------------
hc595_Veri_Yaz
	movf	hc595_data, W		;Gönderilecek veriyi önce W 
					;kaydedicisine yükle.
	banksel TXREG			;TXREG kaydedicisinin bulunduðu 
					;bank seçildi.
	movwf	TXREG			;W kaydedicisindeki deðer TXREG 
					;kaydedicisine aktarýldý.
	banksel TXSTA			;TXSTA kaydedicisinin bulunduðu 
					;bank seçildi.
hc595_j1
	btfss	TXSTA, 1		;set ise veri transfer edilmiþ 
					;demektir, bir komut atla.
	goto	hc595_j1		;bir geriye. Tekrar kontrol et. 
					;(goto $-1 ;kullanýlabilir). 
	bcf	STATUS, RP0		;Bank0'a geç.
	bcf	PORTC, 1		;74HC595 kaydedicisinde bulunan 
					;veriyi çýkýþa transfer.
	bsf	PORTC, 1		;etmek için RCK giriþini HIGH yap 
					;(yükselen darbe kenarý).
	return
;-------------------------------------------------------------------
; Ana program USART modülü senkron master modu kullanarak 74HC595’e 
; transferini gösteriyor.
;-------------------------------------------------------------------
Ana_program
	banksel TRISC			;TRISC'nin bulunduðu bank seçildi
	clrf	TRISC			;PORTC'nin tüm pinleri çýkýþa 
					;yönlendirildi.
	bcf	STATUS, RP0		;BANK0'a geç.
	clrf	PORTC			;PORTC'nin ilk durumda tüm pinleri 
					;LOW yapýldý.
	call	hc595_Ilk_islemler	;74HC595 için USART modülü Senkron 
					;Master moda alýndý.
	movlw	0x57
	movwf 	hc595_data		;0x57 bilgisini alt program 
					;deðiþkenine aktar.
	call	hc595_Veri_Yaz		;74HC595 kaydedicisine veriyi yaz

	goto	$		     	;Sistem kapatýlana ya da resetlenene 
     					;kadar boþ döngü.
	END
;*******************************************************************

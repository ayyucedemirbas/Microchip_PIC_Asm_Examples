;*******************************************************************
;	Dosya Ad�		: 6_10.asm
;	Program�n Amac�		: USART mod�l� ile senkron master mod veri
;				  ileti�imi(74HC595 kullanarak).
;	Notlar 			: XT ==> 4 Mhz
;******************************************************************* 
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, di�erler sigortalar� 
					;kapal�, Osilat�r XT ve 4 Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlamalar� yap�l�yor.
;-------------------------------------------------------------------
hc595_data	equ	0x20		;hc595_Veri_Yaz alt program 
					;de�i�keni.
	ORG	0
	clrf	PCLATH			;0. program sayfas� kullan�l�yor.
	goto	Ana_program		;Ana programa git.
;-------------------------------------------------------------------
; 74HC595, USART mod�l� senkron master modda ileti�im i�in 
; haz�rlan�yor.
;-------------------------------------------------------------------
hc595_Ilk_islemler
	movlw	0x09		;(Synchronous) Baud Rate = Fosc/(4(X+1))
				;Baud Rate 	= 4.000.000/(4*(9+1))
				;		= 4.000.000/40 = 100.000 Hz
banksel SPBRG
	movwf	SPBRG			;Baud Rate de�eri SPBRG 
					;kaydedicisine y�klendi.
	bsf	TXSTA, SYNC		;Senkron ileti�im se�ildi.		
	bcf	STATUS, RP0		;BANK0'a ge�. RCSTA bu bankta.
	bcf	RCSTA, SREN		;Veri okuma olay� yok.
	bsf	STATUS, RP0		;BANK1'e ge�. TXSTA bu bankta.
	bsf	TXSTA, CSRC		;Clock kayna�� se�me bit�i set 
					;edildi. Kaynak: BRG kaydedicisi.
	bcf	TXSTA, TX9		;TX9 kullan�lm�yor, 8 bit veri 
					;ileti�imi.
	bcf	STATUS, RP0		;BANK0'a ge�. RCSTA bu bankta
	bsf	RCSTA, SPEN		;Senkron master seri port aktif 
					;hale getirildi.
	bsf	STATUS, RP0		;BANK1'e ge�. TXSTA bu bankta.
	bsf	TXSTA, TXEN		;Veri g�nderme etkinle�tirildi.
	return
;-------------------------------------------------------------------
; USART mod�l� Senkron master mod kullanarak veri 74HC595'e transfer 
; ediliyor.
;-------------------------------------------------------------------
hc595_Veri_Yaz
	movf	hc595_data, W		;G�nderilecek veriyi �nce W 
					;kaydedicisine y�kle.
	banksel TXREG			;TXREG kaydedicisinin bulundu�u 
					;bank se�ildi.
	movwf	TXREG			;W kaydedicisindeki de�er TXREG 
					;kaydedicisine aktar�ld�.
	banksel TXSTA			;TXSTA kaydedicisinin bulundu�u 
					;bank se�ildi.
hc595_j1
	btfss	TXSTA, 1		;set ise veri transfer edilmi� 
					;demektir, bir komut atla.
	goto	hc595_j1		;bir geriye. Tekrar kontrol et. 
					;(goto $-1 ;kullan�labilir). 
	bcf	STATUS, RP0		;Bank0'a ge�.
	bcf	PORTC, 1		;74HC595 kaydedicisinde bulunan 
					;veriyi ��k��a transfer.
	bsf	PORTC, 1		;etmek i�in RCK giri�ini HIGH yap 
					;(y�kselen darbe kenar�).
	return
;-------------------------------------------------------------------
; Ana program USART mod�l� senkron master modu kullanarak 74HC595�e 
; transferini g�steriyor.
;-------------------------------------------------------------------
Ana_program
	banksel TRISC			;TRISC'nin bulundu�u bank se�ildi
	clrf	TRISC			;PORTC'nin t�m pinleri ��k��a 
					;y�nlendirildi.
	bcf	STATUS, RP0		;BANK0'a ge�.
	clrf	PORTC			;PORTC'nin ilk durumda t�m pinleri 
					;LOW yap�ld�.
	call	hc595_Ilk_islemler	;74HC595 i�in USART mod�l� Senkron 
					;Master moda al�nd�.
	movlw	0x57
	movwf 	hc595_data		;0x57 bilgisini alt program 
					;de�i�kenine aktar.
	call	hc595_Veri_Yaz		;74HC595 kaydedicisine veriyi yaz

	goto	$		     	;Sistem kapat�lana ya da resetlenene 
     					;kadar bo� d�ng�.
	END
;*******************************************************************

;*******************************************************************
;	Dosya Ad�		: 6_2.asm
;	Program�n Amac�		: SFR�siz senkron seri veri ileti�imi
;				 (74HC595 kullan�larak).
;	PIC DK 2.1 		: PORTB ��k�� (74HC595) ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz.
;-------------------------------------------------------------------
; Genel tan�mlamalar ve de�i�ken tan�mlamalar� yap�l�yor.
;-------------------------------------------------------------------
#define hc595_port	PORTB		;74HC595�in ba�land��� port. 
#define DATA_Pin	1		;Data pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.
#define CLK_Pin	2			;Clock pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.
#define LATCH_Pin	3		;Latch pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.
delay_ms_data		equ 0x20 	;delay_ms i�in 2 byte'l�k de�i�ken 
					;tan�m� yap�l�yor.
i			equ 0x22 	;Transfer edilecek verinin bit 
					;s�ras�n� tespit de�i�keni.
hc595_data		equ 0x23 	;Transfer edilecek veriyi tutan 
					;de�i�ken.
sayac			equ 0x24 	;Ana programda kullan�lan saya� 
					;de�i�keni.
	ORG 	0			;Reset vekt�r adresi buras�, 
					;program buradan �al��maya ba�lar.
	pagesel Ana_program		;Ana program�n bulundu�u program 
					;sayfas� se�ildi.
	goto 	Ana_program		;Ana programa git.
	ORG 	4			;Kesme alt program� bu adresten 
					;ba�l�yor.
;-------------------------------------------------------------------
; hc595_Yaz alt program�, 1 byte veriyi donan�m mod�llerini 
; kullanmadan yaln�zca yaz�l�m ile 74HC595�e transfer eder.
;-------------------------------------------------------------------
hc595_Yaz
	banksel hc595_port		;hc595_port'nin bulundu�u 
					;bank se�ildi.
	bcf	hc595_port, CLK_Pin	;CLK ve LATCH pinleri LOW 
bcf	hc595_port, LATCH_Pin		;seviyesine �ekildi.
	movlw	0x80			;8 bit transferini kontrol 
					;i�in i de�i�kenine 0x80
	movwf	i			;bilgisi y�klendi. i de�i�keni  
					;verinin aktar�lacak bit�ini tespit
					;i�in ve 8 bit�in tamam�n�n transfer
					;edildi�ini kontrol i�in kullan�l�yor.
hc595_j0
	movf	hc595_data, W		;Veriyi i ile and i�lemine tabi 
					;tutarak ilgili bit�in s�f�r
	andwf	i, W			;olup olmad���n� belirle.
	btfsc	STATUS, Z		;Kontrol edilen bit 1 ise bir komut atla.
	goto	hc595_j1		;kontrol edilen bit 0 oldu�u i�in 
					;hc595_j1'e git.
	bsf	hc595_port, DATA_Pin	;Kontrol edilen bit 1	 
	goto	hc595_j2		;oldu�undan DATA_Pin�i �1� yap.
hc595_j1				;Kontrol edilen bit 0
	bcf	hc595_port, DATA_Pin	;oldu�undan DATA_Pin'i reset 
					;yap. 
hc595_j2
	bsf	hc595_port, CLK_Pin	;74HC595'in CLK pinine d��en
	bcf	hc595_port, CLK_Pin	;darbe kenar� uygulan�yor,
	rrf	i, F			;b�ylece verinin i bit veri 
					;74HC595 ��k��lar�nda 
					;g�z�k�r. i'yi bir bit sa�a 
					;kayd�rarak s�radaki transfer edilecek 
					;bit�i tespit et. 
	bcf    i, 7			;i de�i�keninin en de�erli bit�ini sil.
	movf	i, W
	btfss	STATUS, Z		;i = 0 ise bir sonraki komuta atla.
	goto	hc595_j0

	bsf	hc595_port, LATCH_Pin	;74HC595'in LATCH pinine 
					;d��en	 darbe kenar� 
					;uygulan�yor,
	bcf	hc595_port, LATCH_Pin	;b�ylece veri 74HC595 
					;��k��lar�nda g�z�k�r.
	return
;-------------------------------------------------------------------
; delay_ms alt program� 1-255 ms aras�nda de�i�ken bekleme s�resi 
; sa�lar delay_ms_data y�ksek byte de�i�kenine y�klenecek de�er 
; kadar ms olarak gecikme sa�lar.
;-------------------------------------------------------------------
delay_ms
delay_j0
	movlw	D'142'			;1 ms gecikme i�in taban de�er.
	movwf	delay_ms_data+1		;delay parametresinin d���k 
					;byte��na y�klendi.
	nop				;2 us bekle.
	nop
delay_j1
	nop				;4 us gecikme.
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F	;delay parametresinin d���k 
					;byte'�n� azalt, s�f�rsa komut atla
	goto	delay_j1		;Hen�z 1 ms gecikme sa�lanamad�, 
					;d���k byte'� azaltmaya devam et.
	nop				;1 us bekle.
	decfsz	delay_ms_data, F	;delay parametresinin y�ksek 
					;byte'�n� azalt s�f�rsa komut atla.
	goto	delay_j0		;1 ms beklemeyi tekrarla.
	nop				;1 us bekle.
	return				;Alt programdan ��k��.
;-------------------------------------------------------------------
; Ana program 74HC595 entegresi ��k��lar�n�n donan�m mod�lleri 
; kullan�lmadan yaln�zca yaz�l�m ile 1-255 aras�nda yukar� sayan 
; binary saya� olarak nas�l kullan�laca��n� g�stermektedir.
;-------------------------------------------------------------------
Ana_program
	banksel TRISB		;TRISB'nin bulundu�u banka ge�.
	clrf	TRISB		;PORTB'nin t�m pinlerini ��k��a y�nlendir.
	banksel PORTB		;PORTB'nin bulundu�u banka ge�.
	clrf	PORTB		;PORTB'nin ilk andaki ��k��lar� s�f�r.
Ana_j0
	movlw	0x01		;Sayaca ilk de�er atamas� yap�l�yor 
	movwf	sayac		
Ana_j1
	movf	sayac, W	;Saya� de�eri 0xFF'ten sonra 0x00'a 
				;d�nd���nde,
	btfsc	STATUS, Z	;Saya� s�f�rdan farkl� ise bir komut atla.
	goto	Ana_j0		;sayac = 0 ise Ana_j0 adresine git.
	movf	sayac, W	;Saya� de�erini W'ye y�kle.
	incf	sayac, F	;sayac�� bir art�r.
	movwf	hc595_data	;W'de bulunan �nceki saya� de�erini 
				;hc595_data de�i�kenine y�kle.
	call	hc595_Yaz	;hc595_data de�i�kenindeki de�eri
				;74HC595'e yaz.
	movlw	D'250'		;delay_ms_data de�i�kenine 250 ms yaz.
	movwf	delay_ms_data		
	call	delay_ms	;250 ms bekle.
	goto	Ana_j1		;Ana_j1 adresine git.

	END
;*******************************************************************

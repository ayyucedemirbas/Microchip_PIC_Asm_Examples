;*******************************************************************
;	Dosya Adý		: 6_2.asm
;	Programýn Amacý		: SFR’siz senkron seri veri iletiþimi
;				 (74HC595 kullanýlarak).
;	PIC DK 2.1 		: PORTB Çýkýþ (74HC595) ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz.
;-------------------------------------------------------------------
; Genel tanýmlamalar ve deðiþken tanýmlamalarý yapýlýyor.
;-------------------------------------------------------------------
#define hc595_port	PORTB		;74HC595’in baðlandýðý port. 
#define DATA_Pin	1		;Data pininin iþlemciye baðlý 
					;olduðu pin tanýmlanýyor.
#define CLK_Pin	2			;Clock pininin iþlemciye baðlý 
					;olduðu pin tanýmlanýyor.
#define LATCH_Pin	3		;Latch pininin iþlemciye baðlý 
					;olduðu pin tanýmlanýyor.
delay_ms_data		equ 0x20 	;delay_ms için 2 byte'lýk deðiþken 
					;tanýmý yapýlýyor.
i			equ 0x22 	;Transfer edilecek verinin bit 
					;sýrasýný tespit deðiþkeni.
hc595_data		equ 0x23 	;Transfer edilecek veriyi tutan 
					;deðiþken.
sayac			equ 0x24 	;Ana programda kullanýlan sayaç 
					;deðiþkeni.
	ORG 	0			;Reset vektör adresi burasý, 
					;program buradan çalýþmaya baþlar.
	pagesel Ana_program		;Ana programýn bulunduðu program 
					;sayfasý seçildi.
	goto 	Ana_program		;Ana programa git.
	ORG 	4			;Kesme alt programý bu adresten 
					;baþlýyor.
;-------------------------------------------------------------------
; hc595_Yaz alt programý, 1 byte veriyi donaným modüllerini 
; kullanmadan yalnýzca yazýlým ile 74HC595’e transfer eder.
;-------------------------------------------------------------------
hc595_Yaz
	banksel hc595_port		;hc595_port'nin bulunduðu 
					;bank seçildi.
	bcf	hc595_port, CLK_Pin	;CLK ve LATCH pinleri LOW 
bcf	hc595_port, LATCH_Pin		;seviyesine çekildi.
	movlw	0x80			;8 bit transferini kontrol 
					;için i deðiþkenine 0x80
	movwf	i			;bilgisi yüklendi. i deðiþkeni  
					;verinin aktarýlacak bit’ini tespit
					;için ve 8 bit’in tamamýnýn transfer
					;edildiðini kontrol için kullanýlýyor.
hc595_j0
	movf	hc595_data, W		;Veriyi i ile and iþlemine tabi 
					;tutarak ilgili bit’in sýfýr
	andwf	i, W			;olup olmadýðýný belirle.
	btfsc	STATUS, Z		;Kontrol edilen bit 1 ise bir komut atla.
	goto	hc595_j1		;kontrol edilen bit 0 olduðu için 
					;hc595_j1'e git.
	bsf	hc595_port, DATA_Pin	;Kontrol edilen bit 1	 
	goto	hc595_j2		;olduðundan DATA_Pin’i “1” yap.
hc595_j1				;Kontrol edilen bit 0
	bcf	hc595_port, DATA_Pin	;olduðundan DATA_Pin'i reset 
					;yap. 
hc595_j2
	bsf	hc595_port, CLK_Pin	;74HC595'in CLK pinine düþen
	bcf	hc595_port, CLK_Pin	;darbe kenarý uygulanýyor,
	rrf	i, F			;böylece verinin i bit veri 
					;74HC595 çýkýþlarýnda 
					;gözükür. i'yi bir bit saða 
					;kaydýrarak sýradaki transfer edilecek 
					;bit’i tespit et. 
	bcf    i, 7			;i deðiþkeninin en deðerli bit’ini sil.
	movf	i, W
	btfss	STATUS, Z		;i = 0 ise bir sonraki komuta atla.
	goto	hc595_j0

	bsf	hc595_port, LATCH_Pin	;74HC595'in LATCH pinine 
					;düþen	 darbe kenarý 
					;uygulanýyor,
	bcf	hc595_port, LATCH_Pin	;böylece veri 74HC595 
					;çýkýþlarýnda gözükür.
	return
;-------------------------------------------------------------------
; delay_ms alt programý 1-255 ms arasýnda deðiþken bekleme süresi 
; saðlar delay_ms_data yüksek byte deðiþkenine yüklenecek deðer 
; kadar ms olarak gecikme saðlar.
;-------------------------------------------------------------------
delay_ms
delay_j0
	movlw	D'142'			;1 ms gecikme için taban deðer.
	movwf	delay_ms_data+1		;delay parametresinin düþük 
					;byte’ýna yüklendi.
	nop				;2 us bekle.
	nop
delay_j1
	nop				;4 us gecikme.
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F	;delay parametresinin düþük 
					;byte'ýný azalt, sýfýrsa komut atla
	goto	delay_j1		;Henüz 1 ms gecikme saðlanamadý, 
					;düþük byte'ý azaltmaya devam et.
	nop				;1 us bekle.
	decfsz	delay_ms_data, F	;delay parametresinin yüksek 
					;byte'ýný azalt sýfýrsa komut atla.
	goto	delay_j0		;1 ms beklemeyi tekrarla.
	nop				;1 us bekle.
	return				;Alt programdan çýkýþ.
;-------------------------------------------------------------------
; Ana program 74HC595 entegresi çýkýþlarýnýn donaným modülleri 
; kullanýlmadan yalnýzca yazýlým ile 1-255 arasýnda yukarý sayan 
; binary sayaç olarak nasýl kullanýlacaðýný göstermektedir.
;-------------------------------------------------------------------
Ana_program
	banksel TRISB		;TRISB'nin bulunduðu banka geç.
	clrf	TRISB		;PORTB'nin tüm pinlerini çýkýþa yönlendir.
	banksel PORTB		;PORTB'nin bulunduðu banka geç.
	clrf	PORTB		;PORTB'nin ilk andaki çýkýþlarý sýfýr.
Ana_j0
	movlw	0x01		;Sayaca ilk deðer atamasý yapýlýyor 
	movwf	sayac		
Ana_j1
	movf	sayac, W	;Sayaç deðeri 0xFF'ten sonra 0x00'a 
				;döndüðünde,
	btfsc	STATUS, Z	;Sayaç sýfýrdan farklý ise bir komut atla.
	goto	Ana_j0		;sayac = 0 ise Ana_j0 adresine git.
	movf	sayac, W	;Sayaç deðerini W'ye yükle.
	incf	sayac, F	;sayac’ý bir artýr.
	movwf	hc595_data	;W'de bulunan önceki sayaç deðerini 
				;hc595_data deðiþkenine yükle.
	call	hc595_Yaz	;hc595_data deðiþkenindeki deðeri
				;74HC595'e yaz.
	movlw	D'250'		;delay_ms_data deðiþkenine 250 ms yaz.
	movwf	delay_ms_data		
	call	delay_ms	;250 ms bekle.
	goto	Ana_j1		;Ana_j1 adresine git.

	END
;*******************************************************************

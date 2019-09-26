;*******************************************************************
;	Dosya Adý		: 6_3.asm
;	Programýn Amacý		: SFR’siz senkron seri veri iletiþimi
;				 (74HC597 kullanýlarak).
;	PIC DK 2.1 		: PORTB<0:4> Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F31' 	;PWRT on, diðerleri kapalý, 
				;Osilatör XT ve 4Mhz.
;-------------------------------------------------------------------
; Genel tanýmlamalar ve deðiþken tanýmlamalarý yapýlýyor.
;-------------------------------------------------------------------
#define hc597_port	PORTB		;74HC597’ün baðlý olduðu 
					;port tanýmý yapýlýyor.
#define LOAD_Pin	0		;Load pininin iþlemciye baðlý 
					;olduðu pin tanýmlanýyor.
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
hc597_data		equ 0x23 	;Okunacak veriyi tutan deðiþken.

	ORG 	0			;Reset vektör adresi burasý. 
	pagesel Ana_program		;Ana programýn bulunduðu program 
					;sayfasý seçildi.
	goto 	Ana_program		;Ana programa git.

	ORG 	4
;-------------------------------------------------------------------
; hc597_Oku alt programý, 1 byte veriyi donaným modüllerini
; kullanmadan yalnýzca yazýlým ile 74HC597 entegresinden okuyup 
; iþlemciye transfer eder.
;-------------------------------------------------------------------
hc597_Oku
	Banksel hc597_port		;hc597_port'nin bulunduðu 
					;bank seçildi.
	bsf	hc597_port, LATCH_Pin	;Anahtarlardan bilgi Latch'a 
					;alýnýyor.
	nop
	bcf	hc597_port, LATCH_Pin
	bcf	hc597_port, LOAD_Pin	;Latch'taki bilgi kaydýrmalý 
					;kaydediciye aktarýlýyor.
	nop
	bsf	hc597_port, LOAD_Pin

	movlw	8			;i deðiþkenine 8 bilgisi yüklendi.
	movwf	i			;i, 8 bit’in de alýndýðýný kontrol 
					;etmek için kullanýlýyor.
hc597_j0
	rlf	hc597_data, F
	btfss	hc597_port, DATA_Pin	;Data pininden gelen veri 1 
					;ise bir komut atla.
	goto	hc597_j1		;Gelen veri 0, o halde 
					;hc597_j1'e git.
	bsf	hc597_data, 0		;hc597_data deðiþkeninin 0.
					;bit’ini set et.
	goto	hc597_j2		;Clock palsi için devam.
hc597_j1
	bcf	hc597_data, 0		;hc597_data deðiþkeninin 0. 
					;bit’ini reset et.
hc597_j2
	bsf	hc597_port, CLK_Pin	;74HC597'in CLK pinine inen 
					;darbe kenarý uygulanýyor.
	nop
	bcf	hc597_port, CLK_Pin
	decfsz	i, F			; i sayacýný bir azalt ve 8 bit’in
					;tamamý okundu ise bir komut atla.
	goto	hc597_j0
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
					;byte'ýna yüklendi.
	nop				;2 us bekle.
	nop
delay_j1
	nop				;4 us gecikme.
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F	;delay parametresinin düþük 
					;byte'ýný azalt sýfýrsa komut atla.
	goto	delay_j1		;Henüz 1 ms gecikme saðlanamadý, 
					;düþük byte'ý azaltmaya devam et
	nop				;1 us bekle.
	decfsz	delay_ms_data, F	;delay parametresinin yüksek 
					;byte'ýný azalt sýfýrsa komut atla.
	goto	delay_j0		;1 ms beklemeyi tekrarla.
	nop				;1 us bekle.
	return				;Alt programdan çýkýþ.
;-------------------------------------------------------------------
; delay_5s alt programý 5 saniye gecikme için 20 kez 250 ms gecikme 
; iþlemi gerçekleþtirir. Delay sonucunda 5 saniyeye çok yakýn bir 
; gecikme saðlanýr.
;-------------------------------------------------------------------
delay_5s
	movlw	0x14			;20 * 250ms = 5000ms 
	movwf	i
delay_5s_j0	
	movlw	D'250'			;250 ms deðerini delay_ms_data 
					;deðiþkenine yaz.
	movwf	delay_ms_data	
	call	delay_ms		;250 ms bekle.
	decfsz	i, F
	goto	delay_5s_j0
	return
;-------------------------------------------------------------------
; Ana program 74HC597 entegresine baðlý anahtarlardan alýnan 
; bilginin donaným modülleri kullanýlmadan yalnýzca yazýlým ile 
; okunarak PORTB’nin en deðerli 4 çýkýþýnda (RB7 - RB4) 5 sn 
; aralýklarla görüntülenmesini saðlar.
;-------------------------------------------------------------------
Ana_program
	banksel TRISB			;TRISB’nin bulunduðu banka geç.
	movlw	2
	movwf	TRISB			;PORTB’nin RB1 pini giriþ, diðer 
					;pinleri çýkýþ yapýldý.
	Banksel PORTB			;PORTB’nin bulunduðu banka geç.
	clrf	PORTB			;PORTB'nin pinlerinin ilk andaki 
					;çýkýþlarý sýfýr.
Ana_j0
	call	hc597_Oku		;hc597_data deðiþkenindeki deðeri 
					;74HC597’e yaz.
	movf	hc597_data, W		;hc597_data deðiþkeninde bulunan 
					;veriyi W’ye aktar.
	andlw	0xF0			;Verinin en deðerli 4 bit’ini al.
	movwf	PORTB			;En deðerli 4 anahtarýn konumlarýný 
					;PORTB’nin RB7-RB4 çýkýþlarýnda 
					;göster.
	call	delay_5s		;5 saniye bekle.
	swapf	hc597_data, W		;hc597_data deðiþkeninde bulunan 
					;verinin en deðerli ve en deðersiz 
					;4 bit’ini yer deðiþtirerek W’ye 
					;aktar.
	andlw	0xF0			;Verinin en deðersiz 4 bit’i artýk 
					;W’nin en deðerli 4 bit’i durumunda
	movwf	PORTB			;En deðersiz 4 anahtarýn 
					;konumlarýný PORTB’nin RB7-RB4 
					;çýkýþlarýnda göster.
	call	delay_5s		;5 sn bekle.
	goto	Ana_j0			;Ana_j0 etiketine git.

	END
;*******************************************************************

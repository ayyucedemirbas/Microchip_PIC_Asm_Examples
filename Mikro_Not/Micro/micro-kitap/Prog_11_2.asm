;*******************************************************************
;	Dosya Adý		: 11_2.asm
;	Programýn Amacý		: 4 dijit 7 segment display uygulamasý
;	PIC DK2.1a 		: PORTB Çýkýþ ==> 7 segment display
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osc:XT ve 4Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlarý yapýlýyor.
;-------------------------------------------------------------------	
CBLOCK	0x20			;16F877A’nýn RAM baþlangýç adresi, 
				;deðiþkenler burada.
		sayacH		;sayacýn yüksek byte'ý.
		sayacL		;sayacýn düþük byte'ý.
		sira		;Display sýrasýný belirler.

		HexMSB		;Çevrilecek sayýnýn en deðerli byte'ý.
		HexLSB		;Çevrilecek sayýnýn en deðersiz byte'ý.
		binler		;Çevrilen sayýnýn binler basamaðý burada.
		yuzler		;Çevrilen sayýnýn yüzler basamaðý burada.
		onlar		;Çevrilen sayýnýn onlar basamaðý burada.
		birler		;Çevrilen sayýnýn birler basamaðý burada.

		Timer5ms	;5 ms sayacý.
		Timer1s		;1 sn sayacý.
		TimeCtrl	;Zaman kontrol kaydedicisi.
	ENDC

	ORG 	0 
	pagesel Ana_program		;Ana programýn bulunduðu program 
					;sayfasý seçildi.
	goto 	Ana_program
	ORG 	4			;Kesme alt programý bu adresten	goto	kesme	
					;baþlýyor.
;-------------------------------------------------------------------
; 2 byte binary veriyi bcd koda dönüþtürür. Sonuç binler, yüzler,
; onlar ve birler deðiþkenlerinde saklanýr.
;-------------------------------------------------------------------
HexToDec
	clrf binler		;binler = 0
	clrf yuzler		;yuzler = 0
	clrf onlar		;onlar = 0
	clrf birler		;birler = 0
binler_kont
	movlw	04h		;W’ye 1024 (0x0400) sayýsýnýn en deðerli 
				;byte'ýný yükle.
	subwf	HexMSB, W	;HexMSB’den 1024 çýkart.
	btfss	STATUS, C	;HexMSB > 1024'mü?
	goto	yuzler_kont2	;hayýr ise yüzleri kontrol et.
	incf	binler, F	;evet ise binleri bir artýr.
	movlw	04h		;W’ye 0x04 yükle.
	subwf	HexMSB, F	;HexMSB’den 1000 çýkart.
	movlw	18h		;W’ye 0x18 yükle.
	addwf	HexLSB, F	;HexLSB’ye (0x18 = 24) ekle.
	btfsc	STATUS, C	;elde var mý?
	incf	HexMSB, F	;evet ise bir artýr.
	goto	binler_kont	;binleri yeniden kontrol et.
yuzler_kont2
	movlw	0x01		;256 (0x0100)
	subwf	HexMSB, W	;HexMSB’den 200 çýkart ve sonucu W’ye 
				;sakla.
	btfss	STATUS, C	;sonuç >= 256’mý?
	goto	yuzler_kont1	;Hayýr ise yüzler basamaðýný kontrol et
	movlw	0x02		;deðilse,
	addwf	yuzler, F	;yuzler'e 2 ekle.
	movlw	0x01		;W = 1
	subwf	HexMSB, F	;HexMSB’den 200 çýkart.
	movlw	0x38		;W =0x38 (256'nýn 56 lýk kýsmý).
	addwf	HexLSB, F	;HexLSB’ye 56’yý ekle.
	btfsc	STATUS, C	;elde var mý?
	incf	HexMSB, F	;evet ise HexMSB’yi bir artýr.
	movlw	0x0A		;W = 10
	subwf	yuzler, W	;yuzler = 1000 olup olmadýðýný kontrol et,
	btfss	STATUS, Z	;sonuç sýfýr mý?
	goto	yuzler_kont2	;hayýr ise yuzleri yeniden kontrol et.
	clrf	yuzler		;yuzler = 0
	incf	binler, F	;binler'i artýr.
	goto	yuzler_kont2	;yuzler'i 200 ya da daha büyük sayý için 
				;yeniden kontrol et.
yuzler_kont1 
	movlw	0x64		;W = 0x64
	subwf	HexLSB, W	;HexLSB’den 100 çýkart.
	btfss	STATUS, C	;sonuç >= 100 mü?
	goto	onlar_kont	;hayýr ise onlarý kontrol et,
	incf	yuzler, F	;evet ise yuzler'i bir artýr.
	movlw	0x64		;W = 0x64 (100)
	subwf	HexLSB, F	;HexLSB’yi 100 azalt.
	movlw	0x0A		;W = 0x0A (10)
	subwf	yuzler, W	;yuzler = 1000 kontrolü yap.
	btfss	STATUS, Z	;sonuç = 0 mý?
	goto	yuzler_kont1	;hayýr ise 100 için yuzler'i yeniden 
				;kontrol et.
	clrf	yuzler		;yuzler = 0
	incf	binler, F	;binleri bir artýr.
	goto	yuzler_kont1	;100 ya da daha büyük olma durumu için 
				;yuzleri yeniden kontrol et.
onlar_kont
	movlw	0x0A		;W = 0x0A (10)
	subwf	HexLSB, W	;HexLSB’den 10 çýkart.
	btfss	STATUS, C	;sonuç >= 10 mu?
	goto	birler_kont	;hayýr ise birleri kontrol et,
	incf	onlar, F	;evet ise onlarý bir artýr.
	movlw	0x0A		;W = 0x0A (10)
	subwf	HexLSB, F	;HexLSB’den 10 çýkart.
	goto	onlar_kont	;onlar'ý yeniden kontrol et.
birler_kont
	movf	HexLSB, W	;W = HexLSB
	movwf	birler		;birler = W, dönüþüm iþlemi tamam.
	return			;Alt programdan çýk.
;-------------------------------------------------------------------
; Her 1 saniyede sayaç deðerini bir artýran alt program.
;-------------------------------------------------------------------
SayacArtir
	incf	sayacL, F	;sayacL’yi bir artýr.
	btfsc	STATUS, Z	;sýfýrdan farklý ise bir komut atla.
	incf	sayacH, F	;sayacH’i bir artýr.
	movlw	0x27	
 	subwf	sayacH, W
	btfss	STATUS, Z		;sayacH = 0x27 ise bir komut atla
	goto	SayacArtir_j1		;sayac henüz 10000’e ulaþmadý, o 
					;halde devam et.
	movlw	0x10
 	subwf	sayacL, W
	btfss	STATUS, Z		;sayacL = 0x10 ise bir komut atla
	goto	SayacArtir_j1		;sayac henüz 10000’e ulaþmadý, o 
					;halde devam et.
	clrf	sayacH			;sayacý sýfýrla.
	clrf	sayacL
SayacArtir_j1
	movf	sayacH, W		;sayac deðerini desimale dönüþtür.
	movwf	HexMSB
	movf	sayacL, W
	movwf	HexLSB
	call	HexToDec
	return
;-------------------------------------------------------------------
; Her 5ms’de bir display’leri tarayarak görüntü oluþturur.
;------------------------------------------------------------------- 
DisplaydeGoster
display1
	incf	sira, F	;Taranacak display sýrasýseçiliyor.
	movlw	.1
	subwf	sira, W
	btfss	STATUS, Z	;1. display mi taranacak?
	goto	display2	;Hayýr ise 2.display için kontrol et.	
	movf	birler, W
	iorlw	0x10		;1. display sürme bilgisi ve deðeri W’de
	movwf	PORTB		;1. display’de görüntü oluþturuldu.
	goto	disp_son
display2
	movlw	.2
	subwf	sira, W
	btfss	STATUS, Z	;2. display mi taranacak?
	goto	display3	;Hayýr ise 3. display için kontrol yap.
	movf	onlar, W
	iorlw	0x20		;2. display sürme bilgisi ve deðeri W’de.
	movwf	PORTB		;2. display’de görüntü oluþturuldu.
	goto	disp_son
display3
	movlw	.3
	subwf	sira, W
	btfss	STATUS, Z	;3. display mi taranacak.
	goto	display4	;Hayýr ise 4. display için kontrol yap.
	movf	yuzler, W
	iorlw	0x40		;3. display sürme bilgisi ve deðeri W’de.
	movwf	PORTB		;3. display’de görüntü oluþturuldu.
	goto	disp_son
display4
	movlw	.4
	subwf	sira, W
	btfss	STATUS, Z	;4. display mi taranacak.
	goto	display5	;Hayýr ise sirayi 1.display için ayarla.	
	movf	binler, W
	iorlw	0x80		;4. display sürme bilgisi ve deðeri W’de.
	movwf	PORTB		;4. display’de görüntü oluþturuldu.
	goto	disp_son
display5
	clrf	sira		;sira deðerini sýfýrla ve
	goto	display1	;tekrar bir artýrarak kontrol için baþa 
disp_son:
	return
;-------------------------------------------------------------------
; Kesme programý her 1 ms de bir çalýþýr ve zaman sayaçlarýný 
; artýrýr.
;-------------------------------------------------------------------
kesme
	btfss	INTCON, T0IE		;TMR0 kesmesi etkin mi? Evetse bir 
					;komut atla.
	goto	int_son			;hayýrsa kesmeden çýk.
	btfss	INTCON, T0IF		;TMR0 kesmesi oluþtumu? T0IF = 1 mi 	
	goto	int_son			;hayýrsa kesmeden çýk.
	movlw	0x06
	movwf	TMR0
	incf	Timer5ms, F
	movlw	.5
	subwf	Timer5ms, W
	btfss	STATUS, Z
	goto	int_son
	clrf	Timer5ms		;5 ms doldu.
	bsf	TimeCtrl, 0		;5 ms bayraðý set oldu.
	incf	Timer1s, F		;1 s sayacýný artýr, deðeri 200 
					;olduðunda 1s geçmiþtir
					;bu durumda sayaç artýrýlacak.
	movlw	.200
	subwf	Timer1s, W
	btfss	STATUS, C
	goto	int_son
	clrf	Timer1s			;1 sn doldu.
	bsf	TimeCtrl, 1		;1 sn bayraðý set oldu.
int_son
	bcf	INTCON, T0IF		;Kesme bayraðýný sil.
	retfie
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
Ana_program	
	movlw	0xD1			;RB pull-up pasif, TMR0 için clock 
					;kaynaðý internal clock.
	option				;1:4 prescaler deðer seçildi.

	banksel TRISB			;BANK1 seçildi.
	clrf	TRISB			;PORTB çýkýþ yapýldý.
	banksel PORTB			;BANK0 seçildi.
	clrf	PORTB			;PORTB çýkýþlarý sýfýrlandý.

	clrf	sayacH			;sayac = 0
	clrf	sayacL
	clrf	HexMSB			;Desimal deðiþkenler sýfýrlandý.
	clrf	HexLSB
	call	HexToDec

	clrf	sira			;sira = 0, þu an herhangi bir 
					;display’i iþaret etmiyor.
	
	clrf	Timer5ms		;5 ms sayacý sýfýrlandý.
	clrf	Timer1s			;1 sn sayacý sýfýrlandý.
	clrf	TimeCtrl		;Zaman kontrol kaydedicisi 
					;sýfýrlandý.
	movlw	0x06
	movwf	TMR0			;TMR0 zamanlayýcýsý ilk deðeri 
					;verildi.
	bsf	INTCON, T0IE		;TMR0 kesmesi etkin hale getirildi
	bsf	INTCON, GIE		;Etkinleþtirilen tüm kesmelere 
					;izin verildi.
Ana_j1:
	btfss	TimeCtrl, 0		;5 ms süre geçti mi?
	goto	Ana_j2			;1 sn bayraðýný kontrol et.
	bcf	TimeCtrl, 0		;5 ms bayraðýný sil.
	call	DisplaydeGoster		;Display tara.

Ana_j2
	btfss	TimeCtrl, 1		;1 sn süre geçti mi?
	goto	Ana_j1			;5 ms bayraðýný kontrol et.
	bcf	TimeCtrl, 1		;1 sn bayraðýný sil.
	call	SayacArtir		;Sayacý bir artýr.
	goto	Ana_j1			;Sistem kapatýlana ya da 
					;resetlenene kadar boþ döngü.
					;Bu döngü sýrasýnda 5ms'de bir 
					;kesme çalýþýyor.
	end
;*******************************************************************

;*******************************************************************
;	Dosya Adý		: 7_2.asm
;	Programýn Amacý		: A/D modülü ile ýsý ölçümü (LM35 ile)
;	PIC DK2.1a 		: PORTB Çýkýþ ==> 7 segment display’ler
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F31' 	;PWRT on, diðerleri kapalý,
				;Osc:XT ve 4Mhz
;-------------------------------------------------------------------
; Deðiþken tanýmlarý yapýlýyor.
;-------------------------------------------------------------------	
CBLOCK	0x20		;16F877A'nýn RAM baþlangýç adresi, 
			;deðiþkenler burada.
	sira		;display sýrasýný belirler.
	HexLSB		;Çevrilecek sayýnýn en deðersiz byte'ý.
	onlar		;Çevrilen sayýnýn onlar basamaðý burada.
	birler		;Çevrilen sayýnýn birler basamaðý burada.
	Timer5ms	;5 ms sayacý.
	Timer1s		;1sn sayacý.
	TimeCtrl	;Zaman kontrol laydedicisi
	ENDC

	ORG 	0
	pagesel Ana_program		;ana programýn bulunduðu program 
					;sayfasý seçildi.
	goto 	Ana_program		;ana programa git.
	ORG 	4			;Kesme alt programý bu adresten 
					;baþlýyor.
	goto	kesme
;-------------------------------------------------------------------
; 1 byte binary veriyi bcd'ye dönüþtürür. Sonuç onlar ve birler 
; deðiþkenlerinde saklanýr.0'dan 99'a kadar olan desimal sayý 
; dönüþümü yapar, 99'u aþan deðerler için uygun deðildir.
;------------------------------------------------------------------- 
HexToDec
	clrf onlar			;onlar = 0
	clrf birler			;birler = 0
onlar_kont
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, W		;HexLSB'den 10 çýkart.
	btfss	STATUS, C		;sonuç >= 10 mu?
	goto	birler_kont		;hayýr ise birleri kontrol et.
	incf	onlar, F		;evet ise onlarý bir artýr.
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, F		;HexLSB'den 10 çýkart.
	goto	onlar_kont		;onlar'ý yeniden kontrol et.
birler_kont
	movf	HexLSB, W		;W = HexLSB
	movwf	birler			;birler = W, dönüþüm iþlemi tamam.
	return				;alt programdan çýk.
;-------------------------------------------------------------------
; Isý dönüþümünü gerçekleþtirir ve desimale dönüþtürür.
;------------------------------------------------------------------- 
IsiOlc
	Banksel ADCON0			;BANK0'a geç, ADCON0 bu bankta.
	bsf	ADCON0, GO		;Isý dönüþümünü baþlat.
	btfsc	ADCON0, GO		;Dönüþüm tamamlanana kadar bekle.
	goto	$ - 1
	bcf	STATUS, C
	rrf	ADRESH, F
	banksel ADRESL			;ADRESL BANK1'de.
	rrf	ADRESL, W
	banksel HexLSB			;BANK0'a geç.
	movwf	HexLSB
	call	HexToDec
	return
;-------------------------------------------------------------------
; Her 5 ms'de bir display'leri tarayarak görüntü oluþturur.
;------------------------------------------------------------------- 
DisplaydeGoster
display1
	incf	sira, F		;Taranacak display sýrasýný seçiliyor.
	movlw	.1
	subwf	sira, W
	btfss	STATUS, Z	;1. display mi taranacak?
	goto	display2	;Hayýr ise 2. display için kontrol yap.
	movlw	0x0A		;C iþareti için.
	iorlw	0x10		;1. display sürme bilgisi ve deðeri W'de.
	movwf	PORTB		;1. display’de görüntü oluþturuldu.
	goto	disp_son
display2
	movlw	.2
	subwf	sira, W
	btfss	STATUS, Z	;2. display mi taranacak?
	goto	display3	;Hayýr ise 3. display için kontrol yap.
	movf	birler, W
	iorlw	0x20		;2. display sürme bilgisi ve deðeri W'de.
	movwf	PORTB		;2. display’de görüntü oluþturuldu.
	goto	disp_son
display3
	movlw	.3
	subwf	sira, W
	btfss	STATUS, Z	;3. display mi taranacak?
	goto	display4	;Hayýr ise 4. display için kontrol yap.
	movf	onlar, W
	iorlw	0x40		;3. display sürme bilgisi ve deðeri W'de
	movwf	PORTB		;3. display’de görüntü oluþturuldu.
	goto	disp_son
display4
	movlw	.4
	subwf	sira, W
	btfss	STATUS, Z	;4. display mi taranacak?
	goto	display5	;Hayýr ise sirayi 1. display için ayarla 
				;ve uygula.
	movlw	0x0F		;Display'de biþey görünmez.
	iorlw	0x80		;4. display sürme bilgisi ve deðeri W'de.
	movwf	PORTB		;4. display’de görüntü oluþturuldu.
	goto	disp_son
display5
	clrf	sira		;sira deðerini sýfýrla ve
	goto	display1	;tekrar bir artýrarak kontrol için baþa.
disp_son
	return
;-------------------------------------------------------------------
; Kesme programý (kullanýlacak ise LCD ya da zamanlamanýn önemli
; olduðu cihazlarla çalýþýrken iletiþimin kesilmemesine dikkat 
; ediniz).
;------------------------------------------------------------------- 
kesme
	btfss	INTCON, T0IE		;TMR0 kesmesi etkinse bir 
					;komut atla.
	goto	int_son			;hayýrsa kesmeden çýk.
	btfss	INTCON, T0IF		;TMR0 kesmesi oluþtu mu? T0IF =? 1	
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
	incf	Timer1s, F		;1 sn sayacýný artýr, deðeri 200 
					;olduðunda 1 sn geçmiþtir.
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
					;kaynaðý intrenal clock
	option				;1:4 prescaler deðer seçildi.
	banksel	TRISB			;BANK1 seçildi.
	clrf	TRISB			;PORTB çýkýþ yapýldý.
	movlw	0x8E					
	movwf	ADCON1			;Isý sonuç saða dayalý ve RA0 
					;analog giriþ, diðerleri dijital.
	banksel	PORTB			;BANK0 seçildi.
	clrf	PORTB			;PORTB çýkýþlarý sýfýrlandý.
	movlw	0x81
	movwf	ADCON0			;Fosc/32, 0. Kanal seçildi ve AD 
					;modülü açýldý.
	clrf	HexLSB			;Ýlk durumda ýsý deðeri sýfýr 
					;kabul edildi.
	call	HexToDec
	clrf	sira			;sira = 0, þu an herhangi bir 
					;display’i iþaret etmiyor.
	clrf	Timer5ms		;5ms sayacý sýfýrlandý.
	clrf	Timer1s			;1sn sayacý sýfýrlandý.
	clrf	TimeCtrl		;Zaman kontrol kaydedicisi 
					;sýfýrlandý.
	movlw	0x06
	movwf	TMR0			;TMR0’a ilk deðeri verildi.

	bsf	INTCON, T0IE		;TMR0 kesmesi etkin hale getirildi.
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
	call	IsiOlc			;Isý ölç ve dönüþtür.
	bcf	TimeCtrl, 1		;1 sn bayraðýný sil.
	goto	Ana_j1			;Sistem kapatýlana ya da 
					;resetlenene kadar boþ döngü
					;Bu döngü sýrasýnda 5ms'de bir 
					;kesme çalýþýyor.
	END
;*******************************************************************

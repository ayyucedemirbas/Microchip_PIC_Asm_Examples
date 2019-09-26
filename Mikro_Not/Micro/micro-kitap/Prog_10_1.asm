;*****************************************************************
;	Dosya Adý		: 10_1.asm
;	Programýn Amacý		: PSP kullanýmý
;	Notlar 			: Proteus programý simülasyonu
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý
;-------------------------------------------------------------------
#define PSP_errorFlag	7
#define PSP_inputFlag	6
#define PSP_outputFlag	5

PSP_CtrlByte		equ 0x20
PSP_inputBuffer		equ 0x21
PSP_outputBuffer	equ 0x21

	ORG	0
	clrf	PCLATH
	goto	Ana_Program

	ORG	4
;-------------------------------------------------------------------
; PSP'den gelen kesmeleri iþler. Veri alýndý ise alýnan veriyi 
; PSP_inputBuffer'a yazar ve verinin alýndýðýna dair PSP_inputFlag 
; bayraðýný set eder. Master cihazdan okuma komutu geldi ise ve 
; gönderilecek bir veri daha önceden PSP_outputBuaffer'a yazýldý ise 
; Master cihaza PORTD üzerinden veriyi transfer eder. Ve Verinin 
; hazýr olduðunu belirten PSP_outputFlag bayraðý siler.
;-------------------------------------------------------------------
interrupt
	banksel PIR1
	btfss	PIR1, PSPIF		;PSP kesmesi oluþtu ise (veri geldi 
					;ya da veri gönderildi ise) komut 
					;atla.
	goto	int_son			;Kesme sonuna git ve kesmeden çýk.
	banksel TRISE
	btfss	TRISE, IBF		;Veri alýndý ise komut atla.
	goto	int_j1
	banksel PSP_CtrlByte
	bsf	PSP_CtrlByte, PSP_inputFlag	;Veri alýndý bayraðýný 
						;set et.
	movf	PORTD, W			;Gelen veriyi W'ye al. 
	movwf	PSP_inputBuffer			;W'yi giriþ buffer deðiþkenine 
						;aktar.
int_j1
	banksel TRISE				;Bank1'e geç.
	btfss	TRISE, OBF			;Veri gönderildi ise komut atla.
	goto	int_j2
	banksel PSP_CtrlByte			;Bank0 seçildi, bu deðiþken ve 
						;PORTD ayný bankda.
	btfss	PSP_CtrlByte, PSP_outputFlag	;veri gönderme bayraðý 
						;set ise komut atla.
	goto	int_j2
	movf	PSP_outputBuffer, W		;Çýkýþ buffer deðiþkenine 
						;yüklenen veriyi
	movwf	PORTD				;PORD'ye gönder.
	bcf	PSP_CtrlByte, PSP_outputFlag	;Veri göndermeye hazýr 
						;bayraðýný sil.
int_j2
	banksel TRISE				;Bank1'e geç.
	btfss	TRISE, IBOV			;PSP'de hata oluþtuysa komut atla.
	goto	int_son
	banksel PSP_CtrlByte
	bsf	PSP_CtrlByte, PSP_errorFlag	;Hata bayraðýný set et
	bcf	TRISE, IBOV	
	bcf	PIR1, PSPIF			;PSP kesme bayraðýný sil.
int_son
	retfie	
;-------------------------------------------------------------------
; PSP iletiþimi ayarlar, portlarý yönlendirir ve kesmeleri 
; aktifleþtirerek PSP iletiþimi baþlatýr.
;-------------------------------------------------------------------
init
	banksel TRISE			;Bank1'e geçildi.
	movlw	B'00110111'
	movwf	TRISE			;PSPMODE aktif hale getirildi, RD, 
					;WR ve CS uçlarý giriþ yapýldý.
	clrf	TRISB			;PORTB çýkýþ yapýldý.
	movlw	0x07
	movwf	ADCON1			;Analog giriþler kapatýldý. 
					;PORTE'nin RD, WR ve CS giriþleri 
					;için
	banksel PORTB			;Bank0'a geçildi.
	clrf	PORTB			;PORTB'nin ilk çýkýþlarý LOW 
					;yapýldý.
	clrf	PSP_CtrlByte		;PSP deðiþkenlerinin ilk durumu 
					;sýfýrlanýyor.
	clrf	PSP_inputBuffer
	clrf	PSP_outputBuffer
	banksel PIE1
	bsf	PIE1, PSPIE		;Paralel Slave Port kesmesi 
					;etkinleþtirildi.
	bsf	INTCON, PEIE		;Çevresel kesmeler etkinleþtirildi.
	bsf	INTCON, GIE		;Etkinleþtirilen kesmelere izin
					;verildi.
	return
;-------------------------------------------------------------------
; Ana program PSP'den yazma sinyali geldiðinde gelen veriyi alýr ve 
; PORTB üzerinde baðlý olan LED’ler üzerinde görüntüler. Veri okuma 
; kýsmý uygun bir master cihaz kullanýlmadýðý ve kurulan devremiz 
; uygun olmadýðý için boþ býrakýlmýþtýr, fakat gerekli ipucu 
; verilmiþtir.
;-------------------------------------------------------------------
Ana_Program
	call	init
ana_j1
	banksel PSP_CtrlByte
	btfss	PSP_CtrlByte, PSP_inputFlag
	goto	ana_j2
	movf	PSP_inputBuffer, W
	movwf	PORTB
	bcf	PSP_CtrlByte, PSP_inputFlag	;Veri alýndý bayraðýný 
						;sil.
ana_j2
	btfsc	PSP_CtrlByte, PSP_outputFlag	;Çýkýþ verisi hazýr 
						;bayraðý sýfýr ise 
						;komut atla.
	goto	ana_j1

;Buraya gönderilecek veriyi çýkýþ buffer deðiþkenine yazan kodlar 
;eklenecek. Örneðin sayac diye bir deðiþken içeriðini çýkýþa 
;transfer etmek istersek

	;movf	sayac, W
	;movwf	PSP_outputBuffer		

;sayac içeriði çýkýþ buffer'ýna yazýldý, gönderilmek için beklemede

	bsf	PSP_CtrlByte, PSP_outputFlag	;Veri gönderme 
;bayraðýný set et 
;(veri gönderilmeye hazýr).

;Eðer MASTER cihazdan okuma (RD) sinyali gelirse TRISE'nin OBF bit’i 
;set olur, kesmede ilgili kýsým çalýþýr. PSP_outputBuffer'a yüklenen 
;veri kesme içerisinden Master cihaza gönderilir ve PSP_outputFlag 
;bayraðý silinir.
	goto	ana_j1

	END
;*******************************************************************

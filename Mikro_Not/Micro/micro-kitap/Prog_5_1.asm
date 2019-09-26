;*******************************************************************
;	Dosya Adý		: 5_1.asm
;	Programýn Amacý		: CCP1 capture modunun kullanýlmasý.
;	Notlar 			: PORTB Çýkýþ ==> LED’ler.
;				: RC0’a baðlý buton Timer1 sayma kaynaðý.
;				: RC2’ye baðlý buton CCP1 olay kaynaðý.
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc" 
	__config H'3F3A' 	;Tüm program sigortalarý kapalý, 
				;Osilatör HS ve 20Mhz
	ORG 	0 
	Pagesel  ana_program	;Ana programýn bulunduðu program 
				;sayfasý seçildi.
	goto 	ana_program	;Ana programa git.
	ORG 	4			
;-------------------------------------------------------------------
; Kesme alt programý: Her Capture (yakalama) olayýnda kesme oluþur 
; ve PORTB çýkýþý bir artar.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;0. bank seçildi. PIR1 bu bankta.
	btfss 	PIR1, 2		;CCP1IF set ise bir komut atla.
	goto 	int_j1		;Kesmeden çýkýþa git.
	bcf 	PIR1, 2		;CCP1IF kesme bayraðýný sil.
	incf 	PORTB, F	;PORTB çýkýþ kaydedicisi deðeri bir artýr.
int_j1
	retfie
;-------------------------------------------------------------------
; Capture (yakalama) mod ilk iþlemler: TMR1 1:8 prescaler deðere 
;ayarlanýr. CCP1 Her yükselen 4. darbe kenarý olayýna ayarlanýr.
;-------------------------------------------------------------------
Capture_Ilk_Islemler
	Banksel TMR1L		;0. bank seçildi. TMR1 bu bankta
	clrf 	TMR1L		;TMR1 sýfýrlandý
	clrf 	TMR1H
	movlw 	0x33
	movwf 	T1CON		;TMR1 1:8 prescaler deðere ayarlandý ve 
				;RC0/T1OSO/T1CKI giriþinden gelen her 8. 
				;yükselen darbe kenarýnda ;deðerinin 1 
				;artmasý saðlandý.
	movlw 	0x06		;Her yükselen 4. darbe kenarýný yakala.
	movwf 	CCP1CON
	banksel TRISC		;1. bank seçildi TRISC ve PIE1 bu bankta
	bsf 	TRISC, 2	;RC2/CCP1 pin giriþe ayarlandý.
	bsf 	PIE1, 2		;Capture kesmesi aktif hale getirildi.
	return
;-------------------------------------------------------------------
; Ana program ilk iþlemler:Port yönlendirme iþlemleri.
;-------------------------------------------------------------------
ilk_islemler
	banksel TRISB			;1. bank seçildi. TRISB bu bankta.
	clrf 	TRISB			;PORTB çýkýþa yönlendirildi.
	bcf 	STATUS, RP0		;0. bank seçildi. PORTB bu bankta.
	clrf 	PORTB			;PORTB'nin ilk çýkýþ deðeri sýfýr 
					;olarak set edildi.
	return				;Alt programdan çýkýþ.


;-------------------------------------------------------------------
; Ana program: Bu kýsýmda ilk iþlemler yapýldýktan sonra kesmeler 
; aktif hale getirilip kesmeler bekleniyor.
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler	      	;Ýlk iþlemler alt programý çaðrýldý.
	call 	Capture_Ilk_Islemler	;Capture modun çalýþma 
					;koþullarý belirleniyor.
	bsf 	INTCON, 6		;PEIE set edildi, Çevresel birim 
					;kesmeleri aktif.
	bsf 	INTCON, 7		;Genel kesme izni verildi.
	goto  	$			;Sistem kapatýlana ya da 
					;resetlenene kadar boþ döngü.

	END				;Program sonu
;*******************************************************************

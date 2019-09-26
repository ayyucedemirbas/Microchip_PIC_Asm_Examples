;*******************************************************************
;	Dosya Adý		: 4_4.asm
;	Programýn Amacý		: Timer1’in Zamanlayýcý Olarak
; 				  Kullanýlmasý.
;	PIC DK2.1 		: PORTB<0:7> Çýkýþ ==> LED
;				: PORTA<0:1> dijital giriþ ==> BUTON
;				: XT ==> 20 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"		
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20 Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý
;-------------------------------------------------------------------
					; Deðiþken kullanýlmýyor.
	ORG 	0				
	clrf 	PCLATH			;0. Program sayfasý seçildi.
	goto 	ana_program		;Ana programa git.

	ORG 	4			;Kesme vektör adresi.
;-------------------------------------------------------------------
; Kesme Alt Programý: Timer1 kesmesi burada iþleniyor.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;BANK0’a geçildi.
	btfss 	PIR1, 0		;Kesme kaynaðý Timer1 ise bir komut 
;atla.
	goto 	int_j1		;Kesmeden çýkma komutuna git.
	incf 	PORTB, F	;PORTB'yi bir artýr (Kesme 
				;sonucunda basit bir görev.)
	bcf 	PIR1, 0		;TMR1IF kesme bayraðýný sil (yeni 
				;TMR1 kesmeleri için.)
int_j1
	retfie
;-------------------------------------------------------------------
; Sayýcý ilk iþlemler alt programý: Timer1 ilk ayarlarý burada 
; yapýlýyor.
;-------------------------------------------------------------------
Zamanlayici_ilk_islemler
	banksel T1CON		;BANK0’a geçildi.
	bcf 	T1CON, 0	;TMR1'in ilk durumu pasif hale getirildi.
	clrf 	TMR1L		;16 bit’lik TMR1 sayacý sýfýrlandý.
	clrf 	TMR1H
	movlw 	0x20
	movwf 	T1CON		;t1con kaydedicisinin en deðerli 4 bit’i 
				;0010 yapýlarak 1:4 prescaler deðere 
				;ayarlandý. Bunun anlamý: Her 4 internal
				;clock palsinin her yükselen kenarýnda 
				;Timer1'in artmasý demektir.
	bcf  T1CON, TMR1CS	;Timer1 sayýcý mod seçildi. TMR1CS=0
	bcf  T1CON, T1SYNC	;Timer1 senkronize mod seçildi. 
	return
;-------------------------------------------------------------------
; Ana program ilk iþlemler alt programý: RA1 ve RA2 giriþ, PORTB 
; çýkýþ, Analog giriþler iptal.
;-------------------------------------------------------------------
ilk_islemler
	banksel ADCON1		;BANK1 seçildi.Yönlendirme kaydedicileri için
	movlw	0x06
	movwf	ADCON1		;PORTA tamamen digital giriþe ayarlandý.
	movwf 	TRISA		;RA1 ve RA2 giriþ diðerleri çýkýþ yapýldý.
	clrf 	TRISB		;PORTB tamamen çýkýþ yapýldý.
	movlw	0x02
	movwf	TRISC		;RC1/T1OSI giriþ diðerleri çýkýþa ayarlandý
	bcf 	STATUS, RP0	;0. bank seçildi. Portlara ulaþmak için
	clrf 	PORTA		;PORTA ve PORTB çýkýþlarý silindi.
	clrf 	PORTB
	return
;-------------------------------------------------------------------
; Timer1 sayýcýsýný baþlatma alt programý.
;-------------------------------------------------------------------
Zamanlayici_Baslat
	Banksel T1CON		; BANK0’a geçildi.
	bsf 	T1CON, 0	; Timer1 modülü açýldý. TMR1ON=1
	return
;-------------------------------------------------------------------
; Timer1 sayýcýsýný durdurma alt programý.
;-------------------------------------------------------------------
Zamanlayici_Durdur
	Banksel  T1CON		; BANK0’a geçildi.
	bcf 	T1CON, 0	; Timer1 modülü kapatýldý. TMR1ON=0
	return
;-------------------------------------------------------------------
; Ana program: Ýlk iþlemler, kesmelere izin ve buton kontrol iþlemleri
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler
	call 	Zamanlayici_ilk_islemler	;Timer1, senkronize counter 
						;moda alýndý.
	banksel PIE1			;PIE için bank 1 seçildi.
	bsf 	PIE1, 0			;Timer1 kesmesi 
					;aktif yapýldý.
	bsf 	INTCON, 6		;Çevresel kesmelere izin verildi.
	bsf 	INTCON, 7		;Genel kesme izni verildi.
ana_j1
	banksel PORTA			; BANK0’a geçildi.  
	btfsc	PORTA, 1		;Baþlatma butonuna basýldý ise bir 
					;komut atla.
	goto	ana_j2			;Durdurma butonunu kontrol kýsmýna 
					;git.
	call	Zamanlayici_Baslat	;Zamanlayici_baslat alt programý 
					;çaðrýldý.
ana_j2
	banksel PORTA			; BANK0’a geçildi. 
	btfsc	PORTA, 2		;Durdurma butonuna basýldý ise bir 
					;komut atla.
	goto	ana_j1			;Ana program çevrimine dön.
	call 	Zamanlayici_Durdur	;Zamanlayici_durdur alt programý 
					;çaðrýldý.
	goto 	ana_j1			;Ana program çevrimine dön.
	END				;Assembly programý sonu.
;******************************************************************

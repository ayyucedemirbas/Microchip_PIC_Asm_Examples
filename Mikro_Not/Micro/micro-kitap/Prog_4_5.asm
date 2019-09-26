;*******************************************************************
;	Dosya Adý		: 4_5.asm
;	Programýn Amacý		: Timer1’in Senkronize Sayýcý Olarak
; 				  Kullanýlmasý. 
;	PIC DK2.1 		: PORTB<0:7> Çýkýþ ==> LED
;				: PORTA<0:1> dijital giriþ ==> BUTON
;				: PORTC<0:1> 32.768 KHz kristal baðlý
;				: XT ==> 20 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F3A' 		;Tüm program sigortalarý kapalý, 
					;Osilatör HS ve 20Mhz
	ORG 	0			
	clrf 	PCLATH			
	goto 	ana_program		
	ORG 	4
;-------------------------------------------------------------------
; Kesme Alt Programý: Timer1 kesmesi burada iþleniyor.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;PIR1 ve PORTB'nin bulunduðu 0. bank 
				;seçildi.
	btfss 	PIR1, 0		;Kesme kaynaðý Timer1 ise bir komut atla.
	goto 	int_j1		;Kesmeden çýkma komutuna git.
	incf 	PORTB, F	;PORTB’yi bir artýr (Kesme sonucunda 
				;basit bir görev.)
	bcf 	PIR1, 0		;TMR1IF kesme bayraðýný sil. 
int_j1
	retfie
;-------------------------------------------------------------------
; Sayýcý ilk iþlemler alt programý: Timer1 ilk ayarlarý burada 
; yapýlýyor.
;-------------------------------------------------------------------
Sayici_ilk_islemler
	banksel T1CON		;T1CON kaydedicisinin bulunduðu bank 
				;seçildi.
	bcf 	T1CON, 0	;TMR1'in ilk durumu pasif hale getirildi.
	clrf 	TMR1L		;16 bit’lik TMR1 sayacý sýfýrlandý.
	clrf 	TMR1H
	movlw 	0x20
	movwf 	T1CON		;t1con kaydedicisinin en deðerli 4 bit’i 
				;0010 yapýlarak 1:4 prescaler deðere 
				;ayarlandý. Bunun anlamý: Her 4 external 
				;clock palsinin yükselen kenarýnda 
				;Timer1'in artmasý demektir.
	bsf 	T1CON, 1	;Timer1 Counter mod seçildi (TMR1CS=1).
	bcf 	T1CON, 2	;Senkronize external clock giriþi seçildi. 
				;T1SYNC=0 (sýfýrda aktif)
				;T1SYNC=1 yapýldýðýnda asenkron sayýcý 
				;modu seçilir. 
	bsf 	T1CON, 3	;External clock için RC1/T1OSI/CCP2 giriþi 
				;seçildi (T1OSCEN=1).
	return
;-------------------------------------------------------------------
; Ana program ilk iþlemler alt programý: RA1 ve RA2 giriþ, PORTB 
; çýkýþ, Analog giriþler iptal.
;-------------------------------------------------------------------
ilk_islemler
	banksel ADCON1		;BANK0 seçildi. Yönlendirme 
				;kaydedicileri için.
	movlw	0x06		;PORTA tamamen digital giriþe ayarlandý.
	movwf	ADCON1		
	movwf 	TRISA
	clrf 	TRISB
	banksel PORTA		;BANK0 seçildi. Portlara ulaþmak için
	clrf 	PORTA		;PORTA ve PORTB çýkýþlarý LOW yapýldý. 
	clrf 	PORTB
	return
;-------------------------------------------------------------------
; Timer1 sayýcýsýný baþlatma alt programý.
;-------------------------------------------------------------------
Sayici_Baslat
	banksel T1CON		;T1CON kaydedicisinin bulunduðu bank seçildi
	bsf 	T1CON, 0	;Timer1 modülü açýldý (TMR1ON=1).
	return
;-------------------------------------------------------------------
; Timer1 sayýcýsýný durdurma alt programý.
;-------------------------------------------------------------------
Sayici_Durdur
	banksel T1CON		;T1CON kaydedicisinin bulunduðu bank seçildi
	bcf 	T1CON, 0	;Timer1 modülü kapatýldý (TMR1ON=0).
	return
;-------------------------------------------------------------------
; Ana program: Ýlk iþlemler, kesmelere izin ve buton kontrol iþlemleri
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler
	call 	Sayici_ilk_islemler	;Timer1, senkronize counter moda 
;alýndý.
	banksel PIE1			;PIE için bank 1 seçildi.
	bsf 	PIE1, 0			;Timer1 kesmesi aktifleþtirildi.
	bsf 	INTCON, 6		;Çevresel kesmelere izin verildi.
	bsf 	INTCON, 7		;Genel kesme izni verildi.
ana_j1
	banksel  PORTA			;PORTA'nin bulunduðu 0. bank 
					;seçildi. 
	btfsc	PORTA, 1		;Baþlatma butonuna basýldý ise 
					;komut atla.
	goto	ana_j2			;Durdurma butonunu kontrol kýsmýna 
					;git.
	call	Sayici_Baslat		;Sayýcýyý baþlat alt programý 
					;çaðrýldý.
ana_j2
	banksel PORTA			;PORTA'nin bulunduðu 0. bank 
					;seçildi. 
	btfsc	PORTA, 2		;Durdurma butonuna basýldý ise 
					;komut atla.
	goto	ana_j1			;Ana program çevrimine dön.
	call 	Sayici_Durdur		;Sayýcý_durdur alt programý 
					;çaðrýldý.
	goto 	ana_j1			;Ana program çevrimine dön.
	END				;Assembly programý sonu.
;*******************************************************************

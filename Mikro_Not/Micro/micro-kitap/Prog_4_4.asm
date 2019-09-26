;*******************************************************************
;	Dosya Ad�		: 4_4.asm
;	Program�n Amac�		: Timer1�in Zamanlay�c� Olarak
; 				  Kullan�lmas�.
;	PIC DK2.1 		: PORTB<0:7> ��k�� ==> LED
;				: PORTA<0:1> dijital giri� ==> BUTON
;				: XT ==> 20 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"		
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20 Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�
;-------------------------------------------------------------------
					; De�i�ken kullan�lm�yor.
	ORG 	0				
	clrf 	PCLATH			;0. Program sayfas� se�ildi.
	goto 	ana_program		;Ana programa git.

	ORG 	4			;Kesme vekt�r adresi.
;-------------------------------------------------------------------
; Kesme Alt Program�: Timer1 kesmesi burada i�leniyor.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;BANK0�a ge�ildi.
	btfss 	PIR1, 0		;Kesme kayna�� Timer1 ise bir komut 
;atla.
	goto 	int_j1		;Kesmeden ��kma komutuna git.
	incf 	PORTB, F	;PORTB'yi bir art�r (Kesme 
				;sonucunda basit bir g�rev.)
	bcf 	PIR1, 0		;TMR1IF kesme bayra��n� sil (yeni 
				;TMR1 kesmeleri i�in.)
int_j1
	retfie
;-------------------------------------------------------------------
; Say�c� ilk i�lemler alt program�: Timer1 ilk ayarlar� burada 
; yap�l�yor.
;-------------------------------------------------------------------
Zamanlayici_ilk_islemler
	banksel T1CON		;BANK0�a ge�ildi.
	bcf 	T1CON, 0	;TMR1'in ilk durumu pasif hale getirildi.
	clrf 	TMR1L		;16 bit�lik TMR1 sayac� s�f�rland�.
	clrf 	TMR1H
	movlw 	0x20
	movwf 	T1CON		;t1con kaydedicisinin en de�erli 4 bit�i 
				;0010 yap�larak 1:4 prescaler de�ere 
				;ayarland�. Bunun anlam�: Her 4 internal
				;clock palsinin her y�kselen kenar�nda 
				;Timer1'in artmas� demektir.
	bcf  T1CON, TMR1CS	;Timer1 say�c� mod se�ildi. TMR1CS=0
	bcf  T1CON, T1SYNC	;Timer1 senkronize mod se�ildi. 
	return
;-------------------------------------------------------------------
; Ana program ilk i�lemler alt program�: RA1 ve RA2 giri�, PORTB 
; ��k��, Analog giri�ler iptal.
;-------------------------------------------------------------------
ilk_islemler
	banksel ADCON1		;BANK1 se�ildi.Y�nlendirme kaydedicileri i�in
	movlw	0x06
	movwf	ADCON1		;PORTA tamamen digital giri�e ayarland�.
	movwf 	TRISA		;RA1 ve RA2 giri� di�erleri ��k�� yap�ld�.
	clrf 	TRISB		;PORTB tamamen ��k�� yap�ld�.
	movlw	0x02
	movwf	TRISC		;RC1/T1OSI giri� di�erleri ��k��a ayarland�
	bcf 	STATUS, RP0	;0. bank se�ildi. Portlara ula�mak i�in
	clrf 	PORTA		;PORTA ve PORTB ��k��lar� silindi.
	clrf 	PORTB
	return
;-------------------------------------------------------------------
; Timer1 say�c�s�n� ba�latma alt program�.
;-------------------------------------------------------------------
Zamanlayici_Baslat
	Banksel T1CON		; BANK0�a ge�ildi.
	bsf 	T1CON, 0	; Timer1 mod�l� a��ld�. TMR1ON=1
	return
;-------------------------------------------------------------------
; Timer1 say�c�s�n� durdurma alt program�.
;-------------------------------------------------------------------
Zamanlayici_Durdur
	Banksel  T1CON		; BANK0�a ge�ildi.
	bcf 	T1CON, 0	; Timer1 mod�l� kapat�ld�. TMR1ON=0
	return
;-------------------------------------------------------------------
; Ana program: �lk i�lemler, kesmelere izin ve buton kontrol i�lemleri
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler
	call 	Zamanlayici_ilk_islemler	;Timer1, senkronize counter 
						;moda al�nd�.
	banksel PIE1			;PIE i�in bank 1 se�ildi.
	bsf 	PIE1, 0			;Timer1 kesmesi 
					;aktif yap�ld�.
	bsf 	INTCON, 6		;�evresel kesmelere izin verildi.
	bsf 	INTCON, 7		;Genel kesme izni verildi.
ana_j1
	banksel PORTA			; BANK0�a ge�ildi.  
	btfsc	PORTA, 1		;Ba�latma butonuna bas�ld� ise bir 
					;komut atla.
	goto	ana_j2			;Durdurma butonunu kontrol k�sm�na 
					;git.
	call	Zamanlayici_Baslat	;Zamanlayici_baslat alt program� 
					;�a�r�ld�.
ana_j2
	banksel PORTA			; BANK0�a ge�ildi. 
	btfsc	PORTA, 2		;Durdurma butonuna bas�ld� ise bir 
					;komut atla.
	goto	ana_j1			;Ana program �evrimine d�n.
	call 	Zamanlayici_Durdur	;Zamanlayici_durdur alt program� 
					;�a�r�ld�.
	goto 	ana_j1			;Ana program �evrimine d�n.
	END				;Assembly program� sonu.
;******************************************************************

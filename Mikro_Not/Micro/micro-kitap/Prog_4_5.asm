;*******************************************************************
;	Dosya Ad�		: 4_5.asm
;	Program�n Amac�		: Timer1�in Senkronize Say�c� Olarak
; 				  Kullan�lmas�. 
;	PIC DK2.1 		: PORTB<0:7> ��k�� ==> LED
;				: PORTA<0:1> dijital giri� ==> BUTON
;				: PORTC<0:1> 32.768 KHz kristal ba�l�
;				: XT ==> 20 Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20Mhz
	ORG 	0			
	clrf 	PCLATH			
	goto 	ana_program		
	ORG 	4
;-------------------------------------------------------------------
; Kesme Alt Program�: Timer1 kesmesi burada i�leniyor.
;-------------------------------------------------------------------
interrupt
	banksel PIR1		;PIR1 ve PORTB'nin bulundu�u 0. bank 
				;se�ildi.
	btfss 	PIR1, 0		;Kesme kayna�� Timer1 ise bir komut atla.
	goto 	int_j1		;Kesmeden ��kma komutuna git.
	incf 	PORTB, F	;PORTB�yi bir art�r (Kesme sonucunda 
				;basit bir g�rev.)
	bcf 	PIR1, 0		;TMR1IF kesme bayra��n� sil. 
int_j1
	retfie
;-------------------------------------------------------------------
; Say�c� ilk i�lemler alt program�: Timer1 ilk ayarlar� burada 
; yap�l�yor.
;-------------------------------------------------------------------
Sayici_ilk_islemler
	banksel T1CON		;T1CON kaydedicisinin bulundu�u bank 
				;se�ildi.
	bcf 	T1CON, 0	;TMR1'in ilk durumu pasif hale getirildi.
	clrf 	TMR1L		;16 bit�lik TMR1 sayac� s�f�rland�.
	clrf 	TMR1H
	movlw 	0x20
	movwf 	T1CON		;t1con kaydedicisinin en de�erli 4 bit�i 
				;0010 yap�larak 1:4 prescaler de�ere 
				;ayarland�. Bunun anlam�: Her 4 external 
				;clock palsinin y�kselen kenar�nda 
				;Timer1'in artmas� demektir.
	bsf 	T1CON, 1	;Timer1 Counter mod se�ildi (TMR1CS=1).
	bcf 	T1CON, 2	;Senkronize external clock giri�i se�ildi. 
				;T1SYNC=0 (s�f�rda aktif)
				;T1SYNC=1 yap�ld���nda asenkron say�c� 
				;modu se�ilir. 
	bsf 	T1CON, 3	;External clock i�in RC1/T1OSI/CCP2 giri�i 
				;se�ildi (T1OSCEN=1).
	return
;-------------------------------------------------------------------
; Ana program ilk i�lemler alt program�: RA1 ve RA2 giri�, PORTB 
; ��k��, Analog giri�ler iptal.
;-------------------------------------------------------------------
ilk_islemler
	banksel ADCON1		;BANK0 se�ildi. Y�nlendirme 
				;kaydedicileri i�in.
	movlw	0x06		;PORTA tamamen digital giri�e ayarland�.
	movwf	ADCON1		
	movwf 	TRISA
	clrf 	TRISB
	banksel PORTA		;BANK0 se�ildi. Portlara ula�mak i�in
	clrf 	PORTA		;PORTA ve PORTB ��k��lar� LOW yap�ld�. 
	clrf 	PORTB
	return
;-------------------------------------------------------------------
; Timer1 say�c�s�n� ba�latma alt program�.
;-------------------------------------------------------------------
Sayici_Baslat
	banksel T1CON		;T1CON kaydedicisinin bulundu�u bank se�ildi
	bsf 	T1CON, 0	;Timer1 mod�l� a��ld� (TMR1ON=1).
	return
;-------------------------------------------------------------------
; Timer1 say�c�s�n� durdurma alt program�.
;-------------------------------------------------------------------
Sayici_Durdur
	banksel T1CON		;T1CON kaydedicisinin bulundu�u bank se�ildi
	bcf 	T1CON, 0	;Timer1 mod�l� kapat�ld� (TMR1ON=0).
	return
;-------------------------------------------------------------------
; Ana program: �lk i�lemler, kesmelere izin ve buton kontrol i�lemleri
;-------------------------------------------------------------------
ana_program
	call 	ilk_islemler
	call 	Sayici_ilk_islemler	;Timer1, senkronize counter moda 
;al�nd�.
	banksel PIE1			;PIE i�in bank 1 se�ildi.
	bsf 	PIE1, 0			;Timer1 kesmesi aktifle�tirildi.
	bsf 	INTCON, 6		;�evresel kesmelere izin verildi.
	bsf 	INTCON, 7		;Genel kesme izni verildi.
ana_j1
	banksel  PORTA			;PORTA'nin bulundu�u 0. bank 
					;se�ildi. 
	btfsc	PORTA, 1		;Ba�latma butonuna bas�ld� ise 
					;komut atla.
	goto	ana_j2			;Durdurma butonunu kontrol k�sm�na 
					;git.
	call	Sayici_Baslat		;Say�c�y� ba�lat alt program� 
					;�a�r�ld�.
ana_j2
	banksel PORTA			;PORTA'nin bulundu�u 0. bank 
					;se�ildi. 
	btfsc	PORTA, 2		;Durdurma butonuna bas�ld� ise 
					;komut atla.
	goto	ana_j1			;Ana program �evrimine d�n.
	call 	Sayici_Durdur		;Say�c�_durdur alt program� 
					;�a�r�ld�.
	goto 	ana_j1			;Ana program �evrimine d�n.
	END				;Assembly program� sonu.
;*******************************************************************

;*******************************************************************
;	Dosya Ad�		: 4_1.asm
;	Program�n Amac�		: Timer0��n zamanlay�c� olarak 
;				  kullan�lmas�n� g�stermek.
;	PIC DK2.1a 		: PORTB<0> ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************	
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tan�mlamalar� 
				;programa dahil ediliyor.
	__config H'3F31' 	;PWRT on, di�er sigortalar kapal�, 
				;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
;De�i�ken tan�mlamalar�
;-------------------------------------------------------------------
Tmr0Sayaci	equ	0x25 		;500ms zaman sayac�.
	ORG 	0			;Reset vekt�r adresi.
	clrf 	PCLATH			;ilk program sayfas�.
	goto 	ana_program		;Ana programa git.
	ORG 4				;Kesme vekt�r adresi.
;-------------------------------------------------------------------
;Kesme program� bu etiketten itibaren ba�l�yor.
;-------------------------------------------------------------------
interrupt						
	btfss 	INTCON, 5		;TMR0 kesmesine izin verilmi� mi? 
					;( TMR0IE = 1 mi? )
goto 	int_j1				;HAYIR ise interrupt sonu.
	btfss 	INTCON, 2		;TMR0 kesmesi olu�tu mu? (TMROIF = 1 mi?)
goto 	int_j1				;interrupt sonu,
	movlw 	D'6'
	movwf 	TMR0			;TMR0'a ilk de�er atamas� yap�l�yor
	bcf 	INTCON, 2		;TMROIF kesme bayra�� siliniyor.
	incf 	Tmr0Sayaci, F		;Her 2ms'de bir kesme olu�ur ve 
					;Timer0Counter kesme say�c�s�
	movlw 	D'250'			;250 de�erine ula�ana kadar her 
					;kesmede de�eri 1 artar.
	subwf 	Tmr0Sayaci, W		;250 de�erine ula�t���nda 500ms'lik 
					;zamanlamaya ula��lm�� olur.
	btfss 	STATUS, C		;Timer0Counter >=250 mi? Yan�t EVET 
					;ise bir komut atla
	goto 	int_j1			;HAYIR ise interrupt sonu. 
	clrf 	Tmr0Sayaci		;Timer0Counter 500ms sayac�m�z� 
					;s�f�rlay�p yeniden haz�rl�yoruz.
	btfss	PORTB, 0		;PORTB'nin 0. bit�i set ise bir 
					;komut atla ( LED yan�yor ise )
    	goto	int_j2			;LED s�n�k o halde LED'i yakmak 
					;i�in int_j2'ye git.
	bcf 	PORTB, 0		;PORTB'nin 0. bit�ini s�f�rla 
					;(LED'i s�nd�r.)
	goto 	int_j1			;interrupt sonu.
int_j2
	bsf 	PORTB, 0		;RB0 pinini set et (LED'i yak.)
int_j1
	retfie				;Kesme alt program�ndan geri d�n�� 
;-------------------------------------------------------------------
; �lk i�lemler blo�u
;-------------------------------------------------------------------
ilk_islemler					
	clrf 	Tmr0Sayaci		;500ms kesme zaman say�c�s�n�n ilk 
					;de�eri atand�.
	movlw 	0xD2			;OPTION_REG kaydedicisine atanacak 
					;de�er W register�e y�klendi.
	banksel OPTION_REG		;OPTION_REG kaydedicisine ula�mak 
					;i�in BANK1 se�ildi.
	movwf 	OPTION_REG		;OPTION_REG kaydedicisine W i�eri�i 
					;aktar�ld�.
	bcf	TRISB, 0		;PORTB'nin 0. bit�i ��k��a 
					;y�nlendirildi.
	bcf 	STATUS, RP0		;BANK0 se�ildi.
	bcf 	PORTB, 0		;LED'i s�ren RB0 entegre aya�� �ase 
					;potansiyeline �ekilerek
					;LED'in ilk durumunun s�n�k olmas� 
					;sa�land�.
	movlw 	D'6'			;TMR0 i�in ilk de�er W register�ine 
					;y�klendi.
	movwf 	TMR0			;W register�indeki de�er TMR0'a 
					;aktar�ld�.
	bsf 	INTCON, D'5'		;TOIE Timer0 kesmesine izin verildi
	bsf 	INTCON, D'7'		;GIE set edilerek etkin yap�lan t�m 
					;kesmelere izin verildi.
	return				;�lk_islemler alt program�ndan 
					;��k�� yap�larak 
					;�a�r�lan yerin bir alt sat�r�ndaki 
					;komuta d�n�� yap�ld�.
;-------------------------------------------------------------------
; Ana program blo�u
;-------------------------------------------------------------------
ana_program						
	call 	ilk_islemler		;Port y�nlendirme, ilk ��k��lar, 
					;ilk zamanlama, kesme ayar ve 
					;ba�latma i�lemleri alt program� 
					;�a�r�l�yor.
ana_j1
	goto 	ana_j1			;Sonsuz bo� d�ng� i�letiliyor.  
	END				;Assembly program� sonu.
;******************************************************************

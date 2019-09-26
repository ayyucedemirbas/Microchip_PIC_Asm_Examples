list p=16F877
include "p16F877.inc"
__config h'3F39'
Tmr0sayici EQU 0x25
Tmr1sayici EQU 0x26

	ORG 0x000
clrf PCLATH
goto anaprogram
	ORG 0x004
goto kesme


kesme
	btfss INTCON,5 ;TMRO kesmesine izin verilmi� mi?
goto kesme2 ;Hay�r ise kesmesonu.
	btfss INTCON,2 ;TMR0 kesmesi olu�tu mu(TMR0IF=1 mi?)

goto kesme2 ;kesme sonu.
	movlw D'6' 
	movwf TMR0     ;TMR0'a ilk de�er atamas� yap�l�yor.
	bcf INTCON,2   ;TMR0IF kesme bayra�� siliniyor.
	incf Tmr0sayici, F ;her 2 ms'de bir kesme olu�ur.
	movlw D'250'
	subwf Tmr0sayici,w ; Tmrosayici de�erinden working registerinin de�erini ��kar�r.
	btfss STATUS, C ;Tmrocounter >=250 mi? Yan�t evet ise bir komut atla.
goto kesme2
	clrf Tmr0sayici ;Tmr0sayici 500ms say�c�m�z� s�f�rlay�p haz�rl�yoruz.
	btfss PORTD,0 ;LED yan�yor ise bir komut atla
goto ledyak ;led s�n�kse ledi yakmak i�in "ledyak" blo�una atla.
	bcf PORTD,0 ;PORTD'nin 0. bitini s�f�rla(s�nd�r)
goto kesme2
ledyak
	bsf PORTD,0

kesme2
	
	btfss PIE1,0 ;TMRO kesmesine izin verilmi� mi?
goto kesmesonu ;Hay�r ise kesmesonu.
	btfss PIR1,0 ;TMR0 kesmesi olu�tu mu(TMR0IF=1 mi?)

goto kesmesonu ;kesme sonu.
	movlw H'31' 
	movwf TMR1H
	movlw H'34'
	movwf TMR1L     ;TMR0'a ilk de�er atamas� yap�l�yor.
	bcf PIR1,0   ;TMR0IF kesme bayra�� siliniyor.
	incf Tmr1sayici, F ;her 2 ms'de bir kesme olu�ur.
	movlw D'2'
	subwf Tmr1sayici,w ; Tmrosayici de�erinden working registerinin de�erini ��kar�r.
	btfss STATUS, C ;Tmrocounter >=250 mi? Yan�t evet ise bir komut atla.
goto kesmesonu
	clrf Tmr1sayici ;Tmr0sayici 500ms say�c�m�z� s�f�rlay�p haz�rl�yoruz.
	btfss PORTD,1 ;LED yan�yor ise bir komut atla
goto led2yak ;led s�n�kse ledi yakmak i�in "ledyak" blo�una atla.
	bcf PORTD,1 ;PORTD'nin 0. bitini s�f�rla(s�nd�r)
goto kesmesonu
led2yak
	bsf PORTD,1

kesmesonu
	retfie
ilk_islemler
	clrf Tmr0sayici ;500ms kesme zaman say�c�n�n ilk de�er atamas� yap�ld�
	clrf Tmr1sayici ;
	movlw 0xD2 ; OPTION_REG'e atanacak de�er workinge at�l�yor.
	banksel OPTION_REG ; option_rege ula�mak i�in bank1 se�ildi.
	movwf OPTION_REG  ;option_rege working i�eri�i aktar�ld�.
	movlw 0x31 ;
	banksel T1CON ;
	movwf T1CON ;
	bsf STATUS, RP0 ;
	bcf TRISD,0 ; d portunun 0. biti ��k��a y�nlendirildi.
	bcf TRISD,1 ; 
	bcf STATUS, RP0
	bcf PORTD,0 ;ledin ilk durumu s�n�k
	bcf PORTD,1 ;
	
	movlw D'6' ;TMR0 i�in ilk de�er w registerine y�klendi.
	movwf TMR0
	movlw H'31'
	movwf TMR1H
	movlw H'34'
	movwf TMR1L
	bsf INTCON, D'5'
	bsf INTCON, D'7'
	bsf PIE1, D'0'

return
anaprogram
	call ilk_islemler ; ana program i�in ilk i�lemler �a��r�l�yor
sonsuzdongu
	goto sonsuzdongu ;sonsuz bo� d�ng� i�letiliyor.
end


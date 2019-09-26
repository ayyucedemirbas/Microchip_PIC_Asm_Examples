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
	btfss INTCON,5 ;TMRO kesmesine izin verilmiþ mi?
goto kesme2 ;Hayýr ise kesmesonu.
	btfss INTCON,2 ;TMR0 kesmesi oluþtu mu(TMR0IF=1 mi?)

goto kesme2 ;kesme sonu.
	movlw D'6' 
	movwf TMR0     ;TMR0'a ilk deðer atamasý yapýlýyor.
	bcf INTCON,2   ;TMR0IF kesme bayraðý siliniyor.
	incf Tmr0sayici, F ;her 2 ms'de bir kesme oluþur.
	movlw D'250'
	subwf Tmr0sayici,w ; Tmrosayici deðerinden working registerinin deðerini çýkarýr.
	btfss STATUS, C ;Tmrocounter >=250 mi? Yanýt evet ise bir komut atla.
goto kesme2
	clrf Tmr0sayici ;Tmr0sayici 500ms sayýcýmýzý sýfýrlayýp hazýrlýyoruz.
	btfss PORTD,0 ;LED yanýyor ise bir komut atla
goto ledyak ;led sönükse ledi yakmak için "ledyak" bloðuna atla.
	bcf PORTD,0 ;PORTD'nin 0. bitini sýfýrla(söndür)
goto kesme2
ledyak
	bsf PORTD,0

kesme2
	
	btfss PIE1,0 ;TMRO kesmesine izin verilmiþ mi?
goto kesmesonu ;Hayýr ise kesmesonu.
	btfss PIR1,0 ;TMR0 kesmesi oluþtu mu(TMR0IF=1 mi?)

goto kesmesonu ;kesme sonu.
	movlw H'31' 
	movwf TMR1H
	movlw H'34'
	movwf TMR1L     ;TMR0'a ilk deðer atamasý yapýlýyor.
	bcf PIR1,0   ;TMR0IF kesme bayraðý siliniyor.
	incf Tmr1sayici, F ;her 2 ms'de bir kesme oluþur.
	movlw D'2'
	subwf Tmr1sayici,w ; Tmrosayici deðerinden working registerinin deðerini çýkarýr.
	btfss STATUS, C ;Tmrocounter >=250 mi? Yanýt evet ise bir komut atla.
goto kesmesonu
	clrf Tmr1sayici ;Tmr0sayici 500ms sayýcýmýzý sýfýrlayýp hazýrlýyoruz.
	btfss PORTD,1 ;LED yanýyor ise bir komut atla
goto led2yak ;led sönükse ledi yakmak için "ledyak" bloðuna atla.
	bcf PORTD,1 ;PORTD'nin 0. bitini sýfýrla(söndür)
goto kesmesonu
led2yak
	bsf PORTD,1

kesmesonu
	retfie
ilk_islemler
	clrf Tmr0sayici ;500ms kesme zaman sayýcýnýn ilk deðer atamasý yapýldý
	clrf Tmr1sayici ;
	movlw 0xD2 ; OPTION_REG'e atanacak deðer workinge atýlýyor.
	banksel OPTION_REG ; option_rege ulaþmak için bank1 seçildi.
	movwf OPTION_REG  ;option_rege working içeriði aktarýldý.
	movlw 0x31 ;
	banksel T1CON ;
	movwf T1CON ;
	bsf STATUS, RP0 ;
	bcf TRISD,0 ; d portunun 0. biti çýkýþa yönlendirildi.
	bcf TRISD,1 ; 
	bcf STATUS, RP0
	bcf PORTD,0 ;ledin ilk durumu sönük
	bcf PORTD,1 ;
	
	movlw D'6' ;TMR0 için ilk deðer w registerine yüklendi.
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
	call ilk_islemler ; ana program için ilk iþlemler çaðýrýlýyor
sonsuzdongu
	goto sonsuzdongu ;sonsuz boþ döngü iþletiliyor.
end


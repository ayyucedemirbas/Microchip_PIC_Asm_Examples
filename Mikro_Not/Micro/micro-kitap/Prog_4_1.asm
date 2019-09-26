;*******************************************************************
;	Dosya Adý		: 4_1.asm
;	Programýn Amacý		: Timer0’ýn zamanlayýcý olarak 
;				  kullanýlmasýný göstermek.
;	PIC DK2.1a 		: PORTB<0> Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************	
	list p=16F877A
	include "p16F877A.inc"	;PIC16F877A genel tanýmlamalarý 
				;programa dahil ediliyor.
	__config H'3F31' 	;PWRT on, diðer sigortalar kapalý, 
				;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
;Deðiþken tanýmlamalarý
;-------------------------------------------------------------------
Tmr0Sayaci	equ	0x25 		;500ms zaman sayacý.
	ORG 	0			;Reset vektör adresi.
	clrf 	PCLATH			;ilk program sayfasý.
	goto 	ana_program		;Ana programa git.
	ORG 4				;Kesme vektör adresi.
;-------------------------------------------------------------------
;Kesme programý bu etiketten itibaren baþlýyor.
;-------------------------------------------------------------------
interrupt						
	btfss 	INTCON, 5		;TMR0 kesmesine izin verilmiþ mi? 
					;( TMR0IE = 1 mi? )
goto 	int_j1				;HAYIR ise interrupt sonu.
	btfss 	INTCON, 2		;TMR0 kesmesi oluþtu mu? (TMROIF = 1 mi?)
goto 	int_j1				;interrupt sonu,
	movlw 	D'6'
	movwf 	TMR0			;TMR0'a ilk deðer atamasý yapýlýyor
	bcf 	INTCON, 2		;TMROIF kesme bayraðý siliniyor.
	incf 	Tmr0Sayaci, F		;Her 2ms'de bir kesme oluþur ve 
					;Timer0Counter kesme sayýcýsý
	movlw 	D'250'			;250 deðerine ulaþana kadar her 
					;kesmede deðeri 1 artar.
	subwf 	Tmr0Sayaci, W		;250 deðerine ulaþtýðýnda 500ms'lik 
					;zamanlamaya ulaþýlmýþ olur.
	btfss 	STATUS, C		;Timer0Counter >=250 mi? Yanýt EVET 
					;ise bir komut atla
	goto 	int_j1			;HAYIR ise interrupt sonu. 
	clrf 	Tmr0Sayaci		;Timer0Counter 500ms sayacýmýzý 
					;sýfýrlayýp yeniden hazýrlýyoruz.
	btfss	PORTB, 0		;PORTB'nin 0. bit’i set ise bir 
					;komut atla ( LED yanýyor ise )
    	goto	int_j2			;LED sönük o halde LED'i yakmak 
					;için int_j2'ye git.
	bcf 	PORTB, 0		;PORTB'nin 0. bit’ini sýfýrla 
					;(LED'i söndür.)
	goto 	int_j1			;interrupt sonu.
int_j2
	bsf 	PORTB, 0		;RB0 pinini set et (LED'i yak.)
int_j1
	retfie				;Kesme alt programýndan geri dönüþ 
;-------------------------------------------------------------------
; Ýlk iþlemler bloðu
;-------------------------------------------------------------------
ilk_islemler					
	clrf 	Tmr0Sayaci		;500ms kesme zaman sayýcýsýnýn ilk 
					;deðeri atandý.
	movlw 	0xD2			;OPTION_REG kaydedicisine atanacak 
					;deðer W register’e yüklendi.
	banksel OPTION_REG		;OPTION_REG kaydedicisine ulaþmak 
					;için BANK1 seçildi.
	movwf 	OPTION_REG		;OPTION_REG kaydedicisine W içeriði 
					;aktarýldý.
	bcf	TRISB, 0		;PORTB'nin 0. bit’i çýkýþa 
					;yönlendirildi.
	bcf 	STATUS, RP0		;BANK0 seçildi.
	bcf 	PORTB, 0		;LED'i süren RB0 entegre ayaðý þase 
					;potansiyeline çekilerek
					;LED'in ilk durumunun sönük olmasý 
					;saðlandý.
	movlw 	D'6'			;TMR0 için ilk deðer W register’ine 
					;yüklendi.
	movwf 	TMR0			;W register’indeki deðer TMR0'a 
					;aktarýldý.
	bsf 	INTCON, D'5'		;TOIE Timer0 kesmesine izin verildi
	bsf 	INTCON, D'7'		;GIE set edilerek etkin yapýlan tüm 
					;kesmelere izin verildi.
	return				;Ýlk_islemler alt programýndan 
					;çýkýþ yapýlarak 
					;çaðrýlan yerin bir alt satýrýndaki 
					;komuta dönüþ yapýldý.
;-------------------------------------------------------------------
; Ana program bloðu
;-------------------------------------------------------------------
ana_program						
	call 	ilk_islemler		;Port yönlendirme, ilk çýkýþlar, 
					;ilk zamanlama, kesme ayar ve 
					;baþlatma iþlemleri alt programý 
					;çaðrýlýyor.
ana_j1
	goto 	ana_j1			;Sonsuz boþ döngü iþletiliyor.  
	END				;Assembly programý sonu.
;******************************************************************

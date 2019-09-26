;*******************************************************************
;	Dosya Adý		: 3_4.asm
;	Programýn Amacý	: Ýki kesmeyi kaynaðýný
;				  beraber kullanmak.
;	PICDK2.1a 		: PORTB Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list		p=16F877A	; Derleyici için bilgi
	#include	<P16F877A.INC>	; 877A için gerekli özel		
					; amaçlý register isim adres eþleþmeleri.
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
YEDEK_W	EQU	0x020		; Genel amaçlý adres-isim eþleþmeleri.
YEDEK_STATUS	EQU	0x021
YEDEK_PCLATH	EQU	0x022

	ORG	0x000		; Baþlangýç adresi.
	goto	ana_program	; Ana programa git.
	ORG	0x004		; Kesme vektörü adresi.
	movwf	YEDEK_W		; W register’i içeriðini YEDEK_W’ye kaydet.
	movf	STATUS,W	; STATUS’ü W ye al,
	movwf	YEDEK_STATUS	; bunu YEDEK_STATUS’e kayýt et.
	movf	PCLATH,W	; PCLATH’i W ye aktar,
	movwf	YEDEK_PCLATH	; bunu YEDEK_PCCLATH’a kaydet.

kesme 
	btfsc	INTCON, TMR0IF	; Eðer TMR0IF “1” ise TMR0  kesme
				; bayraðý çekilmiþ demektir.
				; Satýrý atlama, tmr0_int adresine
				; git. Eðer bayrak çekili deðilse
goto	tmr0_int		; tmr1 kesmesi olmalýdýr. tmr1_int
				; adresinden program çalýþmaya 
				; devam eder.
tmr1_int
	bcf	PIR1,TMR1IF		; Artýk bayrak ile iþimiz 
					; bitti, kapatabiliriz.
	btfsc	PORTB,1			; PORTB'nin 1. bit’ine baðlý LED 
					; yanýyorsa kapatma
	goto	portb1sýfýryap		; programýný çaðýr. Kapalýysa 
					; devam et ve
	bsf	PORTB,1			; PORTB'yi "1" durumuna getir ve
	goto	kesme_bitir		; kesmeden çýkmaya hazýrlan.
portb1sýfýryap
	bcf	PORTB,1			; PORTB'yi "0 durumuna getir ve
	goto	kesme_bitir		; kesmeden çýkmaya hazýrlan.
tmr0_int					
	bcf	INTCON,TMR0IF		; TMR0IF bayraðýný kapatabiliriz.
	btfss	PORTB,0			; PORTB'nin 0. bit’i 0 mý 1 mi?
	goto	portb0setet		; 1 ise 0 yapan yere git.
	goto	portb0sýfýryap		; 0 ise 1 yapan yere git.
portb0setet				
	bsf	PORTB,0			; LED'i yak.
	goto	kesme_bitir		; Kesmeden çýkmaya hazýrlan.
portb0sýfýryap
	bcf	PORTB,0			; LED'i söndür.
					; Nasýl olsa programýn sonundayýz,
					; burada goto kesme_bitir'e gerek yok 
kesme_bitir
	movf	YEDEK_PCLATH, W 	; Kesme öncesi kopyayý W’ye al.
	movwf	PCLATH			; Bunu PCLATH’a kopyala.
	movf	YEDEK_STATUS, W 	; Kesme öncesi STATUS’ü W’ye al,
	movwf	STATUS			; bunu STATUS’e kopyala.
	swapf	YEDEK_W, F		; Dört bit’in yerini deðiþtir.
	swapf	YEDEK_W, W		; Tekrar çevir fakat W’ye kaydet.
	retfie				; Kesmeden geri dön.
;-------------------------------------------------------------------
 ana_program
;-------------------------------------------------------------------
	movlw	b'11100000'		; GIE’yi PEIE’yi ve TMR0IEyý “1”
	movwf	INTCON			; yap.Böylece TMR0 kesmesi açýlsýn.
	movlw	b'11110001'		; T1CON registeri ile TMR1 zamanlayý
	movwf	T1CON			; cýsýnýn “0” lanma süresini ayarla
	bsf	STATUS,RP0		; BANK1’e geç.
	movlw	b'10000111'		; TMR0 zamanlayýcýsýnýn ön çarpanýn
	movwf	OPTION_REG		; ný ayarla RB pull-uplarýný kapat.
	bsf	PIE1,0			; TMR1 kesmesini aç.
	movlw	b'11111100'		; PORTB’nin son iki bit’i çýkýþ, 
	movwf	TRISB			; diðer bit’leri giriþ olsun.
	bcf	STATUS,RP0		; BANK0’a geç.
dongu					 
	goto	dongu			; Sonsuz döngüye devam et.
	end
;*************************	****************************************

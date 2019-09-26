;******************************************************************
;	Dosya Adý		: 4_7.asm
;	Programýn Amacý		: WDT uygulamasý.
;	PICDK2.1a 		: PORTB Çýkýþ ==> LED
;				: PORTA Dijital Giriþ <== BUTON
;				: XT ==> 4Mhz
;*****************************************************************
	list		p=16F877A	; Derleyici için bilgi
	#include	<P16F877A.INC>	; 877A için gerekli isim-							
					; adres eþleþmeleri.
	__config H'3F31' 		; PWRT on, diðerleri kapalý, 
					; Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Genel deðiþken tanýmlamalarý.
;-------------------------------------------------------------------
YEDEK_W	EQU	0x020			; Yedekleme register’larý.
YEDEK_STATUS	EQU	0x021
YEDEK_PCLATH	EQU 	0x022
hata_kayit_reg	EQU	0x025		; Kaç kere hata yapýldýðýný sayar. 
;-------------------------------------------------------------------	
	ORG	0x000			; Baþlangýç adresi.
	goto	ana_program		; Ana programa git.
	ORG	0x004			; Kesme vektörü adresi.
;-------------------------------------------------------------------
; PCLATH, W ve STATUS register’ýný yedekleme bölümü.
;-------------------------------------------------------------------
	movwf	YEDEK_W			;W register’i içeriðini YEDEK_W’ye kaydet.
	movf	STATUS,W		; STATUS’ü W ye al.
	movwf	YEDEK_STATUS		; Bunu YEDEK_STATUS’e kayýt et.
	movf	PCLATH,W		; PCLATH’i W ye aktar,
	movwf	YEDEK_PCLATH		; bunu YEDEK_PCCLATH’a kaydet.
;-------------------------------------------------------------------
; Kesme alt programý: TMR1'e ait her kesmede PORTB=1’se “0”,
; PORTB=0’sa “1” yapar.
;-------------------------------------------------------------------
kesme
	bcf	PORTB,6			; Sýfýrlama belirtme LED'i.
	bcf	PIR1,TMR1IF		; Artýk bayrak ile iþimiz 
					; bitti, kapatabiliriz.
	btfsc	PORTB,7			; PORTB'nin 1. bit’ine baðlý LED 
					; yanýyorsa kapatma
	goto	portb1sýfýryap		; programýný çaðýr, kapalýysa 
					; devam et ve
	bsf	PORTB,7			; PORTB'yi "1" durumuna getir ve
	goto	kesme_bitir		; kesmeden çýkmaya hazýrlan.
portb1sýfýryap
	bcf	PORTB,7			; PORTB'yi "0 durumuna getir.
;------ Yedekteki PCLATH, W ve STATUS registerini geri yüklemek-----
kesme_bitir
	movf	YEDEK_PCLATH, W 	; Kesme öncesi kopyayý W’ye al,
	movwf	PCLATH			; bunu PCLATH’a kopyala.
	movf	YEDEK_STATUS, W 	; Kesme öncesi STATUS’ü W’ye al,
	movwf	STATUS			; bunu STATUS’e kopyala.
	swapf	YEDEK_W, F		; Dört bit’in yerini deðiþtir,
	swapf	YEDEK_W, W		; tekrar çevir fakat W’ye kaydet. 
	retfie				; Kesmeden geri dön.
;-------------------------------------------------------------------
; Ana program: Port yönlendirme, Zamanlayýcý ayarý ve ana program 
; döngüsü burada.
;-------------------------------------------------------------------
ana_program
	clrf	PORTA			; PORTA'yý temizle.
	clrf	PORTB			; PORTB'yi temizle.
	movlw	b'11110001'	
	movwf	T1CON			; TMR1 zamanlayýcýsýný kur.
	movlw	b'11000000'		; TMR1 kesmesi için uygun bit’leri
	movwf	INTCON			; aktif duruma getir.
	movlw	b'00001111'		; WDT zamanlayýcýsýnýn çarpanýný
	movwf	OPTION_REG  		;111 olarak belirleyerek 2.3 sn de sýfýrla.
	bsf	STATUS,RP0		; BANK1’e geç.
	bsf	PIE1,0			; TMR1 kesmesini aç.
	movlw	b'00000000'		; PORTB çýkýþ.
	movwf	TRISB
	movlw	b'11111111'		; PORTA giriþ.
	movwf	TRISA		
	movlw	b'00000111'		; PORTA dijital giriþ
	movwf	ADCON1			; olacak þekilde ADCON1 ayarlandý.
	bcf	STATUS,RP0		; BANK0’a geç.
	btfss	STATUS,4		;STATUS,ün 4. bit’i 1 ise buraya WDT 
					;sýfýrlamasý ile gelinmiþ demektir o zaman 
					;hata sayýsýný bir artýr. 
	incf	hata_kayit_reg,f	; Hata kaydý için bir bellek
					; adresine kaç kez
	movfw	hata_kayit_reg		; hata yapýldýðý kayýt edilir,
	xorwf	PORTB,F			; bu deðer PORTB'de görüntülenir.
	bsf	PORTB,6			; PORTB'nin 6 bit’ini 1 yap,
					; sýfýrlamanýn anlaþýlmasý
					; için... ilk kesmede 0 yapýlacaktýr.
dongu
	btfsc	PORTA,1			; PORTA'nýn 1. bit’ine baðlý olan 
					; RA0 isimli düðmeye basýlmadýðý
	clrwdt				; sürece WDT sayacý sýfýrlanýr.
	goto	dongu			; Eðer tuþa basýlmazsa WDT saymaya baþlar.
					; Eðer belirlenen süreden uzun bir süre 
					; tuþa basýlýrsa WDT taþar ve 
					; mikrodenetleyici sýfýrlanýr.
hata_kayit				
	return	
	end
;******************************************************************

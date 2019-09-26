;*******************************************************************
;	Dosya Adý		: 11_5_b.asm
;	Programýn Amacý		: Baþka bir PIC’den USART ile senkron veri 
;	alýmý
;	PIC DK2.1a 		: PORTB<4:7> Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list	p=16f628A
	#include <p16F628A.inc>

	__CONFIG   	_CP_OFF & _DATA_CP_OFF & _LVP_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT
;-------------------------------------------------------------------
; Deðiþken tanýmlama
;-------------------------------------------------------------------
	cblock	0x20
	temp
	endc

	ORG	0x000
	goto	main
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
main
	call	initilize
loop
	call	snkSlaveRead		;Veri oku.
	movwf	temp			;Geçici deðiþkene al.
	sublw	0xFF			;Okunan veriyi 0xFF ile 
					;karþýlaþtýr, Hatalý veri mi?
	btfsc	STATUS, Z		;Veri hatasýz ise komut atla.
	goto	loop			;Okunan veri hatalý, baþa dön.
	swapf	temp, W			;Okunan verinin (tuþun) kodunu 
					;W'nin en deðerli 4 bit’ine taþý.
	movwf	PORTB			;Sonucu PORTB'de görüntüle.
	goto	loop			;Baþa dön.

initilize
	clrf	PORTB			;PORTB'nýn ilk çýkýþlarý sýfýrlandý
	banksel TRISB			;TRISB ve TXSTA BANK1'de.
	movlw	b'00000110'
	movwf	TRISB			;RB1/RX/DT ve RB2/TX/CK pinlerini 
					;giriþe ayarla.
					;Usart modülü Senkron Slave Moduna alýnýyor.
	bsf	TXSTA, SYNC		;Usart modülü senkron iletiþime 
					;ayarlandý.
	banksel RCSTA
	bsf	RCSTA, SPEN		;Seri portun açýldý.
	banksel TXSTA			;TXSTA ve PIE1 BANK1'de.
	bcf	TXSTA, CSRC		;Senkron Slave Mod seçildi.
	bsf	PIE1, RCIE		;Veri alma kesmesi aktifleþtirildi.
	banksel RCSTA
	bcf	RCSTA, RX9		;8 bit veri alýmý.
	return

snkSlaveRead
					;Aþaðýdaki durum atamalarý sýralý olmalý.
	banksel RCSTA
	bsf	RCSTA, SPEN		;Seri portun her seferinde 
					;öncelikle yeniden açýlmasý ;gerekiyor.
	banksel TXSTA
	bcf	TXSTA, CSRC		;Veri alma iþleminden sonra set 
					;oluyor ve Master moda geçiyor, 
					;dolayýsýyle Slave mod için 
					;silinmeli.
	banksel RCSTA			;RCSTA, PIR1 ve RCREG BANK0'da.
	bsf	RCSTA, CREN		;Sürekli alma modu açýldý, almada 
					;hata oluþursa bu bit resetleniyor, 
					;hata olma durumuna karþý set 
					;edilmeli.
	btfss	PIR1, RCIF		;Alma iþlemi tamamlanana kadar 
	goto	$-1			;bekle.
	movf	RCREG, W		;Alýnan veriyi W'ye yaz.
	bcf	PIR1, RCIF		;Alma bayraðýný yeni veri alýmý 
					;için resetle.
	btfsc	RCSTA, CREN		;Hata varsa komut atla.
	return				;Hata yoksa normal çýkýþ (W'de 
					;alýnan veri var).
	retlw	0xFF			;Veri almada hata oluþtu 0xFF hata 
					;kodu döndür (W'de 0xFF var).

	END
;*******************************************************************

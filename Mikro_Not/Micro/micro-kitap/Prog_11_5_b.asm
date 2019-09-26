;*******************************************************************
;	Dosya Ad�		: 11_5_b.asm
;	Program�n Amac�		: Ba�ka bir PIC�den USART ile senkron veri 
;	al�m�
;	PIC DK2.1a 		: PORTB<4:7> ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list	p=16f628A
	#include <p16F628A.inc>

	__CONFIG   	_CP_OFF & _DATA_CP_OFF & _LVP_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT
;-------------------------------------------------------------------
; De�i�ken tan�mlama
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
	movwf	temp			;Ge�ici de�i�kene al.
	sublw	0xFF			;Okunan veriyi 0xFF ile 
					;kar��la�t�r, Hatal� veri mi?
	btfsc	STATUS, Z		;Veri hatas�z ise komut atla.
	goto	loop			;Okunan veri hatal�, ba�a d�n.
	swapf	temp, W			;Okunan verinin (tu�un) kodunu 
					;W'nin en de�erli 4 bit�ine ta��.
	movwf	PORTB			;Sonucu PORTB'de g�r�nt�le.
	goto	loop			;Ba�a d�n.

initilize
	clrf	PORTB			;PORTB'n�n ilk ��k��lar� s�f�rland�
	banksel TRISB			;TRISB ve TXSTA BANK1'de.
	movlw	b'00000110'
	movwf	TRISB			;RB1/RX/DT ve RB2/TX/CK pinlerini 
					;giri�e ayarla.
					;Usart mod�l� Senkron Slave Moduna al�n�yor.
	bsf	TXSTA, SYNC		;Usart mod�l� senkron ileti�ime 
					;ayarland�.
	banksel RCSTA
	bsf	RCSTA, SPEN		;Seri portun a��ld�.
	banksel TXSTA			;TXSTA ve PIE1 BANK1'de.
	bcf	TXSTA, CSRC		;Senkron Slave Mod se�ildi.
	bsf	PIE1, RCIE		;Veri alma kesmesi aktifle�tirildi.
	banksel RCSTA
	bcf	RCSTA, RX9		;8 bit veri al�m�.
	return

snkSlaveRead
					;A�a��daki durum atamalar� s�ral� olmal�.
	banksel RCSTA
	bsf	RCSTA, SPEN		;Seri portun her seferinde 
					;�ncelikle yeniden a��lmas� ;gerekiyor.
	banksel TXSTA
	bcf	TXSTA, CSRC		;Veri alma i�leminden sonra set 
					;oluyor ve Master moda ge�iyor, 
					;dolay�s�yle Slave mod i�in 
					;silinmeli.
	banksel RCSTA			;RCSTA, PIR1 ve RCREG BANK0'da.
	bsf	RCSTA, CREN		;S�rekli alma modu a��ld�, almada 
					;hata olu�ursa bu bit resetleniyor, 
					;hata olma durumuna kar�� set 
					;edilmeli.
	btfss	PIR1, RCIF		;Alma i�lemi tamamlanana kadar 
	goto	$-1			;bekle.
	movf	RCREG, W		;Al�nan veriyi W'ye yaz.
	bcf	PIR1, RCIF		;Alma bayra��n� yeni veri al�m� 
					;i�in resetle.
	btfsc	RCSTA, CREN		;Hata varsa komut atla.
	return				;Hata yoksa normal ��k�� (W'de 
					;al�nan veri var).
	retlw	0xFF			;Veri almada hata olu�tu 0xFF hata 
					;kodu d�nd�r (W'de 0xFF var).

	END
;*******************************************************************

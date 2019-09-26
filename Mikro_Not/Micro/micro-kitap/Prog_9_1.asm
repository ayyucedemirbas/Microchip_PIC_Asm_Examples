;*******************************************************************
;	Dosya Ad�		: 9_1.asm
;	Program�n Amac�		: Dahili eeprom belle�e veri yazma ve okuma
;	PIC DK2.1a 		: PORTB ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F39' 		;T�m program sigortalar� kapal�, 
					;Osilat�r XT ve 4Mhz
	ORG 	0			;Reset vekt�r adresi.
	clrf 	PCLATH			;0. Program sayfas� se�ildi.
	goto 	ana_program		;ana_programa'a git.
	
	ORG	4			;Kesme vekt�r adresi.
Kesmeler				;Kesme kullan�m� gerekiyorsa 
					;buradan itibaren yaz�lmal�. 
					;ya da goto komutu ile buradan y�nlendirilmeli.
	retfie
;-------------------------------------------------------------------
; Dahili EEPROM'a veri yazma alt program�:
; �a�r�lmadan �nce EEADR kaydedicisine yaz�lacak adres, EEDATA 
; kaydedicisine ise yaz�lacak veri y�klenmeli.
;-------------------------------------------------------------------
dahili_EEPROM_yaz
	banksel EECON1			;EECON1'in bulundu�u BANK se�ildi.
	bcf	INTCON, GIE		;Genel kesmeler pasif. (Yazmada 
					;i�lem ak��� bozulmamal�.)
	bsf	EECON1, WREN		;Yazma etkinle�tirme bit�i set 
					;edildi.
	movlw	0x55			;Yazma i�in buradan itibaren 5 
					;sat�r aynen korunmal�.
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR		;Yaz komutu verildi.
	bsf	INTCON, GIE		;Genel kesmeler aktif. (Kesme 
					;kullan�lmayacaksa silinebilir.)
dahili_ee_j1
	btfsc 	EECON1, WR		;Yazma i�lemi tamamlanana kadar 
					;bekle (WR=0 olana kadar).
	goto 	dahili_ee_j1
	bcf 	EECON1, WREN		;Yazma izni kald�r�ld�.
	return
;-------------------------------------------------------------------
; Dahili EEPROM'dan veri okuma alt program�: �a�r�lmadan �nce EEADR 
; kaydedicisine okunacak verinin adresi y�klenmeli.
;-------------------------------------------------------------------
dahili_EEPROM_oku
	banksel EECON1
	bsf	EECON1, RD
	banksel EEDATA
	movf	EEDATA, W
	return
;-------------------------------------------------------------------
; Ana program: 0x0A dahili EEPROM adresine 0x97 bilgisi y�kleniyor,
; Daha sonra ayn� adresten veri okunarak PORTB'deki LED'lerde 
; g�r�nt�leniyor.
;-------------------------------------------------------------------
ana_program
	banksel TRISB			;BANK1 se�ildi, TRISB bu bankta.
	clrf	TRISB			;PORTB pinleri ��k��a ayarland�.
	banksel PORTB			;BANK0 se�ildi, PORTB bu bankta.
	clrf	PORTB			;�lk anda LED'ler s�n�k.
	movlw	0x0A			;Yaz�lacak Dahili EEPROM adresi
	banksel EEADR			;EEADR kaydedicisi i�in BANK 
					;se�ildi.
	movwf 	EEADR			;Adres bilgisi y�klendi.
	movlw	0x97			;Yaz�lacak veri.
	movwf	EEDATA			;Veri y�klendi.
	call	dahili_EEPROM_yaz	;Yazma alt program�n� �a��r.
	banksel EEADR			;EEADR kaydedicisi i�in BANK 
					;se�ildi.
	movlw	0x0A			;Okunacak Dahili EEPROM adresi.
	movwf	EEADR			;Adres bilgisi y�klendi.
	call	dahili_EEPROM_oku	;Okuma alt program�n� �a��r.
	banksel PORTB			;BANK0'a ge�.
	movwf	PORTB			;Okunan de�eri LED'lerde g�r�nt�le.
ana_j1
	goto	ana_j1			;Sistem kapat�lana yada resetlenene 
					;kadar bo� d�ng�.
	END
;*******************************************************************

;*****************************************************************
;	Dosya Ad�		: 10_1.asm
;	Program�n Amac�		: PSP kullan�m�
;	Notlar 			: Proteus program� sim�lasyonu
;				: XT ==> 20Mhz
;*******************************************************************
	list p = 16F877A
	include "p16F877A.inc"
	__config H'3F3A' 		;T�m program sigortalar� kapal�, 
					;Osilat�r HS ve 20Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�
;-------------------------------------------------------------------
#define PSP_errorFlag	7
#define PSP_inputFlag	6
#define PSP_outputFlag	5

PSP_CtrlByte		equ 0x20
PSP_inputBuffer		equ 0x21
PSP_outputBuffer	equ 0x21

	ORG	0
	clrf	PCLATH
	goto	Ana_Program

	ORG	4
;-------------------------------------------------------------------
; PSP'den gelen kesmeleri i�ler. Veri al�nd� ise al�nan veriyi 
; PSP_inputBuffer'a yazar ve verinin al�nd���na dair PSP_inputFlag 
; bayra��n� set eder. Master cihazdan okuma komutu geldi ise ve 
; g�nderilecek bir veri daha �nceden PSP_outputBuaffer'a yaz�ld� ise 
; Master cihaza PORTD �zerinden veriyi transfer eder. Ve Verinin 
; haz�r oldu�unu belirten PSP_outputFlag bayra�� siler.
;-------------------------------------------------------------------
interrupt
	banksel PIR1
	btfss	PIR1, PSPIF		;PSP kesmesi olu�tu ise (veri geldi 
					;ya da veri g�nderildi ise) komut 
					;atla.
	goto	int_son			;Kesme sonuna git ve kesmeden ��k.
	banksel TRISE
	btfss	TRISE, IBF		;Veri al�nd� ise komut atla.
	goto	int_j1
	banksel PSP_CtrlByte
	bsf	PSP_CtrlByte, PSP_inputFlag	;Veri al�nd� bayra��n� 
						;set et.
	movf	PORTD, W			;Gelen veriyi W'ye al. 
	movwf	PSP_inputBuffer			;W'yi giri� buffer de�i�kenine 
						;aktar.
int_j1
	banksel TRISE				;Bank1'e ge�.
	btfss	TRISE, OBF			;Veri g�nderildi ise komut atla.
	goto	int_j2
	banksel PSP_CtrlByte			;Bank0 se�ildi, bu de�i�ken ve 
						;PORTD ayn� bankda.
	btfss	PSP_CtrlByte, PSP_outputFlag	;veri g�nderme bayra�� 
						;set ise komut atla.
	goto	int_j2
	movf	PSP_outputBuffer, W		;��k�� buffer de�i�kenine 
						;y�klenen veriyi
	movwf	PORTD				;PORD'ye g�nder.
	bcf	PSP_CtrlByte, PSP_outputFlag	;Veri g�ndermeye haz�r 
						;bayra��n� sil.
int_j2
	banksel TRISE				;Bank1'e ge�.
	btfss	TRISE, IBOV			;PSP'de hata olu�tuysa komut atla.
	goto	int_son
	banksel PSP_CtrlByte
	bsf	PSP_CtrlByte, PSP_errorFlag	;Hata bayra��n� set et
	bcf	TRISE, IBOV	
	bcf	PIR1, PSPIF			;PSP kesme bayra��n� sil.
int_son
	retfie	
;-------------------------------------------------------------------
; PSP ileti�imi ayarlar, portlar� y�nlendirir ve kesmeleri 
; aktifle�tirerek PSP ileti�imi ba�lat�r.
;-------------------------------------------------------------------
init
	banksel TRISE			;Bank1'e ge�ildi.
	movlw	B'00110111'
	movwf	TRISE			;PSPMODE aktif hale getirildi, RD, 
					;WR ve CS u�lar� giri� yap�ld�.
	clrf	TRISB			;PORTB ��k�� yap�ld�.
	movlw	0x07
	movwf	ADCON1			;Analog giri�ler kapat�ld�. 
					;PORTE'nin RD, WR ve CS giri�leri 
					;i�in
	banksel PORTB			;Bank0'a ge�ildi.
	clrf	PORTB			;PORTB'nin ilk ��k��lar� LOW 
					;yap�ld�.
	clrf	PSP_CtrlByte		;PSP de�i�kenlerinin ilk durumu 
					;s�f�rlan�yor.
	clrf	PSP_inputBuffer
	clrf	PSP_outputBuffer
	banksel PIE1
	bsf	PIE1, PSPIE		;Paralel Slave Port kesmesi 
					;etkinle�tirildi.
	bsf	INTCON, PEIE		;�evresel kesmeler etkinle�tirildi.
	bsf	INTCON, GIE		;Etkinle�tirilen kesmelere izin
					;verildi.
	return
;-------------------------------------------------------------------
; Ana program PSP'den yazma sinyali geldi�inde gelen veriyi al�r ve 
; PORTB �zerinde ba�l� olan LED�ler �zerinde g�r�nt�ler. Veri okuma 
; k�sm� uygun bir master cihaz kullan�lmad��� ve kurulan devremiz 
; uygun olmad��� i�in bo� b�rak�lm��t�r, fakat gerekli ipucu 
; verilmi�tir.
;-------------------------------------------------------------------
Ana_Program
	call	init
ana_j1
	banksel PSP_CtrlByte
	btfss	PSP_CtrlByte, PSP_inputFlag
	goto	ana_j2
	movf	PSP_inputBuffer, W
	movwf	PORTB
	bcf	PSP_CtrlByte, PSP_inputFlag	;Veri al�nd� bayra��n� 
						;sil.
ana_j2
	btfsc	PSP_CtrlByte, PSP_outputFlag	;��k�� verisi haz�r 
						;bayra�� s�f�r ise 
						;komut atla.
	goto	ana_j1

;Buraya g�nderilecek veriyi ��k�� buffer de�i�kenine yazan kodlar 
;eklenecek. �rne�in sayac diye bir de�i�ken i�eri�ini ��k��a 
;transfer etmek istersek

	;movf	sayac, W
	;movwf	PSP_outputBuffer		

;sayac i�eri�i ��k�� buffer'�na yaz�ld�, g�nderilmek i�in beklemede

	bsf	PSP_CtrlByte, PSP_outputFlag	;Veri g�nderme 
;bayra��n� set et 
;(veri g�nderilmeye haz�r).

;E�er MASTER cihazdan okuma (RD) sinyali gelirse TRISE'nin OBF bit�i 
;set olur, kesmede ilgili k�s�m �al���r. PSP_outputBuffer'a y�klenen 
;veri kesme i�erisinden Master cihaza g�nderilir ve PSP_outputFlag 
;bayra�� silinir.
	goto	ana_j1

	END
;*******************************************************************

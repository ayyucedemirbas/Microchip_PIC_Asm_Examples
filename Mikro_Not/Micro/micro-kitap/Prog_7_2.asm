;*******************************************************************
;	Dosya Ad�		: 7_2.asm
;	Program�n Amac�		: A/D mod�l� ile �s� �l��m� (LM35 ile)
;	PIC DK2.1a 		: PORTB ��k�� ==> 7 segment display�ler
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A	
	include "p16F877A.inc"	
	__config H'3F31' 	;PWRT on, di�erleri kapal�,
				;Osc:XT ve 4Mhz
;-------------------------------------------------------------------
; De�i�ken tan�mlar� yap�l�yor.
;-------------------------------------------------------------------	
CBLOCK	0x20		;16F877A'n�n RAM ba�lang�� adresi, 
			;de�i�kenler burada.
	sira		;display s�ras�n� belirler.
	HexLSB		;�evrilecek say�n�n en de�ersiz byte'�.
	onlar		;�evrilen say�n�n onlar basama�� burada.
	birler		;�evrilen say�n�n birler basama�� burada.
	Timer5ms	;5 ms sayac�.
	Timer1s		;1sn sayac�.
	TimeCtrl	;Zaman kontrol laydedicisi
	ENDC

	ORG 	0
	pagesel Ana_program		;ana program�n bulundu�u program 
					;sayfas� se�ildi.
	goto 	Ana_program		;ana programa git.
	ORG 	4			;Kesme alt program� bu adresten 
					;ba�l�yor.
	goto	kesme
;-------------------------------------------------------------------
; 1 byte binary veriyi bcd'ye d�n��t�r�r. Sonu� onlar ve birler 
; de�i�kenlerinde saklan�r.0'dan 99'a kadar olan desimal say� 
; d�n���m� yapar, 99'u a�an de�erler i�in uygun de�ildir.
;------------------------------------------------------------------- 
HexToDec
	clrf onlar			;onlar = 0
	clrf birler			;birler = 0
onlar_kont
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, W		;HexLSB'den 10 ��kart.
	btfss	STATUS, C		;sonu� >= 10 mu?
	goto	birler_kont		;hay�r ise birleri kontrol et.
	incf	onlar, F		;evet ise onlar� bir art�r.
	movlw	0x0A			;W = 0x0A (10)
	subwf	HexLSB, F		;HexLSB'den 10 ��kart.
	goto	onlar_kont		;onlar'� yeniden kontrol et.
birler_kont
	movf	HexLSB, W		;W = HexLSB
	movwf	birler			;birler = W, d�n���m i�lemi tamam.
	return				;alt programdan ��k.
;-------------------------------------------------------------------
; Is� d�n���m�n� ger�ekle�tirir ve desimale d�n��t�r�r.
;------------------------------------------------------------------- 
IsiOlc
	Banksel ADCON0			;BANK0'a ge�, ADCON0 bu bankta.
	bsf	ADCON0, GO		;Is� d�n���m�n� ba�lat.
	btfsc	ADCON0, GO		;D�n���m tamamlanana kadar bekle.
	goto	$ - 1
	bcf	STATUS, C
	rrf	ADRESH, F
	banksel ADRESL			;ADRESL BANK1'de.
	rrf	ADRESL, W
	banksel HexLSB			;BANK0'a ge�.
	movwf	HexLSB
	call	HexToDec
	return
;-------------------------------------------------------------------
; Her 5 ms'de bir display'leri tarayarak g�r�nt� olu�turur.
;------------------------------------------------------------------- 
DisplaydeGoster
display1
	incf	sira, F		;Taranacak display s�ras�n� se�iliyor.
	movlw	.1
	subwf	sira, W
	btfss	STATUS, Z	;1. display mi taranacak?
	goto	display2	;Hay�r ise 2. display i�in kontrol yap.
	movlw	0x0A		;C i�areti i�in.
	iorlw	0x10		;1. display s�rme bilgisi ve de�eri W'de.
	movwf	PORTB		;1. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display2
	movlw	.2
	subwf	sira, W
	btfss	STATUS, Z	;2. display mi taranacak?
	goto	display3	;Hay�r ise 3. display i�in kontrol yap.
	movf	birler, W
	iorlw	0x20		;2. display s�rme bilgisi ve de�eri W'de.
	movwf	PORTB		;2. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display3
	movlw	.3
	subwf	sira, W
	btfss	STATUS, Z	;3. display mi taranacak?
	goto	display4	;Hay�r ise 4. display i�in kontrol yap.
	movf	onlar, W
	iorlw	0x40		;3. display s�rme bilgisi ve de�eri W'de
	movwf	PORTB		;3. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display4
	movlw	.4
	subwf	sira, W
	btfss	STATUS, Z	;4. display mi taranacak?
	goto	display5	;Hay�r ise sirayi 1. display i�in ayarla 
				;ve uygula.
	movlw	0x0F		;Display'de bi�ey g�r�nmez.
	iorlw	0x80		;4. display s�rme bilgisi ve de�eri W'de.
	movwf	PORTB		;4. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display5
	clrf	sira		;sira de�erini s�f�rla ve
	goto	display1	;tekrar bir art�rarak kontrol i�in ba�a.
disp_son
	return
;-------------------------------------------------------------------
; Kesme program� (kullan�lacak ise LCD ya da zamanlaman�n �nemli
; oldu�u cihazlarla �al���rken ileti�imin kesilmemesine dikkat 
; ediniz).
;------------------------------------------------------------------- 
kesme
	btfss	INTCON, T0IE		;TMR0 kesmesi etkinse bir 
					;komut atla.
	goto	int_son			;hay�rsa kesmeden ��k.
	btfss	INTCON, T0IF		;TMR0 kesmesi olu�tu mu? T0IF =? 1	
	goto	int_son			;hay�rsa kesmeden ��k.
	movlw	0x06
	movwf	TMR0
	incf	Timer5ms, F
	movlw	.5
	subwf	Timer5ms, W
	btfss	STATUS, Z
	goto	int_son
	clrf	Timer5ms		;5 ms doldu.
	bsf	TimeCtrl, 0		;5 ms bayra�� set oldu.
	incf	Timer1s, F		;1 sn sayac�n� art�r, de�eri 200 
					;oldu�unda 1 sn ge�mi�tir.
					;bu durumda saya� art�r�lacak.
	movlw	.200
	subwf	Timer1s, W
	btfss	STATUS, C
	goto	int_son
	clrf	Timer1s			;1 sn doldu.
	bsf	TimeCtrl, 1		;1 sn bayra�� set oldu.
int_son
	bcf	INTCON, T0IF		;Kesme bayra��n� sil.
	retfie
;-------------------------------------------------------------------
; Ana program
;------------------------------------------------------------------- 
Ana_program	
	movlw	0xD1			;RB pull-up pasif, TMR0 i�in clock 
					;kayna�� intrenal clock
	option				;1:4 prescaler de�er se�ildi.
	banksel	TRISB			;BANK1 se�ildi.
	clrf	TRISB			;PORTB ��k�� yap�ld�.
	movlw	0x8E					
	movwf	ADCON1			;Is� sonu� sa�a dayal� ve RA0 
					;analog giri�, di�erleri dijital.
	banksel	PORTB			;BANK0 se�ildi.
	clrf	PORTB			;PORTB ��k��lar� s�f�rland�.
	movlw	0x81
	movwf	ADCON0			;Fosc/32, 0. Kanal se�ildi ve AD 
					;mod�l� a��ld�.
	clrf	HexLSB			;�lk durumda �s� de�eri s�f�r 
					;kabul edildi.
	call	HexToDec
	clrf	sira			;sira = 0, �u an herhangi bir 
					;display�i i�aret etmiyor.
	clrf	Timer5ms		;5ms sayac� s�f�rland�.
	clrf	Timer1s			;1sn sayac� s�f�rland�.
	clrf	TimeCtrl		;Zaman kontrol kaydedicisi 
					;s�f�rland�.
	movlw	0x06
	movwf	TMR0			;TMR0�a ilk de�eri verildi.

	bsf	INTCON, T0IE		;TMR0 kesmesi etkin hale getirildi.
	bsf	INTCON, GIE		;Etkinle�tirilen t�m kesmelere 
					;izin verildi.
Ana_j1:
	btfss	TimeCtrl, 0		;5 ms s�re ge�ti mi?
	goto	Ana_j2			;1 sn bayra��n� kontrol et.
	bcf	TimeCtrl, 0		;5 ms bayra��n� sil.
	call	DisplaydeGoster		;Display tara.
Ana_j2
	btfss	TimeCtrl, 1		;1 sn s�re ge�ti mi?
	goto	Ana_j1			;5 ms bayra��n� kontrol et.
	call	IsiOlc			;Is� �l� ve d�n��t�r.
	bcf	TimeCtrl, 1		;1 sn bayra��n� sil.
	goto	Ana_j1			;Sistem kapat�lana ya da 
					;resetlenene kadar bo� d�ng�
					;Bu d�ng� s�ras�nda 5ms'de bir 
					;kesme �al���yor.
	END
;*******************************************************************

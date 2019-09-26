;*******************************************************************
;	Dosya Ad�		: 11_2.asm
;	Program�n Amac�		: 4 dijit 7 segment display uygulamas�
;	PIC DK2.1a 		: PORTB ��k�� ==> 7 segment display
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osc:XT ve 4Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlar� yap�l�yor.
;-------------------------------------------------------------------	
CBLOCK	0x20			;16F877A�n�n RAM ba�lang�� adresi, 
				;de�i�kenler burada.
		sayacH		;sayac�n y�ksek byte'�.
		sayacL		;sayac�n d���k byte'�.
		sira		;Display s�ras�n� belirler.

		HexMSB		;�evrilecek say�n�n en de�erli byte'�.
		HexLSB		;�evrilecek say�n�n en de�ersiz byte'�.
		binler		;�evrilen say�n�n binler basama�� burada.
		yuzler		;�evrilen say�n�n y�zler basama�� burada.
		onlar		;�evrilen say�n�n onlar basama�� burada.
		birler		;�evrilen say�n�n birler basama�� burada.

		Timer5ms	;5 ms sayac�.
		Timer1s		;1 sn sayac�.
		TimeCtrl	;Zaman kontrol kaydedicisi.
	ENDC

	ORG 	0 
	pagesel Ana_program		;Ana program�n bulundu�u program 
					;sayfas� se�ildi.
	goto 	Ana_program
	ORG 	4			;Kesme alt program� bu adresten	goto	kesme	
					;ba�l�yor.
;-------------------------------------------------------------------
; 2 byte binary veriyi bcd koda d�n��t�r�r. Sonu� binler, y�zler,
; onlar ve birler de�i�kenlerinde saklan�r.
;-------------------------------------------------------------------
HexToDec
	clrf binler		;binler = 0
	clrf yuzler		;yuzler = 0
	clrf onlar		;onlar = 0
	clrf birler		;birler = 0
binler_kont
	movlw	04h		;W�ye 1024 (0x0400) say�s�n�n en de�erli 
				;byte'�n� y�kle.
	subwf	HexMSB, W	;HexMSB�den 1024 ��kart.
	btfss	STATUS, C	;HexMSB > 1024'm�?
	goto	yuzler_kont2	;hay�r ise y�zleri kontrol et.
	incf	binler, F	;evet ise binleri bir art�r.
	movlw	04h		;W�ye 0x04 y�kle.
	subwf	HexMSB, F	;HexMSB�den 1000 ��kart.
	movlw	18h		;W�ye 0x18 y�kle.
	addwf	HexLSB, F	;HexLSB�ye (0x18 = 24) ekle.
	btfsc	STATUS, C	;elde var m�?
	incf	HexMSB, F	;evet ise bir art�r.
	goto	binler_kont	;binleri yeniden kontrol et.
yuzler_kont2
	movlw	0x01		;256 (0x0100)
	subwf	HexMSB, W	;HexMSB�den 200 ��kart ve sonucu W�ye 
				;sakla.
	btfss	STATUS, C	;sonu� >= 256�m�?
	goto	yuzler_kont1	;Hay�r ise y�zler basama��n� kontrol et
	movlw	0x02		;de�ilse,
	addwf	yuzler, F	;yuzler'e 2 ekle.
	movlw	0x01		;W = 1
	subwf	HexMSB, F	;HexMSB�den 200 ��kart.
	movlw	0x38		;W =0x38 (256'n�n 56 l�k k�sm�).
	addwf	HexLSB, F	;HexLSB�ye 56�y� ekle.
	btfsc	STATUS, C	;elde var m�?
	incf	HexMSB, F	;evet ise HexMSB�yi bir art�r.
	movlw	0x0A		;W = 10
	subwf	yuzler, W	;yuzler = 1000 olup olmad���n� kontrol et,
	btfss	STATUS, Z	;sonu� s�f�r m�?
	goto	yuzler_kont2	;hay�r ise yuzleri yeniden kontrol et.
	clrf	yuzler		;yuzler = 0
	incf	binler, F	;binler'i art�r.
	goto	yuzler_kont2	;yuzler'i 200 ya da daha b�y�k say� i�in 
				;yeniden kontrol et.
yuzler_kont1 
	movlw	0x64		;W = 0x64
	subwf	HexLSB, W	;HexLSB�den 100 ��kart.
	btfss	STATUS, C	;sonu� >= 100 m�?
	goto	onlar_kont	;hay�r ise onlar� kontrol et,
	incf	yuzler, F	;evet ise yuzler'i bir art�r.
	movlw	0x64		;W = 0x64 (100)
	subwf	HexLSB, F	;HexLSB�yi 100 azalt.
	movlw	0x0A		;W = 0x0A (10)
	subwf	yuzler, W	;yuzler = 1000 kontrol� yap.
	btfss	STATUS, Z	;sonu� = 0 m�?
	goto	yuzler_kont1	;hay�r ise 100 i�in yuzler'i yeniden 
				;kontrol et.
	clrf	yuzler		;yuzler = 0
	incf	binler, F	;binleri bir art�r.
	goto	yuzler_kont1	;100 ya da daha b�y�k olma durumu i�in 
				;yuzleri yeniden kontrol et.
onlar_kont
	movlw	0x0A		;W = 0x0A (10)
	subwf	HexLSB, W	;HexLSB�den 10 ��kart.
	btfss	STATUS, C	;sonu� >= 10 mu?
	goto	birler_kont	;hay�r ise birleri kontrol et,
	incf	onlar, F	;evet ise onlar� bir art�r.
	movlw	0x0A		;W = 0x0A (10)
	subwf	HexLSB, F	;HexLSB�den 10 ��kart.
	goto	onlar_kont	;onlar'� yeniden kontrol et.
birler_kont
	movf	HexLSB, W	;W = HexLSB
	movwf	birler		;birler = W, d�n���m i�lemi tamam.
	return			;Alt programdan ��k.
;-------------------------------------------------------------------
; Her 1 saniyede saya� de�erini bir art�ran alt program.
;-------------------------------------------------------------------
SayacArtir
	incf	sayacL, F	;sayacL�yi bir art�r.
	btfsc	STATUS, Z	;s�f�rdan farkl� ise bir komut atla.
	incf	sayacH, F	;sayacH�i bir art�r.
	movlw	0x27	
 	subwf	sayacH, W
	btfss	STATUS, Z		;sayacH = 0x27 ise bir komut atla
	goto	SayacArtir_j1		;sayac hen�z 10000�e ula�mad�, o 
					;halde devam et.
	movlw	0x10
 	subwf	sayacL, W
	btfss	STATUS, Z		;sayacL = 0x10 ise bir komut atla
	goto	SayacArtir_j1		;sayac hen�z 10000�e ula�mad�, o 
					;halde devam et.
	clrf	sayacH			;sayac� s�f�rla.
	clrf	sayacL
SayacArtir_j1
	movf	sayacH, W		;sayac de�erini desimale d�n��t�r.
	movwf	HexMSB
	movf	sayacL, W
	movwf	HexLSB
	call	HexToDec
	return
;-------------------------------------------------------------------
; Her 5ms�de bir display�leri tarayarak g�r�nt� olu�turur.
;------------------------------------------------------------------- 
DisplaydeGoster
display1
	incf	sira, F	;Taranacak display s�ras�se�iliyor.
	movlw	.1
	subwf	sira, W
	btfss	STATUS, Z	;1. display mi taranacak?
	goto	display2	;Hay�r ise 2.display i�in kontrol et.	
	movf	birler, W
	iorlw	0x10		;1. display s�rme bilgisi ve de�eri W�de
	movwf	PORTB		;1. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display2
	movlw	.2
	subwf	sira, W
	btfss	STATUS, Z	;2. display mi taranacak?
	goto	display3	;Hay�r ise 3. display i�in kontrol yap.
	movf	onlar, W
	iorlw	0x20		;2. display s�rme bilgisi ve de�eri W�de.
	movwf	PORTB		;2. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display3
	movlw	.3
	subwf	sira, W
	btfss	STATUS, Z	;3. display mi taranacak.
	goto	display4	;Hay�r ise 4. display i�in kontrol yap.
	movf	yuzler, W
	iorlw	0x40		;3. display s�rme bilgisi ve de�eri W�de.
	movwf	PORTB		;3. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display4
	movlw	.4
	subwf	sira, W
	btfss	STATUS, Z	;4. display mi taranacak.
	goto	display5	;Hay�r ise sirayi 1.display i�in ayarla.	
	movf	binler, W
	iorlw	0x80		;4. display s�rme bilgisi ve de�eri W�de.
	movwf	PORTB		;4. display�de g�r�nt� olu�turuldu.
	goto	disp_son
display5
	clrf	sira		;sira de�erini s�f�rla ve
	goto	display1	;tekrar bir art�rarak kontrol i�in ba�a 
disp_son:
	return
;-------------------------------------------------------------------
; Kesme program� her 1 ms de bir �al���r ve zaman saya�lar�n� 
; art�r�r.
;-------------------------------------------------------------------
kesme
	btfss	INTCON, T0IE		;TMR0 kesmesi etkin mi? Evetse bir 
					;komut atla.
	goto	int_son			;hay�rsa kesmeden ��k.
	btfss	INTCON, T0IF		;TMR0 kesmesi olu�tumu? T0IF = 1 mi 	
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
	incf	Timer1s, F		;1 s sayac�n� art�r, de�eri 200 
					;oldu�unda 1s ge�mi�tir
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
					;kayna�� internal clock.
	option				;1:4 prescaler de�er se�ildi.

	banksel TRISB			;BANK1 se�ildi.
	clrf	TRISB			;PORTB ��k�� yap�ld�.
	banksel PORTB			;BANK0 se�ildi.
	clrf	PORTB			;PORTB ��k��lar� s�f�rland�.

	clrf	sayacH			;sayac = 0
	clrf	sayacL
	clrf	HexMSB			;Desimal de�i�kenler s�f�rland�.
	clrf	HexLSB
	call	HexToDec

	clrf	sira			;sira = 0, �u an herhangi bir 
					;display�i i�aret etmiyor.
	
	clrf	Timer5ms		;5 ms sayac� s�f�rland�.
	clrf	Timer1s			;1 sn sayac� s�f�rland�.
	clrf	TimeCtrl		;Zaman kontrol kaydedicisi 
					;s�f�rland�.
	movlw	0x06
	movwf	TMR0			;TMR0 zamanlay�c�s� ilk de�eri 
					;verildi.
	bsf	INTCON, T0IE		;TMR0 kesmesi etkin hale getirildi
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
	bcf	TimeCtrl, 1		;1 sn bayra��n� sil.
	call	SayacArtir		;Sayac� bir art�r.
	goto	Ana_j1			;Sistem kapat�lana ya da 
					;resetlenene kadar bo� d�ng�.
					;Bu d�ng� s�ras�nda 5ms'de bir 
					;kesme �al���yor.
	end
;*******************************************************************

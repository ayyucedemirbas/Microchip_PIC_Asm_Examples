;*****************************************************************
;	Dosya Ad�		: 11_1.asm
;	Program�n Amac�		: 7 segment display uygulamas�
;	Notlar 			: Proteus program� sim�lasyonu
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A		
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�.
;-------------------------------------------------------------------
#define	DISPLAY1	PORTB
#define	DISPLAY2	PORTD
#define 	BUTON		PORTA, 1	; RA1'e ba�l� buton.
sayac		equ		0x20		; Saya� de�i�keni i�in 
						; RAM'de yer ayr�l�yor.
	org	0
	goto	ana_program
	org	4
kesme
	retfie
;-------------------------------------------------------------------
; Ortak anot display i�in rakamlar�n segment bilgileri.
;-------------------------------------------------------------------
ortak_anot
	addwf	PCL, F
	retlw	0x40		; 0 rakam� i�in segment de�eri.
	retlw	0x79		; 1 rakam� i�in segment de�eri.
	retlw	0x24		; 2 rakam� i�in segment de�eri.
	retlw	0x30		; 3 rakam� i�in segment de�eri.
	retlw	0x19		; 4 rakam� i�in segment de�eri.
	retlw	0x12		; 5 rakam� i�in segment de�eri.
	retlw	0x02		; 6 rakam� i�in segment de�eri.
	retlw	0x78		; 7 rakam� i�in segment de�eri.
	retlw	0x00		; 8 rakam� i�in segment de�eri.
	retlw	0x10		; 9 rakam� i�in segment de�eri.
;-------------------------------------------------------------------
; Ortak katot display i�in rakamlar�n segment bilgileri.
;-------------------------------------------------------------------
ortak_katot
	addwf	PCL, F
	retlw	0x3F		; 0 rakam� i�in segment de�eri.
	retlw	0x06		; 1 rakam� i�in segment de�eri.
	retlw	0x5B		; 2 rakam� i�in segment de�eri.
	retlw	0x4F		; 3 rakam� i�in segment de�eri.
	retlw	0x66		; 4 rakam� i�in segment de�eri.
	retlw	0x6D		; 5 rakam� i�in segment de�eri.
	retlw	0x7D		; 6 rakam� i�in segment de�eri.
	retlw	0x07		; 7 rakam� i�in segment de�eri.
	retlw	0x7F		; 8 rakam� i�in segment de�eri.
	retlw	0x6F		; 9 rakam� i�in segment de�eri.
;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
ana_program
	banksel TRISB		; BANK1 se�ildi.
	movlw	0x06		;
	movwf	ADCON1		; Analog giri�ler kapat�ld�.
	movwf	TRISA		; RA1 ve RA2 giri�e ayarland�, di�erleri 
				; ��k��.
	clrf	TRISB		; PORTB ��k��a y�nlendirildi.
	clrf	TRISD		; PORTD ��k�� yap�ld�.
	banksel PORTB		; BANK0 se�ildi.
	clrf	sayac		; Saya� s�f�rland�.
dongu
	movf	sayac, W	; Saya� de�eri al�n�yor.
	call	ortak_anot	; Saya�taki rakam�n ortak anot display 
				; i�in segment bilgisi al�n�yor.
	movwf	DISPLAY1	; Elde edilen segment de�erini DISPLAY1'de 
				; g�r�nt�le.
	movf	sayac, W	; Saya� de�eri al�n�yor.
	call	ortak_katot	; Saya�taki rakam�n ortak katot display 
				; i�in segment bilgisi al�n�yor.
	movwf	DISPLAY2	; Elde edilen segment de�erini DISPLAY2'de 
				; g�r�nt�le.
	btfsc	BUTON		; BUTON bas�lana kadar bekle.
	goto	$-1
	btfss	BUTON		; BUTON b�rak�lana kadar bekle.
	goto	$-1
	incf	sayac		; Sayac� bir art�r.
	movlw	.10
	subwf	sayac ,W
	btfsc	STATUS, Z	; Sayac� 10 ile kar��la�t�r. Farkl� ise 
				; bir komut atla.
	clrf	sayac		; saya� = 10 ise sayac� s�f�rla, de�ilse 
				; bir �ey yapmadan geri d�n.
	goto	dongu

	end
;******************************************************************* 

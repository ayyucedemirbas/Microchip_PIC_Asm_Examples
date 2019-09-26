;******************************************************************
;	Dosya Ad�		: 4_7.asm
;	Program�n Amac�		: WDT uygulamas�.
;	PICDK2.1a 		: PORTB ��k�� ==> LED
;				: PORTA Dijital Giri� <== BUTON
;				: XT ==> 4Mhz
;*****************************************************************
	list		p=16F877A	; Derleyici i�in bilgi
	#include	<P16F877A.INC>	; 877A i�in gerekli isim-							
					; adres e�le�meleri.
	__config H'3F31' 		; PWRT on, di�erleri kapal�, 
					; Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Genel de�i�ken tan�mlamalar�.
;-------------------------------------------------------------------
YEDEK_W	EQU	0x020			; Yedekleme register�lar�.
YEDEK_STATUS	EQU	0x021
YEDEK_PCLATH	EQU 	0x022
hata_kayit_reg	EQU	0x025		; Ka� kere hata yap�ld���n� sayar. 
;-------------------------------------------------------------------	
	ORG	0x000			; Ba�lang�� adresi.
	goto	ana_program		; Ana programa git.
	ORG	0x004			; Kesme vekt�r� adresi.
;-------------------------------------------------------------------
; PCLATH, W ve STATUS register��n� yedekleme b�l�m�.
;-------------------------------------------------------------------
	movwf	YEDEK_W			;W register�i i�eri�ini YEDEK_W�ye kaydet.
	movf	STATUS,W		; STATUS�� W ye al.
	movwf	YEDEK_STATUS		; Bunu YEDEK_STATUS�e kay�t et.
	movf	PCLATH,W		; PCLATH�i W ye aktar,
	movwf	YEDEK_PCLATH		; bunu YEDEK_PCCLATH�a kaydet.
;-------------------------------------------------------------------
; Kesme alt program�: TMR1'e ait her kesmede PORTB=1�se �0�,
; PORTB=0�sa �1� yapar.
;-------------------------------------------------------------------
kesme
	bcf	PORTB,6			; S�f�rlama belirtme LED'i.
	bcf	PIR1,TMR1IF		; Art�k bayrak ile i�imiz 
					; bitti, kapatabiliriz.
	btfsc	PORTB,7			; PORTB'nin 1. bit�ine ba�l� LED 
					; yan�yorsa kapatma
	goto	portb1s�f�ryap		; program�n� �a��r, kapal�ysa 
					; devam et ve
	bsf	PORTB,7			; PORTB'yi "1" durumuna getir ve
	goto	kesme_bitir		; kesmeden ��kmaya haz�rlan.
portb1s�f�ryap
	bcf	PORTB,7			; PORTB'yi "0 durumuna getir.
;------ Yedekteki PCLATH, W ve STATUS registerini geri y�klemek-----
kesme_bitir
	movf	YEDEK_PCLATH, W 	; Kesme �ncesi kopyay� W�ye al,
	movwf	PCLATH			; bunu PCLATH�a kopyala.
	movf	YEDEK_STATUS, W 	; Kesme �ncesi STATUS�� W�ye al,
	movwf	STATUS			; bunu STATUS�e kopyala.
	swapf	YEDEK_W, F		; D�rt bit�in yerini de�i�tir,
	swapf	YEDEK_W, W		; tekrar �evir fakat W�ye kaydet. 
	retfie				; Kesmeden geri d�n.
;-------------------------------------------------------------------
; Ana program: Port y�nlendirme, Zamanlay�c� ayar� ve ana program 
; d�ng�s� burada.
;-------------------------------------------------------------------
ana_program
	clrf	PORTA			; PORTA'y� temizle.
	clrf	PORTB			; PORTB'yi temizle.
	movlw	b'11110001'	
	movwf	T1CON			; TMR1 zamanlay�c�s�n� kur.
	movlw	b'11000000'		; TMR1 kesmesi i�in uygun bit�leri
	movwf	INTCON			; aktif duruma getir.
	movlw	b'00001111'		; WDT zamanlay�c�s�n�n �arpan�n�
	movwf	OPTION_REG  		;111 olarak belirleyerek 2.3 sn de s�f�rla.
	bsf	STATUS,RP0		; BANK1�e ge�.
	bsf	PIE1,0			; TMR1 kesmesini a�.
	movlw	b'00000000'		; PORTB ��k��.
	movwf	TRISB
	movlw	b'11111111'		; PORTA giri�.
	movwf	TRISA		
	movlw	b'00000111'		; PORTA dijital giri�
	movwf	ADCON1			; olacak �ekilde ADCON1 ayarland�.
	bcf	STATUS,RP0		; BANK0�a ge�.
	btfss	STATUS,4		;STATUS,�n 4. bit�i 1 ise buraya WDT 
					;s�f�rlamas� ile gelinmi� demektir o zaman 
					;hata say�s�n� bir art�r. 
	incf	hata_kayit_reg,f	; Hata kayd� i�in bir bellek
					; adresine ka� kez
	movfw	hata_kayit_reg		; hata yap�ld��� kay�t edilir,
	xorwf	PORTB,F			; bu de�er PORTB'de g�r�nt�lenir.
	bsf	PORTB,6			; PORTB'nin 6 bit�ini 1 yap,
					; s�f�rlaman�n anla��lmas�
					; i�in... ilk kesmede 0 yap�lacakt�r.
dongu
	btfsc	PORTA,1			; PORTA'n�n 1. bit�ine ba�l� olan 
					; RA0 isimli d��meye bas�lmad���
	clrwdt				; s�rece WDT sayac� s�f�rlan�r.
	goto	dongu			; E�er tu�a bas�lmazsa WDT saymaya ba�lar.
					; E�er belirlenen s�reden uzun bir s�re 
					; tu�a bas�l�rsa WDT ta�ar ve 
					; mikrodenetleyici s�f�rlan�r.
hata_kayit				
	return	
	end
;******************************************************************

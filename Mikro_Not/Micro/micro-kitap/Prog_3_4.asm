;*******************************************************************
;	Dosya Ad�		: 3_4.asm
;	Program�n Amac�	: �ki kesmeyi kayna��n�
;				  beraber kullanmak.
;	PICDK2.1a 		: PORTB ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list		p=16F877A	; Derleyici i�in bilgi
	#include	<P16F877A.INC>	; 877A i�in gerekli �zel		
					; ama�l� register isim adres e�le�meleri.
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
YEDEK_W	EQU	0x020		; Genel ama�l� adres-isim e�le�meleri.
YEDEK_STATUS	EQU	0x021
YEDEK_PCLATH	EQU	0x022

	ORG	0x000		; Ba�lang�� adresi.
	goto	ana_program	; Ana programa git.
	ORG	0x004		; Kesme vekt�r� adresi.
	movwf	YEDEK_W		; W register�i i�eri�ini YEDEK_W�ye kaydet.
	movf	STATUS,W	; STATUS�� W ye al,
	movwf	YEDEK_STATUS	; bunu YEDEK_STATUS�e kay�t et.
	movf	PCLATH,W	; PCLATH�i W ye aktar,
	movwf	YEDEK_PCLATH	; bunu YEDEK_PCCLATH�a kaydet.

kesme 
	btfsc	INTCON, TMR0IF	; E�er TMR0IF �1� ise TMR0  kesme
				; bayra�� �ekilmi� demektir.
				; Sat�r� atlama, tmr0_int adresine
				; git. E�er bayrak �ekili de�ilse
goto	tmr0_int		; tmr1 kesmesi olmal�d�r. tmr1_int
				; adresinden program �al��maya 
				; devam eder.
tmr1_int
	bcf	PIR1,TMR1IF		; Art�k bayrak ile i�imiz 
					; bitti, kapatabiliriz.
	btfsc	PORTB,1			; PORTB'nin 1. bit�ine ba�l� LED 
					; yan�yorsa kapatma
	goto	portb1s�f�ryap		; program�n� �a��r. Kapal�ysa 
					; devam et ve
	bsf	PORTB,1			; PORTB'yi "1" durumuna getir ve
	goto	kesme_bitir		; kesmeden ��kmaya haz�rlan.
portb1s�f�ryap
	bcf	PORTB,1			; PORTB'yi "0 durumuna getir ve
	goto	kesme_bitir		; kesmeden ��kmaya haz�rlan.
tmr0_int					
	bcf	INTCON,TMR0IF		; TMR0IF bayra��n� kapatabiliriz.
	btfss	PORTB,0			; PORTB'nin 0. bit�i 0 m� 1 mi?
	goto	portb0setet		; 1 ise 0 yapan yere git.
	goto	portb0s�f�ryap		; 0 ise 1 yapan yere git.
portb0setet				
	bsf	PORTB,0			; LED'i yak.
	goto	kesme_bitir		; Kesmeden ��kmaya haz�rlan.
portb0s�f�ryap
	bcf	PORTB,0			; LED'i s�nd�r.
					; Nas�l olsa program�n sonunday�z,
					; burada goto kesme_bitir'e gerek yok 
kesme_bitir
	movf	YEDEK_PCLATH, W 	; Kesme �ncesi kopyay� W�ye al.
	movwf	PCLATH			; Bunu PCLATH�a kopyala.
	movf	YEDEK_STATUS, W 	; Kesme �ncesi STATUS�� W�ye al,
	movwf	STATUS			; bunu STATUS�e kopyala.
	swapf	YEDEK_W, F		; D�rt bit�in yerini de�i�tir.
	swapf	YEDEK_W, W		; Tekrar �evir fakat W�ye kaydet.
	retfie				; Kesmeden geri d�n.
;-------------------------------------------------------------------
 ana_program
;-------------------------------------------------------------------
	movlw	b'11100000'		; GIE�yi PEIE�yi ve TMR0IEy� �1�
	movwf	INTCON			; yap.B�ylece TMR0 kesmesi a��ls�n.
	movlw	b'11110001'		; T1CON registeri ile TMR1 zamanlay�
	movwf	T1CON			; c�s�n�n �0� lanma s�resini ayarla
	bsf	STATUS,RP0		; BANK1�e ge�.
	movlw	b'10000111'		; TMR0 zamanlay�c�s�n�n �n �arpan�n
	movwf	OPTION_REG		; n� ayarla RB pull-uplar�n� kapat.
	bsf	PIE1,0			; TMR1 kesmesini a�.
	movlw	b'11111100'		; PORTB�nin son iki bit�i ��k��, 
	movwf	TRISB			; di�er bit�leri giri� olsun.
	bcf	STATUS,RP0		; BANK0�a ge�.
dongu					 
	goto	dongu			; Sonsuz d�ng�ye devam et.
	end
;*************************	****************************************

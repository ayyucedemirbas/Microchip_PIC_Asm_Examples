;*******************************************************************
;	Dosya Ad�		: 3_3.asm
;	Program�n Amac�		: Kesmeden ��kmak i�in tu�tan parma��n
;                           	�ekilmesini bekleyen program.
;	PICDK2.1a 		: PORTB ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list		p=16F877A	; Derleyici i�in bilgi
	#include	<P16F877A.INC>	; 877A i�in gerekli isim-
					; adres e�lemesi.
	__config H'3F31' 		;PWRT on, di�erleri kapal�, 
					;Osilat�r XT ve 4Mhz
;-------------------------------------------------------------------
; Tan�mlamalar
;-------------------------------------------------------------------
YEDEK_W	EQU	0x020
YEDEK_STATUS	EQU	0x021
YEDEK_PCLATH	EQU 	0x022
	ORG	0x000		; Ba�lang�� Adresi.
	goto	ana_program	; ana programa git
;-------------------------------------------------------------------
; Kesme
;-------------------------------------------------------------------
	ORG	0x004		; Kesme vekt�r� adresi.
	movwf	YEDEK_W		; W register�i i�eri�ini YEDEK_W�ye kaydet.
	movf	STATUS,W	; STATUS�� W ye al.
	movwf	YEDEK_STATUS	; Bunu YEDEK_STATUS�e kay�t et.
	movf	PCLATH,W	; PCLATH�i W ye aktar,
	movwf	YEDEK_PCLATH	; bunu YEDEK_PCCLATH�a kaydet
	bcf	INTCON, INTF	; Kesme bayra��n� kapat.
sorgu				; Bu sorgunun amac� tu�a bas�l�p	bas�lmad���n� 
				; ve TMR1 bayra��n� kontrol etmektir.
	btfsc	PORTB, 0	; Tu�a bas�l� m�?
	goto	kesme_bitir	; bas�l� de�ilse kesmeden ��k.
	btfss	INTCON, INTF	; TMR1 65536'yi a�t� bayra��n� kontrol et
	goto	sorgu		; e�er a�mad�ysa sorguya geri d�n.
	bcf	INTCON, INTF	; Bayrak a��ld�ysa bayra�� kapat
	btfss	PORTB,7		; ve LED yan�yor mu s�n�k m�? test et.
	goto	yak		; S�n�kse yak'a git.
	bcf	PORTB,7		; Yan�yorsa s�nd�r
	goto	sorgu		; ve sorguya d�n.
yak							
	bsf	PORTB,7		; LED'i yak.
	goto	sorgu		; Sorguya d�n.
kesme_bitir	
	movf	YEDEK_PCLATH, W 	; Kesme �ncesi kopyay� W�ye al,
	movwf	PCLATH			; bunu PCLATH�a kopyala.
	movf	YEDEK_STATUS, W 	; Kesme �ncesi STATUS�� W�ye al
	movwf	STATUS			; bunu STATUS�e kopyala.
	swapf	YEDEK_W, F		; D�rt bit�in yerini de�i�tir,
	swapf	YEDEK_W, W		; tekrar �evir, fakat W�ye kaydet.
	retfie				; Kesmeden geri d�n.

ana_program
	movlw	b'10010000'	; RB0 kesmesini aktif hale getir.
	movwf	INTCON		
	bsf	STATUS,RP0	; BANK1�e ge�.
	movlw	b'00000111'	
	clrf	OPTION_REG	; Kesme d��en kenarda olacak.
	movlw	b'00000001'	; Sadece RB0 giri� di�erleri ��k��.
	movwf	TRISB
	bcf	STATUS,RP0	; BANK0�a ge�.
dongu		
	goto	dongu		; Sonsuz d�ng�ye gir.
	end
;*****************************************************************

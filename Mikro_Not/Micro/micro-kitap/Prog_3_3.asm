;*******************************************************************
;	Dosya Adý		: 3_3.asm
;	Programýn Amacý		: Kesmeden çýkmak için tuþtan parmaðýn
;                           	çekilmesini bekleyen program.
;	PICDK2.1a 		: PORTB Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list		p=16F877A	; Derleyici için bilgi
	#include	<P16F877A.INC>	; 877A için gerekli isim-
					; adres eþlemesi.
	__config H'3F31' 		;PWRT on, diðerleri kapalý, 
					;Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Tanýmlamalar
;-------------------------------------------------------------------
YEDEK_W	EQU	0x020
YEDEK_STATUS	EQU	0x021
YEDEK_PCLATH	EQU 	0x022
	ORG	0x000		; Baþlangýç Adresi.
	goto	ana_program	; ana programa git
;-------------------------------------------------------------------
; Kesme
;-------------------------------------------------------------------
	ORG	0x004		; Kesme vektörü adresi.
	movwf	YEDEK_W		; W register’i içeriðini YEDEK_W’ye kaydet.
	movf	STATUS,W	; STATUS’ü W ye al.
	movwf	YEDEK_STATUS	; Bunu YEDEK_STATUS’e kayýt et.
	movf	PCLATH,W	; PCLATH’i W ye aktar,
	movwf	YEDEK_PCLATH	; bunu YEDEK_PCCLATH’a kaydet
	bcf	INTCON, INTF	; Kesme bayraðýný kapat.
sorgu				; Bu sorgunun amacý tuþa basýlýp	basýlmadýðýný 
				; ve TMR1 bayraðýný kontrol etmektir.
	btfsc	PORTB, 0	; Tuþa basýlý mý?
	goto	kesme_bitir	; basýlý deðilse kesmeden çýk.
	btfss	INTCON, INTF	; TMR1 65536'yi aþtý bayraðýný kontrol et
	goto	sorgu		; eðer aþmadýysa sorguya geri dön.
	bcf	INTCON, INTF	; Bayrak açýldýysa bayraðý kapat
	btfss	PORTB,7		; ve LED yanýyor mu sönük mü? test et.
	goto	yak		; Sönükse yak'a git.
	bcf	PORTB,7		; Yanýyorsa söndür
	goto	sorgu		; ve sorguya dön.
yak							
	bsf	PORTB,7		; LED'i yak.
	goto	sorgu		; Sorguya dön.
kesme_bitir	
	movf	YEDEK_PCLATH, W 	; Kesme öncesi kopyayý W’ye al,
	movwf	PCLATH			; bunu PCLATH’a kopyala.
	movf	YEDEK_STATUS, W 	; Kesme öncesi STATUS’ü W’ye al
	movwf	STATUS			; bunu STATUS’e kopyala.
	swapf	YEDEK_W, F		; Dört bit’in yerini deðiþtir,
	swapf	YEDEK_W, W		; tekrar çevir, fakat W’ye kaydet.
	retfie				; Kesmeden geri dön.

ana_program
	movlw	b'10010000'	; RB0 kesmesini aktif hale getir.
	movwf	INTCON		
	bsf	STATUS,RP0	; BANK1’e geç.
	movlw	b'00000111'	
	clrf	OPTION_REG	; Kesme düþen kenarda olacak.
	movlw	b'00000001'	; Sadece RB0 giriþ diðerleri çýkýþ.
	movwf	TRISB
	bcf	STATUS,RP0	; BANK0’a geç.
dongu		
	goto	dongu		; Sonsuz döngüye gir.
	end
;*****************************************************************

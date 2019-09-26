;*******************************************************************
;	Dosya Adý		: 11_4.asm
;	Programýn Amacý		: 4x4 tuþ takýmý tasarýmý
;	PIC DK2.1a 		: PORTB Çýkýþ ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A			
	include "p16F877A.inc"				
	__config H'3F31' 			;PWRT on, diðerleri kapalý, 
						;Osilatör XT ve 4Mhz.
;-------------------------------------------------------------------
; Deðiþken tanýmlarý yapýlýyor.
;-------------------------------------------------------------------
	CBLOCK	0x20			;16F877A'nýn RAM baþlangýç adresi, 
		_W			;deðiþkenler burada
		_STATUS
		_FSR
		_PCLATH
		satir			;klavyede taranacak satýrý belirler
		tus
		temp
		Timer10ms		;10ms sayacý
		Timer1s			;1s sayacý
		TimeCtrl
		ButonCtrl
	ENDC

	ORG 	0					
	pagesel Ana_program		;ana programýn bulunduðu program 
					;sayfasý seçildi.
	goto 	Ana_program		;ana programa git.

	ORG 	4			;Kesme alt programý bu adresten 
					;baþlýyor. Fakat programda kesme 
					;kullanmadýk. Ýstenirse buradan 
					;itibaren kesme programý ilave 
					;edilebilir.
	goto	kesme
;-------------------------------------------------------------------
; Her 10ms’de bir satýr tarama iþlemi yapar. Taranan satýr LOW, 
; diðerleri HIGH seviyesine çekilir.
;-------------------------------------------------------------------
KlavyeTara
satir1
	movlw	b'11100000'
	movwf	PORTD			;0. satýr aktif.
sifir					;sütun = 0
	btfss	PORTD,0			;0. sütundaki tuþa basýlý mý?
	retlw	d'0'
bir					;sütun = 1
	btfss	PORTD,1			;1. sütundaki tuþ basýlý mý?
	retlw	d'1'
iki					;sutun = 2
	btfss	PORTD,2			;2. sütundaki tuþ basýlý mý?
	retlw	d'2'
uc					;sutun = 3
	btfss	PORTD,3			;3. sütundaki tuþa basýlý mý?
	retlw	d'3'
satir2
	movlw	b'11010000'
	movwf	PORTD			;1. satýr aktif
dort					;sutun = 0
	btfss	PORTD,0			;0. sütundaki tuþa basýlý mý?
	retlw	d'4'
bes					;sutun = 1
	btfss	PORTD,1			;1. sütundaki tuþ basýlý mý?
	retlw	d'5'
alti					;sutun = 2
	btfss	PORTD,2			;2. sütundaki tuþ basýlý mý?
	retlw	d'6'
yedi					;sutun = 3
	btfss	PORTD,3			;3. sütundaki tuþa basýlý mý?
	retlw	d'7'
satir3
	movlw	b'10110000'
	movwf	PORTD			;2. satýr aktif
sekiz					;sutun = 0
	btfss	PORTD,0			;0. sütundaki tuþa basýlý mý?
	retlw	d'8'
dokuz					;sutun = 1
	btfss	PORTD,1			;1. sütundaki tuþ basýlý mý?
	retlw	d'9'
on					;sutun = 2
	btfss	PORTD,2			;2. sütundaki tuþ basýlý mý?
	retlw	d'10'
onbir					;sutun = 3
	btfss	PORTD,3			;3. sütundaki tuþa basýlý mý?
	retlw	d'11'
satir4
	movlw	b'01110000'
	movwf	PORTD			;3. satýr aktif
oniki
	btfss	PORTD,0			;0. sütundaki tuþa basýlý mý?
	retlw	d'12'
onuc
	btfss	PORTD,1			;1. sütundaki tuþ basýlý mý?
	retlw	d'13'
ondort
	btfss	PORTD,2			;2. sütundaki tuþ basýlý mý?
	retlw	d'14'
onbes
	btfss	PORTD,3			;3. sütundaki tuþa basýlý mý?
	retlw	d'15'
	retlw	d'255'
;-------------------------------------------------------------------
; Kesme programý (kullanýlacak ise LCD ya da zamanlamanýn önemli 
; olduðu cihazlarla çalýþýrken iletiþimin kesilmemesine dikkat ediniz).
;-------------------------------------------------------------------
kesme	
	movwf	_W			;PCLATH, FSR, STATUS ve
	swapf	_W, F			;W yedekleniyor.
	swapf	STATUS, W
	movwf	_STATUS
	swapf	FSR, W
	movwf	_FSR
	swapf	PCLATH, W
	movwf	_PCLATH

	btfss	INTCON, T0IE		;TMR0 kesmesi etkin mi? Evetse bir 
					;komut atla.
	goto	int_son			;hayýrsa kesmeden çýk.
	btfss	INTCON, T0IF		;TMR0 kesmesi oluþtu mu? (T0IF=1 ?)
	goto	int_son			;hayýrsa kesmeden çýk.
	movlw	0x06
	movwf	TMR0
	bsf	TimeCtrl, 0		;1 ms bayraðý set oldu.
	incf	Timer10ms, F
	movlw	.10
	subwf	Timer10ms, W
	btfss	STATUS, Z
	goto	int_son
	clrf	Timer10ms		;10 ms doldu.
	bsf	TimeCtrl, 1		;10 ms bayraðý set oldu.
	incf	Timer1s, F		;1 sn sayacýný artýr, deðeri 100 
					;olduðunda 1 sn geçmiþtir,
					;bu durumda sayaç artýrýlacak.
	movlw	.100
	subwf	Timer1s, W
	btfss	STATUS, C
	goto	int_son
	clrf	Timer1s			;1 sn doldu.
	bsf	TimeCtrl, 2		;1 sn bayraðý set oldu.

int_son
	bcf	INTCON, T0IF		;Kesme bayraðýný sil.
	swapf	_PCLATH, W		;PCLATH, FSR, STATUS ve W
	movwf	PCLATH			;yedekten geri alýnýyor.
	swapf	_FSR, W
	movwf	FSR
	swapf	_STATUS, W
	movwf	STATUS
	swapf	_W, W
	retfie

;-------------------------------------------------------------------
; Ana program
;-------------------------------------------------------------------
Ana_program	
	movlw	0xD1			;RB pull-up pasif, TMR0 için clock 
					;kaynaðý intrenal clock
	option				;1:4 prescaler deðer seçildi.
	banksel TRISB			;BANK1 seçildi.
	clrf	TRISB			;PORTB çýkýþ yapýldý.
	clrf	TRISE			;PORTE çýkýþ yapýldý, PORTD ise 
					;normal giriþ/çýkýþ moduna alýndý.
	movlw	0x0F
	movwf	TRISD			;PORTD’nin en deðerli 4 bit’i satýr 
					;bilgisi için giriþe, sütun bilgisi 
					;için çýkýþa ayarlandý.
	banksel PORTB			;BANK0 seçildi.
	clrf	PORTB			;PORTB çýkýþlarý sýfýrlandý.
	clrf	satir			;satir = 0
	clrf	tus
	clrf	Timer10ms		;10ms sayacý sýfýrlandý.
	clrf	TimeCtrl		;Zaman kontrol kaydedicisi silindi.
	clrf	ButonCtrl		;Buton kontrol kaydedicisi silindi. 

	movlw	0x06
	movwf	TMR0			;TMR0 zamanlayýcýsý ilk deðeri 
					;verildi.

	bsf	INTCON, T0IE		;TMR0 kesmesi etkin hale getirildi.
	bsf	INTCON, GIE		;Etkinleþtirilen tüm kesmelere izin 
					;verildi.
	btfss	TimeCtrl, 2		;örneðin baþlangýçta 1 saniye 
					;gecikme istersek
	goto	$-1			;1 sn bayraðý test edilerek set 
					;olmasý beklenir.
Ana_j1
	btfss	TimeCtrl, 1		;10 ms süre geçti mi?
	goto	Ana_j2			;buton kontrol et.
	call	KlavyeTara		;Klavye tara.
	movwf	tus			;Basýlan tuþun kodunu al.
	sublw	0xFF
	btfsc	STATUS, Z
	goto	Ana_j2			;Butona basýlmamýþ.
	bsf	ButonCtrl, 0		;Butona basýldý bayraðýný set et.
	bcf	TimeCtrl, 1		;10 ms bayraðýný sil.

Ana_j2
	btfss	ButonCtrl, 0		;Butona basýlmýþ ise bir komut atla
	goto	Ana_j1			;Baþa dön
	movf	tus, W			;Basýlan butonun kodu W'de.
	movwf	PORTB			;kodu PORTB'ye aktar.
	bcf	ButonCtrl, 0		;Butona basýlma durumunu gösteren 
					;bayraðý sil.
	goto	Ana_j1			;Sistem kapatýlana ya da
					;resetlenene kadar boþ döngü Bu 
					;döngü sýrasýnda 10ms’de bir kesme
					;çalýþýyor.
	end
;*******************************************************************

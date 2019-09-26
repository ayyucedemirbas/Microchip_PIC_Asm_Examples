;*******************************************************************
;	Dosya Ad�		: 11_4.asm
;	Program�n Amac�		: 4x4 tu� tak�m� tasar�m�
;	PIC DK2.1a 		: PORTB ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A			
	include "p16F877A.inc"				
	__config H'3F31' 			;PWRT on, di�erleri kapal�, 
						;Osilat�r XT ve 4Mhz.
;-------------------------------------------------------------------
; De�i�ken tan�mlar� yap�l�yor.
;-------------------------------------------------------------------
	CBLOCK	0x20			;16F877A'n�n RAM ba�lang�� adresi, 
		_W			;de�i�kenler burada
		_STATUS
		_FSR
		_PCLATH
		satir			;klavyede taranacak sat�r� belirler
		tus
		temp
		Timer10ms		;10ms sayac�
		Timer1s			;1s sayac�
		TimeCtrl
		ButonCtrl
	ENDC

	ORG 	0					
	pagesel Ana_program		;ana program�n bulundu�u program 
					;sayfas� se�ildi.
	goto 	Ana_program		;ana programa git.

	ORG 	4			;Kesme alt program� bu adresten 
					;ba�l�yor. Fakat programda kesme 
					;kullanmad�k. �stenirse buradan 
					;itibaren kesme program� ilave 
					;edilebilir.
	goto	kesme
;-------------------------------------------------------------------
; Her 10ms�de bir sat�r tarama i�lemi yapar. Taranan sat�r LOW, 
; di�erleri HIGH seviyesine �ekilir.
;-------------------------------------------------------------------
KlavyeTara
satir1
	movlw	b'11100000'
	movwf	PORTD			;0. sat�r aktif.
sifir					;s�tun = 0
	btfss	PORTD,0			;0. s�tundaki tu�a bas�l� m�?
	retlw	d'0'
bir					;s�tun = 1
	btfss	PORTD,1			;1. s�tundaki tu� bas�l� m�?
	retlw	d'1'
iki					;sutun = 2
	btfss	PORTD,2			;2. s�tundaki tu� bas�l� m�?
	retlw	d'2'
uc					;sutun = 3
	btfss	PORTD,3			;3. s�tundaki tu�a bas�l� m�?
	retlw	d'3'
satir2
	movlw	b'11010000'
	movwf	PORTD			;1. sat�r aktif
dort					;sutun = 0
	btfss	PORTD,0			;0. s�tundaki tu�a bas�l� m�?
	retlw	d'4'
bes					;sutun = 1
	btfss	PORTD,1			;1. s�tundaki tu� bas�l� m�?
	retlw	d'5'
alti					;sutun = 2
	btfss	PORTD,2			;2. s�tundaki tu� bas�l� m�?
	retlw	d'6'
yedi					;sutun = 3
	btfss	PORTD,3			;3. s�tundaki tu�a bas�l� m�?
	retlw	d'7'
satir3
	movlw	b'10110000'
	movwf	PORTD			;2. sat�r aktif
sekiz					;sutun = 0
	btfss	PORTD,0			;0. s�tundaki tu�a bas�l� m�?
	retlw	d'8'
dokuz					;sutun = 1
	btfss	PORTD,1			;1. s�tundaki tu� bas�l� m�?
	retlw	d'9'
on					;sutun = 2
	btfss	PORTD,2			;2. s�tundaki tu� bas�l� m�?
	retlw	d'10'
onbir					;sutun = 3
	btfss	PORTD,3			;3. s�tundaki tu�a bas�l� m�?
	retlw	d'11'
satir4
	movlw	b'01110000'
	movwf	PORTD			;3. sat�r aktif
oniki
	btfss	PORTD,0			;0. s�tundaki tu�a bas�l� m�?
	retlw	d'12'
onuc
	btfss	PORTD,1			;1. s�tundaki tu� bas�l� m�?
	retlw	d'13'
ondort
	btfss	PORTD,2			;2. s�tundaki tu� bas�l� m�?
	retlw	d'14'
onbes
	btfss	PORTD,3			;3. s�tundaki tu�a bas�l� m�?
	retlw	d'15'
	retlw	d'255'
;-------------------------------------------------------------------
; Kesme program� (kullan�lacak ise LCD ya da zamanlaman�n �nemli 
; oldu�u cihazlarla �al���rken ileti�imin kesilmemesine dikkat ediniz).
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
	goto	int_son			;hay�rsa kesmeden ��k.
	btfss	INTCON, T0IF		;TMR0 kesmesi olu�tu mu? (T0IF=1 ?)
	goto	int_son			;hay�rsa kesmeden ��k.
	movlw	0x06
	movwf	TMR0
	bsf	TimeCtrl, 0		;1 ms bayra�� set oldu.
	incf	Timer10ms, F
	movlw	.10
	subwf	Timer10ms, W
	btfss	STATUS, Z
	goto	int_son
	clrf	Timer10ms		;10 ms doldu.
	bsf	TimeCtrl, 1		;10 ms bayra�� set oldu.
	incf	Timer1s, F		;1 sn sayac�n� art�r, de�eri 100 
					;oldu�unda 1 sn ge�mi�tir,
					;bu durumda saya� art�r�lacak.
	movlw	.100
	subwf	Timer1s, W
	btfss	STATUS, C
	goto	int_son
	clrf	Timer1s			;1 sn doldu.
	bsf	TimeCtrl, 2		;1 sn bayra�� set oldu.

int_son
	bcf	INTCON, T0IF		;Kesme bayra��n� sil.
	swapf	_PCLATH, W		;PCLATH, FSR, STATUS ve W
	movwf	PCLATH			;yedekten geri al�n�yor.
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
	movlw	0xD1			;RB pull-up pasif, TMR0 i�in clock 
					;kayna�� intrenal clock
	option				;1:4 prescaler de�er se�ildi.
	banksel TRISB			;BANK1 se�ildi.
	clrf	TRISB			;PORTB ��k�� yap�ld�.
	clrf	TRISE			;PORTE ��k�� yap�ld�, PORTD ise 
					;normal giri�/��k�� moduna al�nd�.
	movlw	0x0F
	movwf	TRISD			;PORTD�nin en de�erli 4 bit�i sat�r 
					;bilgisi i�in giri�e, s�tun bilgisi 
					;i�in ��k��a ayarland�.
	banksel PORTB			;BANK0 se�ildi.
	clrf	PORTB			;PORTB ��k��lar� s�f�rland�.
	clrf	satir			;satir = 0
	clrf	tus
	clrf	Timer10ms		;10ms sayac� s�f�rland�.
	clrf	TimeCtrl		;Zaman kontrol kaydedicisi silindi.
	clrf	ButonCtrl		;Buton kontrol kaydedicisi silindi. 

	movlw	0x06
	movwf	TMR0			;TMR0 zamanlay�c�s� ilk de�eri 
					;verildi.

	bsf	INTCON, T0IE		;TMR0 kesmesi etkin hale getirildi.
	bsf	INTCON, GIE		;Etkinle�tirilen t�m kesmelere izin 
					;verildi.
	btfss	TimeCtrl, 2		;�rne�in ba�lang��ta 1 saniye 
					;gecikme istersek
	goto	$-1			;1 sn bayra�� test edilerek set 
					;olmas� beklenir.
Ana_j1
	btfss	TimeCtrl, 1		;10 ms s�re ge�ti mi?
	goto	Ana_j2			;buton kontrol et.
	call	KlavyeTara		;Klavye tara.
	movwf	tus			;Bas�lan tu�un kodunu al.
	sublw	0xFF
	btfsc	STATUS, Z
	goto	Ana_j2			;Butona bas�lmam��.
	bsf	ButonCtrl, 0		;Butona bas�ld� bayra��n� set et.
	bcf	TimeCtrl, 1		;10 ms bayra��n� sil.

Ana_j2
	btfss	ButonCtrl, 0		;Butona bas�lm�� ise bir komut atla
	goto	Ana_j1			;Ba�a d�n
	movf	tus, W			;Bas�lan butonun kodu W'de.
	movwf	PORTB			;kodu PORTB'ye aktar.
	bcf	ButonCtrl, 0		;Butona bas�lma durumunu g�steren 
					;bayra�� sil.
	goto	Ana_j1			;Sistem kapat�lana ya da
					;resetlenene kadar bo� d�ng� Bu 
					;d�ng� s�ras�nda 10ms�de bir kesme
					;�al���yor.
	end
;*******************************************************************

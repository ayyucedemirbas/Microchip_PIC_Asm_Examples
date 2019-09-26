;*******************************************************************
;	Dosya Ad�		: 6_3.asm
;	Program�n Amac�		: SFR�siz senkron seri veri ileti�imi
;				 (74HC597 kullan�larak).
;	PIC DK 2.1 		: PORTB<0:4> ��k�� ==> LED
;				: XT ==> 4Mhz
;*******************************************************************
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F31' 	;PWRT on, di�erleri kapal�, 
				;Osilat�r XT ve 4Mhz.
;-------------------------------------------------------------------
; Genel tan�mlamalar ve de�i�ken tan�mlamalar� yap�l�yor.
;-------------------------------------------------------------------
#define hc597_port	PORTB		;74HC597��n ba�l� oldu�u 
					;port tan�m� yap�l�yor.
#define LOAD_Pin	0		;Load pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.
#define DATA_Pin	1		;Data pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.
#define CLK_Pin	2			;Clock pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.
#define LATCH_Pin	3		;Latch pininin i�lemciye ba�l� 
					;oldu�u pin tan�mlan�yor.

delay_ms_data		equ 0x20 	;delay_ms i�in 2 byte'l�k de�i�ken 
					;tan�m� yap�l�yor.
i			equ 0x22 	;Transfer edilecek verinin bit 
					;s�ras�n� tespit de�i�keni.
hc597_data		equ 0x23 	;Okunacak veriyi tutan de�i�ken.

	ORG 	0			;Reset vekt�r adresi buras�. 
	pagesel Ana_program		;Ana program�n bulundu�u program 
					;sayfas� se�ildi.
	goto 	Ana_program		;Ana programa git.

	ORG 	4
;-------------------------------------------------------------------
; hc597_Oku alt program�, 1 byte veriyi donan�m mod�llerini
; kullanmadan yaln�zca yaz�l�m ile 74HC597 entegresinden okuyup 
; i�lemciye transfer eder.
;-------------------------------------------------------------------
hc597_Oku
	Banksel hc597_port		;hc597_port'nin bulundu�u 
					;bank se�ildi.
	bsf	hc597_port, LATCH_Pin	;Anahtarlardan bilgi Latch'a 
					;al�n�yor.
	nop
	bcf	hc597_port, LATCH_Pin
	bcf	hc597_port, LOAD_Pin	;Latch'taki bilgi kayd�rmal� 
					;kaydediciye aktar�l�yor.
	nop
	bsf	hc597_port, LOAD_Pin

	movlw	8			;i de�i�kenine 8 bilgisi y�klendi.
	movwf	i			;i, 8 bit�in de al�nd���n� kontrol 
					;etmek i�in kullan�l�yor.
hc597_j0
	rlf	hc597_data, F
	btfss	hc597_port, DATA_Pin	;Data pininden gelen veri 1 
					;ise bir komut atla.
	goto	hc597_j1		;Gelen veri 0, o halde 
					;hc597_j1'e git.
	bsf	hc597_data, 0		;hc597_data de�i�keninin 0.
					;bit�ini set et.
	goto	hc597_j2		;Clock palsi i�in devam.
hc597_j1
	bcf	hc597_data, 0		;hc597_data de�i�keninin 0. 
					;bit�ini reset et.
hc597_j2
	bsf	hc597_port, CLK_Pin	;74HC597'in CLK pinine inen 
					;darbe kenar� uygulan�yor.
	nop
	bcf	hc597_port, CLK_Pin
	decfsz	i, F			; i sayac�n� bir azalt ve 8 bit�in
					;tamam� okundu ise bir komut atla.
	goto	hc597_j0
	return
;-------------------------------------------------------------------
; delay_ms alt program� 1-255 ms aras�nda de�i�ken bekleme s�resi 
; sa�lar delay_ms_data y�ksek byte de�i�kenine y�klenecek de�er 
; kadar ms olarak gecikme sa�lar.
;-------------------------------------------------------------------
delay_ms
delay_j0
	movlw	D'142'			;1 ms gecikme i�in taban de�er.
	movwf	delay_ms_data+1		;delay parametresinin d���k 
					;byte'�na y�klendi.
	nop				;2 us bekle.
	nop
delay_j1
	nop				;4 us gecikme.
	nop
	nop
	nop
	decfsz	delay_ms_data+1, F	;delay parametresinin d���k 
					;byte'�n� azalt s�f�rsa komut atla.
	goto	delay_j1		;Hen�z 1 ms gecikme sa�lanamad�, 
					;d���k byte'� azaltmaya devam et
	nop				;1 us bekle.
	decfsz	delay_ms_data, F	;delay parametresinin y�ksek 
					;byte'�n� azalt s�f�rsa komut atla.
	goto	delay_j0		;1 ms beklemeyi tekrarla.
	nop				;1 us bekle.
	return				;Alt programdan ��k��.
;-------------------------------------------------------------------
; delay_5s alt program� 5 saniye gecikme i�in 20 kez 250 ms gecikme 
; i�lemi ger�ekle�tirir. Delay sonucunda 5 saniyeye �ok yak�n bir 
; gecikme sa�lan�r.
;-------------------------------------------------------------------
delay_5s
	movlw	0x14			;20 * 250ms = 5000ms 
	movwf	i
delay_5s_j0	
	movlw	D'250'			;250 ms de�erini delay_ms_data 
					;de�i�kenine yaz.
	movwf	delay_ms_data	
	call	delay_ms		;250 ms bekle.
	decfsz	i, F
	goto	delay_5s_j0
	return
;-------------------------------------------------------------------
; Ana program 74HC597 entegresine ba�l� anahtarlardan al�nan 
; bilginin donan�m mod�lleri kullan�lmadan yaln�zca yaz�l�m ile 
; okunarak PORTB�nin en de�erli 4 ��k���nda (RB7 - RB4) 5 sn 
; aral�klarla g�r�nt�lenmesini sa�lar.
;-------------------------------------------------------------------
Ana_program
	banksel TRISB			;TRISB�nin bulundu�u banka ge�.
	movlw	2
	movwf	TRISB			;PORTB�nin RB1 pini giri�, di�er 
					;pinleri ��k�� yap�ld�.
	Banksel PORTB			;PORTB�nin bulundu�u banka ge�.
	clrf	PORTB			;PORTB'nin pinlerinin ilk andaki 
					;��k��lar� s�f�r.
Ana_j0
	call	hc597_Oku		;hc597_data de�i�kenindeki de�eri 
					;74HC597�e yaz.
	movf	hc597_data, W		;hc597_data de�i�keninde bulunan 
					;veriyi W�ye aktar.
	andlw	0xF0			;Verinin en de�erli 4 bit�ini al.
	movwf	PORTB			;En de�erli 4 anahtar�n konumlar�n� 
					;PORTB�nin RB7-RB4 ��k��lar�nda 
					;g�ster.
	call	delay_5s		;5 saniye bekle.
	swapf	hc597_data, W		;hc597_data de�i�keninde bulunan 
					;verinin en de�erli ve en de�ersiz 
					;4 bit�ini yer de�i�tirerek W�ye 
					;aktar.
	andlw	0xF0			;Verinin en de�ersiz 4 bit�i art�k 
					;W�nin en de�erli 4 bit�i durumunda
	movwf	PORTB			;En de�ersiz 4 anahtar�n 
					;konumlar�n� PORTB�nin RB7-RB4 
					;��k��lar�nda g�ster.
	call	delay_5s		;5 sn bekle.
	goto	Ana_j0			;Ana_j0 etiketine git.

	END
;*******************************************************************

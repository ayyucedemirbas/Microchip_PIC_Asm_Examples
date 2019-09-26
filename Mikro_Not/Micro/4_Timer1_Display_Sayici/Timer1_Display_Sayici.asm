	list p=16f877
	include "p16f877.inc"
	ORG 0
	goto ana_program
	Sayac_Display equ 0x25
	Sayac equ 0x26
	clrf PCLATH
	ORG 4
	
Kesme
	Banksel PIR1
	bcf PIR1,TMR1IF             ; Bayrak indir
	decfsz Sayac,1
	retfie

	movlw 10
	movwf Sayac
	
	call Lookup	
	movwf PORTD
	
	incf Sayac_Display
	retfie
	
ana_program
	Banksel TRISD
	clrf TRISD
	
	Banksel T1CON               ; (0010 0001) 4,5 Bitler Prescaler, 1.Bit Clock secme, 0.Bit Timer1 Açma 
	movlw 0x21
	movwf T1CON

	bcf PIR1,TMR1IF             ; Bayrak indir

	movlw 1
	movwf Sayac
	clrf Sayac_Display

	Banksel PIE1                ; Timer1 Kesmesine izin ver.
	bsf PIE1,TMR1IE

	movlw 0xC0		                ; 11000000 Workinge atýldý
	movwf INTCON		            ; Gýe ve Peýe set edildi tüm kesmeleri ve çevresel kesmeler aktif


Dongu
	goto Dongu

Lookup
	movf Sayac_Display,0
	addwf PCL,1
	
	nop
	retlw b'00111111';0             
	retlw b'00000110';1
	retlw b'01011011';2
	retlw b'01001111';3
	retlw b'01100110';4
	retlw b'01101101';5
	retlw b'01111101';6
	retlw b'00000111';7
	retlw b'01111111';8
	clrf Sayac_Display
	retlw b'01100111';9
	
	END

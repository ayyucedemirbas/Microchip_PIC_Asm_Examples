
	list p=16F877A
	include "p16F877A.inc"	
	__config H'3F31' 		;PWRT on, diðerler sigortalarý 
					;kapalý, Osilatör XT ve 4Mhz
;-------------------------------------------------------------------
; Deðiþkenler tanýmlamalarý.	
;-------------------------------------------------------------------
say EQU 0X20
topla EQU 0X21
ds1 EQU 0X22
ds2 EQU 0X23
ds3 EQU 0X24
say1  EQU 0X25
	ORG 	0			
	clrf 	PCLATH			
	goto 	ana_program		
	ORG	4			
Kesme				
	Retfie

ana_program
	Banksel TRISA
	movlw H'01'
	movwf 	TRISA		
	clrf 	TRISD			
	bcf 	STATUS, RP0	
	clrf say
	clrf topla
	clrf ds1
	clrf ds2
	clrf ds3	
	clrf 	PORTD
	movlw B'11110000'
	movwf PORTA		
	movlw 	b'11000001'
	movwf 	ADCON0		
	movlw 	b'10001110'
	bsf 	STATUS, RP0		
	movwf 	ADCON1			
	bcf 	STATUS, RP0	
	bsf    ADCON0,2           ;BAÞLA
bekle
	btfsc 	ADCON0, 2		;Dönüþtürme tamamlanana kadar bekle
	goto 	bekle
	bsf 	STATUS, RP0	
	movf ADRESL,W
	bcf 	STATUS, RP0	
	movwf say
	btfsc say,0	         				
	call bir
	btfsc say,1
	call iki
	btfsc say,2
	call dort
	btfsc say,3
	call sekiz
	btfsc say,4
	call onaltý
	btfsc say,5
	call otuz2
	btfsc say,6
	call atmýs4
	btfsc say,7
	call yuz28
;;;;DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
	goto cozumle
bir
	incf topla,F
	return
iki
	movlw D'2'
	addwf topla
	return
dort
	movlw D'4'
	addwf topla
	return
sekiz
	movlw D'8'
	addwf topla
	return
onaltý
	movlw D'16'
	addwf topla
	return
otuz2
	movlw D'32'
	addwf topla
	return
atmýs4
	movlw D'64'
	addwf topla
	return
yuz28
	movlw D'128'
	addwf topla
	return
cozumle
	movlw D'100'
	subwf topla,W
	btfss STATUS,C	
	goto birler
	movwf ds2
	incf ds3,F
	goto cozumle
birler
	movlw D'10'
    subwf topla,W
	btfss STATUS,DC
    goto yaz
	movwf ds2
	goto birler

gecik
    nop
	nop
	decfsz say1,1
	goto gecik
	movlw D'250'
	movwf say1
	return
tablo
	addwf	PCL, F
	retlw	0x3F		; 0 rakamý için segment deðeri.
	retlw	0x06		; 1 rakamý için segment deðeri.
	retlw	0x5B		; 2 rakamý için segment deðeri.
	retlw	0x4F		; 3 rakamý için segment deðeri.
	retlw	0x66		; 4 rakamý için segment deðeri.
	retlw	0x6D		; 5 rakamý için segment deðeri.
	retlw	0x7D		; 6 rakamý için segment deðeri.
	retlw	0x07		; 7 rakamý için segment deðeri.
	retlw	0x7F		; 8 rakamý için segment deðeri.
	retlw	0x6F		; 9 rakamý için segment deðeri.
yaz
    bsf PORTA,1
	movf ds1
	call tablo
	movwf PORTD
	bsf PORTA,1
	call gecik
	bsf PORTA,2
	movf ds2
	call tablo
	movwf PORTD
	bsf PORTA,2
	call gecik
    bsf PORTA,3
	movf ds3
	call tablo
	movwf PORTD
	bsf PORTA,3
	call gecik
	goto yaz

	END
;*******************************************************************

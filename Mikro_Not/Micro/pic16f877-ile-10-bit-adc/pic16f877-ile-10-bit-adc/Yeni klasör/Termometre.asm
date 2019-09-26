	LIST P=16F877A						
	ERRORLEVEL  -302  
;--------
	include <p16F877A.inc>	 
	__CONFIG _CP_OFF &_WDT_OFF &_PWRTE_ON &_HS_OSC &_BODEN_OFF &_LVP_OFF &_CPD_OFF
	ONE     EQU     H'06'
	TWO     EQU     H'5B'
	THREE   EQU     H'4F'
	FOUR    EQU     H'66'
	FIVE    EQU     H'6D'
	SIX     EQU     H'7D';
;------
	ZERO    EQU     H'3F'	

	SEVEN   EQU     H'07'
	EIGHT   EQU     H'7F'	
	NINE    EQU     H'6F'
;------
	DEGER	EQU	H'0020'
	DEGERH	EQU	H'0021'
	DEGERL	EQU	H'0022'
	DEGER3	EQU	H'0023'
	SAYI1	EQU	H'0024'
	SAYI2	EQU	H'0025'
	SAYI3	EQU	H'0026'
	SAYI4	EQU	H'0027'
	D1	EQU	H'0028'
	D2	EQU	H'0029'
	D3	EQU	H'002A'
	D4	EQU	H'002B'
	LSB	EQU	H'002C'
	MSB	EQU	H'002D'
	TEMP	EQU	H'002E'
	BEKLEM	EQU	H'002F'
	TOPLA1	EQU	H'0034'
	TOPLA2	EQU	H'0035'
	TOPLA3	EQU	H'0036'
;---------
	ORG	00H 
	GOTO	START
;-------------
START
	CLRF	PORTA		;
	CLRF	PORTB		;
	CLRF	PORTC		;lcd
	CLRF	PORTD		;lcd
	CLRF	DEGER		;Degiskenler
	CLRF	DEGERH		;
	CLRF	DEGERL		;
	CLRF	DEGER3		;
	CLRF	SAYI1		;
	CLRF	SAYI2		;
	CLRF	SAYI3		;
	CLRF	SAYI4		;
	CLRF	D1			;
	CLRF	D2			;
	CLRF	D3			;
	CLRF	D4			;
	CLRF	LSB			;
	CLRF	MSB			;
	CLRF	TEMP		;	
	CLRF	BEKLEM		;
	MOVLW	H'C1'	;
	MOVWF	ADCON0		;--------
	BSF     STATUS,RP0	;bank 1
	MOVLW	H'01'	;
	MOVWF	TRISA   ;   
	CLRF	TRISB   ;   
	CLRF	TRISC	;
	CLRF	TRISD	;
	CLRF	TRISE	;			
	MOVLW	H'8E'	;
	MOVWF	ADCON1	;	
	MOVLW	B'10000111'	;	
	MOVWF	OPTION_REG	;
	BCF     STATUS,RP0  ; 	  
	GOTO	ANA			;
;------------------------------
ADC
	MOVLW	.250
	MOVWF	TEMP
ADBEKLE
	DECFSZ	TEMP,F
	GOTO	ADBEKLE
	MOVLW	.250
	MOVWF	TEMP
ADBEK2
	DECFSZ	TEMP,F
	GOTO	ADBEK2	
	BSF	ADCON0,GO	;Start A/D conversion
TARA
	BTFSC	ADCON0,GO		;tarama devam ediyorsa burda kal
	GOTO	TARA			;tarama bittiginde 
	BSF	STATUS,RP0			;burda
	MOVF	ADRESL,W		;
	BCF	STATUS,RP0
	MOVWF	DEGERL
	MOVF	ADRESH,W
	MOVWF	DEGERH
	RETURN
;-----------------------
;-----------------------
BEKLE
	MOVLW	.10		 	
	MOVWF	MSB
D11	
	MOVLW	.150
	MOVWF	LSB
D22
	DECFSZ	LSB,F
	GOTO	D22
	DECFSZ	MSB,F
	GOTO	D11
;-------
	RETURN
;-----------------------
HESAP
	MOVLW	.0			;
	MOVWF	SAYI1		;
	MOVWF	SAYI2		;	
	MOVWF	SAYI3		;
	MOVWF	SAYI4		;sayi1,2,3,4=0	
HES						
	MOVLW	.100		;
	SUBWF	DEGER,W		;	
	BTFSS	STATUS,C	;cýkarma negatif olana kadar c=1dir	
	GOTO	HES1		;sayý2 herneyse yuzler basamagý o olarak doner
	MOVLW	.100		;
	SUBWF	DEGER,F		;deger -=100;
	INCF	SAYI2,F		;sayý++;
	GOTO	HES	
HES1
	MOVLW	.10			;	
	SUBWF	DEGER,W		;
	BTFSS	STATUS,C	;	
	GOTO	HES2		;
	MOVLW	.10			;
	SUBWF	DEGER,F		;
	INCF	SAYI3,F		;
	GOTO	HES1		;	
HES2	
	MOVLW	.1
	SUBWF	DEGER,W
	BTFSS	STATUS,C
	GOTO	HESSON
	MOVLW	.1
	SUBWF	DEGER,F
	INCF	SAYI4,F
	GOTO	HES2		
HESSON
	RETURN

;-----------------------------------------------------------------
ANA	
	CALL	ADC				;burayý kesmede yapcaz
	MOVF	DEGERL,W		;
	MOVWF	DEGER			;
	CALL	HESAP			;adresl yi yuzler onlar býrler boluyo
	CALL	HESAP2			;
	MOVF	SAYI1,W			;
	MOVWF	D1				;
	MOVF	SAYI2,W			;
	MOVWF	D2				;
	MOVF	SAYI3,W			;
	MOVWF	D3				;
	MOVF	SAYI4,W			;
	MOVWF	D4				;
	CALL	DISPTARA		;
	MOVF	DEGERL,W		
	MOVWF	PORTB
	MOVF	DEGERH,W
	MOVWF	PORTE
	GOTO	ANA
;-------------------------------------------------------------------
DISPTARA
	;BSF	PORTA,0
	BSF	PORTA,1
	BSF	PORTA,2
	BSF	PORTA,3;portc 				
	MOVLW	.0    
	SUBWF	D1,W       
	BTFSS	STATUS,Z
	GOTO	DIS0
	GOTO	TEST1
DIS0
	BSF	PORTA,1
	BSF	PORTA,2
	BSF	PORTA,3 
      ;  BCF   PORTC,0
        MOVF    D1,W
        CALL	KODLA
	MOVWF   PORTD 
	CALL	BEKLE 
	;BSF   PORTC,0
	GOTO	DIS1
;---------------------------
TEST1
	MOVLW	.0    
	SUBWF	D2,W       
	BTFSS	STATUS,Z
	GOTO	DIS1
	GOTO	TEST2
DIS1
	BSF	PORTA,2
	BSF	PORTA,3 	
        BCF   	PORTA,1
        MOVF    D2,W
	CALL	KODLA
        MOVWF   PORTD
	CALL	BEKLE
	BSF   PORTA,1
	GOTO	DIS2
;---------------------------
TEST2

	MOVLW	.0    
	SUBWF	D3,W       
	BTFSS	STATUS,Z
	GOTO	DIS2
	GOTO	DIS3
DIS2
	;BSF   PORTA,0
	BSF   PORTA,3
        BCF   PORTA,2
        MOVF    D3,W
	CALL	KODLA
	MOVWF   PORTD
	CALL	BEKLE 
	BSF   PORTA,2
	GOTO	DIS3
;---------------------------
DIS3
	;BSF   PORTA,0
	BSF   PORTA,1
        BCF   PORTA,3
        MOVF    D4,W
	CALL	KODLA
	MOVWF   PORTD
	CALL	BEKLE 
	BSF   PORTA,3
;-------
	RETURN
;***************************************************
HESAP2
	MOVLW	.0			;256 oldugunu anlamak ýcýn
	SUBWF	DEGERH,W	;
	BTFSC	STATUS,Z	;255den 0a gecerken z=1 olur	
	RETURN				;
	BTFSC	DEGERH,0	;	
	GOTO	YAZ256		;
DEVAM
	BTFSC	DEGERH,1	;512 oldugunu anlamak ýcýn	
	GOTO	YAZ512		;
	RETURN
SONUC					;
	MOVLW	.10			;
	SUBWF	SAYI4,W		;birler basamagý
	BTFSC	STATUS,C	;	
	CALL	BUYUK		;	
	MOVLW	.10			;
	SUBWF	SAYI3,W		;
	BTFSC	STATUS,C	;
	CALL	BUYUK1		;
	MOVLW	.10			;
	SUBWF	SAYI2,W		;
	BTFSC	STATUS,C	;	
	CALL	BUYUK2		;
	RETURN				;
BUYUK					
	MOVWF	SAYI4	
	INCF	SAYI3,F
	RETURN
BUYUK1
	MOVWF	SAYI3	
	INCF	SAYI2,F
	RETURN
BUYUK2
	MOVWF	SAYI2	
	INCF	SAYI1,F
	RETURN
YAZ256
	MOVLW	.2
	ADDWF	SAYI2,F
	MOVLW	.5
	ADDWF	SAYI3,F
	MOVLW	.6
	ADDWF	SAYI4,F
	CALL	SONUC
	GOTO	DEVAM
YAZ512
	MOVLW	.5
	ADDWF	SAYI2,F
	MOVLW	.1
	ADDWF	SAYI3,F
	MOVLW	.2
	ADDWF	SAYI4,F
	CALL	SONUC
	RETURN
;------------------------------------------------------------------

KODLA
        ADDWF   PCL,1
        RETLW   ZERO
        RETLW   ONE
        RETLW   TWO
        RETLW   THREE
        RETLW   FOUR
        RETLW   FIVE
        RETLW   SIX
        RETLW   SEVEN
        RETLW   EIGHT
        RETLW   NINE
	END

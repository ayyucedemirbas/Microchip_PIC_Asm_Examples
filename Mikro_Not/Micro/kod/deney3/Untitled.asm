list p=16F877A
#include<p16F877A.inc>
SAYAC1 EQU 0x23
TEMP EQU 0x21
PWMSET EQU 0x22
SAYAC2 equ 0X24




ORG 0
GOTO ANA
ORG 4
KESME
BTFSS INTCON,0
RETFIE
BCF INTCON,0
BTFSS PORTB,6
GOTO ARTIR
BTFSS PORTB,7
GOTO AZALT
RETFIE


ARTIR
BANKSEL PWMSET
MOVLW .100
SUBWF PWMSET,W
BTFSS STATUS,C
INCF PWMSET,1
MOVLW .255
MOVWF SAYAC1
CALL GECIK
CALL PWMYAP
RETFIE
AZALT
BANKSEL PWMSET
MOVF PWMSET,0
SUBLW .0
BTFSS STATUS,C
DECF PWMSET,1
MOVLW .255
MOVWF SAYAC1
CALL GECIK
CALL PWMYAP
RETFIE

GECIK

movlw 0xFF                        ; workinge 255 deðeri veriliyor
	movwf SAYAC2                      ; Sayac2 = 255 yapýlýyor 
	decfsz SAYAC1,1                   ; Sayac1 den 1 çýkarýlýyor ve sonuc Sayac1 re yazýlýyor. Sayac1 0 olursa 1 Komut atlar
	goto Gecikme_Dongusu              ; Sayac1 0 olmamýþsa Gecikme_Dongusu alt programýna dallanýyor
	return	                          ; Sayac1 0 olduysa çaðrýldýðý yere geri dönüyor.

Gecikme_Dongusu                       ; Bu döngüde 8 normal komut 1 dallanma komutu toplamda 10 komut ve 255 döngü ile toplamda =2550 komut icra eder
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decfsz SAYAC2,1                   ; Sayac2 den 1 çýkarýlýyor ve sonuc Sayac2 ye yazýlýyor Sayac2 0 olursa 1 komut atlar
	goto Gecikme_Dongusu              ; Sayac2 0 olmadýysa Gecikme_Dongusune dallanýyor.
	goto GECIK  





ANA
BANKSEL PORTB
CLRF PORTB
BANKSEL TRISB
MOVLW h'F0'
MOVWF TRISB
BANKSEL TRISC
BCF TRISC,2
BANKSEL INTCON
MOVLW b'10001000'
MOVWF INTCON
BANKSEL T2CON
MOVLW b'00000110'
MOVWF T2CON
BANKSEL CCP1CON
MOVLW b'00001100'
MOVWF CCP1CON
BANKSEL CCPR1L
CLRF CCPR1L
BANKSEL PR2
MOVLW .24
MOVWF PR2
BANKSEL PWMSET
MOVLW .50
MOVWF PWMSET
BANKSEL SAYAC1
CLRF SAYAC1
CLRF SAYAC2
CALL PWMYAP

DONGU
GOTO DONGU

PWMYAP
BANKSEL PWMSET
MOVF PWMSET,0
ANDLW .3
MOVWF TEMP
SWAPF TEMP,0
ANDLW 0xF0
IORLW 0x0C
BANKSEL CCP1CON
MOVWF CCP1CON

BANKSEL PWMSET
MOVF PWMSET,0
MOVWF TEMP
RRF TEMP,1
RRF TEMP,0
ANDLW 0x3F
BANKSEL CCPR1L
MOVWF CCPR1L
RETURN

     

 


END
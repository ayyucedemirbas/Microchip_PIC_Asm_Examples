list p=16F877A
#include <P16F877A.inc>
sayac0 EQU 0x20 
sayac1 equ 0x21
sayac2 equ 0x22
sayac3 equ 0x24
sondeger equ 0x25
org 0x00
goto anaprogram
org 0x04
kesme 
btfss PIR1,0
goto KESME_BITIR
movwf sondeger
movlw H'3C'
movwf TMR1H
movlw H'B0'
movwf TMR1L
movlw D'9'
subwf sayac0,W
btfsc STATUS,Z
goto DISPLAY1
incf sayac0,F
goto KESME_BITIR

DISPLAY1
clrf sayac0
movlw D'9'
subwf sayac1,W
btfsc STATUS,Z
goto DISPLAY2
incf sayac1,F
goto KESME_BITIR

DISPLAY2
clrf sayac1
movlw D'9'
subwf sayac2,W
btfsc STATUS,Z
goto DISPLAY3
incf sayac2,F
goto KESME_BITIR

DISPLAY3
clrf sayac2
movlw D'10'
subwf sayac3,W
btfsc STATUS,Z
clrf sayac3
incf sayac3,F

KESME_BITIR
movf sondeger,W
bcf PIR1,0
retfie

table
addwf PCL,F
retlw 0x3F
retlw 0x06
retlw 0x5B
retlw 0x4F
retlw 0x66
retlw 0x6D
retlw 0x7D
retlw 0x07
retlw 0x7F
retlw 0x6F

anaprogram
clrf sayac0
clrf sayac1
clrf sayac2
clrf sayac3
bsf STATUS,RP0
movlw h'00'
movwf TRISA 
clrf TRISD
bsf PIE1,0
bcf STATUS,RP0
movlw H'3C'
movwf TMR1H
movlw H'B0'
movwf TMR1L
movlw H'31'
movwf T1CON
movlw H'C0'
movwf INTCON


dongu 
bcf PORTA,0
movf sayac0,w
call table
movwf PORTD
bsf PORTA,0

bcf PORTA,1
movf sayac1,w
call table
movwf PORTD
bsf PORTA,1

bcf PORTA,2
movf sayac2,w
call table
movwf PORTD
bsf PORTA,2

bcf PORTA,3
movf sayac3,w
call table
movwf PORTD
bsf PORTA,3

goto dongu
end


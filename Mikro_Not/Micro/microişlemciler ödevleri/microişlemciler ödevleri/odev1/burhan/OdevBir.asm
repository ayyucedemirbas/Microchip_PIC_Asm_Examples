list p=16f877A
#include <16F877A.INC>
ORG 0X000
SAY EQU h'25'
goto ana program
org 0X004
goto kesme
anaprogram
        bcf STATUS,RP0
        clrf PORTD
        movlw b'10010000'
        movwf INTCON
        bsf STATUS,RP0
        clrf TRISD
        bsf STATUS,C
        bcf OPTION_REG,INTEDG
        movlw h'01'
        movwf TRISB
        bcf STATUS,RP0
        MOVLW h'00'
        movwf SAY
        movwf PORTD
dongu
        goto dongu
kesme
        bcf INTCON,INTF
        rlf SAY,1
        btfsc STATUS,0
        goto dvm
        movf SAY,0
        movwf PORTD
    retfie
dvm
        bcf STATUS,C
        movlw h'01'
        movwf SAY
        movwf PORTD
retfie
    end

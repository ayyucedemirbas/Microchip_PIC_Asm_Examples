list p=16F877A
#include <P16F877A.inc>
ORG 0x000
goto ana_program
ORG 0x004
BCF STATUS,RP0
BCF INTCON, INTF; RB0 Flagýný resetle
BSF PORTB,7; Port'u yak
RETFIE
ana_program
CLRF PORTB; PORTB'yi temizle
MOVLW B'10010000'; GIE ve INTE aktif
MOVWF INTCON; RB0'dan kesme aktifleþtirildi
BSF STATUS,RP0; Bank-1'e geç
;BCF OPTION_REG,6
BCF OPTION_REG,7; Pull-up dirençler aktif
MOVLW B'00000011';PORTB'nin 0 ve 1. biti giriþ diðerleri çýkýþ
MOVWF TRISB
BCF STATUS,RP0;Bank-0'a gecis
DONGU
BTFSC PORTB,1;1 nolu bit (basýldýðýnda)0 ise söndür
goto DONGU
BCF PORTB,7;söndür
GOTO DONGU
END
list p=16F877A
#include <P16F877A.inc>
ORG 0x000
goto ana_program
ORG 0x004
BCF STATUS,RP0
BCF INTCON, INTF; RB0 Flag�n� resetle
BSF PORTB,7; Port'u yak
RETFIE
ana_program
CLRF PORTB; PORTB'yi temizle
MOVLW B'10010000'; GIE ve INTE aktif
MOVWF INTCON; RB0'dan kesme aktifle�tirildi
BSF STATUS,RP0; Bank-1'e ge�
;BCF OPTION_REG,6
BCF OPTION_REG,7; Pull-up diren�ler aktif
MOVLW B'00000011';PORTB'nin 0 ve 1. biti giri� di�erleri ��k��
MOVWF TRISB
BCF STATUS,RP0;Bank-0'a gecis
DONGU
BTFSC PORTB,1;1 nolu bit (bas�ld���nda)0 ise s�nd�r
goto DONGU
BCF PORTB,7;s�nd�r
GOTO DONGU
END
list p=16F877A
#include <P16F877A.inc>
__config H'3F31'
TEMP1 EQU 0X20;CCPR1L i�eri�ini yedeklemek i�in
TEMP2 EQU 0X21;kontrol i�in

ORG 0X00
GOTO ANA_PROGRAM 
ORG 0X004; 
KESME;---------------------------------
BCF STATUS,RP0 ; 00 nolu banka ge�i� yap�ld�
BTFSS PIR1,1 ;TMR2 bayara�� kalkm�� m�
GOTO ATLA ;TMR2 kesmesi de�ilse git RB0 kesmesini kontrol et
BCF PIR1,1 ;TMR2 kesmesi ise bayra�� indir

GOTO KESME_B�T�R ;kesmeyi bitir
ATLA;--------------------------
BTFSS INTCON,1 ;RB0 kesme bayra�� kalkm�� m�?
GOTO KESME_B�T�R ;kalkmam�� ise kesmeyi bitir
INCF TEMP2,F ;TEMP2 i�eri�ini 1 art�r
MOVLW D'9'
SUBWF TEMP2,W ;TEMP2-WORK�NG(9) U WORK�NG e at
BTFSS STATUS,2 ;Zero fla��n� kontrol et
GOTO �SLEM
GOTO B�T�R
�SLEM;----------------
BCF INTCON,1 ;RB0 kesme bayra��n� indir
MOVLW D'25' ; her RB0 kesmesinde CCPR1L registerin� 25 azalt
SUBWF TEMP1,F ;TEMP1- WORK�NG(25) TEMP1 E Y�KLE
MOVF TEMP1,W ;TEMP1'i WORK�NG e at
MOVWF CCPR1L ;Working i CCPR1L ye y�kle
GOTO KESME_B�T�R ;kesmeyi bitir
B�T�R;-----------------
BCF INTCON,4 ;RB0 ;RB0 kesmesine izin verme
GOTO KESME_B�T�R ;kesmeyi bitir
 KESME_B�T�R;--------------------------
 RETFIE
 ANA_PROGRAM;------------------------------ 
 BSF STATUS,RP0;01 nolu banka ge�
 BCF TRISC,2 ;RC2 pinini ��k�� yap
 BSF TRISB,0 ;RB0 pinini giri� yap
 BCF OPTION_REG,7 ;pull-up aktif yap
 BSF OPTION_REG,6 ;RB0 giri�i y�kselen kenar se�ildi
 MOVLW B'11010000' ;t�m kesmeler,�evresel kesmeler,RB0 kesmesine izin ver
 MOVWF INTCON ;izinler ayarland�
 BSF PIE1,1 ; TMR2 kesmesine izin ver
 MOVLW D'249' ; PR2 de�eri hesaplanarak  
 MOVWF PR2  ; y�klendi
 BCF STATUS,RP0  ;00 nolu banka ge�
CLRF PORTC ; portc yi temizle
 MOVLW B'00000101';TMR2 yi aktif et ve prescaler'� 1/4 ayarla
 MOVWF T2CON ;y�kle
 MOVLW B'00001100' ;pwm modu se�ildi
 MOVWF CCP1CON ; y�klendi
 MOVLW B'11100001' ; CCPR1L + CCP1CON(5,4)=900 YAN�(11100001 00) "10 B�T olmas� sa�land�
 MOVWF CCPR1L ;y�zde 90 g�rev peryodu ayarlanm�� olsu
 MOVWF TEMP1 ;kesmede kullanmak CCPR1L yi TEMP1 e y�kle
 
 DONGU 
 GOTO DONGU
END
 
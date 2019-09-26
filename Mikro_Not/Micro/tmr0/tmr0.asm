list p=16F877A;derleyici i�in bilgi verildi
#include <P16F877A.inc>;gerekli isim-adress e�le�mesi yap�ld�
__config H'3F31'
SAYAC1 EQU 0X20;sayac1 de�i�keni adresi tanmland�
SAYAC2 EQU 0X22;sayac2 de�i�keni adresi tanmland�
SAYAC3 EQU 0X25;sayac3 de�i�keni adresi tanmland�
ORG 0X00;reset vekt�r adresi
GOTO ANA_PROGRAM ;ana programa git
ORG 0X004; ;kesme vekt�r adresi
KESME;--------------------------------------------------------------
BTFSS INTCON,5;tmr0 kesmesine izin verilmi� mi bak
GOTO KESME_B�T�R
BTFSS INTCON,2 ;tmr0 kesmesi bayra�� kalkm�� m� bak
GOTO KESME_B�T�R
BCF INTCON,2 ;tekrar kesme gelebilmesi i�in bayra�� indir
MOVLW D'6' ; 
MOVWF TMR0; tmr0'a 6 �n de�erini y�kle
INCF SAYAC1,F ;sayac1'in de�erini art�r
INCF SAYAC2,F; sayac2'in de�erini art�r
MOVLW D'125' 
SUBWF SAYAC1,W ;sayac1 - working
BTFSS STATUS,C ; sayac1-working>=0 ise c=1 olur
GOTO KONTROL 
GOTO LEDYAK1 ;c=1 ise 1.led yak
KONTROL;------------------------------------------------------------
MOVLW D'200' 
SUBWF SAYAC2,W ;sayac2 - working
BTFSS STATUS,C ;sayac2 - working>=0 ise c=1
GOTO KESME_B�T�R
CLRF SAYAC2 ;sayac2 s�f�rla
BTFSS PORTD,1 ;led2 yan�yor mu?
GOTO YAK2 ;s�n�kse yak
BCF PORTD,1 ;yan�yorsa s�nd�r
GOTO KESME_B�T�R
LEDYAK1;------------------------------------------------------------
INCF SAYAC3,F ;kesi�im kontrol� i�in saya�
CLRF SAYAC1 ;sayac1 i s�f�rla
BTFSC SAYAC3,3 ;sayac3 8 mi
GOTO KES�S�M;sayac3 8 oldu ise git kesisim'e
BTFSS PORTD,0 ; led1 yan�yormu
GOTO YAK1 ;s�n�kse yak
BCF PORTD,0 ;yan�ksa s�nd�r
GOTO KESME_B�T�R
KES�S�M;----------------------------------------------------------------
CLRF SAYAC2 ;sayac2 s�f�rla
CLRF SAYAC3  ;sayac1 s�f�rla
BTFSS PORTD,0 ;led1 yan�yormu?
GOTO YAK1 ;yanm�yorsa yak
BCF PORTD,0 ;yan�yorsa s�nd�r
BTFSS PORTD,1 ;led2 yan�yormu?
GOTO YAK2 ;yanm�yorsa yak
BCF PORTD,1;yan�yorsa s�nd�r
KESME_B�T�R;--------------------------------------------------------
RETFIE
YAK1;---------------------------------------------------------------
BSF PORTD,0
GOTO KESME_B�T�R
YAK2;---------------------------------------------------------------
BSF PORTD,1
GOTO KESME_B�T�R
ANA_PROGRAM;--------------------------------------------------------
BSF STATUS,RP0 ;01 nolu banka ge�i� yap�ld�
CLRF TRISD ;portd ��k�� yap�ld�
MOVLW B'00000100' ; prescaler de�eri 1/16 yap�ld�
MOVWF OPTION_REG 
MOVLW B'10100000' ;genel ve tmr0 kesmelerine izin verildi
MOVWF INTCON
BCF STATUS,RP0 ;00 nolu bank'a ge�ildi
CLRF PORTD ;portd s�f�rland�
MOVLW D'6' ;tmr0 6 �n de�eri y�klendi
MOVWF TMR0 
CLRF SAYAC1 ;s�f�rlama i�lemleri yap�ld�
CLRF SAYAC2
CLRF SAYAC3
DONGU
GOTO DONGU ;d�n
END

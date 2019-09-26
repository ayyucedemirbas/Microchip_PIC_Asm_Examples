list p=16F877A;derleyici i�in bilgi verildi
#include <P16F877A.inc>;gerekli isim-adress e�le�mesi yap�ld�
__config H'3F31'
sayac EQU 0X20 ;saycac de�i�keninin adresi g�sterildi
degisken EQU 0X25; adres belirtildi
ORG 0X00;ba�lang�� adresi belirtildi
GOTO ana_program ;ana programa git
ORG 0X004; ;kesme alt program�n�n ba�lang�� adresi
kesme;kesme alt program�n�n etiketi

BSF STATUS,RP0 ;01 nolu banka ge�
BTFSS INTCON,1 ;INCON register �n�n 1. biti(RB0 kesme bayra��) 1 ise bir sonraki kod a ge�
GOTO kesme_bitir ; kesme alt program�ndan ��k
BCF INTCON,1 ;kesme bayra��n� indir
INCF sayac,F ;sayac �n de�erini 1 art�r sayaca yaz
MOVLW D'10' ;working register �na  10 de�erini y�kle
SUBWF sayac,W ;sayac-10 
BTFSS STATUS,C ;c elde biti olu�mu� ise bir sonraki kod a ge�
GOTO say_basla ;say_basla etiketine git
GOTO ana_program ;ana_program etiketine git
say_basla 

INCF degisken,F ;de�i�kenin de�erini 1 art�r
SWAPF degisken,W ;de�i�kenin de�erini swap yap  working e kaydet
BCF STATUS,RP0 ; 00 nolu bank a ge�
MOVWF PORTD ;working registerindaki de�eri portd ye yaz
GOTO kesme_bitir ;kesme bitir
kesme_bitir

RETFIE
ana_program

CLRF sayac ;sayac i�eri�ini s�f�rla
CLRF degisken ;de�i�ken i�eri�ini s�f�rla
BSF STATUS,RP0 ;01 nolu banka ge�
BCF OPTION_REG,7 ;pull-upp dire�lerini aktif yap
CLRF TRISD ; portD ��k�� oldu
BSF TRISB,0 ;portB nin 0. biti giri� oldu
MOVLW B'10010000' ;de�eri working e y�kle
MOVWF INTCON ;genel ve harici kesme i�in izin verildi
BCF STATUS,RP0 ;00 nolu bayra�a ge�
CLRF PORTD ;PortD yi s�f�rla
dongu
GOTO dongu ;d�ng�......
END




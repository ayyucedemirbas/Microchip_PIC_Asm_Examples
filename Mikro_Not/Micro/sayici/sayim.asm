list p=16F877A;derleyici için bilgi verildi
#include <P16F877A.inc>;gerekli isim-adress eþleþmesi yapýldý
__config H'3F31'
sayac EQU 0X20 ;saycac deðiþkeninin adresi gösterildi
degisken EQU 0X25; adres belirtildi
ORG 0X00;baþlangýç adresi belirtildi
GOTO ana_program ;ana programa git
ORG 0X004; ;kesme alt programýnýn baþlangýç adresi
kesme;kesme alt programýnýn etiketi

BSF STATUS,RP0 ;01 nolu banka geç
BTFSS INTCON,1 ;INCON register ýnýn 1. biti(RB0 kesme bayraðý) 1 ise bir sonraki kod a geç
GOTO kesme_bitir ; kesme alt programýndan çýk
BCF INTCON,1 ;kesme bayraðýný indir
INCF sayac,F ;sayac ýn deðerini 1 artýr sayaca yaz
MOVLW D'10' ;working register ýna  10 deðerini yükle
SUBWF sayac,W ;sayac-10 
BTFSS STATUS,C ;c elde biti oluþmuþ ise bir sonraki kod a geç
GOTO say_basla ;say_basla etiketine git
GOTO ana_program ;ana_program etiketine git
say_basla 

INCF degisken,F ;deðiþkenin deðerini 1 artýr
SWAPF degisken,W ;deðiþkenin deðerini swap yap  working e kaydet
BCF STATUS,RP0 ; 00 nolu bank a geç
MOVWF PORTD ;working registerindaki deðeri portd ye yaz
GOTO kesme_bitir ;kesme bitir
kesme_bitir

RETFIE
ana_program

CLRF sayac ;sayac içeriðini sýfýrla
CLRF degisken ;deðiþken içeriðini sýfýrla
BSF STATUS,RP0 ;01 nolu banka geç
BCF OPTION_REG,7 ;pull-upp direçlerini aktif yap
CLRF TRISD ; portD çýkýþ oldu
BSF TRISB,0 ;portB nin 0. biti giriþ oldu
MOVLW B'10010000' ;deðeri working e yükle
MOVWF INTCON ;genel ve harici kesme için izin verildi
BCF STATUS,RP0 ;00 nolu bayraða geç
CLRF PORTD ;PortD yi sýfýrla
dongu
GOTO dongu ;döngü......
END




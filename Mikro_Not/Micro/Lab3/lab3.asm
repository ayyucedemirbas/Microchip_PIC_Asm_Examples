list p=16F877A
#include <P16F877A.inc>
__config H'3F31'
TEMP1 EQU 0X20;CCPR1L içeriðini yedeklemek için
TEMP2 EQU 0X21;kontrol için

ORG 0X00
GOTO ANA_PROGRAM 
ORG 0X004; 
KESME;---------------------------------
BCF STATUS,RP0 ; 00 nolu banka geçiþ yapýldý
BTFSS PIR1,1 ;TMR2 bayaraðý kalkmýþ mý
GOTO ATLA ;TMR2 kesmesi deðilse git RB0 kesmesini kontrol et
BCF PIR1,1 ;TMR2 kesmesi ise bayraðý indir

GOTO KESME_BÝTÝR ;kesmeyi bitir
ATLA;--------------------------
BTFSS INTCON,1 ;RB0 kesme bayraðý kalkmýþ mý?
GOTO KESME_BÝTÝR ;kalkmamýþ ise kesmeyi bitir
INCF TEMP2,F ;TEMP2 içeriðini 1 artýr
MOVLW D'9'
SUBWF TEMP2,W ;TEMP2-WORKÝNG(9) U WORKÝNG e at
BTFSS STATUS,2 ;Zero flaðýný kontrol et
GOTO ÝSLEM
GOTO BÝTÝR
ÝSLEM;----------------
BCF INTCON,1 ;RB0 kesme bayraðýný indir
MOVLW D'25' ; her RB0 kesmesinde CCPR1L registeriný 25 azalt
SUBWF TEMP1,F ;TEMP1- WORKÝNG(25) TEMP1 E YÜKLE
MOVF TEMP1,W ;TEMP1'i WORKÝNG e at
MOVWF CCPR1L ;Working i CCPR1L ye yükle
GOTO KESME_BÝTÝR ;kesmeyi bitir
BÝTÝR;-----------------
BCF INTCON,4 ;RB0 ;RB0 kesmesine izin verme
GOTO KESME_BÝTÝR ;kesmeyi bitir
 KESME_BÝTÝR;--------------------------
 RETFIE
 ANA_PROGRAM;------------------------------ 
 BSF STATUS,RP0;01 nolu banka geç
 BCF TRISC,2 ;RC2 pinini çýkýþ yap
 BSF TRISB,0 ;RB0 pinini giriþ yap
 BCF OPTION_REG,7 ;pull-up aktif yap
 BSF OPTION_REG,6 ;RB0 giriþi yükselen kenar seçildi
 MOVLW B'11010000' ;tüm kesmeler,çevresel kesmeler,RB0 kesmesine izin ver
 MOVWF INTCON ;izinler ayarlandý
 BSF PIE1,1 ; TMR2 kesmesine izin ver
 MOVLW D'249' ; PR2 deðeri hesaplanarak  
 MOVWF PR2  ; yüklendi
 BCF STATUS,RP0  ;00 nolu banka geç
CLRF PORTC ; portc yi temizle
 MOVLW B'00000101';TMR2 yi aktif et ve prescaler'ý 1/4 ayarla
 MOVWF T2CON ;yükle
 MOVLW B'00001100' ;pwm modu seçildi
 MOVWF CCP1CON ; yüklendi
 MOVLW B'11100001' ; CCPR1L + CCP1CON(5,4)=900 YANÝ(11100001 00) "10 BÝT olmasý saðlandý
 MOVWF CCPR1L ;yüzde 90 görev peryodu ayarlanmýþ olsu
 MOVWF TEMP1 ;kesmede kullanmak CCPR1L yi TEMP1 e yükle
 
 DONGU 
 GOTO DONGU
END
 
'****************************************************************
'*  Name    : KESMETMR0.BAS                                      *
'*  Author  : [Erol Tahir Erdal]                                *
'*  Notice  : Copyright (c) 2005 [ETE]                          *
'*          : All Rights Reserved                               *
'*  Date    : 23.04.2005                                        *
'*  Version : 1.0                                               *
'*  Notes   :                                                   *
'*          :(1)LCD                                                  *
'****************************************************************
PORTA=0:portb=0
TRISB=%11110000   'PortB tamam� giri� yap�ld�.
TRISA=%00000111   'A portu tamam� ��k�� yap�ld�.
'-----------------------------------------------------------------
@ DEVICE pic16F628                      'i�lemci 16F628                                
@ DEVICE pic16F628, WDT_ON              'Watch Dog timer a��k
@ DEVICE pic16F628, PWRT_ON             'Power on timer a��k
@ DEVICE pic16F628, PROTECT_OFF         'Kod Protek kapal�
@ DEVICE pic16F628, MCLR_off            'MCLR pini kullan�l�yor.
@ DEVICE pic16F628, XT_OSC
'@ DEVICE pic16F628, INTRC_OSC_NOCLKOUT  'Dahili osilat�r kullan�lacak 
'-----------------------------------------------------------------
DEFINE LCD_DREG		PORTB	'LCD data bacaklar� hangi porta ba�l�?
DEFINE LCD_DBIT		4		'LCD data bacaklar� hangi bitten ba�l�yor?
DEFINE LCD_EREG		PORTB	'LCD Enable Baca�� Hangi Porta ba�l�?
DEFINE LCD_EBIT		3		'LCD Enable Baca�� Hangi bite ba�l� ?
define LCD RWREG    PORTB   'LCD R/W Baca�� Hangi Porta ba�l�?
define LCD_RWBIT    2       'LCD R/W Baca�� Hangi bite ba�l� ?
DEFINE LCD_RSREG	PORTB	'LCD RS Baca�� Hangi Porta ba�l� ?
DEFINE LCD_RSBIT	1		'LCD RS baca�� Hangi Bite ba�l�  ?
DEFINE LCD_BITS		4		'LCD 4 bit mi yoksa 8 bit olarak ba�l�?
DEFINE LCD_LINES	2		'LCD Ka� s�ra yazabiliyor
'DEFINE OSC 4
'-------------------------------------------------------------------------
ON INTERRUPT GoTo KESME   'kesme olu�ursa KESME adl� etikete git.
OPTION_REG=%10000101   'Pull up diren�leri �PTAL- B�lme oran� 1/64.
INTCON=%10100000  'Kesmeler aktif ve TMR0 kesmesi aktif
TMR0=0
CMCON=7    '16F628 de komparat�r pinleri iptal hepsi giri� ��k��
'----------------------------------------------------------------------------
Comm_Pin    VAR	Portb.0     ' One-wire Data-Pin "DQ" PortB.0 da
Busy        VAR BIT         ' Busy Status-Bit
HAM         VAR	WORD        ' Sens�r HAM okuma de�eri
ISI         VAR WORD        ' Hesaplanm�� ISI de�eri
Float       VAR WORD        ' Holds remainder for + temp C display
X           VAR WORD       
SIGN_BITI   VAR HAM.Bit11   '   +/- s�cakl�k ��aret biti,  1 = olursa eksi s�cakl�k
NEGAT_ISI   CON 1           ' Negatif_Cold = 1
Deg         CON 223         ' � i�areti
SIGN        VAR BYTE        '  ISI de�eri i�in  +/-  i�aret
TEMP        VAR BYTE         ' Div32 bit hesap i�in ge�ici de�i�ken
SAYAC       VAR   BYTE
SN          VAR   BYTE
DAK         VAR   BYTE
SAAT        VAR   BYTE
GUN         VAR   BYTE
symbol  SEC=PORTA.0
SYMBOL  YUKARI=PORTA.2
SYMBOL  ASAGI =PORTA.1
'-----------------------------------------------------------------------------
CLEAR  't�m de�i�kenler s�f�rland�
PAUSE 200
LCDOUT $FE,1

'-----------------------------------------------------------------------------

BASLA:
      GOSUB EKRAN0        'SAAT� EKRANA YAZ
      if SEC=0 THEN AYAR  'MODE TU�UNA BASILMI� �SE AYAR'A G�T
      gosub SENSOROKU     'SONS�R OKU VE SICAKLI�I EKRANA YAZ
      GOTO BASLA
      
EKRAN0:
       LCDOUT $FE,$84,DEC2 SAAT,":",DEC2 DAK:RETURN
       
AYAR:  
       WHILE SEC=0 
       WEND
HOUR:  GOSUB EKRAN0
       LCDOUT $FE,$84
       lcdout $FE,$0E  '��ZG�L� KURS�R A�IK
       IF SEC=0 THEN MINBIR
       IF YUKARI=0 THEN
          SAAT=SAAT+1
          IF SAAT=24 THEN SAAT=0       
        ENDIF   
        IF ASAGI=0 THEN
           SAAT=SAAT-1
           IF SAAT=255 THEN SAAT=23
        ENDIF   
        GOSUB GECIKME
        GOTO HOUR
        
MINBIR: WHILE SEC=0
        WEND
        
MINUTE: GOSUB EKRAN0
       LCDOUT $FE,$87
        IF SEC=0 THEN SECBIR
        IF YUKARI=0 THEN
           DAK=DAK+1
           IF DAK=60 THEN DAK=0
        ENDIF
        IF ASAGI=0 THEN
           DAK=DAK-1
           IF DAK=255 THEN DAK=59              
        ENDIF
        GOSUB GECIKME
        GOTO MINUTE
        
SECBIR: WHILE SEC=0
        WEND
SECOND: 
        GOSUB EKRAN0
        LCDOUT $FE,$8A
        IF SEC=0 THEN ARA
        IF YUKARI=0 THEN
           SN=SN+1
           IF SN=60 THEN SN=0
        ENDIF
        IF ASAGI=0 THEN
           SN=SN-1
           IF SN=255 THEN SN=0
        ENDIF
        GOSUB GECIKME
        GOTO SECOND

GECIKME:
        FOR X=0 TO 1800
        PAUSEUS 100
        NEXT
        RETURN

ARA:    LCDOUT $FE,$0C
        WHILE SEC=0  
        wend
'        gosub GECIKME
        goto BASLA
                
        
'----------------ISI SENS�R OKUMA B�L�M� --------------------------------
SENSOROKU: 
           'ham=$FE6F:Gosub hesapla:RETURN bu sat�r normal devrede silinecek
           OWOUT   Comm_Pin, 1, [$CC, $44]' ISI de�erini oku
Bekle:
           OWIN    Comm_Pin, 4, [Busy]    ' Busy de�erini oku
           IF      Busy = 0 THEN Bekle  ' hala me�gulm�? , evet ise goto Bekle..!
           OWOUT   Comm_Pin, 1, [$CC, $BE]' scratchpad memory oku
           OWIN    Comm_Pin, 2, [HAM.Lowbyte, HAM.Highbyte]' �ki byte oku ve okumay� bitir.
           GOSUB   Hesapla
           RETURN
    
Hesapla:                 ' Ham de�erden Santigrat derece hesab�
    Sign  = "+"
    IF SIGN_BITI = NEGAT_ISI THEN
       Sign   = "-"  
       temp=($ffff-ham+1)*625
       ISI  = DIV32 10 
       GOTO GEC   
    endif
    TEMP = 625 * (HAM+1)        ' 
    ISI = DIV32 10          ' Div32 hassas derece hesab� i�in 32 bit b�lme yap�yoruz.
GEC:
    FLOAT = (ISI //1000)/100
    ISI=ISI/1000
    LCDOUT $FE,$C4,Sign,DEC ISI,".",DEC1 (Float)," ",Deg,"C " '2. sat�rda �s�
    RETURN

DISABLE
KESME:
      SAYAC=SAYAC+1  'kesme sayac�  1 sn= 61(sayac) x 256 (Tmr0) x 64 (b�lme)
      IF SAYAC=61 then  '61 adet kesme olunca 1 sn. s�re ge�iyor.(999424 us)
         SAYAC=0        'saya� s�f�rlan�yor
          SN=SN+1
          toggle portb.0       'saniye de�eri bir art�r�l�yor
            IF SN=60 THEN  'saniye 60 olmu� ise 1 dakika s�re ge�ti ohalde
              SN=0        ' saniye s�f�rlan�yor
               DAK=DAK+1   ' dakika de�eri bir art�r�l�yor
                  IF DAK=60 then   'dakika 60 olmu� ise 1 saat s�re ge�ti
                     DAK=0         ' dakika s�f�rlan�yor
                     SAAT=SAAT+1   ' saat de�eri bir art�r�l�yor
                        IF SAAT=24 THEN  'saat 24 olmu� ise 1 g�n ge�ti
                           SAAT=0        'saat s�f�rlan�yor
'                           GUN=GUN+1     'g�n de�eri bir art�r�l�yor
'                              IF GUN=365 THEN GUN=0  'g�n 365 olmu� ise
                        endif                    'g�n s�f�rlan�yor 1 y�l ge�ti
                  ENDIF 
            ENDIF
           lcdout $fe,$89,":",DEC2 SN
          ENDIF
CIK:     INTCON.2=0        'TMR0 Kesme bayra�� s�f�rlan�yor
         RESUME
         ENABLE
         
END
         
                      

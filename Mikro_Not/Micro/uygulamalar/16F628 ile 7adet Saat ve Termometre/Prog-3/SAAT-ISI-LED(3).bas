'****************************************************************
'*  Name    : KESMETMR0.BAS                                      *
'*  Author  : [Erol Tahir Erdal]                                *
'*  Notice  : Copyright (c) 2005 [ETE]                          *
'*          : All Rights Reserved                               *
'*  Date    : 23.04.2005                                        *
'*  Version : 1.0   LED (3 )                                            *
'*  Notes   : SICAKLIK KUSURAT YAZMIYOR AMA EKSI SICAKLIK       *
'*          :  GOSTEREB�L�YOR                                   *
'****************************************************************
PORTA=255:portb=0
TRISB=0   'PortB tamam� giri� yap�ld�.
TRISA=%00011111  'A portu tamam� ��k�� yap�ld�.
'-----------------------------------------------------------------
@ DEVICE pic16F628                      'i�lemci 16F628                                
@ DEVICE pic16F628, WDT_ON              'Watch Dog timer a��k
@ DEVICE pic16F628, PWRT_ON             'Power on timer a��k
@ DEVICE pic16F628, PROTECT_OFF         'Kod Protek kapal�
@ DEVICE pic16F628, MCLR_off            'MCLR pini kullan�lMIYOR.
@ DEVICE pic16F628, XT_OSC
'@ DEVICE pic16F628, INTRC_OSC_NOCLKOUT  'Dahili osilat�r kullan�lacak 
'-----------------------------------------------------------------
'DEFINE OSC 4
'-------------------------------------------------------------------------
ON INTERRUPT GoTo KESME   'kesme olu�ursa KESME adl� etikete git.
OPTION_REG=%10000101   'Pull up diren�leri �PTAL- B�lme oran� 1/64.
INTCON=%10100000  'Kesmeler aktif ve TMR0 kesmesi aktif
TMR0=0
CMCON=7    '16F628 de komparat�r pinleri iptal hepsi giri� ��k��
'----------------------------------------------------------------------------
Comm_Pin    VAR	PortA.4     ' One-wire Data-Pin "DQ" PortB.0 da
Busy        VAR BIT         ' Busy Status-Bit
POZ         var BIT         
HAM         VAR	WORD        ' Sens�r HAM okuma de�eri
ISI         VAR WORD        ' Hesaplanm�� ISI de�eri
Float       VAR WORD        ' Holds remainder for + temp C display
X           VAR WORD  
Y           VAR BYTE  
SAYI        VAR BYTE   
SIGN_BITI   VAR HAM.Bit11   '   +/- s�cakl�k ��aret biti,  1 = olursa eksi s�cakl�k
NEGAT_ISI   CON 1           ' Negatif_Cold = 1
Deg         CON 223         ' � i�areti
SIGN        VAR BYTE        '  ISI de�eri i�in  +/-  i�aret
TEMP        VAR BYTE         ' Div32 bit hesap i�in ge�ici de�i�ken
SAYAC       VAR BYTE
SN          VAR BYTE
DAK         VAR BYTE
SAAT        VAR BYTE
GUN         VAR BYTE
symbol  SEC   =PORTA.0
SYMBOL  ASAGI =PORTA.1 
SYMBOL  YUKARI=PORTA.2
'-----------------------------------------------------------------------------
CLEAR  't�m de�i�kenler s�f�rland�
PAUSE 200
Y=1 :POZ=0
'-----------------------------------------------------------------------------
 PORTB=0  
BASLA: 
       IF Y>6 THEN
           IF Y>=11 THEN Y=1
           GOSUB EKRAN1
           GOTO ATLA
       ENDIF        
       GOSUB EKRAN0
       
ATLA:  if SEC=0 THEN AYAR  'MODE TU�UNA BASILMI� �SE AYAR'A G�T
       gosub SENSOROKU     'SONS�R OKU VE SICAKLI�I EKRANA YAZ
       GOTO BASLA

EKRAN0:
       if sayac=30 then low porta.3
       X= SAAT DIG 1:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.2:PAUSEUS 2:LOW PORTB.2
       
       X= SAAT DIG 0:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.3:PAUSEUS 2:LOW PORTB.3 

       X= DAK DIG 1:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.4:PAUSEUS 2:LOW PORTB.4
       
       X= DAK DIG 0:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.5:PAUSEUS 2:LOW PORTB.5
       
       X= sn DIG 1:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.6:PAUSEUS 2:LOW PORTB.6
       
       X= SN DIG 0:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.7:PAUSEUS 2:LOW PORTB.7
       RETURN
       
AL:    LOOKUP X,[63,6,91,79,102,109,125,7,127,111,99,57],SAYI :RETURN

EKRAN1:
       LOW PORTA.3 :SAYI=0
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.2:PAUSEUS 2:LOW PORTB.2
       IF SIGN_BITI = NEGAT_ISI THEN SAYI=64
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.3:PAUSEUS 2:LOW PORTB.3
       
       x=(ISI DIG 1):GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.4:PAUSEUS 2:LOW PORTB.4
       x=(ISI DIG 0):GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.5:PAUSEUS 2:LOW PORTB.5
       X=10:GOSUB AL 
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.6:PAUSEUS 2:LOW PORTB.6 
       X=11:GOSUB AL
       SHIFTOUT PORTB.0,PORTB.1,1,[SAYI]
       HIGH PORTB.7:PAUSEUS 2:LOW PORTB.7
       RETURN
       
AYAR:  POZ=1:gosub FLASH
       WHILE SEC=0 
       WEND
HOUR:  GOSUB EKRAN0
       LOW PORTA.3
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
        
MINBIR: 
        GOSUB FLASH
        WHILE SEC=0
        WEND
        
MINUTE: GOSUB eKRAN0
       LOW PORTA.3
       IF SEC=0 THEN ara
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

GECIKME:
        FOR X=0 TO 3500
        PAUSEUS 10
        NEXT
        RETURN

ARA:    
        GOSUB FLASH
        HIGH PORTA.3
        WHILE SEC=0  
        wend
        POZ=0:SN=0
        goto BASLA
                
FLASH:
      TOGGLE PORTA.3:PAUSE 150:TOGGLE PORTA.3:PAUSE 150
      TOGGLE PORTA.3:PAUSE 150:TOGGLE PORTA.3:PAUSE 150 
      return       
'----------------ISI SENS�R OKUMA B�L�M� --------------------------------
SENSOROKU: 
           ham=$ff5e:Gosub hesapla:return 'NORMAL �ALI�MADA BU SATIR S�L�NECEK
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
'    ISI  = (HAM & $0FF0) >> 4 'ortadaki 8 biti maskele, ve sa�a do�ru 4 hane kayd�r.
GEC:
    FLOAT = (ISI //1000)/100
    ISI=ISI/1000
'    Float = ((HAM.Lowbyte & $0F) * 625) ' K�s�rat hesab�
'    LCDOUT $FE,$C4,Sign,DEC ISI,".",DEC1 (Float)," ",Deg,"C " '2. sat�rda �s�
    RETURN                      

DISABLE
KESME:
      IF POZ=1 THEN CIK 
      SAYAC=SAYAC+1  'kesme sayac�  1 sn= 61(sayac) x 256 (Tmr0) x 64 (b�lme)
       IF SAYAC=58 then  '61 adet kesme olunca 1 sn. s�re ge�iyor.(999424 us)
         SAYAC=0        'saya� s�f�rlan�yor
          SN=SN+1 
          Y=Y+1       'saniye de�eri bir art�r�l�yor
            if y<7 then high porta.3
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
'           lcdout $fe,$89,":",DEC2 SN
          ENDIF
CIK:     INTCON.2=0  'TMR0 Kesme bayra�� s�f�rlan�yor
         RESUME
         ENABLE
         
END
         
                      

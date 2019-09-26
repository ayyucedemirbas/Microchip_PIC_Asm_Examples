'****************************************************************
'*  Name    : SAAT-TERMO.BAS                                      *
'*  Author  : [Erol Tahir Erdal]                                *
'*  Notice  : Copyright (c) 2005 [ETE]                          *
'*          : All Rights Reserved                               *
'*  Date    : 23.06.2005                                        *
'*  Version : 1.0      LED (6)                                         *
'*  Notes   : SICAKLIK KUSURAT YAZMIYOR AMA EKSI SICAKLIK       *
'*          :  GOSTEREB�L�YOR SAAT RTC DS1302 ile �al���yor                                  *
'****************************************************************
PORTA=0:portb=0
TRISB=0   
TRISA=%11100000  
'-----------------------------------------------------------------
@ DEVICE pic16F628                      'i�lemci 16F628                                
@ DEVICE pic16F628, WDT_ON              'Watch Dog timer a��k
@ DEVICE pic16F628, PWRT_ON             'Power on timer a��k
@ DEVICE pic16F628, PROTECT_OFF         'Kod Protek kapal�
@ DEVICE pic16F628, MCLR_off            'MCLR pini kullan�lMIYOR.
@ DEVICE pic16F628, INTRC_OSC_NOCLKOUT  'Dahili osilat�r kullan�lacak 
'-----------------------------------------------------------------
'DEFINE OSC 4
'-------------------------------------------------------------------------
ON INTERRUPT GoTo KESME   'kesme olu�ursa KESME adl� etikete git.
OPTION_REG=%10000101   'Pull up diren�leri �PTAL- B�lme oran� 1/64.
INTCON=%10100000  'Kesmeler aktif ve TMR0 kesmesi aktif
TMR0=0
CMCON=7  
'----------------------------------------------------------------------------
Comm_Pin    VAR	PortA.4     ' One-wire Data-Pin "DQ" PortB.0 da
Busy        VAR BIT         ' Busy Status-Bit
poz         var BIT
GOR         VAR BYTE
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
AY          VAR BYTE
YIL         VAR BYTE
MEM         var byte ' Temporary data holder
'TARIH       var byte ' Second byte to ds1302
ONLAR       VAR BYTE
BIRLER      VAR BYTE
ESN         VAR BYTE
'---------------------------------------------
SYMBOL  DTA=PortB.0
SYMBOL  CLK=PORTB.1
SYMBOL  RTC_DTA=PORTA.0
SYMBOL  RTC_CLK=PORTA.1
SYMBOL  RTC_RST=PORTA.2
symbol  SEC   =PORTA.5  
SYMBOL  ASAGI =PORTA.6 
SYMBOL  YUKARI=PORTA.7 
'-----------------------------------------------------------------------------
CLEAR  't�m de�i�kenler s�f�rland�
low RTC_RST
low RTC_CLK 
PAUSE 200
esn=0:GOR=0:POZ=0
'-----------------------------------------------------------------------------
PORTB=0  
gosub ZAMAN_OKU:esn=SN
BASLA: 
        IF Y=11 THEN Y=0
        IF Y>5 THEN GOSUB EKRAN1
        IF Y<6 THEN GOSUB EKRAN0
       
ATLA:  if SEC=0 THEN AYAR  'MODE TU�UNA BASILMI� �SE AYAR'A G�T
       gosub SENSOROKU     'SONS�R OKU VE SICAKLI�I EKRANA YAZ

       GOTO BASLA

EKRAN0: if sayac=30 then LOW porta.3
       X= SAAT DIG 1:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.2:PAUSEUS 2:LOW PORTB.2
       
       X= SAAT DIG 0:GOSUB AL
       SHIFTOUT  DTA,CLK,1,[SAYI]
       HIGH PORTB.3:PAUSEUS 2:LOW PORTB.3 

       X= DAK DIG 1:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.4:PAUSEUS 2:LOW PORTB.4
       
       X= DAK DIG 0:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.5:PAUSEUS 2:LOW PORTB.5
       
       X= sn DIG 1:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.6:PAUSEUS 2:LOW PORTB.6
       
       X= SN DIG 0:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.7:PAUSEUS 2:LOW PORTB.7
       RETURN
       
AL:    LOOKUP X,[63,6,91,79,102,109,125,7,127,111,99,57],SAYI :RETURN
     

EKRAN1:LOW PORTA.3 
       SAYI=0
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.2:PAUSEUS 2:LOW PORTB.2
       IF SIGN_BITI = NEGAT_ISI THEN SAYI=64
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.3:PAUSEUS 2:LOW PORTB.3       
       x=(ISI DIG 1):GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.4:PAUSEUS 2:LOW PORTB.4
       x=(ISI DIG 0):GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.5:PAUSEUS 2:LOW PORTB.5
       X=10:GOSUB AL 
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.6:PAUSEUS 2:LOW PORTB.6 
       X=11:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.7:PAUSEUS 2:LOW PORTB.7
       RETURN
       
EKRAN2: HIGH porta.3
       X= GUN DIG 1:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.2:PAUSEUS 2:LOW PORTB.2
       
       X= GUN DIG 0:GOSUB AL
       SHIFTOUT  DTA,CLK,1,[SAYI]
       HIGH PORTB.3:PAUSEUS 2:LOW PORTB.3 

       X= AY DIG 1:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.4:PAUSEUS 2:LOW PORTB.4
       
       X= AY DIG 0:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.5:PAUSEUS 2:LOW PORTB.5
       
       X= YIL DIG 1:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
       HIGH PORTB.6:PAUSEUS 2:LOW PORTB.6
       
       X= YIL DIG 0:GOSUB AL
       SHIFTOUT DTA,CLK,1,[SAYI]
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
        
MINUTE: GOSUB EKRAN0
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
        FOR X=0 TO 1800
        PAUSEUS 100
        NEXT
        RETURN

ARA:    
        GOSUB FLASH
        HIGH PORTA.3
        WHILE SEC=0  
        wend
        MEM=SN:GOSUB TERSCEVIR:SN=SAYI
        MEM=DAK:GOSUB TERSCEVIR:DAK=SAYI
        MEM=SAAT:GOSUB TERSCEVIR:SAAT=SAYI
        MEM=GUN:GOSUB TERSCEVIR:GUN=SAYI
        MEM=AY:GOSUB TERSCEVIR:AY=SAYI
        MEM=YIL:GOSUB TERSCEVIR:YIL=SAYI        
        GOSUB ZAMAN_YAZ
        POZ=0
        goto BASLA
        
FLASH:
      TOGGLE PORTA.3:PAUSE 150:TOGGLE PORTA.3:PAUSE 150
      TOGGLE PORTA.3:PAUSE 150:TOGGLE PORTA.3:PAUSE 150 
      return          
'----------------ISI SENS�R OKUMA B�L�M� --------------------------------
SENSOROKU: 
'-----------------D�KKAT �S�S'de BU SATIR AKT�F ED�LECEK----------------------
           ham=$ff5e:Gosub hesapla:return 'NORMAL �ALI�MADA BU SATIR S�L�NECEK
'------------------------------------------------------------------------------
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
    RETURN                      

ZAMAN_OKU:
'         sayac=1-sayac: 'if sayac=1 then low porta.3
         high RTC_RST
         shiftout RTC_DTA, RTC_CLK, 0, [$BF]
         SHIFTIN RTC_DTA, RTC_CLK, 1, [SN, DAK, SAAT,GUN , AY, MEM, YIL, MEM]  'OKU
         MEM=SN:GOSUB CEVIR:SN=SAYI
         MEM=DAK:GOSUB CEVIR:DAK=SAYI
         MEM=SAAT:GOSUB CEVIR:SAAT=SAYI
         MEM=GUN:GOSUB CEVIR:GUN=SAYI
         MEM=AY:GOSUB CEVIR:AY=SAYI
         MEM=YIL:GOSUB CEVIR:YIL=SAYI
         low RTC_RST ':PAUSE 100
         return
          

ZAMAN_YAZ:
           
         high  RTC_RST 
         SHIFTOUT RTC_DTA, RTC_CLK, 0, [$8E, 0]    'YAZMAK ���N HAZIRLA
         low RTC_RST:PAUSE 1 
         high RTC_RST          
         SHIFTOUT  RTC_DTA, RTC_CLK, 0, [$BE, SN, DAK, SAAT,GUN , AY, 0, YIL, 0]  'YAZ
         low RTC_RST 
         PAUSE 10
         return
               
CEVIR:
         ONLAR=MEM & %01110000
         ONLAR=ONLAR>>4
         BIRLER=MEM & %00001111
         SAYI=ONLAR*10+BIRLER
         RETURN  

TERSCEVIR:                
         ONLAR=MEM DIG 1
         ONLAR=ONLAR<<4
         BIRLER=MEM DIG 0
         SAYI=ONLAR+BIRLER
         RETURN
         
DISABLE
KESME:
      IF POZ=1 then CIK 
      SAYAC=SAYAC+1  'kesme sayac�  1 sn= 61(sayac) x 256 (Tmr0) x 64 (b�lme)
       IF SAYAC=61 then  '61 adet kesme olunca 1 sn. s�re ge�iyor.(999424 us)
         SAYAC=0        'saya� s�f�rlan�yor
          Y=Y+1
          GOSUB ZAMAN_OKU
         if Y<5 then HIGH porta.3
       ENDIF
CIK:     INTCON.2=0  'TMR0 Kesme bayra�� s�f�rlan�yor
         RESUME
         ENABLE
                  
         
END
         
                      

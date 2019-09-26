// *****************************************************************
// Dosya Ad�		: 15_1.c
// A��klama		: Terminal Projesi
// PIC DK 2.1		: PORTB ��k�� ==> LCD display
//			: A/D se�im anahtar� RA1 A, di�erleri D konumunda
//			: XT ==> 4 MHz
// *****************************************************************
// Hi ve Lo fonksiyonlar� i�in ba�l�k dosyas� programa kat�l�yor.
#include "built_in.h"
// Alarm fonksiyonu ile ilgili tan�mlamalar yap�l�yor.
#define ALARMPORT        PORTE
#define ALARMTRIS        TRISE
#define ALARMCIKIS       F0
#define ALARMKURULU      F1
#define ALARMKAPAT       PORTA.F4  // Alarm kesme butonu
// Sens�rler i�in analog kanal tan�mlamalar� yap�l�yor.
#define LM35            0    // 0. adc kanal�na ba�l�
#define LDR             1    // 1. adc kanal�na ba�l�
// Global de�i�ken tan�mlamalar� yap�l�yor.
unsigned short tmp,i;
unsigned char ControlReg, TaskControl, RxBuffer;
unsigned char saat, dakika, saniye, a_saat, a_dakika, AlarmCnt;
unsigned int isi, isik, epadres, adr;
unsigned short PWMDuty;
//------------------------------------------------------------------
// Kesme Alt Program�.
//------------------------------------------------------------------
void interrupt(void)
{
    // Timer1 kesmesi i�leniyor.
    if (PIR1.TMR1IF)
    {
         TaskControl.F3 = 1;
         TMR1L = 0x00;    // �n de�erler atan�yor 4096 art�� sonras�
         TMR1H = 0xF0;    // ta�ma ger�ekle�ecek
         PIR1.TMR1IF = 0;
    }
    // RX seri ileti�im veri alma kesmesi i�leniyor.
    if (PIR1.RCIF)
    {
        // al�nan karakter RCREG'de
        if(RCSTA.FERR || RCSTA.OERR)
        {
            RCSTA.CREN = 0;
            asm nop       // Bit i�lemleri aras�nda 1us kadar bekle
            RCSTA.CREN = 1;
        }
        PIR1.RCIF = 0;     	// Alma kesme bayra��n� sil.
        RxBuffer = RCREG;       	// Al�nan veriyi de�i�kene ata.
        ControlReg.F7 = 1;      	// Veri al�nd� kontrol bitini set et
	TaskControl.F0 = 1;      	// Terminal i�in g�rev kontrol 
     	// bayra��n� set et.
	PIR1.RCIF = 0;
    }
}
//------------------------------------------------------------------
// EEPROM�a veri yazar.
//------------------------------------------------------------------
void e2eprom_write(unsigned int adr, unsigned short data)
{
  I2C_Start();           // I2C start sinyali g�nder
  I2C_Wr(0xA0);          // I2C donan�m adresi + yazma komutu g�nder
  I2C_Wr(Hi(adr));       // Yaz�lacak adresin y�ksek byte'�n� g�nder
  I2C_Wr(Lo(adr));       // Yaz�lacak adresin al�ak byte'�n� g�nder
  I2C_Wr(data);          // Yaz�lacak veriyi g�nder
  I2C_Stop();            // I2C ileti�imi durdur
  Delay_ms(100);         // i�lemlerin tamamlanmas� i�in 100ms bekle
}
//------------------------------------------------------------------
// EEPROM�dan veri okur.
//------------------------------------------------------------------
unsigned short e2eprom_read(unsigned int adr)
{
  unsigned short data;
  I2C_Start();           // I2C start sinyali g�nder
  I2C_Wr(0xA0);          // I2C donan�m adresi + yazma komutu g�nder
  I2C_Wr(Hi(adr));       // Yaz�lacak adresin y�ksek byte'�n� g�nder
  I2C_Wr(Lo(adr));       // Yaz�lacak adresin al�ak byte'�n� g�nder
  I2C_Repeated_Start();  // I2C reStart sinyali g�nder
  I2C_Wr(0xA1);          // I2C donan�m adresi + okuma komutu g�nder
  data = I2C_Rd(0u);     // Veriyi oku (NO acknowledge)
  I2C_Stop();            // I2C ileti�imi durdur
  return data;           // okunan veriyi fonksiyon d���na ta��
}
//------------------------------------------------------------------
// USART birminden bir karakter al�r.
//------------------------------------------------------------------
char GetChar()
{
  while(!(ControlReg.F7));  // Seri porttan 1 karakter al�nana kadar 
                            // bekle
  ControlReg.F7 = 0;        // Karakter al�nd� bayra��n� sil
  return RxBuffer;          // Al�nan karakteri ��k��a aktar
}
//------------------------------------------------------------------
// USART'a bir karakter g�nderir.
//------------------------------------------------------------------
void sendChar(char c)
{
  if(!(TXSTA.TXEN)) TXSTA.TXEN = 1;  // Veri g�nderme kesmesini 
                                     // etkinle�tir.
  while(!(PIR1.TXIF));               // Veri g�nderilene kadar bekle
  PIR1.TXIF = 0;                     // Veri g�nderildi, bayra�� sil
  TXREG = c;
}
//------------------------------------------------------------------
// USART'a string yazar.
//------------------------------------------------------------------
void writeString(const char *s)
{
  char i=0;      // G�nderilecek stringin karakter s�ras�
  while( s[i]!=0 ) sendChar(s[i++]); 	// stringin s�radaki 
// karakterini g�nder
}
//------------------------------------------------------------------
// Karakteri hex de�ere d�n��t�r�r.
//------------------------------------------------------------------
unsigned short Char_to_Hex(unsigned short gec)
{
  ControlReg.F6 = 0;
  if (gec>47 && gec<58)
  {
     gec=gec-48;
     return gec;
  }
  else if (gec>64 && gec<71)   // A, B, C, D, E, F giri�leri i�in
  {
     gec=gec-65;
     gec=gec+0x0A;
     return gec;
  }
  else if (gec>96 && gec<103)   // a, b, c, d, e, f giri�leri i�in
  {
     gec=gec-97;
     gec=gec+0x0A;
     return gec;
  }
  // Hatal� karakter ControlReg 6. bit set et. Gerekirse bu bit 
  // kontrol edilerek hatal� giri�ler engellenebilir.
  ControlReg.F6 = 1;
  return 0;
}
//------------------------------------------------------------------
// USART'dan hex bilgi al�r ve USART'a g�nderir.
//------------------------------------------------------------------
unsigned short GetSendHexByte()
{
    unsigned short ch;
    ch = GetChar();
    sendChar(ch);
    tmp = Char_to_Hex(ch);
    asm swapf _tmp,F
    ch = GetChar();
    sendChar(ch);
    ch = Char_to_Hex(ch);
    if (ControlReg.F6) return 0xFF;  	// Hatal� karakter ise 0xFF 
// aktar
    tmp = tmp + ch;
    return tmp;
}
//------------------------------------------------------------------
// USART'dan desimal bilgi al�r ve USART'a g�nderir.
//------------------------------------------------------------------
unsigned short GetSendDecByte()
{
    return Bcd2Dec(GetSendHexByte());
}
//------------------------------------------------------------------
// USART'a Desimal olarak 1 byte yazar
//------------------------------------------------------------------
void sendDecByte(unsigned short data)
{
    unsigned short onlar, birler;
    onlar = 0;
    birler = 0;
    while( data>=10) { onlar++; data = data - 10; }
    birler = data;
    sendChar('0'+ onlar);
    sendChar('0'+ birler);
}
//------------------------------------------------------------------
// LCD'ye Desimal olarak 1 byte yazar
//------------------------------------------------------------------
void LCD_DecWrite(unsigned short data)
{
    unsigned short onlar, birler;
    onlar = 0;
    birler = 0;
    while( data>=10) { onlar++; data = data - 10; }
    birler = data;
    Lcd_Chr_Cp('0'+ onlar);
    Lcd_Chr_Cp('0'+ birler);
}
//------------------------------------------------------------------
// LM35 ISI sens�r� ile ilgili fonksiyonlar
//------------------------------------------------------------------
void IsiOlc()
{
    // LM35'in ba�l� oldu�u ADC kanal�ndan �s� �iddetini al ve 
    // d�n��t�r
    Isi = Adc_Read(LM35) >> 1;   
    // 2'ye b�lerek ger�ek �s� de�erini bul yakla��k her bir art�� 
    // de�eri 5 mV, 2 artt���nda 10 mV yani 1 derece, Bu nedenle 
    // 2'ye b�l�yoruz. Sonu� ger�ek �s� de�erine �ok yak�n. 
    // �stenirse yar�m derece hassasiyet ile �s� g�r�nt�lenebilir. 
    // Ayr�ca referans gerilim ayarlanarak daha hassas ve daha do�ru 
    // �s� �l��mleri ger�ekle�tirilebilir.
}
void IsiGoruntule()
{
    // Is� �iddetini PC terminalinde g�r�nt�le
    sendDecByte(Isi);sendChar(' ');sendChar('C');
}
//------------------------------------------------------------------
// LDR I�IK sens�r� ile ilgili fonksiyonlar
//------------------------------------------------------------------
void IsikOlc()
{
    // LDR'nin ba�l� oldu�u ADC kanal�ndan ���k �iddetinin en 
    // de�ersiz byte'�n� al
    Isik = Adc_Read(LDR);
}

void IsikGoruntule()
{
    // I��k �iddetini PC terminalinde g�r�nt�le
    sendDecByte(Isik);
}
//------------------------------------------------------------------
// Zaman ile ilgili fonksiyonlar
//------------------------------------------------------------------
void ZamanAyarla()
{
    saat = GetSendDecByte(); sendChar(':'); dakika = GetSendDecByte();
}

void ZamanGoruntule()
{
    // Saati PC terminalinde g�r�nt�le
    SendDecByte(saat); sendChar(':'); SendDecByte(Dakika);
}
//------------------------------------------------------------------
// Alarm ile ilgili fonksiyonlar
//------------------------------------------------------------------
void AlarmAyarla()
{
    // Alarm saat ve dakika bilgisini al ve eeproma kaydet
    a_saat = GetSendDecByte(); sendChar(':'); a_dakika = GetSendDecByte();
    Eeprom_Write(0x10, a_saat);
    Eeprom_Write(0x11, a_dakika);
}

void AlarmGoruntule()
{
    // Alarm� eepromdan oku ve PC terminalinde g�r�nt�le
    a_saat = Eeprom_Read(0x10); a_dakika = Eeprom_Read(0x11);
    sendDecByte(a_saat); sendChar(':'); sendDecByte(a_dakika);
}
//------------------------------------------------------------------
// Saat ile ilgili fonksiyonlar
//------------------------------------------------------------------
void ZamanIsle()
{
    saniye++;
    if(saniye>59)
    {
        saniye = 0;
        dakika++;
        if(dakika>59)
        {
            dakika = 0;
            saat++;
            if(saat>23) saat = 0;
            // Her saat ba�� saat bilgisi ve �s� bilgisi e2eproma 
            // kaydediliyor.
            IsiOlc();
            e2eprom_write(epadres, saat);
            epadres++;
            e2eprom_write(epadres, Isi);
            epadres++;
        }
        // 40 dk boyunca alarm susturulmad� ise alarm� kes
        if (ControlReg.ALARMCIKIS)
        { AlarmCnt++;
          if (AlarmCnt>=40)
          {
             ControlReg.ALARMCIKIS = 0;
             ControlReg.ALARMKURULU = 0;
             ALARMPORT.ALARMCIKIS = 0;
             AlarmCnt = 0;
          }
        }
    }
    // Alarm kurulu ise alarm zaman�n� kontrol et
    if (ControlReg.ALARMKURULU)
         if ((saat == a_saat) && (dakika == a_dakika))
         {
             ALARMPORT.ALARMCIKIS = 1;
             ControlReg.ALARMCIKIS = 1;
         }
    // LCD'de saat:dakika:saniye bilgilerini g�r�nt�le
    Lcd_Out(1,1, "");
    LCD_DecWrite(saat);Lcd_Chr_Cp(':');
    LCD_DecWrite(dakika);Lcd_Chr_Cp(':');
    LCD_DecWrite(saniye);
    // LCD'de �s� bilgisini g�r�nt�le
    IsiOlc();
    Lcd_Out(2,1, "ISI: ");
    LCD_DecWrite(Isi);
    Lcd_Chr_Cp('C');
}
//------------------------------------------------------------------
// PC ile ileti�im kuran terminal fonksiyonu
//------------------------------------------------------------------
void TerminalProgram()
{
    unsigned short ch,tmp,i;
    ch=GetChar();
    if (ch==13)
    while(ch!=48)
    {
           do {
                // PC Terminalinde men� yazd�r�l�yor.
             writeString("\r\n\r\n        DK 2.1 Iletisim Menusune Hosgeldiniz");
             writeString("\r\n Copyright � Ayhan DAYANIK - 2006 adayanik@gmail.com");
             	writeString("\r\n\r\n   MENU SECENEKLERI:\n\r");
             	writeString(" <1> Isi goster..\n\r");
             writeString(" <2> Isik siddeti goster..\n\r");
             writeString(" <3> Saati goster..\n\r");
             writeString(" <4> Alarmi goster..\n\r");
             writeString(" <5> e2eprom'dan saat-isi bilgilerini listele..\n\r");
             writeString(" <6> Saati ayarla..\n\r");
             writeString(" <7> Alarmi kur..\n\r");
             writeString(" <8> PWM darbe genisligi ayarla..\n\r");
             writeString(" <0> Cikis..\n\r\n\r");
             writeString("     SECIMINIZ: ");
             ch=GetChar();     // PC terminalinden karakter al
	   } while(ch<48 || ch>57);  	// Al�nan se�im 0-8 aras�nda 
// de�ilse tekrar giri� al
            // Al�nan se�im bilgisini PC terminaline yaz
            sendDecByte(ch-48);writeString("\n\r ");
            // Al�nan karakteri kontrol et ve g�revi yerine getir.
	    switch(ch)
	    {
           	// Al�nan karakter '0' ise ch = 0 oldu�undan while 
	// d�ng�s�nden dolay�s� ile Terminal Program'dan 
	// ��k�l�r.
                case 48:writeString("\n\r Menuye girmek icin ENTER'e basiniz.. \n\r");
                      break;
                // Is� de�erini �l� ve PC terminalinde g�ster
	         case 49:writeString("\n\r Isi degeri: ");
                      IsiOlc();
                      sendDecByte(Isi);sendChar(' ');sendChar('C');
		        break;

// I��k �iddetini �l� ve PC terminalinde g�ster, Burada ���k �iddeti 
// i�lenmemi� bir �ekilde g�r�nt�lendi. I��k �iddetini do�ru olarak 
// g�r�nt�lemek i�in okunan de�erin logaritmik olarak i�lenmesi 
// gerekmektedir. Projemizde ���k �iddeti �s� kadar �nemli 
// olmad���ndan ve program�n anla��l�rl���n� korumak i�in d�n���m 
// yap�lmam��t�r. �stenirse okunan belirli de�erlerde ���k �iddeti 
// hesaplama y�ntemi yerine bilgisayar ortam�nda hesaplanm�� bir 
// tablo kullanmak daha yerinde olacakt�r.
		case 50:writeString("\n\r Isik siddeti: ");
                        Isik = Adc_Read(LDR);
                        sendDecByte(Isik);
			break;

                // PC terminalinde saat:dakika format�nda zaman 
                // g�r�nt�lenir.
              case 51:writeString("\n\r Saat: ");
		        SendDecByte(saat); sendChar(':'); SendDecByte(Dakika);
		        break;

                // PC terminalinde alarm kurulu ise alarm zaman�n�, 
                // kurulu de�il ise alarm�n kurulu olmad���na dair 
                // mesaj g�r�nt�ler.
	case 52:if(ControlReg.ALARMKURULU)
         {
           a_saat = Eeprom_Read(0x10); a_dakika = Eeprom_Read(0x11);
           writeString("\n\r Alarm zamani: ");
           sendDecByte(a_saat); sendChar(':'); sendDecByte(a_dakika);
           } else writeString("\n\r Alarm kurulmamis..");
           break;

           // PC terminalinde ESC tu�una basana kadar ya da eeprom 
           // sonuna yak�n bir de�ere ula�ana kadar 10'ar 10'ar 
           // belirli zamanlarda �l��lm�� �s� de�erini g�r�nt�le
		case 53:adr = 0; tmp = 1;
                        do {
                            writeString("\n\r Saat - Isi \n\r");
                            writeString("\n\r ----------- \n\r");
                            for ( i=0;i<10;i++)
                            {
                                writeString("  ");
                                ch = e2eprom_read(adr);
                                if (ch > 23) {tmp = 0; ch = 27; break;}
                                sendDecByte(ch);
                                writeString(" --- ");
                                adr++;
                                ch = e2eprom_read(adr);
                                sendDecByte(ch);
                                writeString("\n\r");
                                adr++;
                            }
                           if (tmp)
                           {
                                writeString("\n\r Cikis icin ESC tusuna basiniz..\n\r");
                                ch = GetChar();
                           } else
                           { if (adr < 0xFF0) ch = 0; else ch = 27; }
                        } while (ch!=27);
                        break;
                        
     // PC terminalinden saat:dakika giri�ini alarak zaman� ayarlar
     case 54:writeString("\n\r Saat ve dakika giriniz ( HH:MM ): ");
	             saat = GetSendDecByte(); sendChar(':'); dakika = GetSendDecByte();
                    break;

     // PC terminalinden alarma ait saat:dakika giri�ini alarak 
     // alarm zaman�n� ayarlar
     case 55:writeString("\n\r Alarm zamanini giriniz ( HH:MM ): ");
               a_saat = GetSendDecByte(); sendChar(':'); a_dakika = GetSendDecByte();
              Eeprom_Write(0x10, a_saat); Eeprom_Write(0x11, a_dakika);
              ControlReg.ALARMKURULU = 1; // Alarm etkinle�tirildi
              break;

       // PC terminalinden PWM darbe geni�li�ini alarak darbe 
       // geni�li�ini ayarlar
	case 56:writeString("\n\r PWM darbe genisligini giriniz (00-FF): ");
              PWMDuty = GetSendHexByte();
              PWM_Stop();
              PWM_Init(1000);      // PWM frekans� 1KHz se�ildi
              PWM_Change_Duty(PWMDuty);
              PWM_Start();
              break;
	      }
     }
}
//------------------------------------------------------------------
// Kullan�lan birimlerin kullan�ma haz�r getirildi�i ve baz� 
// de�i�kenlere ilk de�er atamalar�n�n yap�ld��� alt program
//------------------------------------------------------------------
void main_init()
{
    TRISC.F1 = 1;               // Timer1 i�in RC1 giri� yap�ld�
    ALARMTRIS.ALARMCIKIS = 0;   // ��k��a y�nlendirildi
    ALARMPORT.ALARMCIKIS = 0;   // �lk anda alarm �alm�yor


    //Port y�nlendir TX ��k��, RX giri�
    TRISC.F6 = 0;       // TX ucu ��k�� yap�ld�
    TRISC.F7 = 1;       // RX ucu giri�e ayarland�
    TXSTA = 0;          // TXSTA ilk anda s�f�r
    RCSTA = 0;          // RCSTA ilk anda s�f�r
// SPBRG = 129;	    // 20 Mhz de 9600 baud h�z i�in
    SPBRG = 25;	    // 4 Mhz de 9600 baud h�z i�in
// SPBRG = 50;          // 8 Mhz de 9600 baud h�z i�in
    TXSTA = 0x26;
    RCSTA = 0x90;
    PIE1.RCIE = 1;
    // Saat ile ilgili ilk de�erler atan�yor.
    saat = 0;
    dakika = 0;
    saniye = 0;
    AlarmCnt = 0;
    // LCD kullan�ma haz�rlan�yor.
    Lcd_Config(&PORTB,4,5,7,3,2,1,0);  // LCD ba�lant� tan�mlamalar�
    Lcd_Cmd(LCD_CLEAR);                // LCD'yi sil
    Lcd_Cmd(LCD_CURSOR_OFF);           // �mleci gizle

    I2C_Init(100000);             // I2C ileti�imi 100 KHz
    epadres = 0;                  // eprom adresi s�f�rland�
    a_saat = Eeprom_Read(0x10);   // Alarm saatini oku
    a_dakika = Eeprom_Read(0x11); // Alarm dakikas�n� oku

    T1CON.TMR1ON = 0;           // ilk anda timer1 kapal�
    TMR1L = 0x00;               // �n de�erler atan�yor 4096 art�� 
      // sonras� 32.768 kHz kristal i�in
    TMR1H = 0xF0;               // ta�ma ger�ekle�ecek
    T1CON = 0x3A;               // 1:8 prescaler, senkronizeli ext. 
      // clock,
    PIE1.TMR1IE = 1;
    T1CON.TMR1ON = 1;           // zamanlay�c� �al��t�r�ld�

    PWM_Init(1000);             // PWM frekans� 1KHz se�ildi
    PWM_Change_Duty(0x80);      // Duty cycle %50 se�ildi
    PWM_Start();

    ADCON1 = 0x84;              // RA0, RA1, RA3 analog, di�erleri 
      // dijital, sonu� sa�a dayal�
    TRISA.F4 = 1;               // Alarm susturma butonu i�in giri� 
      // yap�ld�
    ControlReg = 0;             // Kontrol kaydedicisini sil
    TaskControl = 0;            // G�rev kontrol kaydedicisini sil
    INTCON.PEIE = 1;            // �evresel kesmeleri etkinle�tir.
    INTCON.GIE = 1;             // Etkinle�tirilen kesmelere izin ver
}
//------------------------------------------------------------------
// ANA PROGRAM
//------------------------------------------------------------------
void main()
{
     main_init();             // �lk i�lemler alt program�n� �a��r
     while(1)
     {
// A�a��da g�revler yer almaktad�r. Kesme i�erisinde set olan 
// g�rev bayraklar� burada s�ras� ile i�lenirler. �ncelik 
// s�ralamas� g�revin �nceli�ine g�re tespit edilmelidir.
         
         // Seri ileti�im g�revi, Veri al�nd� ve i�lenmesi gerekiyor
         if (TaskControl.F0)
         {
             TerminalProgram();	// Seri ileti�im men�s�n� PC'de 
// g�ster ve men� i�lemlerini yap
             TaskControl.F0 = 0; // Yeni g�rev i�in silinmelidir.
         }
         
         // LM35 �s� sens�r�nden �s� okuma zaman� geldi
         if (TaskControl.F1)
         {
             IsiOlc();           // Is� �iddeti �l�
             TaskControl.F1 = 0; // Yeni g�rev i�in silinmelidir.
         }

         // LDR ���k sens�r�nden ���k �iddeti okuma zaman�
         if (TaskControl.F2)
         {
             IsikOlc();          // I��k �iddeti �l�
             TaskControl.F2 = 0; // Yeni g�rev i�in silinmelidir.
         }
         
         // 1 sn ge�ti. Zaman� i�le, alarm zaman�n� kontrol et
         if (TaskControl.F3)
         {
             ZamanIsle();        // Saati i�le
             TaskControl.F3 = 0; // Yeni g�rev i�in silinmelidir.
         }

         // Alarm susturma ve iptal butonuna bas�ld� m�?
         if (!ALARMKAPAT)
         {
            ControlReg.ALARMCIKIS = 0; // Alarm �alma bayra��n� sil.
            ControlReg.ALARMKURULU = 0;// Alarm kurulu bayra��n� sil
            ALARMPORT.ALARMCIKIS = 0;    // Alarm� sustur
            AlarmCnt = 0;       // Alarm s�resi kaydedicisini sil
         }
         
         // Bu b�l�me varsa di�er g�revler eklenebilir
     }
}
// *****************************************************************

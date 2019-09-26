// *****************************************************************
// Dosya Adý		: 15_1.c
// Açýklama		: Terminal Projesi
// PIC DK 2.1		: PORTB Çýkýþ ==> LCD display
//			: A/D seçim anahtarý RA1 A, diðerleri D konumunda
//			: XT ==> 4 MHz
// *****************************************************************
// Hi ve Lo fonksiyonlarý için baþlýk dosyasý programa katýlýyor.
#include "built_in.h"
// Alarm fonksiyonu ile ilgili tanýmlamalar yapýlýyor.
#define ALARMPORT        PORTE
#define ALARMTRIS        TRISE
#define ALARMCIKIS       F0
#define ALARMKURULU      F1
#define ALARMKAPAT       PORTA.F4  // Alarm kesme butonu
// Sensörler için analog kanal tanýmlamalarý yapýlýyor.
#define LM35            0    // 0. adc kanalýna baðlý
#define LDR             1    // 1. adc kanalýna baðlý
// Global deðiþken tanýmlamalarý yapýlýyor.
unsigned short tmp,i;
unsigned char ControlReg, TaskControl, RxBuffer;
unsigned char saat, dakika, saniye, a_saat, a_dakika, AlarmCnt;
unsigned int isi, isik, epadres, adr;
unsigned short PWMDuty;
//------------------------------------------------------------------
// Kesme Alt Programý.
//------------------------------------------------------------------
void interrupt(void)
{
    // Timer1 kesmesi iþleniyor.
    if (PIR1.TMR1IF)
    {
         TaskControl.F3 = 1;
         TMR1L = 0x00;    // Ön deðerler atanýyor 4096 artýþ sonrasý
         TMR1H = 0xF0;    // taþma gerçekleþecek
         PIR1.TMR1IF = 0;
    }
    // RX seri iletiþim veri alma kesmesi iþleniyor.
    if (PIR1.RCIF)
    {
        // alýnan karakter RCREG'de
        if(RCSTA.FERR || RCSTA.OERR)
        {
            RCSTA.CREN = 0;
            asm nop       // Bit iþlemleri arasýnda 1us kadar bekle
            RCSTA.CREN = 1;
        }
        PIR1.RCIF = 0;     	// Alma kesme bayraðýný sil.
        RxBuffer = RCREG;       	// Alýnan veriyi deðiþkene ata.
        ControlReg.F7 = 1;      	// Veri alýndý kontrol bitini set et
	TaskControl.F0 = 1;      	// Terminal için görev kontrol 
     	// bayraðýný set et.
	PIR1.RCIF = 0;
    }
}
//------------------------------------------------------------------
// EEPROM’a veri yazar.
//------------------------------------------------------------------
void e2eprom_write(unsigned int adr, unsigned short data)
{
  I2C_Start();           // I2C start sinyali gönder
  I2C_Wr(0xA0);          // I2C donaným adresi + yazma komutu gönder
  I2C_Wr(Hi(adr));       // Yazýlacak adresin yüksek byte'ýný gönder
  I2C_Wr(Lo(adr));       // Yazýlacak adresin alçak byte'ýný gönder
  I2C_Wr(data);          // Yazýlacak veriyi gönder
  I2C_Stop();            // I2C iletiþimi durdur
  Delay_ms(100);         // iþlemlerin tamamlanmasý için 100ms bekle
}
//------------------------------------------------------------------
// EEPROM’dan veri okur.
//------------------------------------------------------------------
unsigned short e2eprom_read(unsigned int adr)
{
  unsigned short data;
  I2C_Start();           // I2C start sinyali gönder
  I2C_Wr(0xA0);          // I2C donaným adresi + yazma komutu gönder
  I2C_Wr(Hi(adr));       // Yazýlacak adresin yüksek byte'ýný gönder
  I2C_Wr(Lo(adr));       // Yazýlacak adresin alçak byte'ýný gönder
  I2C_Repeated_Start();  // I2C reStart sinyali gönder
  I2C_Wr(0xA1);          // I2C donaným adresi + okuma komutu gönder
  data = I2C_Rd(0u);     // Veriyi oku (NO acknowledge)
  I2C_Stop();            // I2C iletiþimi durdur
  return data;           // okunan veriyi fonksiyon dýþýna taþý
}
//------------------------------------------------------------------
// USART birminden bir karakter alýr.
//------------------------------------------------------------------
char GetChar()
{
  while(!(ControlReg.F7));  // Seri porttan 1 karakter alýnana kadar 
                            // bekle
  ControlReg.F7 = 0;        // Karakter alýndý bayraðýný sil
  return RxBuffer;          // Alýnan karakteri çýkýþa aktar
}
//------------------------------------------------------------------
// USART'a bir karakter gönderir.
//------------------------------------------------------------------
void sendChar(char c)
{
  if(!(TXSTA.TXEN)) TXSTA.TXEN = 1;  // Veri gönderme kesmesini 
                                     // etkinleþtir.
  while(!(PIR1.TXIF));               // Veri gönderilene kadar bekle
  PIR1.TXIF = 0;                     // Veri gönderildi, bayraðý sil
  TXREG = c;
}
//------------------------------------------------------------------
// USART'a string yazar.
//------------------------------------------------------------------
void writeString(const char *s)
{
  char i=0;      // Gönderilecek stringin karakter sýrasý
  while( s[i]!=0 ) sendChar(s[i++]); 	// stringin sýradaki 
// karakterini gönder
}
//------------------------------------------------------------------
// Karakteri hex deðere dönüþtürür.
//------------------------------------------------------------------
unsigned short Char_to_Hex(unsigned short gec)
{
  ControlReg.F6 = 0;
  if (gec>47 && gec<58)
  {
     gec=gec-48;
     return gec;
  }
  else if (gec>64 && gec<71)   // A, B, C, D, E, F giriþleri için
  {
     gec=gec-65;
     gec=gec+0x0A;
     return gec;
  }
  else if (gec>96 && gec<103)   // a, b, c, d, e, f giriþleri için
  {
     gec=gec-97;
     gec=gec+0x0A;
     return gec;
  }
  // Hatalý karakter ControlReg 6. bit set et. Gerekirse bu bit 
  // kontrol edilerek hatalý giriþler engellenebilir.
  ControlReg.F6 = 1;
  return 0;
}
//------------------------------------------------------------------
// USART'dan hex bilgi alýr ve USART'a gönderir.
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
    if (ControlReg.F6) return 0xFF;  	// Hatalý karakter ise 0xFF 
// aktar
    tmp = tmp + ch;
    return tmp;
}
//------------------------------------------------------------------
// USART'dan desimal bilgi alýr ve USART'a gönderir.
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
// LM35 ISI sensörü ile ilgili fonksiyonlar
//------------------------------------------------------------------
void IsiOlc()
{
    // LM35'in baðlý olduðu ADC kanalýndan ýsý þiddetini al ve 
    // dönüþtür
    Isi = Adc_Read(LM35) >> 1;   
    // 2'ye bölerek gerçek ýsý deðerini bul yaklaþýk her bir artýþ 
    // deðeri 5 mV, 2 arttýðýnda 10 mV yani 1 derece, Bu nedenle 
    // 2'ye bölüyoruz. Sonuç gerçek ýsý deðerine çok yakýn. 
    // Ýstenirse yarým derece hassasiyet ile ýsý görüntülenebilir. 
    // Ayrýca referans gerilim ayarlanarak daha hassas ve daha doðru 
    // ýsý ölçümleri gerçekleþtirilebilir.
}
void IsiGoruntule()
{
    // Isý þiddetini PC terminalinde görüntüle
    sendDecByte(Isi);sendChar(' ');sendChar('C');
}
//------------------------------------------------------------------
// LDR IÞIK sensörü ile ilgili fonksiyonlar
//------------------------------------------------------------------
void IsikOlc()
{
    // LDR'nin baðlý olduðu ADC kanalýndan ýþýk þiddetinin en 
    // deðersiz byte'ýný al
    Isik = Adc_Read(LDR);
}

void IsikGoruntule()
{
    // Iþýk þiddetini PC terminalinde görüntüle
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
    // Saati PC terminalinde görüntüle
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
    // Alarmý eepromdan oku ve PC terminalinde görüntüle
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
            // Her saat baþý saat bilgisi ve ýsý bilgisi e2eproma 
            // kaydediliyor.
            IsiOlc();
            e2eprom_write(epadres, saat);
            epadres++;
            e2eprom_write(epadres, Isi);
            epadres++;
        }
        // 40 dk boyunca alarm susturulmadý ise alarmý kes
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
    // Alarm kurulu ise alarm zamanýný kontrol et
    if (ControlReg.ALARMKURULU)
         if ((saat == a_saat) && (dakika == a_dakika))
         {
             ALARMPORT.ALARMCIKIS = 1;
             ControlReg.ALARMCIKIS = 1;
         }
    // LCD'de saat:dakika:saniye bilgilerini görüntüle
    Lcd_Out(1,1, "");
    LCD_DecWrite(saat);Lcd_Chr_Cp(':');
    LCD_DecWrite(dakika);Lcd_Chr_Cp(':');
    LCD_DecWrite(saniye);
    // LCD'de ýsý bilgisini görüntüle
    IsiOlc();
    Lcd_Out(2,1, "ISI: ");
    LCD_DecWrite(Isi);
    Lcd_Chr_Cp('C');
}
//------------------------------------------------------------------
// PC ile iletiþim kuran terminal fonksiyonu
//------------------------------------------------------------------
void TerminalProgram()
{
    unsigned short ch,tmp,i;
    ch=GetChar();
    if (ch==13)
    while(ch!=48)
    {
           do {
                // PC Terminalinde menü yazdýrýlýyor.
             writeString("\r\n\r\n        DK 2.1 Iletisim Menusune Hosgeldiniz");
             writeString("\r\n Copyright © Ayhan DAYANIK - 2006 adayanik@gmail.com");
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
	   } while(ch<48 || ch>57);  	// Alýnan seçim 0-8 arasýnda 
// deðilse tekrar giriþ al
            // Alýnan seçim bilgisini PC terminaline yaz
            sendDecByte(ch-48);writeString("\n\r ");
            // Alýnan karakteri kontrol et ve görevi yerine getir.
	    switch(ch)
	    {
           	// Alýnan karakter '0' ise ch = 0 olduðundan while 
	// döngüsünden dolayýsý ile Terminal Program'dan 
	// çýkýlýr.
                case 48:writeString("\n\r Menuye girmek icin ENTER'e basiniz.. \n\r");
                      break;
                // Isý deðerini ölç ve PC terminalinde göster
	         case 49:writeString("\n\r Isi degeri: ");
                      IsiOlc();
                      sendDecByte(Isi);sendChar(' ');sendChar('C');
		        break;

// Iþýk þiddetini ölç ve PC terminalinde göster, Burada ýþýk þiddeti 
// iþlenmemiþ bir þekilde görüntülendi. Iþýk þiddetini doðru olarak 
// görüntülemek için okunan deðerin logaritmik olarak iþlenmesi 
// gerekmektedir. Projemizde ýþýk þiddeti ýsý kadar önemli 
// olmadýðýndan ve programýn anlaþýlýrlýðýný korumak için dönüþüm 
// yapýlmamýþtýr. Ýstenirse okunan belirli deðerlerde ýþýk þiddeti 
// hesaplama yöntemi yerine bilgisayar ortamýnda hesaplanmýþ bir 
// tablo kullanmak daha yerinde olacaktýr.
		case 50:writeString("\n\r Isik siddeti: ");
                        Isik = Adc_Read(LDR);
                        sendDecByte(Isik);
			break;

                // PC terminalinde saat:dakika formatýnda zaman 
                // görüntülenir.
              case 51:writeString("\n\r Saat: ");
		        SendDecByte(saat); sendChar(':'); SendDecByte(Dakika);
		        break;

                // PC terminalinde alarm kurulu ise alarm zamanýný, 
                // kurulu deðil ise alarmýn kurulu olmadýðýna dair 
                // mesaj görüntüler.
	case 52:if(ControlReg.ALARMKURULU)
         {
           a_saat = Eeprom_Read(0x10); a_dakika = Eeprom_Read(0x11);
           writeString("\n\r Alarm zamani: ");
           sendDecByte(a_saat); sendChar(':'); sendDecByte(a_dakika);
           } else writeString("\n\r Alarm kurulmamis..");
           break;

           // PC terminalinde ESC tuþuna basana kadar ya da eeprom 
           // sonuna yakýn bir deðere ulaþana kadar 10'ar 10'ar 
           // belirli zamanlarda ölçülmüþ ýsý deðerini görüntüle
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
                        
     // PC terminalinden saat:dakika giriþini alarak zamaný ayarlar
     case 54:writeString("\n\r Saat ve dakika giriniz ( HH:MM ): ");
	             saat = GetSendDecByte(); sendChar(':'); dakika = GetSendDecByte();
                    break;

     // PC terminalinden alarma ait saat:dakika giriþini alarak 
     // alarm zamanýný ayarlar
     case 55:writeString("\n\r Alarm zamanini giriniz ( HH:MM ): ");
               a_saat = GetSendDecByte(); sendChar(':'); a_dakika = GetSendDecByte();
              Eeprom_Write(0x10, a_saat); Eeprom_Write(0x11, a_dakika);
              ControlReg.ALARMKURULU = 1; // Alarm etkinleþtirildi
              break;

       // PC terminalinden PWM darbe geniþliðini alarak darbe 
       // geniþliðini ayarlar
	case 56:writeString("\n\r PWM darbe genisligini giriniz (00-FF): ");
              PWMDuty = GetSendHexByte();
              PWM_Stop();
              PWM_Init(1000);      // PWM frekansý 1KHz seçildi
              PWM_Change_Duty(PWMDuty);
              PWM_Start();
              break;
	      }
     }
}
//------------------------------------------------------------------
// Kullanýlan birimlerin kullanýma hazýr getirildiði ve bazý 
// deðiþkenlere ilk deðer atamalarýnýn yapýldýðý alt program
//------------------------------------------------------------------
void main_init()
{
    TRISC.F1 = 1;               // Timer1 için RC1 giriþ yapýldý
    ALARMTRIS.ALARMCIKIS = 0;   // Çýkýþa yönlendirildi
    ALARMPORT.ALARMCIKIS = 0;   // Ýlk anda alarm çalmýyor


    //Port yönlendir TX çýkýþ, RX giriþ
    TRISC.F6 = 0;       // TX ucu çýkýþ yapýldý
    TRISC.F7 = 1;       // RX ucu giriþe ayarlandý
    TXSTA = 0;          // TXSTA ilk anda sýfýr
    RCSTA = 0;          // RCSTA ilk anda sýfýr
// SPBRG = 129;	    // 20 Mhz de 9600 baud hýz için
    SPBRG = 25;	    // 4 Mhz de 9600 baud hýz için
// SPBRG = 50;          // 8 Mhz de 9600 baud hýz için
    TXSTA = 0x26;
    RCSTA = 0x90;
    PIE1.RCIE = 1;
    // Saat ile ilgili ilk deðerler atanýyor.
    saat = 0;
    dakika = 0;
    saniye = 0;
    AlarmCnt = 0;
    // LCD kullanýma hazýrlanýyor.
    Lcd_Config(&PORTB,4,5,7,3,2,1,0);  // LCD baðlantý tanýmlamalarý
    Lcd_Cmd(LCD_CLEAR);                // LCD'yi sil
    Lcd_Cmd(LCD_CURSOR_OFF);           // Ýmleci gizle

    I2C_Init(100000);             // I2C iletiþimi 100 KHz
    epadres = 0;                  // eprom adresi sýfýrlandý
    a_saat = Eeprom_Read(0x10);   // Alarm saatini oku
    a_dakika = Eeprom_Read(0x11); // Alarm dakikasýný oku

    T1CON.TMR1ON = 0;           // ilk anda timer1 kapalý
    TMR1L = 0x00;               // Ön deðerler atanýyor 4096 artýþ 
      // sonrasý 32.768 kHz kristal için
    TMR1H = 0xF0;               // taþma gerçekleþecek
    T1CON = 0x3A;               // 1:8 prescaler, senkronizeli ext. 
      // clock,
    PIE1.TMR1IE = 1;
    T1CON.TMR1ON = 1;           // zamanlayýcý çalýþtýrýldý

    PWM_Init(1000);             // PWM frekansý 1KHz seçildi
    PWM_Change_Duty(0x80);      // Duty cycle %50 seçildi
    PWM_Start();

    ADCON1 = 0x84;              // RA0, RA1, RA3 analog, diðerleri 
      // dijital, sonuç saða dayalý
    TRISA.F4 = 1;               // Alarm susturma butonu için giriþ 
      // yapýldý
    ControlReg = 0;             // Kontrol kaydedicisini sil
    TaskControl = 0;            // Görev kontrol kaydedicisini sil
    INTCON.PEIE = 1;            // Çevresel kesmeleri etkinleþtir.
    INTCON.GIE = 1;             // Etkinleþtirilen kesmelere izin ver
}
//------------------------------------------------------------------
// ANA PROGRAM
//------------------------------------------------------------------
void main()
{
     main_init();             // Ýlk iþlemler alt programýný çaðýr
     while(1)
     {
// Aþaðýda görevler yer almaktadýr. Kesme içerisinde set olan 
// görev bayraklarý burada sýrasý ile iþlenirler. Öncelik 
// sýralamasý görevin önceliðine göre tespit edilmelidir.
         
         // Seri iletiþim görevi, Veri alýndý ve iþlenmesi gerekiyor
         if (TaskControl.F0)
         {
             TerminalProgram();	// Seri iletiþim menüsünü PC'de 
// göster ve menü iþlemlerini yap
             TaskControl.F0 = 0; // Yeni görev için silinmelidir.
         }
         
         // LM35 ýsý sensöründen ýsý okuma zamaný geldi
         if (TaskControl.F1)
         {
             IsiOlc();           // Isý þiddeti ölç
             TaskControl.F1 = 0; // Yeni görev için silinmelidir.
         }

         // LDR ýþýk sensöründen ýþýk þiddeti okuma zamaný
         if (TaskControl.F2)
         {
             IsikOlc();          // Iþýk þiddeti ölç
             TaskControl.F2 = 0; // Yeni görev için silinmelidir.
         }
         
         // 1 sn geçti. Zamaný iþle, alarm zamanýný kontrol et
         if (TaskControl.F3)
         {
             ZamanIsle();        // Saati iþle
             TaskControl.F3 = 0; // Yeni görev için silinmelidir.
         }

         // Alarm susturma ve iptal butonuna basýldý mý?
         if (!ALARMKAPAT)
         {
            ControlReg.ALARMCIKIS = 0; // Alarm çalma bayraðýný sil.
            ControlReg.ALARMKURULU = 0;// Alarm kurulu bayraðýný sil
            ALARMPORT.ALARMCIKIS = 0;    // Alarmý sustur
            AlarmCnt = 0;       // Alarm süresi kaydedicisini sil
         }
         
         // Bu bölüme varsa diðer görevler eklenebilir
     }
}
// *****************************************************************

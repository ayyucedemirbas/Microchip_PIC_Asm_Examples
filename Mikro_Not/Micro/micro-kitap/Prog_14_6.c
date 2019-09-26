// *****************************************************************
// Dosya Ad�		: 14_6.c
// A��klama		: PCF8583 ile saat uygulamas�
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
unsigned char saniye, dakika, saat, gun, ay, yil, haftaningunu, controlbyte;
unsigned char asaniye, adakika, asaat, agun, aay;
char *txt, *str="  \0";

char Hex2Dec(char ch)       // 2 digit d�n���m
{
     char tmp = 0;
     while(ch>=10) {tmp++; ch -= 10;}
     tmp = (tmp<<4) + ch;
     return tmp;
}

void BintoStr(char data)
{
    data = Hex2Dec(data);
    str[0]= 48 + ((data & 0xF0) >> 4);
    str[1]= 48 + (data & 0x0F);
}

void pcf8583_read()
{
    I2C_Start();
    I2C_Wr(0xA0);
    I2C_Wr(2);
    I2C_Repeated_Start();
    I2C_Wr(0xA1);
    saniye =I2C_Rd(1);
    while (I2C_Is_Idle() == 0) ;
    dakika =I2C_Rd(1);
    while (I2C_Is_Idle() == 0) ;
    saat =I2C_Rd(1);
    while (I2C_Is_Idle() == 0) ;
    gun =I2C_Rd(1);
    while (I2C_Is_Idle() == 0) ;
    ay =I2C_Rd(0);
    while (I2C_Is_Idle() == 0) ;
    I2C_Stop();
}

void pcf8583_write()
{
   char tmp1, tmp2;
   tmp1 = (yil<<6) | gun;
   tmp2 = (haftaningunu<<5) | ay;
   I2C_Start();          // start sinyali olu�turuluyor
   I2C_Wr(0xA0);     // PCF8583'in adres + yaz bilgisi g�nderiliyor
   I2C_Wr(0);        // 0. adresteki konfig�rasyon bilgisinden ba�la
   I2C_Wr(0x80);         // yaz�lan 0x80 bilgisi sayac� durdurur.
   I2C_Wr(0);   // saniyenin 100'de 1'ini g�steren kaydediciyi sil
   I2C_Wr(saniye);       // saniye bilgisini yaz
   I2C_Wr(dakika);       // dakika bilgisini yaz
   I2C_Wr(saat);         // saat bilgisini yaz
   I2C_Wr(tmp1);         // y�l/g�n bilgisini yaz
   I2C_Wr(tmp2);         // haftan�n g�n� ve ay bilgisini yaz
   I2C_Stop();           // stop sinyali g�nder
   I2C_Start();          // start sinyali g�nder
   I2C_Wr(0xA0);    // PCF8583'in adres + yaz bilgisi g�nderiliyor
   I2C_Wr(0);       // adres 0'dan ba�la
   I2C_Wr(0);       // konfig�rasyon kelimesine 0 yaz. Sayma etkin.
   I2C_Stop();      // stop sinyali g�nder
}

void pcf8583_alarm_write()
{
   I2C_Start();     // start sinyali g�nder
   I2C_Wr(0xA0);    // PCF8583'in adres + yaz bilgisi g�nderiliyor
   I2C_Wr(0x00);    // kontrol kaydedicisinin adresini g�nder
   I2C_Wr(0x80); // alarm etkinle�tirme bitini set et, sayac� durdur
   I2C_Stop();      // stop sinyali g�nder
   delay_ms(5);
   
   I2C_Start();     // start sinyali g�nder
   I2C_Wr(0xA0);    // PCF8583'in adres + yaz bilgisi g�nderiliyor
   I2C_Wr(0x07);    // alarm kontrol kaydedicisi adresini g�nder
   I2C_Wr(0x00);    // Timer pasif
   I2C_Wr(0xA0);    // alarm kesmesini ve haftal�k alarm modunu
                    // etkinle�tir.
   I2C_Wr(0x00);    // PCF8583'in adres + yaz bilgisi g�nderiliyor
   I2C_Wr(asaniye);      // yaz�lan 0x80 bilgisi sayac� durdurur.
   I2C_Wr(adakika);      // saniyenin 100'de 1'ini g�steren 
// kaydediciyi sil
   I2C_Wr(asaat);        // saniye bilgisini yaz
   I2C_Wr(agun);         // dakika bilgisini yaz
   I2C_Wr(aay);          // saat bilgisini yaz
   I2C_Stop();           // stop sinyali g�nder
   delay_ms(5);

   I2C_Start();     // start sinyali g�nder
   I2C_Wr(0xA0);    // PCF8583'in adres + yaz bilgisi g�nderiliyor
   I2C_Wr(0);       // kontrol kaydedicisinin adresini g�nder
   I2C_Wr(0x04); // alarm etkinle�tirme bitini set et, counter etkin
   I2C_Stop();      // stop sinyali g�nder
   delay_ms(5);
}

void Transform_Time()
{
    saniye = ((saniye & 0xF0) >> 4)*10 + (saniye & 0x0F);
    dakika = ((dakika & 0xF0) >> 4)*10 + (dakika & 0x0F);
    saat = ((saat & 0xF0) >> 4)*10 + (saat & 0x0F);
    yil = (gun & 0xC0) >> 6;
    gun = ((gun & 0x30) >> 4)*10 + (gun & 0x0F);
    ay = ((ay & 0x10) >> 4)*10 + (ay & 0x0F);
}

void Display_Time()
{
    LCD_Out(1,1,"Tarih=");
    BintoStr(gun);
    LCD_Out_Cp(str);
    LCD_Out_Cp("-");
    BintoStr(ay);
    LCD_Out_Cp(str);
    LCD_Out_Cp("-");
    LCD_Out_Cp("20");
    BintoStr(yil);
    LCD_Out_Cp(str);

    LCD_Out(2,1," Saat=");
    BintoStr(saat);
    LCD_Out_Cp(str);
    LCD_Out_Cp(":");
    BintoStr(dakika);
    LCD_Out_Cp(str);
    LCD_Out_Cp(":");
    BintoStr(saniye);
    LCD_Out_Cp(str);
}

void init()
{
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    // initialize LCD on portb
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    I2C_Init(100000);   // I2C ileti�imi haz�rla, full master mode
    
    saniye = 0x57;
    dakika = 0x52;
    saat = 0x15;
    gun = 0x03;
    ay = 0x10;
    yil = 0x02;
    haftaningunu = 0x03;   	// 0:pazar, 1:pazartesi, 2:sal�, 
// 3:�ar�amba ...
    asaniye = 0;
    adakika = 0x53;
    asaat = 0x15;
    agun = 0x03;
    aay = 0x10;
}

void main()
{
    init();                // ilk i�lemler ger�ekle�tiriliyor
    pcf8583_write();
    pcf8583_alarm_write();
    while(1)
    {
        pcf8583_read();    // RTC(PCF8583)'den zaman� oku
        Transform_Time();  // Tarih ve saat format�n� ayarla
        Display_Time();    // LCD diplayde g�r�nt�le
        Delay_ms(1000);    // 1 saniye bekle
    }
}
// *****************************************************************

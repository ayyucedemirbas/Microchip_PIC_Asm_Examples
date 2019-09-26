// *****************************************************************
// Dosya Adý		: 14_5.c
// Açýklama		: DS1307 RTC
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
unsigned char saniye, dakika, saat, gun, ay, yil, haftaningunu;
char *str="  \0";

void BintoStr(char data)
{
    str[0]= 48 + ((data & 0xF0) >> 4);    // En deðerli dört bit ve
    str[1]= 48 + (data & 0x0F);           // en deðersiz dört bit 
// text'e döüþtürüldü
}

void ds1307_write()
{
   I2C_Start();          // start sinyali oluþturuluyor
   I2C_Wr(0xD0);         // DS1307'nin adres + yaz bilgisi 
// gönderiliyor
   I2C_Wr(0x00);         // 0. adresteki saniye bilgisinden baþla
   I2C_Wr(saniye);       // saniye bilgisini yaz
   I2C_Wr(dakika);       // dakika bilgisini yaz
   I2C_Wr(saat);         // saat bilgisini yaz
   I2C_Wr(haftaningunu); // haftanýn günü bilgisini yaz
   I2C_Wr(gun);          // gün bilgisini yaz
   I2C_Wr(ay);           // ay bilgisini yaz
   I2C_Wr(yil);          // yil bilgisini yaz
   I2C_Wr(0x90);         // 1Hz'lik darbe çýkýþý etkinleþtirildi.
   I2C_Stop();           // stop sinyali gönder
}

void ds1307_read()
{
   I2C_Start();       // start sinyali oluþturuluyor
   I2C_Wr(0xD0);      // DS1307'nin adres + yaz bilgisi gönderiliyor
   I2C_Wr(0x00);      // 0.adresteki konfigürasyon bilgisinden baþla
   I2C_Repeated_Start();    // Start bilgisini tekrarla
   I2C_Wr(0xD1);      // DS1307'nin adres + yaz bilgisi gönderiliyor
   saniye = I2C_Rd(1);     // saniye okundu + ACK sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   dakika = I2C_Rd(1);     // dakika okundu + ACK sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   saat = I2C_Rd(1);       // saat okundu + ACK sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   haftaningunu = I2C_Rd(1);      // haftanýn günü okundu + ACK 
// sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   gun =I2C_Rd(1);           // gün okundu + ACK sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   ay =I2C_Rd(1);           // ay okundu + ACK sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   yil =I2C_Rd(0);       // yil okundu + NOT ACK sinyali gönderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hattý meþgul ise bekle
   I2C_Stop();                    // stop sinyali gönder
}

void Display_Time()
{
    LCD_Out(1,1,"Tarih=");  // 1.satýr, 1.karakterden yazmaya baþla
    BintoStr(gun);          // gün bilgisini text'e dönüþtür
    LCD_Out_Cp(str);        // ve imlecin bulunduðu yerden 
// baþlayarak yaz
    LCD_Out_Cp("-");        // - iþareti imlecin bulunduðu yerden 
// baþlayarak yaz
    BintoStr(ay);           // ay bilgisini text'e dönüþtür
    LCD_Out_Cp(str);  
    LCD_Out_Cp("-"); 
    LCD_Out_Cp("20");       // yýlýn ilk 2 hanesini imlecin 
// bulunduðu yerden baþlayarak yaz
    BintoStr(yil);          // yil bilgisini text'e dönüþtür
    LCD_Out_Cp(str); 
    LCD_Out(2,1,"St=");     // 2.satýr, 1.karakterden yazmaya baþla
    BintoStr(saat);         // saat bilgisini text'e dönüþtür
    LCD_Out_Cp(str);
    LCD_Out_Cp(":");        // : iþareti
    BintoStr(dakika);       // dakika bilgisini text'e dönüþtür
    LCD_Out_Cp(str); 
    LCD_Out_Cp(":"); 
    BintoStr(saniye);       // saniye bilgisini text'e dönüþtür
    LCD_Out_Cp(str);   
    LCD_Out_Cp("  ");       // 2 karakter boþluk býrak
    switch(haftaningunu)    // haftanýn gününü LCD'de görüntüler
    {
        case 1: LCD_Out_Cp("PTS");break;  	// haftanýn günü 1 ise 
// PAZARTESÝ
        case 2: LCD_Out_Cp("SAL");break;  	// haftanýn günü 2 ise 
// SALI
        case 3: LCD_Out_Cp("CAR");break;  	// haftanýn günü 3 ise 
// ÇARÞAMBA
        case 4: LCD_Out_Cp("PER");break;  	// haftanýn günü 4 ise 
// PERÞEMBE
        case 5: LCD_Out_Cp("CUM");break;  	// haftanýn günü 5 ise 
// CUMA
        case 6: LCD_Out_Cp("CTS");break;  	// haftanýn günü 6 ise 
// CUMARTESÝ
        case 7: LCD_Out_Cp("PAZ");break;  	// haftanýn günü 7 ise 
// PAZAR
    }
}

void init()
{
// LCD baðlantýsý tanýmlanýyor
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    I2C_Init(100000);   // I2C iletiþimi hazýrla, full master mode
    saniye = 0x57;         // saniye deðiþkenine ilk deðer verildi
    dakika = 0x52;         // dakika deðiþkenine ilk deðer verildi
    saat = 0x15;           // En deðerli 2 bit 00 olduðundan 24'lük 
// saat sistemi seçildi ve
                           // saat = 15 olarak belirlendi
    gun = 0x018;           // Ay'ýn 18. günü
    ay = 0x04;             // 4. ay
    yil = 0x06;            // 2006 yýlý
    haftaningunu = 0x02;   // 1:pazartesi, 2:salý, 3:çarþamba ... 
// 7.pazar
    ds1307_write();
}

void main()
{
    init();                // ilk iþlemler gerçekleþtiriliyor
    while(1)
    {
        ds1307_read();     // RTC(DS1307)'den zamaný oku
        Display_Time();    // LCD diplayde görüntüle
        Delay_ms(1000);    // 1 saniye bekle
    }
}
// *****************************************************************

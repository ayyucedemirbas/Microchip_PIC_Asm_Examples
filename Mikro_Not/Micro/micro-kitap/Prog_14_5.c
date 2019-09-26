// *****************************************************************
// Dosya Ad�		: 14_5.c
// A��klama		: DS1307 RTC
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
unsigned char saniye, dakika, saat, gun, ay, yil, haftaningunu;
char *str="  \0";

void BintoStr(char data)
{
    str[0]= 48 + ((data & 0xF0) >> 4);    // En de�erli d�rt bit ve
    str[1]= 48 + (data & 0x0F);           // en de�ersiz d�rt bit 
// text'e d���t�r�ld�
}

void ds1307_write()
{
   I2C_Start();          // start sinyali olu�turuluyor
   I2C_Wr(0xD0);         // DS1307'nin adres + yaz bilgisi 
// g�nderiliyor
   I2C_Wr(0x00);         // 0. adresteki saniye bilgisinden ba�la
   I2C_Wr(saniye);       // saniye bilgisini yaz
   I2C_Wr(dakika);       // dakika bilgisini yaz
   I2C_Wr(saat);         // saat bilgisini yaz
   I2C_Wr(haftaningunu); // haftan�n g�n� bilgisini yaz
   I2C_Wr(gun);          // g�n bilgisini yaz
   I2C_Wr(ay);           // ay bilgisini yaz
   I2C_Wr(yil);          // yil bilgisini yaz
   I2C_Wr(0x90);         // 1Hz'lik darbe ��k��� etkinle�tirildi.
   I2C_Stop();           // stop sinyali g�nder
}

void ds1307_read()
{
   I2C_Start();       // start sinyali olu�turuluyor
   I2C_Wr(0xD0);      // DS1307'nin adres + yaz bilgisi g�nderiliyor
   I2C_Wr(0x00);      // 0.adresteki konfig�rasyon bilgisinden ba�la
   I2C_Repeated_Start();    // Start bilgisini tekrarla
   I2C_Wr(0xD1);      // DS1307'nin adres + yaz bilgisi g�nderiliyor
   saniye = I2C_Rd(1);     // saniye okundu + ACK sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   dakika = I2C_Rd(1);     // dakika okundu + ACK sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   saat = I2C_Rd(1);       // saat okundu + ACK sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   haftaningunu = I2C_Rd(1);      // haftan�n g�n� okundu + ACK 
// sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   gun =I2C_Rd(1);           // g�n okundu + ACK sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   ay =I2C_Rd(1);           // ay okundu + ACK sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   yil =I2C_Rd(0);       // yil okundu + NOT ACK sinyali g�nderildi
   while (I2C_Is_Idle() == 0) ;   // I2C hatt� me�gul ise bekle
   I2C_Stop();                    // stop sinyali g�nder
}

void Display_Time()
{
    LCD_Out(1,1,"Tarih=");  // 1.sat�r, 1.karakterden yazmaya ba�la
    BintoStr(gun);          // g�n bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);        // ve imlecin bulundu�u yerden 
// ba�layarak yaz
    LCD_Out_Cp("-");        // - i�areti imlecin bulundu�u yerden 
// ba�layarak yaz
    BintoStr(ay);           // ay bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);  
    LCD_Out_Cp("-"); 
    LCD_Out_Cp("20");       // y�l�n ilk 2 hanesini imlecin 
// bulundu�u yerden ba�layarak yaz
    BintoStr(yil);          // yil bilgisini text'e d�n��t�r
    LCD_Out_Cp(str); 
    LCD_Out(2,1,"St=");     // 2.sat�r, 1.karakterden yazmaya ba�la
    BintoStr(saat);         // saat bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);
    LCD_Out_Cp(":");        // : i�areti
    BintoStr(dakika);       // dakika bilgisini text'e d�n��t�r
    LCD_Out_Cp(str); 
    LCD_Out_Cp(":"); 
    BintoStr(saniye);       // saniye bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);   
    LCD_Out_Cp("  ");       // 2 karakter bo�luk b�rak
    switch(haftaningunu)    // haftan�n g�n�n� LCD'de g�r�nt�ler
    {
        case 1: LCD_Out_Cp("PTS");break;  	// haftan�n g�n� 1 ise 
// PAZARTES�
        case 2: LCD_Out_Cp("SAL");break;  	// haftan�n g�n� 2 ise 
// SALI
        case 3: LCD_Out_Cp("CAR");break;  	// haftan�n g�n� 3 ise 
// �AR�AMBA
        case 4: LCD_Out_Cp("PER");break;  	// haftan�n g�n� 4 ise 
// PER�EMBE
        case 5: LCD_Out_Cp("CUM");break;  	// haftan�n g�n� 5 ise 
// CUMA
        case 6: LCD_Out_Cp("CTS");break;  	// haftan�n g�n� 6 ise 
// CUMARTES�
        case 7: LCD_Out_Cp("PAZ");break;  	// haftan�n g�n� 7 ise 
// PAZAR
    }
}

void init()
{
// LCD ba�lant�s� tan�mlan�yor
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    I2C_Init(100000);   // I2C ileti�imi haz�rla, full master mode
    saniye = 0x57;         // saniye de�i�kenine ilk de�er verildi
    dakika = 0x52;         // dakika de�i�kenine ilk de�er verildi
    saat = 0x15;           // En de�erli 2 bit 00 oldu�undan 24'l�k 
// saat sistemi se�ildi ve
                           // saat = 15 olarak belirlendi
    gun = 0x018;           // Ay'�n 18. g�n�
    ay = 0x04;             // 4. ay
    yil = 0x06;            // 2006 y�l�
    haftaningunu = 0x02;   // 1:pazartesi, 2:sal�, 3:�ar�amba ... 
// 7.pazar
    ds1307_write();
}

void main()
{
    init();                // ilk i�lemler ger�ekle�tiriliyor
    while(1)
    {
        ds1307_read();     // RTC(DS1307)'den zaman� oku
        Display_Time();    // LCD diplayde g�r�nt�le
        Delay_ms(1000);    // 1 saniye bekle
    }
}
// *****************************************************************

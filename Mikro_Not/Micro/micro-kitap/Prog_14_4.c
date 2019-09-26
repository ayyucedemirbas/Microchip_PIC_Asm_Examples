// *****************************************************************
// Dosya Adý		: 14_4.c
// Açýklama		: DS1302 RTC 
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye baðlantýlarý tanýmlanýyor
//------------------------------------------------------------------
#define ds1302          PORTC
#define ds1302_tris     TRISC
#define rst_pin         F0
#define clk_pin         F1
#define data_pin        F2
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye baðlantýlarý tanýmlanýyor
//------------------------------------------------------------------
unsigned char saniye, dakika, saat, gun, ay, yil, haftaningunu;
char *str="  \0";


//------------------------------------------------------------------
// Hexadesimal deðeri LCD'de görüntülemek için text'e dönüþtürür.
//------------------------------------------------------------------
void BintoStr(char data)
{
    str[0]= 48 + ((data & 0xF0) >> 4);    // En deðerli dört bit ve
    str[1]= 48 + (data & 0x0F);           // en deðersiz dört bit 
// text'e dönüþtürüldü
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye baðlantýlarý tanýmlanýyor
//------------------------------------------------------------------
void init_3wire()
{
// ds1302'ye baðlanan pinler yönlendiriliyor.
    ds1302_tris.data_pin = 0;
    ds1302_tris.rst_pin = 0;
    ds1302_tris.clk_pin = 0;

// ds1302'ye baðlanan pinler LOW seviyesine çekiliyor
    ds1302.data_pin = 0;
    ds1302.rst_pin = 0;
    ds1302.clk_pin = 0;
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye baðlantýlarý tanýmlanýyor
//------------------------------------------------------------------
void reset_3wire()
{
// ds1302 resetleniyor
    ds1302.clk_pin = 0;
    ds1302.rst_pin = 0;
    ds1302.rst_pin = 1;
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye baðlantýlarý tanýmlanýyor
//------------------------------------------------------------------
void write_byte_3wire(unsigned char veri)
{
    unsigned char i;
// data pini çýkýþa yönlendiriliyor.
    ds1302_tris.data_pin = 0;
    for(i = 0; i < 8; ++i)
    {
// Verinin 0. biti 1 ise data_pin HIGH, 0 ise LOW seviyesine 
// çekiliyor.
        if(veri.F0) ds1302.data_pin = 1; else ds1302.data_pin = 0;
// Saat darbesi uygulanýyor. (yükselen kenar)
        ds1302.clk_pin = 0;
        ds1302.clk_pin = 1;
        veri = (veri>>1);           // Veri 1 bit saða kaydýrýlýyor.
    }
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye baðlantýlarý tanýmlanýyor
//------------------------------------------------------------------
unsigned char read_byte_3wire()
{
    unsigned char i, veri;
// data pini veri okumak için giriþe yönlendiriliyor.
    ds1302_tris.data_pin = 1;
    veri = 0x00;                 // Verinin ilk deðeri sýfýr
    for(i=0; i<8; ++i)
    {
// 1 bit okumak için saat darbesi uygulanýyor
        ds1302.clk_pin = 1;
        ds1302.clk_pin = 0;
        veri >>= 1;              // veri bir bit saða kaydýrýlýyor.
// ds1302'nin data_pininden gene veri 1 ise verinin 7. biti 1 
// yapýlýyor, aksi durumda verinin 7. biti 0 yapýlýyor.
        if(ds1302.data_pin) veri.F7 = 1; else veri.F7 = 0;
    }
    return veri;         // okunan veriyi fonksiyon dýþýna taþý
}
//------------------------------------------------------------------
// DS1302'ye tarih, saat ve haftanýn günü bilgisi yazýlýyor ve 
// batarya þarj devresi tespit ediliyor.
//------------------------------------------------------------------
void DS1302_Init()
{
    init_3wire();                // 3 yol iletiþimi kullanýma hazýrla
    reset_3wire();               // 3 yol iletiþimi resetle
    write_byte_3wire(0x8E);      // kontrol kaydedicisine eriþim 
// saðlanýyor
    write_byte_3wire(0);         // Yazma korumasý kaldýrýlýyor.

    reset_3wire();               // 3 yol iletiþimi resetle
    write_byte_3wire(0x90);      // trickle charger kaydedicisine 
// eriþim saðlanýyor
    write_byte_3wire(0xAB);      // 8 Kohm direnç üzerinden 2 
// diyotlu þarj birimi seçildi
    reset_3wire();               // 3 yol iletiþimi resetle
    write_byte_3wire(0xBE);      // sýralý 8 adet kaydediciye 
// yazýlacaðý belirtiliyor.
    write_byte_3wire(saniye);    // saniye bilgisini yaz
    write_byte_3wire(dakika);    // dakika bilgisini yaz
    write_byte_3wire(saat);      // saat bilgisini yaz
    write_byte_3wire(gun);       // gun bilgisini yaz
    write_byte_3wire(ay);        // ay bilgisini yaz
    write_byte_3wire(haftaningunu);   // haftanýn günü bilgisini yaz
    write_byte_3wire(yil);       // yýl bilgisini yaz
    write_byte_3wire(0);         // Kontrol kaydedicisine 0 bilgisi yaz
    reset_3wire();               // 3 yol iletiþimi resetle
}
//------------------------------------------------------------------
// DS1302'den zaman bilgisi okunuyor.
//------------------------------------------------------------------
void DS1302_ReadTime()
{
    reset_3wire();                   // 3 yol iletiþimi resetle
// DS1302'den sýralý saat ve tarih bilgisi okuma baþlatýlýyor
    write_byte_3wire(0xBF);          
    saniye = read_byte_3wire();      // saniye bilgisini oku
    dakika = read_byte_3wire();      // dakika bilgisini oku
    saat = read_byte_3wire();        // saat bilgisini oku
    gun = read_byte_3wire();         // gun bilgisini oku
    ay = read_byte_3wire();          // ay bilgisini oku
    haftaningunu = read_byte_3wire();// haftanýn günü bilgisini oku
    yil = read_byte_3wire();         // yil bilgisini oku
    reset_3wire();                   // 3 yol iletiþimi resetle
}
//------------------------------------------------------------------
// DS1302'den daha tarih, saat ve haftanýn günü bilgisini LCD'de 
// görüntüler.
//------------------------------------------------------------------
void Display_Time()
{
    LCD_Out(1,1,"Tarih=");  // 1.satýr, 1.karakterden yazmaya baþla
    BintoStr(gun);          // gün bilgisini text'e dönüþtür
    LCD_Out_Cp(str);        // ve imlecin bulunduðu yerden 
// baþlayarak yaz
    LCD_Out_Cp("-");        // - iþareti imlecin bulunduðu yerden 
// baþlayarak yaz
    BintoStr(ay);           // ay bilgisini text'e dönüþtür
    LCD_Out_Cp(str);        // ve imlecin bulunduðu yerden 
// baþlayarak yaz
    LCD_Out_Cp("-");        // - iþareti imlecin bulunduðu yerden 
// baþlayarak yaz
    LCD_Out_Cp("20");       // yýlýn ilk 2 hanesini imlecin 
// bulunduðu yerden baþlayarak yaz
    BintoStr(yil);          // yil bilgisini text'e dönüþtür
    LCD_Out_Cp(str);        // ve imlecin bulunduðu yerden 
// baþlayarak yaz
    LCD_Out(2,1,"St=");     // 2.satýr, 1.karakterden yazmaya baþla
    BintoStr(saat);         // saat bilgisini text'e dönüþtür
    LCD_Out_Cp(str);        // ve imlecin bulunduðu yerden 
// baþlayarak yaz
    LCD_Out_Cp(":");        // : iþareti imlecin bulunduðu yerden 
// baþlayarak yaz
    BintoStr(dakika);       // dakika bilgisini text'e dönüþtür
    LCD_Out_Cp(str);   
    LCD_Out_Cp(":");        // : iþareti imlecin bulunduðu yerden 
// baþlayarak yaz
    BintoStr(saniye);       // saniye bilgisini text'e dönüþtür
    LCD_Out_Cp(str);   
    LCD_Out_Cp("  ");       // 2 karakter boþluk imlecin bulunduðu 
// yerden baþlayarak yaz
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
//------------------------------------------------------------------
// LCD ve DS1302 RTC birimini kullanýma hazýrlar.
//------------------------------------------------------------------
void init()
{
// LCD baðlantýsý tanýmlanýyor
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    saniye = 0x50;
    dakika = 0x59;
    saat = 0x23;
    gun = 0x27;
    ay = 0x04;
    yil = 0x06;
    haftaningunu = 0x04;                 // Perþembe
    DS1302_Init();
}
//------------------------------------------------------------------
// Ana program DS1302 saat entegresine bir tarih ve saat bilgisi 
// yazar. Daha sonra tarih, saat ve haftanýn gününü sürekli okuyarak 
// LCD ekranda görüntüler.
//------------------------------------------------------------------
void main()
{
    init();
    do
    {
        DS1302_ReadTime();
        Display_Time();
    } while(1);
}
// *****************************************************************

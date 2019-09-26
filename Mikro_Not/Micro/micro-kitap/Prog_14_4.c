// *****************************************************************
// Dosya Ad�		: 14_4.c
// A��klama		: DS1302 RTC 
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye ba�lant�lar� tan�mlan�yor
//------------------------------------------------------------------
#define ds1302          PORTC
#define ds1302_tris     TRISC
#define rst_pin         F0
#define clk_pin         F1
#define data_pin        F2
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye ba�lant�lar� tan�mlan�yor
//------------------------------------------------------------------
unsigned char saniye, dakika, saat, gun, ay, yil, haftaningunu;
char *str="  \0";


//------------------------------------------------------------------
// Hexadesimal de�eri LCD'de g�r�nt�lemek i�in text'e d�n��t�r�r.
//------------------------------------------------------------------
void BintoStr(char data)
{
    str[0]= 48 + ((data & 0xF0) >> 4);    // En de�erli d�rt bit ve
    str[1]= 48 + (data & 0x0F);           // en de�ersiz d�rt bit 
// text'e d�n��t�r�ld�
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye ba�lant�lar� tan�mlan�yor
//------------------------------------------------------------------
void init_3wire()
{
// ds1302'ye ba�lanan pinler y�nlendiriliyor.
    ds1302_tris.data_pin = 0;
    ds1302_tris.rst_pin = 0;
    ds1302_tris.clk_pin = 0;

// ds1302'ye ba�lanan pinler LOW seviyesine �ekiliyor
    ds1302.data_pin = 0;
    ds1302.rst_pin = 0;
    ds1302.clk_pin = 0;
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye ba�lant�lar� tan�mlan�yor
//------------------------------------------------------------------
void reset_3wire()
{
// ds1302 resetleniyor
    ds1302.clk_pin = 0;
    ds1302.rst_pin = 0;
    ds1302.rst_pin = 1;
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye ba�lant�lar� tan�mlan�yor
//------------------------------------------------------------------
void write_byte_3wire(unsigned char veri)
{
    unsigned char i;
// data pini ��k��a y�nlendiriliyor.
    ds1302_tris.data_pin = 0;
    for(i = 0; i < 8; ++i)
    {
// Verinin 0. biti 1 ise data_pin HIGH, 0 ise LOW seviyesine 
// �ekiliyor.
        if(veri.F0) ds1302.data_pin = 1; else ds1302.data_pin = 0;
// Saat darbesi uygulan�yor. (y�kselen kenar)
        ds1302.clk_pin = 0;
        ds1302.clk_pin = 1;
        veri = (veri>>1);           // Veri 1 bit sa�a kayd�r�l�yor.
    }
}
//------------------------------------------------------------------
// DS1302'nin mikrodenetleyiciye ba�lant�lar� tan�mlan�yor
//------------------------------------------------------------------
unsigned char read_byte_3wire()
{
    unsigned char i, veri;
// data pini veri okumak i�in giri�e y�nlendiriliyor.
    ds1302_tris.data_pin = 1;
    veri = 0x00;                 // Verinin ilk de�eri s�f�r
    for(i=0; i<8; ++i)
    {
// 1 bit okumak i�in saat darbesi uygulan�yor
        ds1302.clk_pin = 1;
        ds1302.clk_pin = 0;
        veri >>= 1;              // veri bir bit sa�a kayd�r�l�yor.
// ds1302'nin data_pininden gene veri 1 ise verinin 7. biti 1 
// yap�l�yor, aksi durumda verinin 7. biti 0 yap�l�yor.
        if(ds1302.data_pin) veri.F7 = 1; else veri.F7 = 0;
    }
    return veri;         // okunan veriyi fonksiyon d���na ta��
}
//------------------------------------------------------------------
// DS1302'ye tarih, saat ve haftan�n g�n� bilgisi yaz�l�yor ve 
// batarya �arj devresi tespit ediliyor.
//------------------------------------------------------------------
void DS1302_Init()
{
    init_3wire();                // 3 yol ileti�imi kullan�ma haz�rla
    reset_3wire();               // 3 yol ileti�imi resetle
    write_byte_3wire(0x8E);      // kontrol kaydedicisine eri�im 
// sa�lan�yor
    write_byte_3wire(0);         // Yazma korumas� kald�r�l�yor.

    reset_3wire();               // 3 yol ileti�imi resetle
    write_byte_3wire(0x90);      // trickle charger kaydedicisine 
// eri�im sa�lan�yor
    write_byte_3wire(0xAB);      // 8 Kohm diren� �zerinden 2 
// diyotlu �arj birimi se�ildi
    reset_3wire();               // 3 yol ileti�imi resetle
    write_byte_3wire(0xBE);      // s�ral� 8 adet kaydediciye 
// yaz�laca�� belirtiliyor.
    write_byte_3wire(saniye);    // saniye bilgisini yaz
    write_byte_3wire(dakika);    // dakika bilgisini yaz
    write_byte_3wire(saat);      // saat bilgisini yaz
    write_byte_3wire(gun);       // gun bilgisini yaz
    write_byte_3wire(ay);        // ay bilgisini yaz
    write_byte_3wire(haftaningunu);   // haftan�n g�n� bilgisini yaz
    write_byte_3wire(yil);       // y�l bilgisini yaz
    write_byte_3wire(0);         // Kontrol kaydedicisine 0 bilgisi yaz
    reset_3wire();               // 3 yol ileti�imi resetle
}
//------------------------------------------------------------------
// DS1302'den zaman bilgisi okunuyor.
//------------------------------------------------------------------
void DS1302_ReadTime()
{
    reset_3wire();                   // 3 yol ileti�imi resetle
// DS1302'den s�ral� saat ve tarih bilgisi okuma ba�lat�l�yor
    write_byte_3wire(0xBF);          
    saniye = read_byte_3wire();      // saniye bilgisini oku
    dakika = read_byte_3wire();      // dakika bilgisini oku
    saat = read_byte_3wire();        // saat bilgisini oku
    gun = read_byte_3wire();         // gun bilgisini oku
    ay = read_byte_3wire();          // ay bilgisini oku
    haftaningunu = read_byte_3wire();// haftan�n g�n� bilgisini oku
    yil = read_byte_3wire();         // yil bilgisini oku
    reset_3wire();                   // 3 yol ileti�imi resetle
}
//------------------------------------------------------------------
// DS1302'den daha tarih, saat ve haftan�n g�n� bilgisini LCD'de 
// g�r�nt�ler.
//------------------------------------------------------------------
void Display_Time()
{
    LCD_Out(1,1,"Tarih=");  // 1.sat�r, 1.karakterden yazmaya ba�la
    BintoStr(gun);          // g�n bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);        // ve imlecin bulundu�u yerden 
// ba�layarak yaz
    LCD_Out_Cp("-");        // - i�areti imlecin bulundu�u yerden 
// ba�layarak yaz
    BintoStr(ay);           // ay bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);        // ve imlecin bulundu�u yerden 
// ba�layarak yaz
    LCD_Out_Cp("-");        // - i�areti imlecin bulundu�u yerden 
// ba�layarak yaz
    LCD_Out_Cp("20");       // y�l�n ilk 2 hanesini imlecin 
// bulundu�u yerden ba�layarak yaz
    BintoStr(yil);          // yil bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);        // ve imlecin bulundu�u yerden 
// ba�layarak yaz
    LCD_Out(2,1,"St=");     // 2.sat�r, 1.karakterden yazmaya ba�la
    BintoStr(saat);         // saat bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);        // ve imlecin bulundu�u yerden 
// ba�layarak yaz
    LCD_Out_Cp(":");        // : i�areti imlecin bulundu�u yerden 
// ba�layarak yaz
    BintoStr(dakika);       // dakika bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);   
    LCD_Out_Cp(":");        // : i�areti imlecin bulundu�u yerden 
// ba�layarak yaz
    BintoStr(saniye);       // saniye bilgisini text'e d�n��t�r
    LCD_Out_Cp(str);   
    LCD_Out_Cp("  ");       // 2 karakter bo�luk imlecin bulundu�u 
// yerden ba�layarak yaz
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
//------------------------------------------------------------------
// LCD ve DS1302 RTC birimini kullan�ma haz�rlar.
//------------------------------------------------------------------
void init()
{
// LCD ba�lant�s� tan�mlan�yor
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    saniye = 0x50;
    dakika = 0x59;
    saat = 0x23;
    gun = 0x27;
    ay = 0x04;
    yil = 0x06;
    haftaningunu = 0x04;                 // Per�embe
    DS1302_Init();
}
//------------------------------------------------------------------
// Ana program DS1302 saat entegresine bir tarih ve saat bilgisi 
// yazar. Daha sonra tarih, saat ve haftan�n g�n�n� s�rekli okuyarak 
// LCD ekranda g�r�nt�ler.
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

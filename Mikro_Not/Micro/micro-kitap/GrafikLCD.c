// *****************************************************************
// Dosya Adý		: GrafikLCD.c
// Açýklama		: T6963C tabanlý Grafik LCD'ye text yazar ve 
//                   	çizgi çizer.
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Grafik LCD'nin (T6963C) genel tanýmlarýnýn ve fonksiyonlarýn 
// prototiplerinin bulunduðu taným dosyasý projemize katýlýyor.
//------------------------------------------------------------------
#include "GrafikLCD.h"
//------------------------------------------------------------------
// Varsa genel deðiþkenler bu kýsýmda tanýmlanacak.
//------------------------------------------------------------------

//------------------------------------------------------------------
// Kesme alt programý (örneðimizde kullanýlmýyor).
//------------------------------------------------------------------
void interrupt(void)
{
    INTCON.GIE = 0;
}
//------------------------------------------------------------------
// Ýlk iþlemler alt programý PIC ve Grafik LCD'ye ilk kontrol 
// deðerlerini yükler ve baþlatýr.
//------------------------------------------------------------------
void grafikLCD_init(void)
{
// Kontrol hatlarýný çýkýþa yönlendir ve ilk durumlarýný HIGH yap.
    LCD_CONTROL = LCD_CONTROL | LCD_WR | LCD_RD | LCD_CE | LCD_CD | LCD_RST;
    LCD_CONTROL_TRIS = LCD_CONTROL_TRIS & (~(LCD_WR | LCD_RD | LCD_CE | LCD_CD | LCD_RST));
    LCD_CONTROL = LCD_WR | LCD_RD | LCD_CE | LCD_CD | LCD_RST;
// PORTB'nin tüm pinlerini giriþe yönlendir.
    LCD_DATA_BUS_TRIS = ALL_INPUTS;
// LCD'nin reset hattýný kýsa bir süre LOW seviyesinde tut.
    LCD_CONTROL.LCD_RST_BIT = 0;
    delay_ms(2000);
    LCD_CONTROL.LCD_RST_BIT = 1;
// CG_ROM moda ayarla.
    lcd_write_command(LCD_CG_ROM_MODE_OR);
// Grafik baþlanngýç adresini set et.
    lcd_write_data(LCD_GRAPHICS_HOME);
    lcd_write_data(LCD_GRAPHICS_HOME >> 8);
    lcd_write_command(LCD_GRAPHIC_HOME_ADDRESS_SET);
// Grafik bellek alanýný set et.
    lcd_write_data(LCD_GRAPHICS_AREA);
    lcd_write_data(0x00);
    lcd_write_command(LCD_GRAPHIC_AREA_SET);
// Text baþlangýç adresini set et.
    lcd_write_data(LCD_TEXT_HOME);
    lcd_write_data(LCD_TEXT_HOME >> 8);
    lcd_write_command(LCD_TEXT_HOME_ADDRESS_SET);
// Text bellek alanýný set et.
    lcd_write_data(LCD_TEXT_AREA);
    lcd_write_data(0x0);
    lcd_write_command(LCD_TEXT_AREA_SET);
}
//------------------------------------------------------------------
// LCD'ye veri yazar.
//------------------------------------------------------------------
void lcd_write_data(unsigned char data)
{
// LCD meþgul olduðu sürece bekle.
    while( (lcd_read_status() & (LCD_STATUS_BUSY1 | LCD_STATUS_BUSY2)) != (LCD_STATUS_BUSY1 | LCD_STATUS_BUSY2));
// C/D' pinini LOW yap.
    LCD_CONTROL.LCD_CD_BIT = 0;
// LCD'ye baðlanan veri hatlarýný çýkýþa yönlendir.
    LCD_DATA_BUS = data;
    LCD_DATA_BUS_TRIS = ALL_OUTPUTS;
// CE ve WR pinlerini LOW yap.
    LCD_CONTROL.LCD_CE_BIT = 0;
    LCD_CONTROL.LCD_WR_BIT = 0;
    asm nop
    asm nop
// CE ve RD pinlerini HIGH yap.
    LCD_CONTROL.LCD_CE_BIT = 1;
    LCD_CONTROL.LCD_WR_BIT = 1;
    LCD_CONTROL.LCD_CD_BIT = 1;
// LCD'ye baðlanan veri hatlarýný giriþe yönlendir.
    LCD_DATA_BUS_TRIS = ALL_INPUTS;
}
//------------------------------------------------------------------
// LCD'den veri okur.
//------------------------------------------------------------------
unsigned char lcd_read_data(void)
{
    unsigned char data;
// LCD meþgul olduðu sürece bekle.
    while( (lcd_read_status() & (LCD_STATUS_BUSY1 | LCD_STATUS_BUSY2)) != (LCD_STATUS_BUSY1 | LCD_STATUS_BUSY2));
// C/D' pinini LOW yap.
    LCD_CONTROL.LCD_CD_BIT = 0;
// LCD'ye baðlanan tüm veri hatlarýný giriþe yönlendir.
    LCD_DATA_BUS_TRIS = ALL_INPUTS;
// CE ve RD pinlerini LOW yap.
//    LCD_CONTROL.LCD_CE_BIT = 0;
    LCD_CONTROL.LCD_RD_BIT = 0;
    asm nop
// LCD veri yolunu oku.
    data = LCD_DATA_BUS;
// CE ve RD pinlerini set et.
    LCD_CONTROL.LCD_CE_BIT = 1;
    LCD_CONTROL.LCD_RD_BIT = 1;
    LCD_CONTROL.LCD_CD_BIT = 1;
    return data;
}
//------------------------------------------------------------------
// LCD'ye komut yazar.
//------------------------------------------------------------------
void lcd_write_command(unsigned char data)
{
    unsigned char status;
// LCD megul olduðu sürece bekle.
    while( (lcd_read_status() & (LCD_STATUS_BUSY1 | LCD_STATUS_BUSY2)) != (LCD_STATUS_BUSY1 | LCD_STATUS_BUSY2));
// C/D' bit’ini set et.
    LCD_CONTROL.LCD_CD_BIT = 1;
// LCD'ye baðlanan tüm veri hatlarýný çýkýþa yönlendir.
    LCD_DATA_BUS = data;
    LCD_DATA_BUS_TRIS = ALL_OUTPUTS;
// CE ve WR bit’ini sil.
    LCD_CONTROL.LCD_CE_BIT = 0;
    LCD_CONTROL.LCD_WR_BIT = 0;
    asm nop
    asm nop
// CE ve RD bit’lerini set et.
    LCD_CONTROL.LCD_CE_BIT = 1;
    LCD_CONTROL.LCD_WR_BIT = 1;
    LCD_CONTROL.LCD_CD_BIT = 1;
// LCD'ye baðlanan tün veri hatlarýný giriþe yönlendir.
    LCD_DATA_BUS_TRIS = ALL_INPUTS;
}
//------------------------------------------------------------------
// LCD'nin durumunu okur.
//------------------------------------------------------------------
unsigned char lcd_read_status(void)
{
    unsigned char data;
// C/D' pini set ediliyor.
    LCD_CONTROL.LCD_CD_BIT = 1;
// Veri hatlarýnýn tümü giriþe yönlendiriliyor.
    LCD_DATA_BUS_TRIS = ALL_INPUTS;
// CE ve RD pinini LOW yap.
    LCD_CONTROL.LCD_CE_BIT = 0;
    LCD_CONTROL.LCD_RD_BIT = 0;
    asm nop
// Veri yolunu oku.
    data = LCD_DATA_BUS;
// tüm bit’leri set et.
    LCD_CONTROL.LCD_CE_BIT = 1;
    LCD_CONTROL.LCD_RD_BIT = 1;
    LCD_CONTROL.LCD_CD_BIT = 1;
    return data;
}
//------------------------------------------------------------------
// LCD grafik ekranýný siler.
//------------------------------------------------------------------
void lcd_clear_graphics(void)
{
    unsigned char adres_l, adres_h;
    unsigned int adres, adres_limit;
// Adres iþaretçisini ekran1 için set eder. 
    adres = LCD_GRAPHICS_HOME;
    adres_l = adres & 0xff;
    adres_h = adres >> 8;
    lcd_write_data(adres_l);
    lcd_write_data(adres_h);
    lcd_write_command(LCD_ADDRESS_POINTER_SET);
    adres_limit = (LCD_GRAPHICS_HOME + LCD_GRAPHICS_SIZE);
    while(adres < adres_limit)
    {
        lcd_write_data(0x00);
        lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
        adres = adres + 1;
    }
    if(LCD_NUMBER_OF_SCREENS == 0x02)
    {
// Adres iþaretçisini ekran2 için set eder.
        adres = LCD_GRAPHICS_HOME + 0x8000;
        adres_l = adres & 0xff;
        adres_h = adres >> 8;
        lcd_write_data(adres_l);
        lcd_write_data(adres_h);
        lcd_write_command(LCD_ADDRESS_POINTER_SET);
        adres_limit = (LCD_GRAPHICS_HOME + LCD_GRAPHICS_SIZE + 0x8000);
        while(adres < adres_limit)
        {
            lcd_write_data(0x00);
            lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
            adres = adres + 1;
        }
    }
}
//------------------------------------------------------------------
// LCD text ekranýný siler.
//------------------------------------------------------------------
void lcd_clear_text(void)
{
    unsigned char adres_l, adres_h;
    unsigned int adres, adres_limit;
// Adres iþaretçisini ekran1 için set eder.
    adres = LCD_TEXT_HOME;
    adres_l = adres & 0xff;
    adres_h = adres >> 8;
    lcd_write_data(adres_l);
    lcd_write_data(adres_h);
    lcd_write_command(LCD_ADDRESS_POINTER_SET);
    adres_limit =  (LCD_TEXT_HOME + LCD_TEXT_SIZE);
    while(adres < adres_limit)
    {
        lcd_write_data(0x00);
        lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
        adres = adres + 1;
    }

    if(LCD_NUMBER_OF_SCREENS == 0x02)
    {
// Adres iþaretçisini ekran2 için set eder.
        adres = LCD_TEXT_HOME + 0x8000;
        adres_l = adres & 0xff;
        adres_h = adres >> 8;
        lcd_write_data(adres_l);
        lcd_write_data(adres_h);
        lcd_write_command(LCD_ADDRESS_POINTER_SET);
        adres_limit =  (LCD_TEXT_HOME + LCD_TEXT_SIZE + 0x8000);
        while(adres < adres_limit)
        {
            lcd_write_data(0x00);
            lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
            adres = adres + 1;
        }
    }
}
//------------------------------------------------------------------
// LCD ekranda istenilen satýr ve sütuna bir karakter yazar.
//------------------------------------------------------------------
void lcd_write_char(unsigned char character, unsigned char x, unsigned char y)
{
    unsigned int adres;
    adres = (y * LCD_TEXT_AREA) + x + LCD_TEXT_HOME;
// Ekran 1'in bellek alanýnýn üzerindeki bir alana yazýlmaya 
// çalýþýlýrsa 2. ekrana geçilir.
    if(y > 63 && LCD_NUMBER_OF_SCREENS == 2)
    {
        adres = adres + 0x8000;
    }
// Standart ASCII kodu T6963C'nin ASCII koduna dönüþtür.
    character = character - 0x20;
    lcd_write_data(adres & 0xff);
    lcd_write_data(adres >> 0x08);
    lcd_write_command(LCD_ADDRESS_POINTER_SET);
    lcd_write_data(character);
    lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
}
//------------------------------------------------------------------
// LCD ekranda istenilen satýr ve sütundan baþlayarak text yazar.
//------------------------------------------------------------------
void lcd_write_text(unsigned char *str, unsigned char x, unsigned char y)
{
    char i=0;
    while(str[i])lcd_write_char(str[i++],x++,y);
}
//------------------------------------------------------------------
// LCD ekranda bir piksel siler.
// x ve y deðiþkenleri LCD sýnýrlarý içerisinde olmalýdýr.
//------------------------------------------------------------------
void lcd_set_pixel(unsigned char x, unsigned char y)
{
    unsigned char data;
    unsigned int adres, shift;
    adres = (y * LCD_GRAPHICS_AREA) + (x / 8) + LCD_GRAPHICS_HOME;
// y deðeri ekran sýnýrlarýný aþarsa 2. ekrana geçilir.
    if(y > 63 && LCD_NUMBER_OF_SCREENS == 2)
    {
        y = y - 64;
        adres = (y * LCD_GRAPHICS_AREA) + (x / 8) + LCD_GRAPHICS_HOME;
        adres = adres + 0x8000;
    }
    data = lcd_bit_to_byte(7 - (x % 8));
    lcd_write_data(adres & 0xff);
    lcd_write_data(adres >> 0x08);
    lcd_write_command(LCD_ADDRESS_POINTER_SET);
// Veri oku
    lcd_write_command(LCD_DATA_READ_NO_INCREMENT);
    data = data | lcd_read_data();
// Veri yaz
    lcd_write_data(data);
    lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
}
//------------------------------------------------------------------
// LCD ekranda bir piksel siler.
// x ve y deðiþkenleri LCD sýnýrlarý içerisinde olmalýdýr.
//------------------------------------------------------------------
void lcd_clear_pixel(unsigned char x, unsigned char y)
{
    unsigned char data;
    unsigned int adres;
    adres = (y * LCD_GRAPHICS_AREA) + (x / 8) + LCD_GRAPHICS_HOME;
// y deðeri ekran sýnýrlarýný aþarsa 2. ekrana geçilir.
    if(y > 63 && LCD_NUMBER_OF_SCREENS == 2)
    {
        y = y - 64;
        adres = (y * LCD_GRAPHICS_AREA) + (x / 8) + LCD_GRAPHICS_HOME;
        adres = adres + 0x8000;
    }
    data = lcd_bit_to_byte(7 - (x % 8));
    lcd_write_data(adres & 0xff);
    lcd_write_data(adres >> 0x08);
    lcd_write_command(LCD_ADDRESS_POINTER_SET);
// Veri oku
    lcd_write_command(LCD_DATA_READ_NO_INCREMENT);
    data = (~data) & lcd_read_data();
// veriyi yaz
    lcd_write_data(data);
    lcd_write_command(LCD_DATA_WRITE_AUTO_INCREMENT);
}
//------------------------------------------------------------------
// 8 basamaklý binary sayýnýn ilgili basamaðýndaki bit’in basamak 
// deðerini verir.
//------------------------------------------------------------------
unsigned char lcd_bit_to_byte(unsigned char bit)
{
    switch(bit)
    {
        case 0: return 1; break;
        case 1: return 2; break;
        case 2: return 4; break;
        case 3: return 8; break;
        case 4: return 16; break;
        case 5: return 32; break;
        case 6: return 64; break;
        case 7: return 128; break;
        default: return 0; break;
    }
}
//------------------------------------------------------------------
// Ana program LCD ekranýnda text yazar ve çizgiler çizer.
// x ve y deðiþkenleri LCD sýnýrlarý içerisinde olmalýdýr.
//------------------------------------------------------------------
void main()
{
    unsigned char x, y;
// LCD'yi baþlat.
    grafikLCD_init();
// Grafik bellek alanýný sil.
    lcd_clear_graphics();
// Text bellek alanýný sil.
    lcd_clear_text();
// Text ve grafik modu aç.
    lcd_write_command(LCD_DISPLAY_MODES_GRAPHICS_ON | LCD_DISPLAY_MODES_TEXT_ON);
// Display’e text yaz.
    lcd_write_text("   iLERi PROG.",0,2);
    lcd_write_text("   TEKNiKLERi ",0,3);
    lcd_write_text("       ve", 0, 4);
    lcd_write_text("   PIC16F877A", 0, 5);
    lcd_write_text("  ------------ ", 0, 6);
// Adres iþaretçisini Grafik adresin baþýna al.
    lcd_write_data(LCD_GRAPHICS_HOME);         // LSB
    lcd_write_data(LCD_GRAPHICS_HOME >> 8);    // MSB
    lcd_write_command(LCD_ADDRESS_POINTER_SET);
// Ýç içe iki dikdörtgen çiziliyor.
    y = 0;
    for(x=0; x<128; x++) lcd_set_pixel(x, y);
    y = 63;
    for(x=0; x<128; x++) lcd_set_pixel(x, y);
    x = 0;
    for(y=0; y<64; y++) lcd_set_pixel(x, y);
    x = 127;
    for(y=0; y<64; y++) lcd_set_pixel(x, y);
    y = 2;
    for(x=2; x<126; x++) lcd_set_pixel(x, y);
    y = 61;
    for(x=2; x<126; x++) lcd_set_pixel(x, y);
    x = 2;
    for(y=2; y<62; y++) lcd_set_pixel(x, y);
    x = 125;
    for(y=2; y<62; y++) lcd_set_pixel(x, y);
    while(1);      //Sistem kapatýlana ya da resetlenene kadar bekle
}
// *****************************************************************

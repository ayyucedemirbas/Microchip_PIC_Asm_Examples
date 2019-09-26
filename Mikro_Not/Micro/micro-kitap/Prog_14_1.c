// *****************************************************************
// Dosya Ad�		: 14_1.c
// A��klama		: DS1620 �s� sens�r� ile �s� �l��m�
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Hi ve Lo fonksiyonlar� i�in built_in.h dosyas� projeye ekleniyor
//------------------------------------------------------------------
#include <built_in.h>
//------------------------------------------------------------------
// DS1620 i�in mikrodenetleyiciye ba�lant� tan�mlar�
//------------------------------------------------------------------
#define ds1620       PORTC
#define ds1620tris   TRISC
#define RST          F0
#define CLK          F1
#define DQ           F2
#define sign         F7
//------------------------------------------------------------------
// Genel de�i�ken tan�mlar�
//------------------------------------------------------------------
unsigned int isi;
char temp, ds1620_ctrl;
char text[]="  \0";
//------------------------------------------------------------------
// Bir byte'l�k hexadesimal say�y� 2 basamakl� desimal say�ya 
// d�n��t�r�r.
//------------------------------------------------------------------
char Hex2Dec(char ch)                // 2 digit d�n���m
{
    char tmp = 0;                    // Ge�ici de�i�keni s�f�rla
    while(ch>=10) {tmp++; ch -= 10;} // say�n�n onlar basama��n� bul
    tmp = (tmp<<4) + ch;            // Birler basama��n� say�ya ekle
    return tmp;                     // Sonucu fonksiyon d���na ta��
}
//------------------------------------------------------------------
// Bir byte'l�k say�y� text'e d�n��t�r�r.
//------------------------------------------------------------------
void Bin2Str(char data)
{
    data = Hex2Dec(data);
// Text'e d�n��t�r (ilk karakter)
    text[0] = 48 + ((data & 0xF0) >> 4);  
// say�n�n 10'lar basama�� s�f�r ise bo�luk yazs�n
    if (text[0] == 48) text[0] = 32; 
// Text'e d�n��t�r (ikinci karakter)     
    text[1]= 48 + (data & 0x0F);          
}
//------------------------------------------------------------------
// Okunan �s� bilgisini LCD'de g�r�nt�ler
//------------------------------------------------------------------
void Isi_Goruntule()
{
// LCD'de yazd�rmaya 1. sat�r, 1. karakterden ba�la
   Lcd_Out(1,1,"Isi = ");     
// Negatif �s� ise - i�areti yaz, de�ilse bo�luk koy
   if(ds1620_ctrl.sign) Lcd_Out_Cp("-"); else Lcd_Out_Cp(" ");
   Bin2Str(temp);             	// Is�y� text'e d�n��t�r (2 dijit)
   Lcd_Out_Cp(text);           	// Is�y� yazd�r
   Lcd_Chr_Cp(0xDF);          	// derece i�areti
   Lcd_Out_Cp("C");           	// C yazd�r
   Delay_ms(1000);            	// yeni �l��m i�in 1 saniye bekle
}
//------------------------------------------------------------------
// DS1620'ye bir byte yazar
//------------------------------------------------------------------
void ds1620_write(char data)
{
   unsigned short i;
   ds1620tris.DQ = 0;
   for(i=0; i<8; i++)
   {
     ds1620.CLK=0;
     if (data.F0) ds1620.DQ = 1; else ds1620.DQ = 0;
     ds1620.CLK = 1;
     data >>= 1;
   }
}
//------------------------------------------------------------------
// DS1620'yi kullan�ma haz�rlar
//------------------------------------------------------------------
void ds1620_init(void)
{
// DS1620'ye ba�lanan DQ, CLK and RST pinleri ��k��a y�nlendiriliyor
   ds1620tris.DQ = 0;
   ds1620tris.CLK = 0;
   ds1620tris.RST = 0;
   ds1620.CLK = 1;            // CLK pini HIGH'da tutuluyor.
   ds1620.RST = 0;            // RST pini LOW'da tutuluyor.
// DS1620 s�rekli �s� d�n���m�ne ve mikrodenetleyici ile ileti�ime 
// ayarlan�yor.
   ds1620.RST = 1;            // RST pini HIGH yap�l�yor.
   ds1620_write(0x0C);        // Konfig�rasyon komutu g�nderiliyor.
// S�rekli �s� d�n���m� ve mikrodenetleyici ile ileti�im komutu 
// g�nderiliyor.
   ds1620_write(0x00);        
   ds1620.RST = 0;            // RST pini LOW yap�l�yor.
// �s� d�n���m� ba�lat�l�yor
   ds1620.RST = 1;            // RST pini HIGH yap�l�yor.
   ds1620_write(0xEE);   // S�rekli �s� d�n���m komutu g�nderiliyor.
   ds1620.RST = 0;            // RST pini LOW yap�l�yor.
}
//------------------------------------------------------------------
// DS1620'den �s� bilgisini okur
//------------------------------------------------------------------
void ds1620_read()
{
   unsigned short i;
   ds1620.RST = 1;
// Is� bilgisini okuma komutu DS1620'ye g�nderiliyor.
   ds1620_write(0xAA); 
// DS1620'nin data pininin ba�land��� pin giri�e ayarlan�yor.
   ds1620tris.DQ = 1;         
   isi = 0;            // �s�n�n ilk de�eri s�f�r kabul ediliyor
   for(i=0; i<9; i++)         // 9 bit i�in d�ng� kuruluyor
   {
// CLK pininden DS1620'e inen darbe kenar� uygulan�yor
       ds1620.CLK = 0;        
       isi >>= 1;             // Is� bilgisi 1 bit sa�a kayd�r�l�yor
// E�er okunan de�er 1 ise �s�n�n en de�erli biti set, de�ilse reset 
// ediliyor.
       if (ds1620.DQ) isi |= 0x100;    
       ds1620.CLK = 1;        // CLK pini tekrar HIGH yap�l�yor.
   }
// Reset pini LOW yap�larak okuma i�lemi tamamlan�yor.
   ds1620.RST = 0;            
   i = Hi(isi);               // Is�n�n en de�erli byte'� al�n�yor
   if(i)      // E�er bu byte s�f�rdan farkl� ise �s� negatiftir.
   {
// ds1620 kontrol kaydedicisinin negatif i�aret bayra�� set ediliyor
       ds1620_ctrl.sign = 1;  
// �s�n�n en de�ersiz byte'�n�n 2. tamlayan� al�n�yor.
       i = Lo(isi);           
       i = ~i;
       i++;
       temp = i>>1;     	// �s� dereceye d�n��t�r�l�yor.
       PORTD = temp;
   }else                  // �s� pozitif ise
   {
// ds1620 kontrol kaydedicisinin negatif i�aret bayra�� siliniyor
       ds1620_ctrl.sign = 0;  
       i = Lo(isi);     	// �s�n�n en de�ersiz byte'� al�n�yor.
       temp = i>>1;     	// �s� dereceye d�n��t�r�l�yor.
       PORTD = temp;
   }
}
//------------------------------------------------------------------
// �lk i�lemler alt program�
//------------------------------------------------------------------
void init(void)
{
// LCD ba�lant�s� tan�mlan�yor
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    ds1620_init();             // DS1620 �s� sens�r� ba�lat�l�yor.
    ADCON1 = 6;
    TRISE = 0;
    TRISD = 0;
    PORTD = 0;
}
//------------------------------------------------------------------
// Ana program DS1620'den �s� bilgisini okuyarak LCD'de g�r�nt�ler
//------------------------------------------------------------------
void Main(void)
{
   init();                 // �evre birimler kullan�ma haz�rlan�yor.
   do                      // Sonsuz ana program �evrimi kuruluyor
   {
// Is�y� DS1620'den oku, sonu� temprature de�i�keninde
        ds1620_read();      
// Is�n�n i�areti ise ds1620_ctrl de�i�keninin sign bayra��nda
// Okunan �s� de�eri ve i�areti LCD'de g�r�nt�leniyor.
        Isi_Goruntule();    
   }while(1);
}
// *****************************************************************

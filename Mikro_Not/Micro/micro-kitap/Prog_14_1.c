// *****************************************************************
// Dosya Adý		: 14_1.c
// Açýklama		: DS1620 ýsý sensörü ile ýsý ölçümü
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Hi ve Lo fonksiyonlarý için built_in.h dosyasý projeye ekleniyor
//------------------------------------------------------------------
#include <built_in.h>
//------------------------------------------------------------------
// DS1620 için mikrodenetleyiciye baðlantý tanýmlarý
//------------------------------------------------------------------
#define ds1620       PORTC
#define ds1620tris   TRISC
#define RST          F0
#define CLK          F1
#define DQ           F2
#define sign         F7
//------------------------------------------------------------------
// Genel deðiþken tanýmlarý
//------------------------------------------------------------------
unsigned int isi;
char temp, ds1620_ctrl;
char text[]="  \0";
//------------------------------------------------------------------
// Bir byte'lýk hexadesimal sayýyý 2 basamaklý desimal sayýya 
// dönüþtürür.
//------------------------------------------------------------------
char Hex2Dec(char ch)                // 2 digit dönüþüm
{
    char tmp = 0;                    // Geçici deðiþkeni sýfýrla
    while(ch>=10) {tmp++; ch -= 10;} // sayýnýn onlar basamaðýný bul
    tmp = (tmp<<4) + ch;            // Birler basamaðýný sayýya ekle
    return tmp;                     // Sonucu fonksiyon dýþýna taþý
}
//------------------------------------------------------------------
// Bir byte'lýk sayýyý text'e dönüþtürür.
//------------------------------------------------------------------
void Bin2Str(char data)
{
    data = Hex2Dec(data);
// Text'e dönüþtür (ilk karakter)
    text[0] = 48 + ((data & 0xF0) >> 4);  
// sayýnýn 10'lar basamaðý sýfýr ise boþluk yazsýn
    if (text[0] == 48) text[0] = 32; 
// Text'e dönüþtür (ikinci karakter)     
    text[1]= 48 + (data & 0x0F);          
}
//------------------------------------------------------------------
// Okunan ýsý bilgisini LCD'de görüntüler
//------------------------------------------------------------------
void Isi_Goruntule()
{
// LCD'de yazdýrmaya 1. satýr, 1. karakterden baþla
   Lcd_Out(1,1,"Isi = ");     
// Negatif ýsý ise - iþareti yaz, deðilse boþluk koy
   if(ds1620_ctrl.sign) Lcd_Out_Cp("-"); else Lcd_Out_Cp(" ");
   Bin2Str(temp);             	// Isýyý text'e dönüþtür (2 dijit)
   Lcd_Out_Cp(text);           	// Isýyý yazdýr
   Lcd_Chr_Cp(0xDF);          	// derece iþareti
   Lcd_Out_Cp("C");           	// C yazdýr
   Delay_ms(1000);            	// yeni ölçüm için 1 saniye bekle
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
// DS1620'yi kullanýma hazýrlar
//------------------------------------------------------------------
void ds1620_init(void)
{
// DS1620'ye baðlanan DQ, CLK and RST pinleri çýkýþa yönlendiriliyor
   ds1620tris.DQ = 0;
   ds1620tris.CLK = 0;
   ds1620tris.RST = 0;
   ds1620.CLK = 1;            // CLK pini HIGH'da tutuluyor.
   ds1620.RST = 0;            // RST pini LOW'da tutuluyor.
// DS1620 sürekli ýsý dönüþümüne ve mikrodenetleyici ile iletiþime 
// ayarlanýyor.
   ds1620.RST = 1;            // RST pini HIGH yapýlýyor.
   ds1620_write(0x0C);        // Konfigürasyon komutu gönderiliyor.
// Sürekli ýsý dönüþümü ve mikrodenetleyici ile iletiþim komutu 
// gönderiliyor.
   ds1620_write(0x00);        
   ds1620.RST = 0;            // RST pini LOW yapýlýyor.
// ýsý dönüþümü baþlatýlýyor
   ds1620.RST = 1;            // RST pini HIGH yapýlýyor.
   ds1620_write(0xEE);   // Sürekli ýsý dönüþüm komutu gönderiliyor.
   ds1620.RST = 0;            // RST pini LOW yapýlýyor.
}
//------------------------------------------------------------------
// DS1620'den ýsý bilgisini okur
//------------------------------------------------------------------
void ds1620_read()
{
   unsigned short i;
   ds1620.RST = 1;
// Isý bilgisini okuma komutu DS1620'ye gönderiliyor.
   ds1620_write(0xAA); 
// DS1620'nin data pininin baðlandýðý pin giriþe ayarlanýyor.
   ds1620tris.DQ = 1;         
   isi = 0;            // ýsýnýn ilk deðeri sýfýr kabul ediliyor
   for(i=0; i<9; i++)         // 9 bit için döngü kuruluyor
   {
// CLK pininden DS1620'e inen darbe kenarý uygulanýyor
       ds1620.CLK = 0;        
       isi >>= 1;             // Isý bilgisi 1 bit saða kaydýrýlýyor
// Eðer okunan deðer 1 ise ýsýnýn en deðerli biti set, deðilse reset 
// ediliyor.
       if (ds1620.DQ) isi |= 0x100;    
       ds1620.CLK = 1;        // CLK pini tekrar HIGH yapýlýyor.
   }
// Reset pini LOW yapýlarak okuma iþlemi tamamlanýyor.
   ds1620.RST = 0;            
   i = Hi(isi);               // Isýnýn en deðerli byte'ý alýnýyor
   if(i)      // Eðer bu byte sýfýrdan farklý ise ýsý negatiftir.
   {
// ds1620 kontrol kaydedicisinin negatif iþaret bayraðý set ediliyor
       ds1620_ctrl.sign = 1;  
// ýsýnýn en deðersiz byte'ýnýn 2. tamlayaný alýnýyor.
       i = Lo(isi);           
       i = ~i;
       i++;
       temp = i>>1;     	// ýsý dereceye dönüþtürülüyor.
       PORTD = temp;
   }else                  // ýsý pozitif ise
   {
// ds1620 kontrol kaydedicisinin negatif iþaret bayraðý siliniyor
       ds1620_ctrl.sign = 0;  
       i = Lo(isi);     	// ýsýnýn en deðersiz byte'ý alýnýyor.
       temp = i>>1;     	// ýsý dereceye dönüþtürülüyor.
       PORTD = temp;
   }
}
//------------------------------------------------------------------
// Ýlk iþlemler alt programý
//------------------------------------------------------------------
void init(void)
{
// LCD baðlantýsý tanýmlanýyor
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);             // imleci gizle
    ds1620_init();             // DS1620 ýsý sensörü baþlatýlýyor.
    ADCON1 = 6;
    TRISE = 0;
    TRISD = 0;
    PORTD = 0;
}
//------------------------------------------------------------------
// Ana program DS1620'den ýsý bilgisini okuyarak LCD'de görüntüler
//------------------------------------------------------------------
void Main(void)
{
   init();                 // Çevre birimler kullanýma hazýrlanýyor.
   do                      // Sonsuz ana program çevrimi kuruluyor
   {
// Isýyý DS1620'den oku, sonuç temprature deðiþkeninde
        ds1620_read();      
// Isýnýn iþareti ise ds1620_ctrl deðiþkeninin sign bayraðýnda
// Okunan ýsý deðeri ve iþareti LCD'de görüntüleniyor.
        Isi_Goruntule();    
   }while(1);
}
// *****************************************************************

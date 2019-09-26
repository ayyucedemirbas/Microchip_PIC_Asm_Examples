// *****************************************************************
// Dosya Ad�		: 14_2.c
// A��klama		: DS1621 �s� sens�r� ile �s� �l��m�
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
// i2c adres tan�mlan�yor
#define DS1621_WRITE_ADDR     0x90
#define DS1621_READ_ADDR      0x91
// Komutlar
#define DS1621_ACCESS_CONFIG_CMD      0xAC
#define DS1621_START_CONVERSION_CMD   0xEE
#define DS1621_STOP_CONVERSION_CMD    0x22
#define DS1621_READ_TEMPERATURE_CMD   0xAA
#define DS1621_ACCESS_TEMP_HIGH_CMD   0xA1
#define DS1621_ACCESS_TEMP_LOW_CMD    0xA2
#define DS1621_READ_COUNTER_CMD       0xA8
#define DS1621_READ_SLOPE_CMD         0xA9
// Config kaydedicisinin bit tan�mlamalar�
#define DS1621_ONE_SHOT_BIT           F0
#define DS1621_OUTPUT_POLARITY_BIT    F1
#define DS1621_NVRAM_BUSY_BIT         F4
#define DS1621_TEMP_LOW_BIT           F5
#define DS1621_TEMP_HIGH_BIT          F6
#define DS1621_CONVERSION_DONE_BIT    F7
// Config kaydedicisinin ba�lang�� de�eri
#define DS1621_CONFIG_INIT_VALUE      0x00
// Is�Kontrol kaydedicisinin bit tan�mlamalar�
#define ERROR                         F7
#define NEG                           F6
#define ONDABES                       F5
//De�i�ken tan�mlamalar�
char *str="  \0";
char IsiKontrol;
//------------------------------------------------------------------
// DS1621 ilk i�lemleri ger�ekle�tirir. Konfig�rasyon kaydedicisine 
// ilk de�er verir.
//------------------------------------------------------------------
void ds1621_init(void)
{
     I2C_Start();
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_ACCESS_CONFIG_CMD);
     I2C_Wr(DS1621_CONFIG_INIT_VALUE);
     I2C_Stop();
}
//------------------------------------------------------------------
//Is� okuma �evrimini ba�lat�r.
//------------------------------------------------------------------
void ds1621_start_conversion(void)
{
     I2C_Start();
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_START_CONVERSION_CMD);
     I2C_Stop();
}
//------------------------------------------------------------------
// Is� bilgisi DS1621'den okunur ve en de�erli byte'� fonksiyon 
// d���na ta��n�r.
//------------------------------------------------------------------
char ds1621_read_temperature(void)
{
     char data_low, data_high;
     I2C_Start();                   // I2C ileti�imi ba�lat
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_READ_TEMPERATURE_CMD);
     I2C_Repeated_Start();
     I2C_Wr(DS1621_READ_ADDR);
// Is�n�n en de�erli byte'� okunur ve ACK g�nderilir
     data_high = I2C_Rd(1); 
// I2C hatt� me�gul oldu�u s�rece bekle        
     while(I2C_Is_Idle() == 0);  
// Is�n�n en de�ersiz byte'� okunur ve NOT ACK g�nderilir  
     data_low = I2C_Rd(0);          
// I2C hatt� me�gul oldu�u s�rece bekle
     while(I2C_Is_Idle() == 0);     
     I2C_Stop();
// Is� Kontrol kaydedicisinin 0. biti set ise bir hata oldu�u 
// anla��l�r.
     if(data_low == 0xFF)
          if(data_high == 0xFF) {IsiKontrol.ERROR = 1; return(0);}
     else IsiKontrol.ERROR = 0;
// E�er �s� 0 derecenin alt�nda ise data_high byte'�n en de�erli 
// biti set olur. Bu durumda data_high de�erinin 2.tamlayan� 
// al�narak �s� de�eri elde edilir ve bu �s�n�n negatif oldu�unu 
// belirtmek i�in IsiKontrol kaydedicisinin NEGATIF bayra�� set 
// edilir.
     if(data_high & 0x80)
     {
// Is�n�n negatif oldu�u kontrol kaydedicisine yaz�l�r
        IsiKontrol.NEG = 1;
// Is�n�n en de�erli byte'�n�n 2. tamlayan� al�n�r                 
        data_high = ~data_high + 1;          
        if(data_low) data_high--;  // 1/2 C k�sm� var ise bir eksilt
     } else IsiKontrol.NEG = 0;    // �s� pozitif
// data_low b�y�k 0 ise 1/2 C de�eri var, o halde IsiKontrol 
// kaydedicisinin ilgili bitini set et data_low = 0 ise 1/2 C de�eri 
// yoktur. Bu durumda IsiKontrol kaydedicisinin ilgili biti silinir.
   if(data_low) IsiKontrol.ONDABES = 1; else IsiKontrol.ONDABES = 0;
// Is� de�eri 99'dan b�y�kse 99 olarak kabul et
     if(data_high > 99) return 99;           
     return data_high;
}
//------------------------------------------------------------------
// E�im de�erini fonksiyon d���na ta��r.
//------------------------------------------------------------------
char ds1621_read_slope(void)
{
     char slope;
     I2C_Start();
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_READ_SLOPE_CMD);
     I2C_Repeated_Start();
     I2C_Wr(DS1621_READ_ADDR);
     slope = I2C_Rd(0);
     I2C_Stop();
     return slope;
}
//------------------------------------------------------------------
// Sayac de�erini fonksiyon d���na ta��r.
//------------------------------------------------------------------
char ds1621_read_counter(void)
{
     char counter;
     I2C_Start();
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_READ_COUNTER_CMD);
     I2C_Repeated_Start();
     I2C_Wr(DS1621_READ_ADDR);
     counter = I2C_Rd(0);
     I2C_Stop();
     return counter;
}
//------------------------------------------------------------------
// Bir byte'l�k hexadesimal say�y� 2 basamakl� desimal say�ya 
// d�n��t�r�r.
//------------------------------------------------------------------
char Hex2Dec(char ch)                    // 2 digit d�n���m
{
     char tmp = 0;                       // Ge�ici de�i�keni s�f�rla
// say�n�n onlar basama��n� bulur
     while(ch>=10) {tmp++; ch -= 10;}  
// Birler basama��n� say�ya ekler  
     tmp = (tmp<<4) + ch;                
     return tmp;               // Sonucu fonksiyon d���na ta��
}
//------------------------------------------------------------------
// Bir byte'l�k say�y� text'e d�n��t�r�r.
//------------------------------------------------------------------
void BintoStr(char data)
{
    data = Hex2Dec(data);                // Desimale d�n��t�r
// Text'e d�n��t�r�r (ilk karakter)
    str[0] = 48 + ((data & 0xF0) >> 4); 
// say�n�n 10'lar basama�� s�f�r ise bo�luk yazar
    if (str[0] == 48) str[0] = 32;   
// Text'e d�n��t�r�r (ikinci karakter)    
    str[1]= 48 + (data & 0x0F);          
}
//------------------------------------------------------------------
// �lk i�lemler alt program� LCD, I2C ve DS1621'i kullan�ma haz�rlar 
// ve �s� d�n���m�n� ba�lat�r.
//------------------------------------------------------------------
void init()
{
    LCD_Config(&PORTB,4,5,7,3,2,1,0);   // LCD ba�lant�s�n� tan�mla
    LCD_Cmd(LCD_CURSOR_OFF);            // imleci gizle
    I2C_Init(100000);    // I2C ileti�imi haz�rla, full master mode
    IsiKontrol = 0;  // Is� kontrol kaydedicisinin ilk de�eri s�f�r.
    ds1621_init();                      // Is� sens�r�n� ba�lat
    ds1621_start_conversion();          // Is� d�n���m�n� ba�lat
}
//------------------------------------------------------------------
// Ana program, �s� bilgisini DS1621'den okuyarak LCD �zerinde 
// g�r�nt�ler.
//------------------------------------------------------------------
void main(void)
{
     char isi;
     init();    // ilk i�lemleri ger�ekle�tir
     while(1)   // Bu blok i�erisindeki i�lemler sistem kapat�lana
     {          // ya da resetlenene kadar tekrarlar.
         isi = ds1621_read_temperature();   // Is�y� �l�
         if(IsiKontrol.ERROR) continue;     // Hata var yeniden �l�
         LCD_Out(1,1,"Isi = ");             
// Negatif �s� ise - i�areti yaz, de�ilse bo�luk koy
         if(IsiKontrol.NEG) LCD_Out_Cp("-"); else LCD_Out_Cp(" "); 
         BintoStr(isi);       // Is�y� text'e d�n��t�r (2 dijit)
         LCD_Out_Cp(str);     // Is�y� yazd�r
         if(IsiKontrol.ONDABES) LCD_Out_Cp(".5"); else LCD_Out_Cp(".0");             // ondal�kl� k�sm� yazd�r
         Lcd_Chr_Cp(0xDF);    // derece i�areti
         LCD_Out_Cp("C");     // C yazd�r
         Delay_ms(1000);      // yeni �l��m i�in 1 saniye bekle
     }
}
// *****************************************************************

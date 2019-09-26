// *****************************************************************
// Dosya Adý		: 14_2.c
// Açýklama		: DS1621 ýsý sensörü ile ýsý ölçümü
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
// i2c adres tanýmlanýyor
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
// Config kaydedicisinin bit tanýmlamalarý
#define DS1621_ONE_SHOT_BIT           F0
#define DS1621_OUTPUT_POLARITY_BIT    F1
#define DS1621_NVRAM_BUSY_BIT         F4
#define DS1621_TEMP_LOW_BIT           F5
#define DS1621_TEMP_HIGH_BIT          F6
#define DS1621_CONVERSION_DONE_BIT    F7
// Config kaydedicisinin baþlangýç deðeri
#define DS1621_CONFIG_INIT_VALUE      0x00
// IsýKontrol kaydedicisinin bit tanýmlamalarý
#define ERROR                         F7
#define NEG                           F6
#define ONDABES                       F5
//Deðiþken tanýmlamalarý
char *str="  \0";
char IsiKontrol;
//------------------------------------------------------------------
// DS1621 ilk iþlemleri gerçekleþtirir. Konfigürasyon kaydedicisine 
// ilk deðer verir.
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
//Isý okuma çevrimini baþlatýr.
//------------------------------------------------------------------
void ds1621_start_conversion(void)
{
     I2C_Start();
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_START_CONVERSION_CMD);
     I2C_Stop();
}
//------------------------------------------------------------------
// Isý bilgisi DS1621'den okunur ve en deðerli byte'ý fonksiyon 
// dýþýna taþýnýr.
//------------------------------------------------------------------
char ds1621_read_temperature(void)
{
     char data_low, data_high;
     I2C_Start();                   // I2C iletiþimi baþlat
     I2C_Wr(DS1621_WRITE_ADDR);
     I2C_Wr(DS1621_READ_TEMPERATURE_CMD);
     I2C_Repeated_Start();
     I2C_Wr(DS1621_READ_ADDR);
// Isýnýn en deðerli byte'ý okunur ve ACK gönderilir
     data_high = I2C_Rd(1); 
// I2C hattý meþgul olduðu sürece bekle        
     while(I2C_Is_Idle() == 0);  
// Isýnýn en deðersiz byte'ý okunur ve NOT ACK gönderilir  
     data_low = I2C_Rd(0);          
// I2C hattý meþgul olduðu sürece bekle
     while(I2C_Is_Idle() == 0);     
     I2C_Stop();
// Isý Kontrol kaydedicisinin 0. biti set ise bir hata olduðu 
// anlaþýlýr.
     if(data_low == 0xFF)
          if(data_high == 0xFF) {IsiKontrol.ERROR = 1; return(0);}
     else IsiKontrol.ERROR = 0;
// Eðer ýsý 0 derecenin altýnda ise data_high byte'ýn en deðerli 
// biti set olur. Bu durumda data_high deðerinin 2.tamlayaný 
// alýnarak ýsý deðeri elde edilir ve bu ýsýnýn negatif olduðunu 
// belirtmek için IsiKontrol kaydedicisinin NEGATIF bayraðý set 
// edilir.
     if(data_high & 0x80)
     {
// Isýnýn negatif olduðu kontrol kaydedicisine yazýlýr
        IsiKontrol.NEG = 1;
// Isýnýn en deðerli byte'ýnýn 2. tamlayaný alýnýr                 
        data_high = ~data_high + 1;          
        if(data_low) data_high--;  // 1/2 C kýsmý var ise bir eksilt
     } else IsiKontrol.NEG = 0;    // ýsý pozitif
// data_low büyük 0 ise 1/2 C deðeri var, o halde IsiKontrol 
// kaydedicisinin ilgili bitini set et data_low = 0 ise 1/2 C deðeri 
// yoktur. Bu durumda IsiKontrol kaydedicisinin ilgili biti silinir.
   if(data_low) IsiKontrol.ONDABES = 1; else IsiKontrol.ONDABES = 0;
// Isý deðeri 99'dan büyükse 99 olarak kabul et
     if(data_high > 99) return 99;           
     return data_high;
}
//------------------------------------------------------------------
// Eðim deðerini fonksiyon dýþýna taþýr.
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
// Sayac deðerini fonksiyon dýþýna taþýr.
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
// Bir byte'lýk hexadesimal sayýyý 2 basamaklý desimal sayýya 
// dönüþtürür.
//------------------------------------------------------------------
char Hex2Dec(char ch)                    // 2 digit dönüþüm
{
     char tmp = 0;                       // Geçici deðiþkeni sýfýrla
// sayýnýn onlar basamaðýný bulur
     while(ch>=10) {tmp++; ch -= 10;}  
// Birler basamaðýný sayýya ekler  
     tmp = (tmp<<4) + ch;                
     return tmp;               // Sonucu fonksiyon dýþýna taþý
}
//------------------------------------------------------------------
// Bir byte'lýk sayýyý text'e dönüþtürür.
//------------------------------------------------------------------
void BintoStr(char data)
{
    data = Hex2Dec(data);                // Desimale dönüþtür
// Text'e dönüþtürür (ilk karakter)
    str[0] = 48 + ((data & 0xF0) >> 4); 
// sayýnýn 10'lar basamaðý sýfýr ise boþluk yazar
    if (str[0] == 48) str[0] = 32;   
// Text'e dönüþtürür (ikinci karakter)    
    str[1]= 48 + (data & 0x0F);          
}
//------------------------------------------------------------------
// Ýlk iþlemler alt programý LCD, I2C ve DS1621'i kullanýma hazýrlar 
// ve ýsý dönüþümünü baþlatýr.
//------------------------------------------------------------------
void init()
{
    LCD_Config(&PORTB,4,5,7,3,2,1,0);   // LCD baðlantýsýný tanýmla
    LCD_Cmd(LCD_CURSOR_OFF);            // imleci gizle
    I2C_Init(100000);    // I2C iletiþimi hazýrla, full master mode
    IsiKontrol = 0;  // Isý kontrol kaydedicisinin ilk deðeri sýfýr.
    ds1621_init();                      // Isý sensörünü baþlat
    ds1621_start_conversion();          // Isý dönüþümünü baþlat
}
//------------------------------------------------------------------
// Ana program, ýsý bilgisini DS1621'den okuyarak LCD üzerinde 
// görüntüler.
//------------------------------------------------------------------
void main(void)
{
     char isi;
     init();    // ilk iþlemleri gerçekleþtir
     while(1)   // Bu blok içerisindeki iþlemler sistem kapatýlana
     {          // ya da resetlenene kadar tekrarlar.
         isi = ds1621_read_temperature();   // Isýyý ölç
         if(IsiKontrol.ERROR) continue;     // Hata var yeniden ölç
         LCD_Out(1,1,"Isi = ");             
// Negatif ýsý ise - iþareti yaz, deðilse boþluk koy
         if(IsiKontrol.NEG) LCD_Out_Cp("-"); else LCD_Out_Cp(" "); 
         BintoStr(isi);       // Isýyý text'e dönüþtür (2 dijit)
         LCD_Out_Cp(str);     // Isýyý yazdýr
         if(IsiKontrol.ONDABES) LCD_Out_Cp(".5"); else LCD_Out_Cp(".0");             // ondalýklý kýsmý yazdýr
         Lcd_Chr_Cp(0xDF);    // derece iþareti
         LCD_Out_Cp("C");     // C yazdýr
         Delay_ms(1000);      // yeni ölçüm için 1 saniye bekle
     }
}
// *****************************************************************

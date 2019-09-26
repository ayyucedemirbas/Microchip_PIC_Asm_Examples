// *****************************************************************
// Dosya Adý		: 14_13.c
// Açýklama		: MPX4115 basýnç sensörü uygulamasý
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// MPX4115 Basýnç sensörünün mikrodenetleyiciye baðlantýlarý 
// tanýmlanýyor.
//------------------------------------------------------------------
#define mpx4115         PORTA
#define mpx4115_tris    TRISA
#define mpx4115_pin     2
//------------------------------------------------------------------
// Deðiþken tanýmlamalarý yapýlýyor.
//------------------------------------------------------------------
unsigned int mpx4115_data, ondalik;
char *str="   .  kP\0";
//------------------------------------------------------------------
// Bir byte'lýk hexadesimal sayýyý 2 basamaklý desimal sayýya 
// dönüþtürür.
//------------------------------------------------------------------
char Hex2Dec(char ch)                    // 2 digit dönüþüm
{
     char tmp = 0;                       // Geçici deðiþkeni sýfýrla
// sayýnýn onlar basamaðý bulunuyor
     while(ch>=10) {tmp++; ch -= 10;}    
     tmp = (tmp<<4) + ch;       	// Birler basamaðýný sayýya ekle
     return tmp;         		// Sonucu fonksiyon dýþýna taþý
}
//------------------------------------------------------------------
// hexadesimal deðeri LCD'de görüntülemek için text'e dönüþtürür.
//------------------------------------------------------------------
void BintoStr(unsigned short tam, unsigned short ondalik)
{
// tam kýsým 200 ve üzerinde ise str'nin ilk karakteri 2, deðilse 
// 100 ve üzerinde olduðu kontrol edilir. 100 ve üzerinde ise 
// str'nin ilk karakteri 1. Eðer tam kýsým 100'den küçükse str'nin 
// ilk karakteri boþluk. Tam kýsmýn 100 ve üzerindeki deðeri tam'dan 
// düþülür.
    if(tam >= 200) {str[0] = 50; tam -= 200; }
       else if (tam >= 100) { str[0] = 49; tam -= 100; } else str[0] = 32;
// tam kýsým artýk 100'den küçüktür. 2 basamak desimal dönüþüme 
// uygundur.
    tam = Hex2Dec(tam);       // Kalan tam kýsmý desimale dönüþtür.
    str[1]= 48 + ((tam & 0xF0) >> 4);  // Onlar basamaðýný elde et
// Eðer yüzler ve onlar basamaðýnýn her ikiside sýfýr ise str'de 
// onlar basamaðýna yani str'nin 2. karakterine boþluk yaz
    if ((str[0] == 32) && (str[1] == 48)) str[1] = 32;
// en deðersiz dört bit text'e dönüþtürülüyor
    str[2]= 48 + (tam & 0x0F); 
// ondalýk kýsmý str'nin 5. karakterine yazýlýyor
    str[4]= 48 + ondalik;              
}
//------------------------------------------------------------------
// Portlarý ve LCD birimini kullanýma hazýrlar.
//------------------------------------------------------------------
void init()
{
// Analog giriþler seçildi, Vref+ = Vdd, Vref- = Vss seçildi.
    ADCON1 = 0x80;  
    TRISA  = 0xFF;
    LCD_Config(&PORTB,4,5,7,3,2,1,0); 
    LCD_Cmd(LCD_CURSOR_OFF);            
    delay_ms(500);                      
}
//------------------------------------------------------------------
// MPX4115 basýnç sensöründen analog basýnç bilgisi elde edilir. Bu 
// bilgi MPX4115'in baðlandýðý analog pinden 10 bit çözünürlüðünde 
// sayýsal bilgiye dönüþtürülür. Elde edilen bilgi iþlenerek basýnç 
// deðeri tam ve ondalýklý kýsmý elde edilir ve fonksiyon dýþýna 
// taþýnýr.
//------------------------------------------------------------------
unsigned short mpx4115_read()
{
// tam kýsmý tutacak deðiþken tanýmlanýyor.
    unsigned short tmp;      
    unsigned i, hata;      // döngü ve hata deðiþkeni tanýmlanýyor.
// Basýnç deðeri sayýsal deðere dönüþtüülüyor
    mpx4115_data = Adc_Read(mpx4115_pin); 
// 15 kP'lýk ilk deðer çýkartýlýyor.
    mpx4115_data -= 56;                   
    hata = 0;                 // hata payý ilk durumda sýfýr.
// Hata oraný tespit ediliyor.
    for(i = 9; i <= mpx4115_data ; i +=15) hata++; 
    mpx4115_data += hata;                 // Hata payý ekleniyor
// tam kýsým elde ediliyor ve 15 kP'lýk ilk deðer ekleniyor.
    tmp = mpx4115_data/10 + 15; 
    ondalik = mpx4115_data%10;     // ondalýklý kýsým elde ediliyor.
    return tmp;             // tam kýsým fonksiyon dýþýna taþýnýyor.
}
//------------------------------------------------------------------
// Ana program MPX4115 basýnç sensöründen analog basýnç bilgisini 
// alarak sayýsal deðere dönüþtürüp iþleyerek basýnç deðerini %1 
// hata payý ile hesaplar. Sonucu LCD display'de 500 ms ara ile 
// görüntüler.
//------------------------------------------------------------------
void main()
{
// 1 byte iþaretsiz geçici deðiþken tanýmlanýyor.
    unsigned short tmp; 
// Portlar ve LCD kullanýma hazýrlanýyor.         
    init();                      
    do        // do - while döngüsü ile sonsuz çevrim baþlýyor.
    {
// MPX4115'ten basýnç deðerinin sayýsal karþýlýðýnýn tam kýsmý ve 
// ondalýklý kýsmý elde ediliyor.
         tmp = mpx4115_read();
// Tam ve ondalýklý kýsým str dizisine aktarýlýyor.
         BintoStr(tmp, ondalik);
         Lcd_Out(1,1, "Basinc= ");
// str dizisi LCD'de görüntüleniyor.
         Lcd_Out_Cp(str);
         Delay_ms(500);
    } while(1);                  // Ana program çevrimine devam et
}
// *****************************************************************

// *****************************************************************
// Dosya Ad�		: 14_13.c
// A��klama		: MPX4115 bas�n� sens�r� uygulamas�
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// MPX4115 Bas�n� sens�r�n�n mikrodenetleyiciye ba�lant�lar� 
// tan�mlan�yor.
//------------------------------------------------------------------
#define mpx4115         PORTA
#define mpx4115_tris    TRISA
#define mpx4115_pin     2
//------------------------------------------------------------------
// De�i�ken tan�mlamalar� yap�l�yor.
//------------------------------------------------------------------
unsigned int mpx4115_data, ondalik;
char *str="   .  kP\0";
//------------------------------------------------------------------
// Bir byte'l�k hexadesimal say�y� 2 basamakl� desimal say�ya 
// d�n��t�r�r.
//------------------------------------------------------------------
char Hex2Dec(char ch)                    // 2 digit d�n���m
{
     char tmp = 0;                       // Ge�ici de�i�keni s�f�rla
// say�n�n onlar basama�� bulunuyor
     while(ch>=10) {tmp++; ch -= 10;}    
     tmp = (tmp<<4) + ch;       	// Birler basama��n� say�ya ekle
     return tmp;         		// Sonucu fonksiyon d���na ta��
}
//------------------------------------------------------------------
// hexadesimal de�eri LCD'de g�r�nt�lemek i�in text'e d�n��t�r�r.
//------------------------------------------------------------------
void BintoStr(unsigned short tam, unsigned short ondalik)
{
// tam k�s�m 200 ve �zerinde ise str'nin ilk karakteri 2, de�ilse 
// 100 ve �zerinde oldu�u kontrol edilir. 100 ve �zerinde ise 
// str'nin ilk karakteri 1. E�er tam k�s�m 100'den k���kse str'nin 
// ilk karakteri bo�luk. Tam k�sm�n 100 ve �zerindeki de�eri tam'dan 
// d���l�r.
    if(tam >= 200) {str[0] = 50; tam -= 200; }
       else if (tam >= 100) { str[0] = 49; tam -= 100; } else str[0] = 32;
// tam k�s�m art�k 100'den k���kt�r. 2 basamak desimal d�n���me 
// uygundur.
    tam = Hex2Dec(tam);       // Kalan tam k�sm� desimale d�n��t�r.
    str[1]= 48 + ((tam & 0xF0) >> 4);  // Onlar basama��n� elde et
// E�er y�zler ve onlar basama��n�n her ikiside s�f�r ise str'de 
// onlar basama��na yani str'nin 2. karakterine bo�luk yaz
    if ((str[0] == 32) && (str[1] == 48)) str[1] = 32;
// en de�ersiz d�rt bit text'e d�n��t�r�l�yor
    str[2]= 48 + (tam & 0x0F); 
// ondal�k k�sm� str'nin 5. karakterine yaz�l�yor
    str[4]= 48 + ondalik;              
}
//------------------------------------------------------------------
// Portlar� ve LCD birimini kullan�ma haz�rlar.
//------------------------------------------------------------------
void init()
{
// Analog giri�ler se�ildi, Vref+ = Vdd, Vref- = Vss se�ildi.
    ADCON1 = 0x80;  
    TRISA  = 0xFF;
    LCD_Config(&PORTB,4,5,7,3,2,1,0); 
    LCD_Cmd(LCD_CURSOR_OFF);            
    delay_ms(500);                      
}
//------------------------------------------------------------------
// MPX4115 bas�n� sens�r�nden analog bas�n� bilgisi elde edilir. Bu 
// bilgi MPX4115'in ba�land��� analog pinden 10 bit ��z�n�rl���nde 
// say�sal bilgiye d�n��t�r�l�r. Elde edilen bilgi i�lenerek bas�n� 
// de�eri tam ve ondal�kl� k�sm� elde edilir ve fonksiyon d���na 
// ta��n�r.
//------------------------------------------------------------------
unsigned short mpx4115_read()
{
// tam k�sm� tutacak de�i�ken tan�mlan�yor.
    unsigned short tmp;      
    unsigned i, hata;      // d�ng� ve hata de�i�keni tan�mlan�yor.
// Bas�n� de�eri say�sal de�ere d�n��t��l�yor
    mpx4115_data = Adc_Read(mpx4115_pin); 
// 15 kP'l�k ilk de�er ��kart�l�yor.
    mpx4115_data -= 56;                   
    hata = 0;                 // hata pay� ilk durumda s�f�r.
// Hata oran� tespit ediliyor.
    for(i = 9; i <= mpx4115_data ; i +=15) hata++; 
    mpx4115_data += hata;                 // Hata pay� ekleniyor
// tam k�s�m elde ediliyor ve 15 kP'l�k ilk de�er ekleniyor.
    tmp = mpx4115_data/10 + 15; 
    ondalik = mpx4115_data%10;     // ondal�kl� k�s�m elde ediliyor.
    return tmp;             // tam k�s�m fonksiyon d���na ta��n�yor.
}
//------------------------------------------------------------------
// Ana program MPX4115 bas�n� sens�r�nden analog bas�n� bilgisini 
// alarak say�sal de�ere d�n��t�r�p i�leyerek bas�n� de�erini %1 
// hata pay� ile hesaplar. Sonucu LCD display'de 500 ms ara ile 
// g�r�nt�ler.
//------------------------------------------------------------------
void main()
{
// 1 byte i�aretsiz ge�ici de�i�ken tan�mlan�yor.
    unsigned short tmp; 
// Portlar ve LCD kullan�ma haz�rlan�yor.         
    init();                      
    do        // do - while d�ng�s� ile sonsuz �evrim ba�l�yor.
    {
// MPX4115'ten bas�n� de�erinin say�sal kar��l���n�n tam k�sm� ve 
// ondal�kl� k�sm� elde ediliyor.
         tmp = mpx4115_read();
// Tam ve ondal�kl� k�s�m str dizisine aktar�l�yor.
         BintoStr(tmp, ondalik);
         Lcd_Out(1,1, "Basinc= ");
// str dizisi LCD'de g�r�nt�leniyor.
         Lcd_Out_Cp(str);
         Delay_ms(500);
    } while(1);                  // Ana program �evrimine devam et
}
// *****************************************************************

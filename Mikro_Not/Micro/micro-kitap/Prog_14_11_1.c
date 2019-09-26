// *****************************************************************
// Dosya Ad�		: 14_11_1.c
// A��klama		: RF verici mod�l� program�
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Sabit tan�mlamalar yap�l�yor. Al�c� devredeki kodlar ile ayn� 
// olmak zorunda
//------------------------------------------------------------------
// Anlaml� bir karakter olmas� �nemli de�il, sonu�ta sadece kontrol // i�i kullan�lacak LCD ya da terminalde yazd�r�lmayacak.
// Al�c� mod�ldeki kodlar burada tan�mlanan kodlar ile ayn� olmal�.
#define ST1               0xA9    
#define ST2               0xAE    
//------------------------------------------------------------------
// Genel de�i�ken tan�mlamalar� yap�l�yor
//------------------------------------------------------------------
unsigned short i, Data[3];
//------------------------------------------------------------------
// RF_write fonksiyonu RF mod�l� ile kodlanm�� 1 byte veri g�nderir.
//------------------------------------------------------------------
void RF_write(const char *str)
{
    i = 0;
    while(str[i])			// Text�in sonuna gelinceye kadar 
    {					// her bir karakterini kodlayarak
        Usart_Write(ST1);		// s�ras� ile g�nderir.
        Usart_Write(ST2);
        Usart_Write(str[i]);
        i++;
    }
}
//------------------------------------------------------------------
// Usart birimlerini kullan�ma haz�rlar
//------------------------------------------------------------------
void init()
{
// Usart mod�l�n� 8 bit, 2400 baud rate, no parity bit ayarlar�nda 
// haz�rla
    Usart_Init(2400);
    delay_ms(500);  // Al�c�n�n haz�r olmas� i�in 500 ms kadar bekle
}


//------------------------------------------------------------------
// Ana program RF mod�l� ile al�c� mod�le bir text bilgi g�nderir. //------------------------------------------------------------------
void main()
{
    init();     	// LCD ve Usart birimlerini kullan�ma haz�rla
    RF_write("PIC16F877A ve uC");      // Text g�nder
    while(1);   	// Sistem kapat�lana kadar bekle
}
// *****************************************************************

// *****************************************************************
// Dosya Adý		: 14_11_1.c
// Açýklama		: RF verici modülü programý
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Sabit tanýmlamalar yapýlýyor. Alýcý devredeki kodlar ile ayný 
// olmak zorunda
//------------------------------------------------------------------
// Anlamlý bir karakter olmasý önemli deðil, sonuçta sadece kontrol // içi kullanýlacak LCD ya da terminalde yazdýrýlmayacak.
// Alýcý modüldeki kodlar burada tanýmlanan kodlar ile ayný olmalý.
#define ST1               0xA9    
#define ST2               0xAE    
//------------------------------------------------------------------
// Genel deðiþken tanýmlamalarý yapýlýyor
//------------------------------------------------------------------
unsigned short i, Data[3];
//------------------------------------------------------------------
// RF_write fonksiyonu RF modülü ile kodlanmýþ 1 byte veri gönderir.
//------------------------------------------------------------------
void RF_write(const char *str)
{
    i = 0;
    while(str[i])			// Text’in sonuna gelinceye kadar 
    {					// her bir karakterini kodlayarak
        Usart_Write(ST1);		// sýrasý ile gönderir.
        Usart_Write(ST2);
        Usart_Write(str[i]);
        i++;
    }
}
//------------------------------------------------------------------
// Usart birimlerini kullanýma hazýrlar
//------------------------------------------------------------------
void init()
{
// Usart modülünü 8 bit, 2400 baud rate, no parity bit ayarlarýnda 
// hazýrla
    Usart_Init(2400);
    delay_ms(500);  // Alýcýnýn hazýr olmasý için 500 ms kadar bekle
}


//------------------------------------------------------------------
// Ana program RF modülü ile alýcý modüle bir text bilgi gönderir. //------------------------------------------------------------------
void main()
{
    init();     	// LCD ve Usart birimlerini kullanýma hazýrla
    RF_write("PIC16F877A ve uC");      // Text gönder
    while(1);   	// Sistem kapatýlana kadar bekle
}
// *****************************************************************

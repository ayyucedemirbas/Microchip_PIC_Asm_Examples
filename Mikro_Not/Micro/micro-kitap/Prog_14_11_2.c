// *****************************************************************
// Dosya Adý		: 14_11_2.c
// Açýklama		: RF alýcý modülü programý
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Sabit tanýmlamalar yapýlýyor.
//------------------------------------------------------------------

// Anlamlý bir karakter olmasý önemli deðil. Sonuçta sadece kontrol 
// içi kullanýlacak LCD ya da terminalde yazdýrýlmayacak. Ancak 
// RF verici modülündeki kodlar ile ayný olmak zorunda.
#define ST1               0xA9    
#define ST2               0xAE    
//------------------------------------------------------------------
// Genel deðiþken tanýmlamalarý yapýlýyor
//------------------------------------------------------------------
unsigned short i, Data[3];
unsigned char ControlReg, RxBuffer;
char txt[]="                \0";
char ch;
//------------------------------------------------------------------
// RF_read fonksiyonu RF modülünden 1 byte veri alýr
//------------------------------------------------------------------
unsigned short RF_read()
{
// Yerel geçici deðiþkenler tanýmlanýyor.
    unsigned short tmp, i;  
    i = 0;                  // Karakter sayacý sýfýrlanýyor.
    do
    {
        if (Usart_Data_Ready())
        {   					// Eðer veri alýndý ise
            tmp = Usart_Read();    	// Alýnan veriyi oku
            switch(i)
            {
// 0. karakter alýndý ise ve alýnan karakter ST1 kontrol karakterine 
// eþitse Data[0]'a kaydet ve i sayacýný artýr.
                 case 0: if (tmp == ST1) {Data[0] = tmp; i++;} break;
// 1. karakter alýndý ise ve alýnan karakter ST2 kontrol karakterine 
// eþitse Data[1]'e kaydet ve i sayacýný artýr. Aksi halde i alýnan 
// karakter sayacýný sýfýrla. Çünkü kontrol karakterleri hatalý, 
// dolayýsýyle veri alýmý hatalý olduðundan baþa dön ve yeniden 
// almaya baþla
                 case 1: if (tmp == ST2) {Data[1] = tmp; i++;} else i = 0; break;
// Ýlk 2 karakter doðru alýndý ise 3. karakterde doðru gelecektir. 
// 3. karakter bizim gerçek verimizdir. Ýstenirse verilerin daha 
// hatasýz ulaþmasý için kontrol karakter sayýsý artýrýlabilir.
                 case 2: Data[2] = tmp; i++; break;
                 default: break;
            }
        }
        PORTD = tmp;
// 3 karakterde alýndý ise do-while döngüsünden çýk
    } while (i<3); 
    return tmp;    // Son alýnan veriyi fonksiyon dýþýna taþý
}


//------------------------------------------------------------------
// LCD ve Usart birimlerini kullanýma hazýrlar
//------------------------------------------------------------------
void init()
{
    Usart_Init(2400);
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);
}
//------------------------------------------------------------------
// Ana program RF modülünden aldýðý verileri LCD'de görüntüler
//------------------------------------------------------------------
void main()
{
    init();          // LCD ve Usart birimlerini kullanýma hazýrla
    do
    {
        i = 0;
        Lcd_Cmd(LCD_FIRST_ROW);
        do
        {
// RF modülünden alýnan karakteri LCD'ye yaz
            ch = RF_read();
            Lcd_Chr_Cp(ch);
            i++;                // karakter sayacýný artýr
        } while (i<16);
    } while(1);   		// Okuma ve görüntüleme iþlemine devam
}
// *****************************************************************

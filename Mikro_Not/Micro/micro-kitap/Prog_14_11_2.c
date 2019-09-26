// *****************************************************************
// Dosya Ad�		: 14_11_2.c
// A��klama		: RF al�c� mod�l� program�
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Sabit tan�mlamalar yap�l�yor.
//------------------------------------------------------------------

// Anlaml� bir karakter olmas� �nemli de�il. Sonu�ta sadece kontrol 
// i�i kullan�lacak LCD ya da terminalde yazd�r�lmayacak. Ancak 
// RF verici mod�l�ndeki kodlar ile ayn� olmak zorunda.
#define ST1               0xA9    
#define ST2               0xAE    
//------------------------------------------------------------------
// Genel de�i�ken tan�mlamalar� yap�l�yor
//------------------------------------------------------------------
unsigned short i, Data[3];
unsigned char ControlReg, RxBuffer;
char txt[]="                \0";
char ch;
//------------------------------------------------------------------
// RF_read fonksiyonu RF mod�l�nden 1 byte veri al�r
//------------------------------------------------------------------
unsigned short RF_read()
{
// Yerel ge�ici de�i�kenler tan�mlan�yor.
    unsigned short tmp, i;  
    i = 0;                  // Karakter sayac� s�f�rlan�yor.
    do
    {
        if (Usart_Data_Ready())
        {   					// E�er veri al�nd� ise
            tmp = Usart_Read();    	// Al�nan veriyi oku
            switch(i)
            {
// 0. karakter al�nd� ise ve al�nan karakter ST1 kontrol karakterine 
// e�itse Data[0]'a kaydet ve i sayac�n� art�r.
                 case 0: if (tmp == ST1) {Data[0] = tmp; i++;} break;
// 1. karakter al�nd� ise ve al�nan karakter ST2 kontrol karakterine 
// e�itse Data[1]'e kaydet ve i sayac�n� art�r. Aksi halde i al�nan 
// karakter sayac�n� s�f�rla. ��nk� kontrol karakterleri hatal�, 
// dolay�s�yle veri al�m� hatal� oldu�undan ba�a d�n ve yeniden 
// almaya ba�la
                 case 1: if (tmp == ST2) {Data[1] = tmp; i++;} else i = 0; break;
// �lk 2 karakter do�ru al�nd� ise 3. karakterde do�ru gelecektir. 
// 3. karakter bizim ger�ek verimizdir. �stenirse verilerin daha 
// hatas�z ula�mas� i�in kontrol karakter say�s� art�r�labilir.
                 case 2: Data[2] = tmp; i++; break;
                 default: break;
            }
        }
        PORTD = tmp;
// 3 karakterde al�nd� ise do-while d�ng�s�nden ��k
    } while (i<3); 
    return tmp;    // Son al�nan veriyi fonksiyon d���na ta��
}


//------------------------------------------------------------------
// LCD ve Usart birimlerini kullan�ma haz�rlar
//------------------------------------------------------------------
void init()
{
    Usart_Init(2400);
    LCD_Config(&PORTB,4,5,7,3,2,1,0);    
    LCD_Cmd(LCD_CURSOR_OFF);
}
//------------------------------------------------------------------
// Ana program RF mod�l�nden ald��� verileri LCD'de g�r�nt�ler
//------------------------------------------------------------------
void main()
{
    init();          // LCD ve Usart birimlerini kullan�ma haz�rla
    do
    {
        i = 0;
        Lcd_Cmd(LCD_FIRST_ROW);
        do
        {
// RF mod�l�nden al�nan karakteri LCD'ye yaz
            ch = RF_read();
            Lcd_Chr_Cp(ch);
            i++;                // karakter sayac�n� art�r
        } while (i<16);
    } while(1);   		// Okuma ve g�r�nt�leme i�lemine devam
}
// *****************************************************************

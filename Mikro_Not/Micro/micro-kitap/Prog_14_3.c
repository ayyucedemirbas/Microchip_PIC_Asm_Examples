// *****************************************************************
// Dosya Adý		: 14_3.c
// Açýklama		: DS18B20 ýsý sensörü ile ýsý ölçümü
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
#include <built_in.h>
//Deðiþken tanýmlamalarý
char *str="  \0";
char *txt="      \0";
//------------------------------------------------------------------
// Bir byte'lýk hexadesimal sayýyý 2 basamaklý desimal sayýya 
// dönüþtürür.
//------------------------------------------------------------------
char Hex2Dec(char ch)                    //2 digit dönüþüm
{
     char tmp = 0;                       //Geçici deðiþkeni sýfýrla
// sayýnýn onlar basamaðýný bulur
     while(ch>=10) {tmp++; ch -= 10;}    
     tmp = (tmp<<4) + ch;          // Birler basamaðýný sayýya ekle
     return tmp;                   // Sonucu fonksiyon dýþýna taþý
}
//------------------------------------------------------------------
// Bir byte'lýk sayýyý text'e dönüþtürür.
//------------------------------------------------------------------
void BintoStr(char data)
{
    data = Hex2Dec(data);
    str[0] = 48 + ((data & 0xF0) >> 4);  
    if (str[0] == 48) str[0] = 32;       
    str[1]= 48 + (data & 0x0F); 
}

void Isi_Olc_Goruntule()
{
    char lsb, msb, tmp;
    int ondalik;
    Ow_Reset(&PORTC,0);        
    Ow_Write(&PORTC,0,0xCC);   
    Ow_Write(&PORTC,0,0x44);   
    Delay_us(120);

    Ow_Reset(&PORTC,0);
    Ow_Write(&PORTC,0,0xCC);   
    Ow_Write(&PORTC,0,0xBE);   
    Delay_ms(400);

    lsb = Ow_Read(&PORTC,0);
    msb = Ow_Read(&PORTC,0); 

    ondalik = 0x0000;
    tmp = lsb & 0x0F;
    if(msb & 0xF0)  tmp = ~tmp + 1;

    if(tmp.F0) ondalik +=  625;
    if(tmp.F1) ondalik += 1250;
    if(tmp.F2) ondalik += 2500;
    if(tmp.F3) ondalik += 5000;


    lsb &= 0xF0;
    lsb >>= 4;
    tmp = (msb & 0x0F) << 4;
    tmp |= lsb;
    lsb = tmp;

    if(msb & 0xF0) lsb = ~lsb;
    if(lsb>99) lsb = 99;
    if((msb&0xF0) && (ondalik == 0)) lsb++;

    IntToStr(ondalik, txt);
    txt[0]=46;
    txt[1]=txt[2];
    txt[2]=txt[3];
    txt[3]=txt[4];
    txt[4]=txt[5];
    txt[5]=223;
    if(ondalik == 625) txt[1] = 48;

    Lcd_Out(1, 1, "Isi:");
    if(msb & 0xF0) LCD_Out_Cp("-"); else LCD_Out_Cp(" ");
    BintoStr(lsb);           // Isýyý text'e dönüþtür (2 dijit)
    Lcd_Out_Cp(str);
    Lcd_Out_Cp(txt);
    LCD_Out_Cp("C");
    LCD_Out_Cp("  ");
}

void init()
{
   PORTB = 0;
   TRISB = 0;    
   PORTC = 0;
   TRISC = 0xFF;

   Lcd_Config(&PORTB, 4,5,7,3,2,1,0);
   Lcd_Cmd(Lcd_CURSOR_OFF);
}

void main()
{
    init();
    do {  // ana program çevrimi
          Isi_Olc_Goruntule();
          Delay_ms(1000);      // yeni ölçüm için 1 saniye bekle
    } while (1);
}
// *****************************************************************

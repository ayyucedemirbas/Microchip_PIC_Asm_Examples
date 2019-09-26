// *****************************************************************
// Dosya Ad�		: 14_8.c
// A��klama		: DS1868 dijital potansiyometre uygulamas�
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
// Buton ba�lant�lar� tan�mlar�
#define BUTONLAR             PORTB
#define BUTONLAR_tris        TRISB
#define POTLAR               F5
#define ARTIR                F3
#define AZALT                F4
#define RESET                F6
// ds1868 ba�lant� tan�mlar�
#define ds1868_port          PORTB
#define ds1868_tris          TRISB
#define DQ                   F0
#define CLK                  F1
#define RST                  F2
// De�i�ken tan�mlamalar�
char pot1_deger, pot2_deger;
//------------------------------------------------------------------
// DS1868 dijital potansiyometre i�erisindeki potansiyometrelere 
// de�er y�kler
//------------------------------------------------------------------
void ds1868_write(char pot1, char pot2, char ss)
{
    unsigned short i;
    ds1868_port.RST = 1;
    if(ss) ds1868_port.DQ = 1; else ds1868_port.DQ = 0;
// Y�kselen (pozitif) saat darbe kenar� uygulan�yor
    ds1868_port.CLK = 0;  		
    asm nop
    ds1868_port.CLK = 1;
    i = 8;
    do
    {
        if(pot2.F7) ds1868_port.DQ = 1; else ds1868_port.DQ = 0;
// Y�kselen (pozitif) saat darbe kenar� uygulan�yor
        ds1868_port.CLK = 0;       
        asm nop
        ds1868_port.CLK = 1;
        pot2 <<= 1;
    }while(--i);
    i = 8;
    do
    {
        if(pot1.F7) ds1868_port.DQ = 1; else ds1868_port.DQ = 0;
// Y�kselen (pozitif) saat darbe kenar� uygulan�yor
        ds1868_port.CLK = 0;       
        asm nop
        ds1868_port.CLK = 1;
        pot1 <<= 1;
    }while(--i);
    ds1868_port.RST = 0;
}
//------------------------------------------------------------------
// �lk i�lemler alt program� DS1868'i kullan�ma haz�rlar 
//------------------------------------------------------------------
void init()
{
    ds1868_tris.DQ = 0;
    ds1868_tris.CLK = 0;
    ds1868_tris.RST = 0;
    BUTONLAR_tris.POTLAR = 1;
    BUTONLAR_tris.ARTIR = 1;
    BUTONLAR_tris.AZALT = 1;
    BUTONLAR_tris.RESET = 1;
    pot1_deger = 0;
    pot2_deger = 0;
    ds1868_write(pot1_deger, pot2_deger, 0);
}
//------------------------------------------------------------------
// Ana program butonlar� kontrol ederek DS1868 dijital 
// potansiyometre ��k�� diren�lerini de�i�tirir.
//------------------------------------------------------------------
void main(void)
{
     init();                    	// ilk i�lemleri ger�ekle�tir
     while(1)   			
     {  				                                 
          if(!BUTONLAR.ARTIR)
          {
               if(BUTONLAR.POTLAR)
               {
                   if(pot2_deger<255) pot2_deger++;
               }else
               {
                   if(pot1_deger<255) pot1_deger++;
               }
               while(!BUTONLAR.ARTIR);
               ds1868_write(pot1_deger, pot2_deger, 0);
          }

          if(!BUTONLAR.AZALT)
          {
               if(BUTONLAR.POTLAR)
               {
                   if(pot2_deger>0) pot2_deger--;
               }else
               {
                   if(pot1_deger>0) pot1_deger--;
               }
               while(!BUTONLAR.AZALT);
               ds1868_write(pot1_deger, pot2_deger, 0);
          }
          if(!BUTONLAR.RESET) {pot1_deger = 0; pot2_deger = 0; ds1868_write(pot1_deger, pot2_deger, 0);}
     }
}
// *****************************************************************

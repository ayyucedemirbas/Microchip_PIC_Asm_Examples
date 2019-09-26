// *****************************************************************
// Dosya Adý		: 14_8.c
// Açýklama		: DS1868 dijital potansiyometre uygulamasý
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
// Buton baðlantýlarý tanýmlarý
#define BUTONLAR             PORTB
#define BUTONLAR_tris        TRISB
#define POTLAR               F5
#define ARTIR                F3
#define AZALT                F4
#define RESET                F6
// ds1868 baðlantý tanýmlarý
#define ds1868_port          PORTB
#define ds1868_tris          TRISB
#define DQ                   F0
#define CLK                  F1
#define RST                  F2
// Deðiþken tanýmlamalarý
char pot1_deger, pot2_deger;
//------------------------------------------------------------------
// DS1868 dijital potansiyometre içerisindeki potansiyometrelere 
// deðer yükler
//------------------------------------------------------------------
void ds1868_write(char pot1, char pot2, char ss)
{
    unsigned short i;
    ds1868_port.RST = 1;
    if(ss) ds1868_port.DQ = 1; else ds1868_port.DQ = 0;
// Yükselen (pozitif) saat darbe kenarý uygulanýyor
    ds1868_port.CLK = 0;  		
    asm nop
    ds1868_port.CLK = 1;
    i = 8;
    do
    {
        if(pot2.F7) ds1868_port.DQ = 1; else ds1868_port.DQ = 0;
// Yükselen (pozitif) saat darbe kenarý uygulanýyor
        ds1868_port.CLK = 0;       
        asm nop
        ds1868_port.CLK = 1;
        pot2 <<= 1;
    }while(--i);
    i = 8;
    do
    {
        if(pot1.F7) ds1868_port.DQ = 1; else ds1868_port.DQ = 0;
// Yükselen (pozitif) saat darbe kenarý uygulanýyor
        ds1868_port.CLK = 0;       
        asm nop
        ds1868_port.CLK = 1;
        pot1 <<= 1;
    }while(--i);
    ds1868_port.RST = 0;
}
//------------------------------------------------------------------
// Ýlk iþlemler alt programý DS1868'i kullanýma hazýrlar 
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
// Ana program butonlarý kontrol ederek DS1868 dijital 
// potansiyometre çýkýþ dirençlerini deðiþtirir.
//------------------------------------------------------------------
void main(void)
{
     init();                    	// ilk iþlemleri gerçekleþtir
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

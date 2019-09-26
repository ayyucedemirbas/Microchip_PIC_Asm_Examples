// *****************************************************************
// Dosya Ad�		: 14_9.c
// A��klama		: Rotary pulse encoder uygulamas�
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Rotary Encoder'in mikrodenetleyiciye ba�lant�s� tan�mlan�yor.
//------------------------------------------------------------------
#define RotaryEncoder           PORTE
#define RotaryEncoder_tris      TRISE
//------------------------------------------------------------------
// Global de�i�ken tan�mlamalar� yap�l�yor.
//------------------------------------------------------------------
char Encoder, oldEncoder;
unsigned tmp, sayac;
char txt[5];
//------------------------------------------------------------------
// Portlar� ve LCD'yi kullan�ma haz�rlar, de�i�kenlere ilk de�er 
// atamalar� yapar.
//------------------------------------------------------------------
void init()
{
   LCD_Config(&PORTB,4,5,7,3,2,1,0);  // LCD ba�lant�s� tan�mlan�yor
   LCD_Cmd(LCD_CURSOR_OFF);           // imleci gizle
   ADCON1 = 0x06;                     // Analog giri�leri kapat.
   RotaryEncoder = 0;          // Portun ilk durumu s�f�rlan�yor.
   RotaryEncoder = 0x03;       // Rotary Encoder portu giri� yap�ld�
// Rotary encoder'in de�erini tutan de�i�kene ilk de�er veriliyor.
   Encoder = 0x03;
   sayac = 0;                  // sayac de�eri s�f�rlan�yor.
   Lcd_Out(1,1,"Sayac:");
}
//------------------------------------------------------------------
// Ana program Rotary encoder'den gelen bilgiyi de�erlendirerek sa�a 
// ya da sola do�ru �evrildi�ini belirler ve rotary encoder sa�a 
// �evrilmi� ise sayac de�erini art�r�r, sola �evrildi ise sayac� 
// azalt�r ve sayac de�erini LCD'de g�r�nt�ler. Herhangi bir 
// de�i�iklik yoksa de�i�im olana kadar rotary encoder'den gelen 
// bilgiyi bir �nceki bilgi ile k�yaslamaya devam eder.
//------------------------------------------------------------------
void main()
{
     init();
     do
     {
// yeni de�er eski de�ere y�kleniyor
          oldEncoder = Encoder; 
// 2 byte'l�k sayac desimale d�n��t�r�l�yor
          tmp = Bcd2Dec16(sayac); 
// desimale d�n��t�r�l�n de�er text'e �evriliyor. 
          WordToStr(tmp, txt);        
          Lcd_Out(1,1,"Sayac:"); 
// sayac de�eri LCD'de g�r�nt�leniyor.
          Lcd_Out(2,4,txt); 
// Rotary encoder'in eski de�eri ile yeni de�erini kar��la�t�r. 
// Birbirinden farkl� olana kadar (rotay encoder �evrilene kadar) 
// kar��la�t�rmaya devam et.
          while(Encoder == oldEncoder) Encoder = RotaryEncoder & 0x03;
          
// eski de�erin 1. biti yeni de�erin 0. bitinden farkl� ise ve eski 
// de�erin 0. biti yeni de�erin 1. bitine e�it ise rotary encoder 
// sa�a do�ru �evrilmi�tir, bu durumda sayac 9999'dan k���kse art�r.
          if(oldEncoder.F1 !=Encoder.F0)
          {
              if(oldEncoder.F0 == Encoder.F1) if(sayac<9999) sayac++;
          } else
// eski de�erin 0. biti yeni de�erin 1. bitinden farkl� ise ve eski 
// de�erin 1. biti yeni de�erin 0. bitine e�it ise rotary encoder 
// sola do�ru �evrilmi�tir, bu durumda sayac 0'dan b�y�kse azalt.
          if(oldEncoder.F0 != Encoder.F1)
          {
              if(oldEncoder.F1 == Encoder.F0 ) if(sayac>0) sayac--;
          }
     } while(1);               // Ana program �evrimine devam et
}
// *****************************************************************

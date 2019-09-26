// *****************************************************************
// Dosya Adý		: 14_10.c
// Açýklama		: Rotary pulse encoder ile ses üretme
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Rotary Encoder'in mikrodenetleyiciye baðlantýsý tanýmlanýyor.
//------------------------------------------------------------------
#define RotaryEncoder           PORTE
#define RotaryEncoder_tris      TRISE
//------------------------------------------------------------------
// Rotary Encoder'in mikrodenetleyiciye baðlantýsý tanýmlanýyor.
//------------------------------------------------------------------
#define Buzzer                  PORTC
#define Buzzer_pin              1
//------------------------------------------------------------------
// Global deðiþken tanýmlamalarý yapýlýyor.
//------------------------------------------------------------------
char Encoder, oldEncoder;
unsigned tmp, sayac;
char txt[5];

//------------------------------------------------------------------
// Portlarý ve LCD'yi kullanýma hazýrlar, deðiþkenlere ilk deðer 
// atamalarý yapar.
//------------------------------------------------------------------
void init()
{
   LCD_Config(&PORTB,4,5,7,3,2,1,0);    
   LCD_Cmd(LCD_CURSOR_OFF);
// Buzzer'ýn bulunduðu port ses çýkýþý için hazýrlandý    
   Sound_Init(&Buzzer, Buzzer_pin);     
   
   ADCON1 = 0x06;              // Analog giriþleri kapat.
   RotaryEncoder = 0;          // Portun ilk durumu sýfýrlanýyor.
   RotaryEncoder = 0x03;       // Rotary Encoder portu giriþ yapýldý

// Rotary encoder'in deðerini tutan deðiþkene ilk deðer veriliyor.
   Encoder = 0x03;
   sayac = 0;                  // sayac deðeri sýfýrlanýyor.
   Lcd_Out(1,1,"Sayac:");
}
//------------------------------------------------------------------
// Ana program Rotary encoder'den gelen bilgiyi deðerlendirerek saða 
// ya da sola doðru çevrildiðini belirler ve rotary encoder saða 
// çevrilmiþ ise sayac deðerini 1 artýrýr, sola çevrildi ise sayacý 
// 1 azaltýr ve sayac deðerini LCD'de görüntüler ve sayac deðerinin 
// 10 katý frekansta ses üzetir. Ayný zamanda herhangi bir 
// deðiþiklik yoksa deðiþim olana kadar rotary encoder'den gelen 
// bilgiyi bir önceki bilgi ile kýyaslamaya devam eder.
//------------------------------------------------------------------
void main()
{
     init();
     do
     {
// yeni deðer eski deðere yükleniyor
          oldEncoder = Encoder; 
// 2 byte'lýk sayac desimale dönüþtürülüyor      
          tmp = Bcd2Dec16(sayac); 
// desimale dönüþtürülün deðer text'e çevriliyor.    
          WordToStr(tmp, txt);        
          Lcd_Out(1,1,"Sayac:");     
          Lcd_Out(2,4,txt);
// Rotary encoder'in eski deðeri ile yeni deðerini karþýlaþtýr. 
// Birbirinden farklý olana kadar (rotay encoder çevrilene kadar) 
// karþýlaþtýrmaya ve sayac frekansýnda ses üretmeye devam et.
          while(Encoder == oldEncoder)
          {
// Rotary encoder'in deðeri okunuyor
               Encoder = RotaryEncoder & 0x03; 
// sayac*10 frekansýnda, 150 peryotluk ses 
               Sound_Play(sayac, 50);   
          }
// eski deðerin 1. biti yeni deðerin 0. bitinden farklý ise ve eski 
// deðerin 0. biti yeni deðerin 1. bitine eþit ise rotary encoder 
// saða doðru çevrilmiþtir, bu durumda sayac 254'den küçükse artýr.
          if(oldEncoder.F1 !=Encoder.F0)
          {
              if(oldEncoder.F0 == Encoder.F1) if(sayac<254) sayac++;
          } else
// eski deðerin 0. biti yeni deðerin 1. bitinden farklý ise ve eski 
// deðerin 1. biti yeni deðerin 0. bitine eþit ise rotary encoder 
// sola doðru çevrilmiþtir, bu durumda sayac 0'dan büyükse azalt.
          if(oldEncoder.F0 != Encoder.F1)
          {
              if(oldEncoder.F1 == Encoder.F0) if(sayac>0) sayac--;
          }
     } while(1);               // Ana program çevrimine devam et
}
// *****************************************************************

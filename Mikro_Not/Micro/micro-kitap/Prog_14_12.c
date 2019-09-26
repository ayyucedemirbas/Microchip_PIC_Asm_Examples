// *****************************************************************
// Dosya Adý		: 14_12.c
// Açýklama		: MT8870 ile DTMF ton kod çözücü uygulamasý
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Genel tanýmlamalar
//------------------------------------------------------------------
#define Telefon     PORTD.F7
#define ON          1
#define OFF         0
#define HatAcmaIzni F0
#define HatAcik     F1

unsigned short MaxRingCount = 5;
unsigned short RingCount;
unsigned short HatKontrol;
unsigned short Timer10sn = 0;
//------------------------------------------------------------------
// Telefon ile ilgili fonksiyonlar
//------------------------------------------------------------------
void Telefon_Hattini_Ac()
{
   Telefon = ON;
}

void Telefon_Hattini_Kapat()
{
   Telefon = OFF;
}

unsigned short DTMF_Isle(unsigned short data)
{
      PORTC = data & 0x0F; 	// Ton bilgisi PORTC'deki LED'ler 
// üzerinde görüntüleniyor.
}
//------------------------------------------------------------------
// Kesme alt programý
//------------------------------------------------------------------
void interrupt()
{
   // Timer1 zamanlayýcýsýný kontrol et
   if(PIR1.TMR1IF)
   {
      // TMR1'e 15535 ön deðeri yükleniyor. 50000 kez arttýðýnda
      // 65535'ten 0'a döner ve kesme oluþur. 1/8 prescaler deðerde 
      // 4 MHz'de 50000*8 = 400.000 komut çevriminde bir bu kesme 
      // oluþur. 25 kez kesme oluþtuðunda ise 10 saniye geçmiþtir.
      TMR1H = 0x3C;
      TMR1L = 0xAF;
      Timer10sn++;
      if(Timer10sn == 25)
      {
         Timer10sn = 0;  		// 10 sn sayacý sýfýrlandý
         if(HatKontrol.HatAcik) 	// Telefon hattý açýk ise hattý kapat.
         {
            HatKontrol.HatAcik = OFF;	// Telefon hattý açýk 
// bayraðýný resetle
            Telefon_Hattini_Kapat(); 	// Telefon hattýný kapat
         }
      }
      PIR1.TMR1IF = 0;  		// Timer 1 kesme bayraðýný sil
   }
   // PORTB'nin RB0 pininden gelen kesme ise
   if(INTCON.INTF)
   {
      DTMF_Isle(PORTD);
      INTCON.INTF = 0;  // PORTB pin deðiþim kesme bayraðýný sil
   }
   // PORTB'nin RB4-RB7 pinlerinin durumunda deðiþiklik var ise
   if(INTCON.RBIF)
   {

      INTCON.RBIF = 0;  // PORTB pin deðiþim kesme bayraðýný sil
   }
   // Komparatör modülünden kesme isteði geldi ise
   if(PIR1.CMIF)
   {
      if(CMCON.C2OUT)
      {
         RingCount++;
         if(RingCount == MaxRingCount)
         {
            RingCount = 0;   // Ring sayacýný sýfýrla
            // HatKontrol kaydedicisinde hat açma izni set ise 
            // telefon hattýný aç
            if(HatKontrol.HatAcmaIzni)
            {
               HatKontrol.HatAcik = ON;
               Telefon_Hattini_Ac(); 	// Telefon hattýný aç
               Timer10sn = 0;        	// Hattýn açýk kalma süresi 
// baþlatýldý
            }
         }
      }
      PIR1.CMIF = 0;     // Komparatör kesme bayraðýný sil
   }
}
//------------------------------------------------------------------
// Ýlk iþlemler alt programý.
//------------------------------------------------------------------
void init()
{
   // RB0/INT kesmesi pozitif kenara ayarlanýyor.
   OPTION_REG.INTEDG = 1;

   // Portlar yönlendiriliyor.
   PORTB = 0;         // PORTB'nin ilk durumu sýfýrlanýyor.
   PORTC = 0;         // PORTC'nin ilk durumu sýfýrlanýyor.
   PORTE = 0;         // PORTE'nin ilk durumu sýfýrlanýyor.
   PORTD = 0;         // PORTD'nin ilk durumu sýfýrlanýyor.
   TRISB = 0xFF;      // PORTB'nin pinlerinin tümü giriþ yapýldý.
   TRISC = 0;         // PORTC'nin pinlerinin tümü çýkýþ yapýldý.
   TRISE = 0;         // PORTE çýkýþ yapýlýyor, ayný zamanda PORTD 
                      // normal I/O moduna alýnýyor.
   TRISD = 0x0F;      // RD0-RD3 ton giriþi için giriþe 
                      // yönlendirildi.

   // Komparatör modülü kuruluyor.
   CMCON.CM2 = 1;
   CMCON.CM1 = 0;
   CMCON.CM0 = 1;     // Baðýmsýz tek karþýlaþtýrýcý modu seçildi 
                      // (komparatör 2 etkin).
   CMCON.C2INV = 1;   // C2Vin+ < C2Vin- ise karþýlaþtýrýcý çýkýþý 1 
                      // olacak.
                      // C2Vin+'ya (RA2/AN2/Vref) pot baðlý ring 
                      // algýlama referans gerilimi için.
                      // C2Vin-'ye (RA1/AN1) hat devresinden giriþ için

   // Timer 1 zamanlayýcýsý kuruluyor.
   T1CON.T1CKPS1 = 1;
   T1CON.T1CKPS0 = 1; // Timer 1 modülü 1/8 prescaler deðere 
                      // ayarlanýyor.
   T1CON.T1OSCEN = 1; // Timer 1 için OSC pasif hale getiriliyor.
   T1CON.TMR1CS = 0;  // Ýçsel saat darbeleri ile artmasý seçiliyor. 
                      // (Zamanlayýcý modu)
   TMR1H = 0x3C;      // Timer 1'e ilk deðer atamasý yapýlýyor. 
                      // (TMR1 = 15535)
   TMR1L = 0xAF;
   T1CON.TMR1ON = ON; // Timer 1 zamanlayýcýsý çalýþmaya baþladý.

   // Karþýlaþtýrýcý 1'i ayarla.
   RingCount = 0;
   HatKontrol = 0;
   HatKontrol.HatAcmaIzni = ON;   // Hat açma izni verildi.
   
   PIE1.CMIE = ON;    // Komparator kesmesi etkinleþtirildi.
   PIE1.TMR1IE = ON;  // Timer 1 kesmesi etkinleþtirildi.
   INTCON.RBIE = ON;  // PORTB'nin RB4-RB7 pinlerinin deðiþimlerinde 
                      // kesme oluþmasý etkinleþtirildi.
   INTCON.INTE = ON;  // PORTB'nin RB0 kesme pini etkinleþtirildi
   INTCON.PEIE = ON;  // PIE Çevresel kesmeler etkinleþtirildi.
   INTCON.GIE = ON;   // Etkinleþtirilen kesmelere izin verildi.
}
//------------------------------------------------------------------
// Ana program
//------------------------------------------------------------------
void main()
{
   init();            // Programý kullanýma hazýrla
   do
   {
        // Boþ döngü
   } while(1);
}
// *****************************************************************

// *****************************************************************
// Dosya Ad�		: 14_12.c
// A��klama		: MT8870 ile DTMF ton kod ��z�c� uygulamas�
// Notlar		: XT ==> 4 MHz
// *****************************************************************
//------------------------------------------------------------------
// Genel tan�mlamalar
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
// �zerinde g�r�nt�leniyor.
}
//------------------------------------------------------------------
// Kesme alt program�
//------------------------------------------------------------------
void interrupt()
{
   // Timer1 zamanlay�c�s�n� kontrol et
   if(PIR1.TMR1IF)
   {
      // TMR1'e 15535 �n de�eri y�kleniyor. 50000 kez artt���nda
      // 65535'ten 0'a d�ner ve kesme olu�ur. 1/8 prescaler de�erde 
      // 4 MHz'de 50000*8 = 400.000 komut �evriminde bir bu kesme 
      // olu�ur. 25 kez kesme olu�tu�unda ise 10 saniye ge�mi�tir.
      TMR1H = 0x3C;
      TMR1L = 0xAF;
      Timer10sn++;
      if(Timer10sn == 25)
      {
         Timer10sn = 0;  		// 10 sn sayac� s�f�rland�
         if(HatKontrol.HatAcik) 	// Telefon hatt� a��k ise hatt� kapat.
         {
            HatKontrol.HatAcik = OFF;	// Telefon hatt� a��k 
// bayra��n� resetle
            Telefon_Hattini_Kapat(); 	// Telefon hatt�n� kapat
         }
      }
      PIR1.TMR1IF = 0;  		// Timer 1 kesme bayra��n� sil
   }
   // PORTB'nin RB0 pininden gelen kesme ise
   if(INTCON.INTF)
   {
      DTMF_Isle(PORTD);
      INTCON.INTF = 0;  // PORTB pin de�i�im kesme bayra��n� sil
   }
   // PORTB'nin RB4-RB7 pinlerinin durumunda de�i�iklik var ise
   if(INTCON.RBIF)
   {

      INTCON.RBIF = 0;  // PORTB pin de�i�im kesme bayra��n� sil
   }
   // Komparat�r mod�l�nden kesme iste�i geldi ise
   if(PIR1.CMIF)
   {
      if(CMCON.C2OUT)
      {
         RingCount++;
         if(RingCount == MaxRingCount)
         {
            RingCount = 0;   // Ring sayac�n� s�f�rla
            // HatKontrol kaydedicisinde hat a�ma izni set ise 
            // telefon hatt�n� a�
            if(HatKontrol.HatAcmaIzni)
            {
               HatKontrol.HatAcik = ON;
               Telefon_Hattini_Ac(); 	// Telefon hatt�n� a�
               Timer10sn = 0;        	// Hatt�n a��k kalma s�resi 
// ba�lat�ld�
            }
         }
      }
      PIR1.CMIF = 0;     // Komparat�r kesme bayra��n� sil
   }
}
//------------------------------------------------------------------
// �lk i�lemler alt program�.
//------------------------------------------------------------------
void init()
{
   // RB0/INT kesmesi pozitif kenara ayarlan�yor.
   OPTION_REG.INTEDG = 1;

   // Portlar y�nlendiriliyor.
   PORTB = 0;         // PORTB'nin ilk durumu s�f�rlan�yor.
   PORTC = 0;         // PORTC'nin ilk durumu s�f�rlan�yor.
   PORTE = 0;         // PORTE'nin ilk durumu s�f�rlan�yor.
   PORTD = 0;         // PORTD'nin ilk durumu s�f�rlan�yor.
   TRISB = 0xFF;      // PORTB'nin pinlerinin t�m� giri� yap�ld�.
   TRISC = 0;         // PORTC'nin pinlerinin t�m� ��k�� yap�ld�.
   TRISE = 0;         // PORTE ��k�� yap�l�yor, ayn� zamanda PORTD 
                      // normal I/O moduna al�n�yor.
   TRISD = 0x0F;      // RD0-RD3 ton giri�i i�in giri�e 
                      // y�nlendirildi.

   // Komparat�r mod�l� kuruluyor.
   CMCON.CM2 = 1;
   CMCON.CM1 = 0;
   CMCON.CM0 = 1;     // Ba��ms�z tek kar��la�t�r�c� modu se�ildi 
                      // (komparat�r 2 etkin).
   CMCON.C2INV = 1;   // C2Vin+ < C2Vin- ise kar��la�t�r�c� ��k��� 1 
                      // olacak.
                      // C2Vin+'ya (RA2/AN2/Vref) pot ba�l� ring 
                      // alg�lama referans gerilimi i�in.
                      // C2Vin-'ye (RA1/AN1) hat devresinden giri� i�in

   // Timer 1 zamanlay�c�s� kuruluyor.
   T1CON.T1CKPS1 = 1;
   T1CON.T1CKPS0 = 1; // Timer 1 mod�l� 1/8 prescaler de�ere 
                      // ayarlan�yor.
   T1CON.T1OSCEN = 1; // Timer 1 i�in OSC pasif hale getiriliyor.
   T1CON.TMR1CS = 0;  // ��sel saat darbeleri ile artmas� se�iliyor. 
                      // (Zamanlay�c� modu)
   TMR1H = 0x3C;      // Timer 1'e ilk de�er atamas� yap�l�yor. 
                      // (TMR1 = 15535)
   TMR1L = 0xAF;
   T1CON.TMR1ON = ON; // Timer 1 zamanlay�c�s� �al��maya ba�lad�.

   // Kar��la�t�r�c� 1'i ayarla.
   RingCount = 0;
   HatKontrol = 0;
   HatKontrol.HatAcmaIzni = ON;   // Hat a�ma izni verildi.
   
   PIE1.CMIE = ON;    // Komparator kesmesi etkinle�tirildi.
   PIE1.TMR1IE = ON;  // Timer 1 kesmesi etkinle�tirildi.
   INTCON.RBIE = ON;  // PORTB'nin RB4-RB7 pinlerinin de�i�imlerinde 
                      // kesme olu�mas� etkinle�tirildi.
   INTCON.INTE = ON;  // PORTB'nin RB0 kesme pini etkinle�tirildi
   INTCON.PEIE = ON;  // PIE �evresel kesmeler etkinle�tirildi.
   INTCON.GIE = ON;   // Etkinle�tirilen kesmelere izin verildi.
}
//------------------------------------------------------------------
// Ana program
//------------------------------------------------------------------
void main()
{
   init();            // Program� kullan�ma haz�rla
   do
   {
        // Bo� d�ng�
   } while(1);
}
// *****************************************************************

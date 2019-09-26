// *****************************************************************
// Dosya Ad�		: 14_7.c
// A��klama		: DS1990(i-button) uygulamas�
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 20MHz
// *****************************************************************
// Kar��la�t�rma i�in kullan�lacak seri no
unsigned char s1, s2, s3, s4, s5, s6, s7, s8; 
// DS1990A'dan okunacak veriyi tutacak de�i�kenler    
unsigned char r1, r2, r3, r4, r5, r6, r7, r8;     
unsigned char kontrol;    // Kontrol = 1 ise iButton bulunamam��t�r.


void main() {

  PORTB = 0;      		// PORTB'nin ilk durumu s�f�rland�.
  TRISB = 0;             	// PORTB ��k�� yap�ld�.
  PORTC = 0;
  TRISC = 0x01;       	// RC0 giri�, di�er pinler ��k�� yap�ld�.
  s1 = 0x01; s2 = 0x23; s3 = 0x45; s4 = 0x67;
  s5 = 0x89; s6 = 0xAB; s7 = 0xCD; s8 = 0xEF;
  
  do {
// �nce RC0 pinine ba�l� bir iButton olup olmad���n� kontrol 
// ediyoruz. Yoksa RB1'e ba�l� k�rm�z� LED'i yakaca��z.
      OW_Reset(&PORTC, 0);  // iButon'a Reset sinyali uygulan�yor.
      OW_Write(&PORTC, 0, 0x0F); // iButon'a okuma komutu veriliyor.
      Delay_us(120);             // 120 us bekle
      r1 = OW_Read(&PORTC, 0);   // S�ras� ile 8 byte veri okunuyor
      r2 = OW_Read(&PORTC, 0);   
      r3 = OW_Read(&PORTC, 0);   
      r4 = OW_Read(&PORTC, 0);   
      r5 = OW_Read(&PORTC, 0);   
      r6 = OW_Read(&PORTC, 0);   
      r7 = OW_Read(&PORTC, 0);   
      r8 = OW_Read(&PORTC, 0);   
// E�er iButon yok ise r1-r8 0xFF olacakt�r. Bu durumda iButon'un 
// ba�l� olup olmad���n� kolayca test edebiliriz.
      kontrol = r1 & r2 & r3 & r4 & r5 & r6 & r7 & r8;
// E�er iButon yoksa RB1'e ba�l� LED'i yak
      if (kontrol == 0xFF) PORTB.F1 = 1;    
      else
      {
// E�er iButon varsa RB1'e ba�l� k�rm�z� renkli LED'i s�nd�r
        PORTB.F1 = 0;
// Seri numaras�n�n ilk d�rt de�erini elimizdeki veri ile kontrol 
// ederek do�ru anahtar olup olmad���n� kontrol et. E�er do�ru 
// anahtar ise RB0'a ba�l� sar� LED'i yak. Do�ru anahtar de�il ise 
// RB0'a ba�l� sar� renkli LED s�n�k kals�n. 
  if((s2==r2) && (s3==r3) && (s4==r4) && (s5==r5))
                                  PORTB.F0 = 1; else PORTB.F0 = 0;
      }
      Delay_ms(500);
    } while(1); // Sistem kapat�lana kadar ayn� kontrolleri tekrarla
}
// *****************************************************************

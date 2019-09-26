// *****************************************************************
// Dosya Adý		: 14_7.c
// Açýklama		: DS1990(i-button) uygulamasý
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 20MHz
// *****************************************************************
// Karþýlaþtýrma için kullanýlacak seri no
unsigned char s1, s2, s3, s4, s5, s6, s7, s8; 
// DS1990A'dan okunacak veriyi tutacak deðiþkenler    
unsigned char r1, r2, r3, r4, r5, r6, r7, r8;     
unsigned char kontrol;    // Kontrol = 1 ise iButton bulunamamýþtýr.


void main() {

  PORTB = 0;      		// PORTB'nin ilk durumu sýfýrlandý.
  TRISB = 0;             	// PORTB çýkýþ yapýldý.
  PORTC = 0;
  TRISC = 0x01;       	// RC0 giriþ, diðer pinler çýkýþ yapýldý.
  s1 = 0x01; s2 = 0x23; s3 = 0x45; s4 = 0x67;
  s5 = 0x89; s6 = 0xAB; s7 = 0xCD; s8 = 0xEF;
  
  do {
// Önce RC0 pinine baðlý bir iButton olup olmadýðýný kontrol 
// ediyoruz. Yoksa RB1'e baðlý kýrmýzý LED'i yakacaðýz.
      OW_Reset(&PORTC, 0);  // iButon'a Reset sinyali uygulanýyor.
      OW_Write(&PORTC, 0, 0x0F); // iButon'a okuma komutu veriliyor.
      Delay_us(120);             // 120 us bekle
      r1 = OW_Read(&PORTC, 0);   // Sýrasý ile 8 byte veri okunuyor
      r2 = OW_Read(&PORTC, 0);   
      r3 = OW_Read(&PORTC, 0);   
      r4 = OW_Read(&PORTC, 0);   
      r5 = OW_Read(&PORTC, 0);   
      r6 = OW_Read(&PORTC, 0);   
      r7 = OW_Read(&PORTC, 0);   
      r8 = OW_Read(&PORTC, 0);   
// Eðer iButon yok ise r1-r8 0xFF olacaktýr. Bu durumda iButon'un 
// baðlý olup olmadýðýný kolayca test edebiliriz.
      kontrol = r1 & r2 & r3 & r4 & r5 & r6 & r7 & r8;
// Eðer iButon yoksa RB1'e baðlý LED'i yak
      if (kontrol == 0xFF) PORTB.F1 = 1;    
      else
      {
// Eðer iButon varsa RB1'e baðlý kýrmýzý renkli LED'i söndür
        PORTB.F1 = 0;
// Seri numarasýnýn ilk dört deðerini elimizdeki veri ile kontrol 
// ederek doðru anahtar olup olmadýðýný kontrol et. Eðer doðru 
// anahtar ise RB0'a baðlý sarý LED'i yak. Doðru anahtar deðil ise 
// RB0'a baðlý sarý renkli LED sönük kalsýn. 
  if((s2==r2) && (s3==r3) && (s4==r4) && (s5==r5))
                                  PORTB.F0 = 1; else PORTB.F0 = 0;
      }
      Delay_ms(500);
    } while(1); // Sistem kapatýlana kadar ayný kontrolleri tekrarla
}
// *****************************************************************

// *****************************************************************
// Dosya Ad�		: 13_3.c
// A��klama		: L297 ve L298 ile step motor kontrol� 
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
// Step motor ba�lant� tan�mlamalar�.
#define stepMotor          PORTB   	// Step motor kontrol u�lar�n�n 
// ba�land��� port.
#define stepMotorTris      TRISB   // Step motorun ba�l� oldu�u 
// portun y�nlendirme kaydedicisi
#define enable             F0      // L297 step motor s�r�c�s�n� 
// etkinle�tiren pin tan�m�.
#define reset              F1      // L297'nin reset ucunun ba�l� 
// oldu�u pin tan�m�.
#define halffull           F2      // Bu pin 1 ise half modda,
// 0 ise full modda.
#define direction          F3      // Y�n kontrol pini, 1 ise saat
// y�n�nde (ileri), 0 ise geri.
#define clock              F4      // L297 i�in saat darbesi �reten 
// pin tan�m�.
#define home               F5      // Bu pin step motorun her tam 
// d�n���nde i�lemciye saat 
// darbesi �retir.
#define control            F6      // Kontrol pini tan�m�.

// Step motoru half moda al�r (45 derecelik a��lar ile d�n�� modu).
void half_mode()
{
     stepMotor.halffull = 1;	//L297'yi yar�m ad�m moduna al�r.
}
// Step motoru full moda al�r (90 derecelik a��lar ile d�n�� modu).
void full_mode()
{
     stepMotor.halffull = 0;	// L297'yi tam ad�m moduna al�r.
}
// Step motoru istenilen ad�m kadar saat ibresi y�n�nde d�nd�r�r.
void ileri(unsigned int adim)
{
     stepMotor.reset = 1; 	// L297'yi resetle.
     stepMotor.enable = 1; 	// L297'yi etkinle�tir.
     stepMotor.direction = 1; 	// Y�n saat ibrelerinin y�n�nde
     do                       	// do - while d�ng�s� a��l�yor.
     {
          stepMotor.clock = 1;	// Y�kselen darbe kenar�.
          asm nop
          stepMotor.clock = 0; 	// �nen darbe kenar� ile L297 
	// tetikleniyor.
          delay_ms(50); 	// 50ms bekle.
     }while(--adim);
}
// Step motoru istenilen ad�m kadar saat ibresinin tersi y�n�nde 
// d�nd�r�r.
void geri(unsigned int adim)
{
     stepMotor.reset = 1;	// L297'yi resetle.
     stepMotor.enable = 1; 	// L297'yi etkinle�tir.
     stepMotor.direction = 0;	// saat ibresinin tersi y�n�nde
     do                     	// do - while d�ng�s� a��l�yor.
     {
          stepMotor.clock = 1; 	// Y�kselen darbe kenar�.
          asm nop
          stepMotor.clock = 0;	// �nen darbe kenar� ile L297 
	// tetikleniyor.
          delay_ms(50);  	// Step motor yeni konumu almas� 
	// i�in k�sa bir s�re bekle.
                            	// Bu s�re step motorun tepki 
	// s�resinden b�y�k olmal�d�r.
                  	// �rne�imizde 50 ms se�ilmi�tir.
     }while(--adim);
}
// L297'yi resetler.
void resetle()
{
     stepMotor.reset = 0; 	// L297 resetlendi.
     stepMotor.enable = 0; 	// L297 pasif yap�ld�.
     delay_ms(1000);
}
// Ana program ilk i�lemler alt program� port y�nlendirir.
void init()
{
     stepMotor = 0;       	// ilk ��k��lar s�f�r.
     stepMotorTris.enable = 0;	// enable pini ��k�� yap�ld�.
     stepMotorTris.reset = 0;  	// enable pini ��k�� yap�ld�.
     stepMotorTris.halffull = 0; 	// half/full pini ��k�� yap�ld�.
     stepMotorTris.direction = 0; 	// direction pini ��k�� yap�ld�.
     stepMotorTris.clock = 0; 	// clock pini ��k�� yap�ld�.
     stepMotorTris.home = 1;  	// home pini giri� yap�ld�.
     stepMotorTris.control = 0;  	// control pini ��k�� yap�ld�.
     resetle();           	// L297'yi resetle
}
// Ana program: Step motoru half ve full modlarda ileri ve geri 
// y�nlerde aralar�nda 1 sn bekleyerek d�nd�r�r ve ayn� i�lemleri 
// sistem resetlenene ya da kapat�lana kadar devam ettirir.
void main()
{
     init();                	// �lk i�lemler yap�l�yor.
     while(1)               	// Sonsuz d�ng� a��l�yor.
     {                      	// while blo�u ba�lang�c�.
         half_mode();       	// Half modda �al��t�r�lacak.
         ileri(50);         	// 50 ad�m saat ibresi y�n�nde.
         delay_ms(1000);    	// 1 sn bekle.
         geri(100);         		// 100 ad�m saat ibresinin tersi 
		// y�n�nde d�n.
         delay_ms(1000);
         full_mode();       	// Full modda �al��t�r�lacak.
         ileri(100);        	// 100 ad�m saat ibresi y�n�nde. 
         delay_ms(1000);
         geri(50);          	// 50 ad�m saat ibresinin tersi. 
         delay_ms(1000);
     }                      	// while blo�u sonu.
}
// *****************************************************************

// *****************************************************************
// Dosya Adý		: 13_3.c
// Açýklama		: L297 ve L298 ile step motor kontrolü 
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
// Step motor baðlantý tanýmlamalarý.
#define stepMotor          PORTB   	// Step motor kontrol uçlarýnýn 
// baðlandýðý port.
#define stepMotorTris      TRISB   // Step motorun baðlý olduðu 
// portun yönlendirme kaydedicisi
#define enable             F0      // L297 step motor sürücüsünü 
// etkinleþtiren pin tanýmý.
#define reset              F1      // L297'nin reset ucunun baðlý 
// olduðu pin tanýmý.
#define halffull           F2      // Bu pin 1 ise half modda,
// 0 ise full modda.
#define direction          F3      // Yön kontrol pini, 1 ise saat
// yönünde (ileri), 0 ise geri.
#define clock              F4      // L297 için saat darbesi üreten 
// pin tanýmý.
#define home               F5      // Bu pin step motorun her tam 
// dönüþünde iþlemciye saat 
// darbesi üretir.
#define control            F6      // Kontrol pini tanýmý.

// Step motoru half moda alýr (45 derecelik açýlar ile dönüþ modu).
void half_mode()
{
     stepMotor.halffull = 1;	//L297'yi yarým adým moduna alýr.
}
// Step motoru full moda alýr (90 derecelik açýlar ile dönüþ modu).
void full_mode()
{
     stepMotor.halffull = 0;	// L297'yi tam adým moduna alýr.
}
// Step motoru istenilen adým kadar saat ibresi yönünde döndürür.
void ileri(unsigned int adim)
{
     stepMotor.reset = 1; 	// L297'yi resetle.
     stepMotor.enable = 1; 	// L297'yi etkinleþtir.
     stepMotor.direction = 1; 	// Yön saat ibrelerinin yönünde
     do                       	// do - while döngüsü açýlýyor.
     {
          stepMotor.clock = 1;	// Yükselen darbe kenarý.
          asm nop
          stepMotor.clock = 0; 	// Ýnen darbe kenarý ile L297 
	// tetikleniyor.
          delay_ms(50); 	// 50ms bekle.
     }while(--adim);
}
// Step motoru istenilen adým kadar saat ibresinin tersi yönünde 
// döndürür.
void geri(unsigned int adim)
{
     stepMotor.reset = 1;	// L297'yi resetle.
     stepMotor.enable = 1; 	// L297'yi etkinleþtir.
     stepMotor.direction = 0;	// saat ibresinin tersi yönünde
     do                     	// do - while döngüsü açýlýyor.
     {
          stepMotor.clock = 1; 	// Yükselen darbe kenarý.
          asm nop
          stepMotor.clock = 0;	// Ýnen darbe kenarý ile L297 
	// tetikleniyor.
          delay_ms(50);  	// Step motor yeni konumu almasý 
	// için kýsa bir süre bekle.
                            	// Bu süre step motorun tepki 
	// süresinden büyük olmalýdýr.
                  	// Örneðimizde 50 ms seçilmiþtir.
     }while(--adim);
}
// L297'yi resetler.
void resetle()
{
     stepMotor.reset = 0; 	// L297 resetlendi.
     stepMotor.enable = 0; 	// L297 pasif yapýldý.
     delay_ms(1000);
}
// Ana program ilk iþlemler alt programý port yönlendirir.
void init()
{
     stepMotor = 0;       	// ilk çýkýþlar sýfýr.
     stepMotorTris.enable = 0;	// enable pini çýkýþ yapýldý.
     stepMotorTris.reset = 0;  	// enable pini çýkýþ yapýldý.
     stepMotorTris.halffull = 0; 	// half/full pini çýkýþ yapýldý.
     stepMotorTris.direction = 0; 	// direction pini çýkýþ yapýldý.
     stepMotorTris.clock = 0; 	// clock pini çýkýþ yapýldý.
     stepMotorTris.home = 1;  	// home pini giriþ yapýldý.
     stepMotorTris.control = 0;  	// control pini çýkýþ yapýldý.
     resetle();           	// L297'yi resetle
}
// Ana program: Step motoru half ve full modlarda ileri ve geri 
// yönlerde aralarýnda 1 sn bekleyerek döndürür ve ayný iþlemleri 
// sistem resetlenene ya da kapatýlana kadar devam ettirir.
void main()
{
     init();                	// Ýlk iþlemler yapýlýyor.
     while(1)               	// Sonsuz döngü açýlýyor.
     {                      	// while bloðu baþlangýcý.
         half_mode();       	// Half modda çalýþtýrýlacak.
         ileri(50);         	// 50 adým saat ibresi yönünde.
         delay_ms(1000);    	// 1 sn bekle.
         geri(100);         		// 100 adým saat ibresinin tersi 
		// yönünde dön.
         delay_ms(1000);
         full_mode();       	// Full modda çalýþtýrýlacak.
         ileri(100);        	// 100 adým saat ibresi yönünde. 
         delay_ms(1000);
         geri(50);          	// 50 adým saat ibresinin tersi. 
         delay_ms(1000);
     }                      	// while bloðu sonu.
}
// *****************************************************************

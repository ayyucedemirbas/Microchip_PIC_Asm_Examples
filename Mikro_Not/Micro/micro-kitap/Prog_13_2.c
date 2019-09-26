// *****************************************************************
// Dosya Adý		: 13_2.c
// Açýklama		: Step motor kontrolü (ULN2003 ile)
// Notlar		: Proteus programý simülasyonu
//			: XT ==> 4 MHz
// *****************************************************************
#define stepMotor       PORTB   	// ULN2003 için baðlantý portu.
#define stepMotortris   TRISB   	// ULN2003 için baðlantý portu 
// yönlendirme kaydedicisi.
#define tamileri        F4      	// tam ileri buton tanýmý, 4. pin.
#define tamgeri         F5      	// tam geri buton tanýmý, 5. pin.
#define yarimileri      F6      	// yarim ileri buton tanýmý, 6. pin
#define yarimgeri       F7      	// yarim geri için buton tanýmý.

// 1 byte'lýk deðiþken tanýmlamalarý.
char pos, tmp; 
// Saat ibresi yönündeki yarým adým deðerleri. 	
char yarimadimileri[8] = {0x03, 0x02, 0x06, 0x04, 0x0C, 0x08, 0x09, 0x01}; 		
// Saat ibresi tersi yönündeki yarým adým deðerleri.
char yarimadimgeri[8] = {0x01, 0x09, 0x08, 0x0C, 0x04, 0x06, 0x02, 0x03}; 
// Saat ibresi yönündeki tam adým deðerleri.
char tamadimileri[4] = {0x06, 0x0C, 0x09, 0x03};   
// Saat ibresi tersi yönündeki tam adým deðerleri.
char tamadimgeri[4] = {0x03, 0x09, 0x0C, 0x06};    

void ileri(char mod)
{
// mod = 1 ise tam adým, mod = 0 ise yarim adým çalýþma.
     if(mod)  	
     {
// pozisyon sonda deðilse pozisyonu artýr, pozisyon sonda ise 
// pozisyonu baþa al.
          if(pos<3) pos++; else pos = 0; 
//pozisyona ait tam adým degerini diziden oku. 
          tmp = tamadimileri[pos]; 
//ve step motor portunun en deðersiz 4 bit’ine aktar.      
          stepMotor = (stepMotor & 0xF0) + tmp;  
     } else
     {
// pozisyon sonda deðilse pozisyonu artýr, pozisyon sonda ise 
// pozisyonu baþa al.
          if(pos<7) pos++; else pos = 0;  
// pozisyona ait yarim adým degerini diziden oku.
          tmp = yarimadimileri[pos];    
// ve step motor portunun en deðersiz 4 bit’ine aktar.  
          stepMotor = (stepMotor & 0xF0) + tmp;
     }
// adýmlarýn test sýrasýnda izlenebilmesi için yarým saniye bekle.
     delay_ms(500);   
}

void geri(char mod)
{
     if(mod)        
     {
          if(pos<3) pos++; else pos = 0;  
          tmp = tamadimgeri[pos];         
          stepMotor = (stepMotor & 0xF0) + tmp;  
     } else
     {
          if(pos<7) pos++; else pos = 0;  
          tmp = yarimadimgeri[pos]; 
          stepMotor = (stepMotor & 0xF0) + tmp;  
     }
     delay_ms(500);   
}

void init()
{
     stepMotor = 0;
     stepMotortris = 0;
     stepMotortris.yarimileri = 1;
     stepMotortris.yarimgeri = 1;  
     stepMotortris.tamileri = 1;   
     stepMotortris.tamgeri = 1;    
     pos = 0x07;      // Step motora ilk pozisyon deðeri veriliyor.
     ileri(0);        // Step motor 0. pozisyona alýnýyor.
}

void main()
{
     init();          // Ýlk iþlemler alt programý çaðrýlýyor.
     while(1)         // sonsuz çevrim bloðu açýlýyor.
     {
          if(!stepMotor.yarimileri) ileri(0);
          if(!stepMotor.yarimgeri) geri(0);   
          if(!stepMotor.tamileri) ileri(1);   
          if(!stepMotor.tamgeri) geri(1);     
     }
}
// *****************************************************************

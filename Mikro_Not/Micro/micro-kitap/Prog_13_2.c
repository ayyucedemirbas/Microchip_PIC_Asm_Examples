// *****************************************************************
// Dosya Ad�		: 13_2.c
// A��klama		: Step motor kontrol� (ULN2003 ile)
// Notlar		: Proteus program� sim�lasyonu
//			: XT ==> 4 MHz
// *****************************************************************
#define stepMotor       PORTB   	// ULN2003 i�in ba�lant� portu.
#define stepMotortris   TRISB   	// ULN2003 i�in ba�lant� portu 
// y�nlendirme kaydedicisi.
#define tamileri        F4      	// tam ileri buton tan�m�, 4. pin.
#define tamgeri         F5      	// tam geri buton tan�m�, 5. pin.
#define yarimileri      F6      	// yarim ileri buton tan�m�, 6. pin
#define yarimgeri       F7      	// yarim geri i�in buton tan�m�.

// 1 byte'l�k de�i�ken tan�mlamalar�.
char pos, tmp; 
// Saat ibresi y�n�ndeki yar�m ad�m de�erleri. 	
char yarimadimileri[8] = {0x03, 0x02, 0x06, 0x04, 0x0C, 0x08, 0x09, 0x01}; 		
// Saat ibresi tersi y�n�ndeki yar�m ad�m de�erleri.
char yarimadimgeri[8] = {0x01, 0x09, 0x08, 0x0C, 0x04, 0x06, 0x02, 0x03}; 
// Saat ibresi y�n�ndeki tam ad�m de�erleri.
char tamadimileri[4] = {0x06, 0x0C, 0x09, 0x03};   
// Saat ibresi tersi y�n�ndeki tam ad�m de�erleri.
char tamadimgeri[4] = {0x03, 0x09, 0x0C, 0x06};    

void ileri(char mod)
{
// mod = 1 ise tam ad�m, mod = 0 ise yarim ad�m �al��ma.
     if(mod)  	
     {
// pozisyon sonda de�ilse pozisyonu art�r, pozisyon sonda ise 
// pozisyonu ba�a al.
          if(pos<3) pos++; else pos = 0; 
//pozisyona ait tam ad�m degerini diziden oku. 
          tmp = tamadimileri[pos]; 
//ve step motor portunun en de�ersiz 4 bit�ine aktar.      
          stepMotor = (stepMotor & 0xF0) + tmp;  
     } else
     {
// pozisyon sonda de�ilse pozisyonu art�r, pozisyon sonda ise 
// pozisyonu ba�a al.
          if(pos<7) pos++; else pos = 0;  
// pozisyona ait yarim ad�m degerini diziden oku.
          tmp = yarimadimileri[pos];    
// ve step motor portunun en de�ersiz 4 bit�ine aktar.  
          stepMotor = (stepMotor & 0xF0) + tmp;
     }
// ad�mlar�n test s�ras�nda izlenebilmesi i�in yar�m saniye bekle.
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
     pos = 0x07;      // Step motora ilk pozisyon de�eri veriliyor.
     ileri(0);        // Step motor 0. pozisyona al�n�yor.
}

void main()
{
     init();          // �lk i�lemler alt program� �a�r�l�yor.
     while(1)         // sonsuz �evrim blo�u a��l�yor.
     {
          if(!stepMotor.yarimileri) ileri(0);
          if(!stepMotor.yarimgeri) geri(0);   
          if(!stepMotor.tamileri) ileri(1);   
          if(!stepMotor.tamgeri) geri(1);     
     }
}
// *****************************************************************

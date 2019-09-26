#include <pic.h>
#include <delay.c>

main(void)
{
//De�i�ken tan�mlamalar�
unsigned int i;
unsigned const char araba[]={
0x60,0x70,0x70,0xf0,0xf8,0x74,0x72,0x7e,
0x72,0x72,0x72,0x7e,0xF2,0xf4,0x78,0x30};

//port ayarlama i�lemleri
TRISB=0; // PortB'nin hepsi ��k��
TRISA=0; // PortA'nin hepsi ��k��
CMCON=0x07; // PORTA say�sal giri�/��k��
PORTB=0x00; // Ba�lang��ta LED'ler s�n�k

//16 adet sat�r verisini s�rayla PORT'a g�nder
for(;;){
	for(i=0;i<=15;i++){
	PORTB=araba[i]; // Verileri PortB'ye g�nder
	PORTA=i; // ilgili s�tunu se�
	DelayMs(1); // 1ms bekle
}} 
}// Program sonu


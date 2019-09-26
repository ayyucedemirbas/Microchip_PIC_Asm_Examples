#include <pic.h>
#include <delay.c>

main(void)
{
//De�i�ken tan�mlamalar�
unsigned int i;
unsigned const char oklar[]={
0x08,0x0c,0xfe,0xff,0xfe,0x0c,0x08,0x00,
0x00,0x10,0x30,0x7f,0xFF,0x7f,0x30,0x10};

//port ayarlama i�lemleri
TRISB=0; // PortB'nin hepsi ��k��
TRISA=0; // PortA'nin hepsi ��k��
CMCON=0x07; // PORTA say�sal giri�/��k��
PORTB=0x00; // Ba�lang��ta LED'ler s�n�k

//16 adet sat�r verisini s�rayla PORT'a g�nder
for(;;){
	for(i=0;i<=15;i++){
	PORTB=oklar[i]; // Verileri PortB'ye g�nder
	PORTA=i; // ilgili s�tunu se�
	DelayMs(1); // 1ms bekle
}} 
}// Program sonu


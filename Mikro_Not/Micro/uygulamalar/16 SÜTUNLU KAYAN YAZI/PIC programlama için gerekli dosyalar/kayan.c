#include <pic.h>
#include <delay.c>
main(void)
{
unsigned char gecici_dizi[16];
unsigned char i,a,toplam_sutun;
signed int kayma,deger;
unsigned const char metin[]={
0xFF,0x89,0x89,0x89,0x76,0x00, // B
0x84,0xFD,0x84,0x00, 	       // �
0xFF,0x80,0x80,0x80,0x80,0x00, // L
0x84,0xFD,0x84,0x00, 	       // �
0xFF,0x02,0x0C,0x02,0xFF,0x00, // M
0x00,0x00,0x00,0x00, 	       // Bosluk
0x38,0x40,0x80,0x40,0x38,0x00, // v
0x70,0xA8,0xA8,0xA8,0xB0,0x00, // e
0x00,0x00,0x00,0x00,	       // Bosluk
0x01,0x01,0xFF,0x01,0x01,0x00, // T
0xFF,0x89,0x89,0x89,0x81,0x00, // E
0xFF,0x18,0x24,0x42,0x81,0x00, // K
0xFF,0x04,0x08,0x10,0xFF,0x00, // N
0x84,0xFD,0x84,0x00, 	       // �
0xFF,0x18,0x24,0x42,0x81,0x00};// K

//Metindeki s�tunlar�n say�s�n� hesapla
toplam_sutun=80; //10x6+5x4=60+20=80

//Port ayarlama i�lemleri
TRISB=0; 
TRISA=0; 
CMCON=0x07; 
PORTB=0x00; 

for(;;){//Ana d�ng�
//Ge�ici diziyi s�f�rla
for(i=0;i<=15;i++){
gecici_dizi[i]=0; //Dizi elemanlar� ba�lang��ta 0
}

//Kayd�rma i�lemleri	
for(kayma=-14;kayma<=toplam_sutun;kayma++){ 

//Metni 16 s�tunluk par�alara b�l
for(i=0;i<=15;i++){
deger=i+kayma;
if(deger<0)gecici_dizi[i]=0; //metin giri�i
if(deger>=0&&deger<=toplam_sutun-1)
gecici_dizi[i]=metin[deger]; 
if(deger>toplam_sutun)gecici_dizi[i]=0; //metin ��k���
}

//Tarama i�lemleri
for(a=0;a<40;a++){ //Ayn� g�r�nt�y� 40 kez tekrarla
for(i=0;i<=15;i++){ //Ge�ici diziyi g�r�nt�le
PORTB=gecici_dizi[i]; // Veriyi PortB'ye g�nder
PORTA=i; // ilgili s�tun'u se�
DelayUs(200); // 200 mikrosaniye bekle
}}}

}// i�lemleri tekrarla
}// Program sonu


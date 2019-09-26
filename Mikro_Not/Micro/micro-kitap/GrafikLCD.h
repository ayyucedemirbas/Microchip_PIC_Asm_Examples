// *****************************************************************
// Dosya Adý		: GrafikLCD.h
// Açýklama		: GrafikLCD.c dosyasý için tanýmlama dosyasý
// Notlar		: XT ==> 4 MHz
// *****************************************************************
// LCD Parametreleri
#define LCD_TEXT_WIDTH  0x14    	// Text geniþliði = Grafik 
// geniþliði-Karakter geniþliði.
#define LCD_TEXT_HEIGHT 	0x08	// Text yüksekliði = Grafik 
// yüksekliði / Karakter yüksekliði
#define LCD_GRAPHICS_WIDTH 0xA0	// Width of display (0xA0 = 160 
// pixels).
#define LCD_GRAPHICS_HEIGHT 0x80	// Height of display (0x80 = 128 
// pixels).
#define LCD_NUMBER_OF_SCREENS   0x02 	// Ekran sayýsý.
#define LCD_CHARACTER_WIDTH     0x08 	// Karakter geniþliði 8x8 
// veya 6x8

// Bellek haritasý tanýmý
#define LCD_GRAPHICS_HOME   0x0000  	// Genellikle RAM baþlangýç 
// adresi burasýdýr.
#define LCD_GRAPHICS_AREA   0x14    	// Bir grafik karakter alaný 
// 8 bit geniþliðinde olup 
// 8x8=64 pikselden oluþur.
#define LCD_GRAPHICS_SIZE   0x0800  // Grafik RAM bellek büyüklüðü.
#define LCD_TEXT_HOME       0x0A00  // Text alanýnýn baþlangýç 
   // adresi.
#define LCD_TEXT_AREA       0x14    // Text satýrý 20 karakter 
   // geniþliðindedir.
#define LCD_TEXT_SIZE       0x0200  // Text RAM bellek büyüklüðü.

//  160x128 piksel display için bellek haritasý:
//
//  Ekran1
//  0x0000  -----------------------------
//          | Grafik RAM bellek alaný   |
//          | 0x0000 - 0x07FF           |
//          | (256x64 piksel)           |
//  0x0800  -----------------------------
//          | Text özellik bellek alaný |
//  0x0A00  -----------------------------
//          | Text RAM bellek alaný     |
//          | 512 Byte                  |
//          | (256x64 piksel)           |
//  0x0C00  -----------------------------

//  Ekran 2 (Ekran 1'den sonra otomatik geçilir.)
//  0x8000  -----------------------------
//          | Grafik RAM bellek alaný   |
//          | 0x0000 - 0x07FF           |
//          | (256x64 piksel)           |
//  0x8800  -----------------------------
//          | Text özellik bellek alaný |
//  0x8A00  -----------------------------
//          | Text RAM bellek alaný     |
//          | 512 Bytes                 |
//          | (256x64 piksel)           |
//  0x8C00  -----------------------------

// LCD veri pinlerinin baðlandýðý port tanýmý:
#define LCD_DATA_BUS        PORTB
#define LCD_DATA_BUS_TRIS   TRISB

// LCD Kontrol pinleri:
#define LCD_CONTROL         PORTC
#define LCD_CONTROL_TRIS    TRISC
#define LCD_WR_BIT          F0
#define LCD_RD_BIT          F1
#define LCD_CE_BIT          F2
#define LCD_CD_BIT          F3
#define LCD_RST_BIT         F4

#define LCD_WR              0x01
#define LCD_RD              0x02
#define LCD_CE              0x04
#define LCD_CD              0x08
#define LCD_RST             0x10

// T6963C LCD kontrol komutlarý:
#define LCD_CURSOR_POINTER_SET          0b00100001
#define LCD_OFFSET_REGISTER_SET         0b00100010
#define LCD_ADDRESS_POINTER_SET         0b00100100

#define LCD_TEXT_HOME_ADDRESS_SET       0b01000000
#define LCD_TEXT_AREA_SET               0b01000001
#define LCD_GRAPHIC_HOME_ADDRESS_SET    0b01000010
#define LCD_GRAPHIC_AREA_SET            0b01000011

#define LCD_CG_ROM_MODE_OR              0b10000000
#define LCD_CG_ROM_MODE_EXOR            0b10000001
#define LCD_CG_ROM_MODE_AND             0b10000011
#define LCD_CG_ROM_MODE_TEXT            0b10000100
#define LCD_CG_RAM_MODE_OR              0b10001000
#define LCD_CG_RAM_MODE_EXOR            0b10001001
#define LCD_CG_RAM_MODE_AND             0b10001011
#define LCD_CG_RAM_MODE_TEXT            0b10001100

// Display mod tanýmlamalarý:
#define LCD_DISPLAY_MODES_ALL_OFF       0b10010000
#define LCD_DISPLAY_MODES_GRAPHICS_ON   0b10011000
#define LCD_DISPLAY_MODES_TEXT_ON       0b10010100
#define LCD_DISPLAY_MODES_CURSOR_ON     0b10010010
#define LCD_DISPLAY_MODES_CURSOR_BLINK  0b10010001

// Ýmleç þekli seçme deðerleri:
#define LCD_CURSOR_PATTERN_UNDERLINE    0b10100000
#define LCD_CURSOR_PATTERN_BLOCK        0b10100111

// Otomatik oku, yaz ve reset komutlarý:
#define LCD_DATA_AUTO_WRITE_SET         0b10110000
#define LCD_DATA_AUTO_READ_SET          0b10110001
#define LCD_DATA_AUTO_RESET             0b10110010

// Bir byte okuma ve yazma iþleminden sonra konum ile ilgili 
// komutlar:
#define LCD_DATA_WRITE_AUTO_INCREMENT   0b11000000
#define LCD_DATA_READ_AUTO_INCREMENT    0b11000001
#define LCD_DATA_WRITE_NO_INCREMENT     0b11000100
#define LCD_DATA_READ_NO_INCREMENT      0b11000101

// LCD Durum kaydedicisinin (Status Register) bit’leri:
#define LCD_STATUS_BUSY1    0x01
#define LCD_STATUS_BUSY2    0x02
#define LCD_STATUS_DARRDY   0x04
#define LCD_STATUS_DAWRDY   0x08

#define LCD_STATUS_CLR      0x20
#define LCD_STATUS_ERR      0x40
#define LCD_STATUS_BLINK    0x80

// Giriþ/Çýkýþ için yönlendirme tanýmlamalarý:
#define ALL_INPUTS  0xFF
#define ALL_OUTPUTS 0x00

// Fonksiyon tanýmlamalarý:
void interrupt(void);
void grafikLCD_init(void);
void lcd_write_data(unsigned char data);
unsigned char lcd_read_data(void);
void lcd_write_command(unsigned char data);
unsigned char lcd_read_status(void);
void lcd_clear_graphics(void);
void lcd_clear_text(void);
void lcd_write_char(unsigned char character, unsigned char x, unsigned char y);
void lcd_write_text(unsigned char *str, unsigned char x, unsigned char y);
void lcd_set_pixel(unsigned char x, unsigned char y);
void lcd_clear_pixel(unsigned char x, unsigned char y);
unsigned char lcd_bit_to_byte(unsigned char bit);
// *****************************************************************

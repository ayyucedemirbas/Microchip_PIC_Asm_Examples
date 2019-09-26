
; PicBasic Pro Compiler 2.46, (c) 1998, 2005 microEngineering Labs, Inc. All Rights Reserved.  
_USED			EQU	1

	INCLUDE	"C:\PROGRA~1\MECANI~1\MCSP\PBP\18F452.INC"


; Define statements.
#define		OSC		 20

RAM_START       		EQU	00000h
RAM_END         		EQU	005FFh
RAM_BANKS       		EQU	00006h
BANK0_START     		EQU	00080h
BANK0_END       		EQU	000FFh
BANK1_START     		EQU	00100h
BANK1_END       		EQU	001FFh
BANK2_START     		EQU	00200h
BANK2_END       		EQU	002FFh
BANK3_START     		EQU	00300h
BANK3_END       		EQU	003FFh
BANK4_START     		EQU	00400h
BANK4_END       		EQU	004FFh
BANK5_START     		EQU	00500h
BANK5_END       		EQU	005FFh
BANKA_START     		EQU	00000h
BANKA_END       		EQU	0007Fh

R0              		EQU	RAM_START + 000h
R1              		EQU	RAM_START + 002h
R2              		EQU	RAM_START + 004h
R3              		EQU	RAM_START + 006h
R4              		EQU	RAM_START + 008h
R5              		EQU	RAM_START + 00Ah
R6              		EQU	RAM_START + 00Ch
R7              		EQU	RAM_START + 00Eh
R8              		EQU	RAM_START + 010h
T1              		EQU	RAM_START + 012h
FLAGS           		EQU	RAM_START + 014h
GOP             		EQU	RAM_START + 015h
RM1             		EQU	RAM_START + 016h
RM2             		EQU	RAM_START + 017h
RR1             		EQU	RAM_START + 018h
RR2             		EQU	RAM_START + 019h
RS1             		EQU	RAM_START + 01Ah
RS2             		EQU	RAM_START + 01Bh
_b               		EQU	RAM_START + 01Ch
_kay_reg         		EQU	RAM_START + 01Eh
_y               		EQU	RAM_START + 020h
_z               		EQU	RAM_START + 022h
_adres_sec       		EQU	RAM_START + 024h
_byte_sayisi     		EQU	RAM_START + 025h
_harf_reg        		EQU	RAM_START + 026h
_harf_sayisi     		EQU	RAM_START + 027h
_i               		EQU	RAM_START + 028h
_lcd_reg         		EQU	RAM_START + 029h
_satir_reg       		EQU	RAM_START + 02Ah
_tekrar          		EQU	RAM_START + 02Bh
_veri            		EQU	RAM_START + 02Ch
_w               		EQU	RAM_START + 02Dh
_x               		EQU	RAM_START + 02Eh
_yazi_reg        		EQU	RAM_START + 02Fh
_yinele          		EQU	RAM_START + 030h
_sutun_reg       		EQU	RAM_START + 031h
_PORTL           		EQU	 PORTB
_PORTH           		EQU	 PORTC
_TRISL           		EQU	 TRISB
_TRISH           		EQU	 TRISC
#define _sda             	_PORTA_4
#define _scl             	_PORTA_3
#define _izin            	_PORTA_5
#define _PORTA_4         	 PORTA, 004h
#define _PORTA_3         	 PORTA, 003h
#define _PORTA_5         	 PORTA, 005h
#define _lcd_reg_7       	_lcd_reg, 007h
	INCLUDE	"8X8X10~1.MAC"
	INCLUDE	"C:\PROGRA~1\MECANI~1\MCSP\PBP\PBPPIC18.LIB"

	MOVE?CB	007h, ADCON1
	MOVE?CB	000h, TRISA
	MOVE?CB	000h, PORTA
	MOVE?CB	000h, TRISB
	MOVE?CB	000h, PORTB
	MOVE?CB	000h, TRISC
	MOVE?CB	000h, PORTC
	MOVE?CB	000h, _tekrar
	MOVE?CB	000h, _yazi_reg
	MOVE?CB	001h, _satir_reg
	MOVE?CW	000h, _kay_reg
	MOVE?CW	000h, _y

	LABEL?L	_main	
	CALL?L	_yazi
	MOVE?BB	_harf_reg, _harf_sayisi
	ADD?BCB	_yazi_reg, 001h, _yazi_reg
	MOVE?CB	001h, _i
	LABEL?L	L00003	
	CMPGT?BBL	_i, _harf_sayisi, L00004
	CALL?L	_yazi
	CALL?L	_data_sec
	MOVE?CB	000h, _x
	LABEL?L	L00005	
	CMPGT?BBL	_x, _yinele, L00006
	CALL?L	_datalar
	ADD?BCB	_adres_sec, 001h, _adres_sec
	AIN?BBW	_veri, _sutun_reg, _y
	ADD?WCW	_y, 001h, _y
	NEXT?BCL	_x, 001h, L00005
	LABEL?L	L00006	
	ADD?BCB	_yazi_reg, 001h, _yazi_reg
	NEXT?BCL	_i, 001h, L00003
	LABEL?L	L00004	
	MOVE?CB	000h, _yazi_reg
	GOTO?L	_loop

	LABEL?L	_loop	
	CALL?L	_logo
	MOVE?CW	001h, _b
	LABEL?L	L00007	
	CMPGT?WCL	_b, 003h, L00008
	CALL?L	_logo_goster
	PAUSE?C	003E8h
	NEXT?WCL	_b, 001h, L00007
	LABEL?L	L00008	
	CALL?L	_logo
	GOTO?L	_loop1

	LABEL?L	_logo_goster	
	MOVE?CW	001h, _z
	LABEL?L	L00009	
	CMPGT?WCL	_z, 00Ah, L00010
	MOVE?CB	001h, _x
	LABEL?L	L00011	
	CMPGT?BCL	_x, 00Ah, L00012
	MOVE?CB	000h, _i
	LABEL?L	L00013	
	CMPGT?BCL	_i, 00Fh, L00014
	AOUT?BWB	_sutun_reg, _y, PORTC
	MOVE?BB	_i, PORTA
	MOVE?BB	_satir_reg, PORTB
	PAUSEUS?C	032h
	MOVE?CB	000h, PORTB
	ADD?WCW	_y, 001h, _y
	NEXT?BCL	_i, 001h, L00013
	LABEL?L	L00014	
	ADD?BCB	_satir_reg, 001h, _satir_reg
	NEXT?BCL	_x, 001h, L00011
	LABEL?L	L00012	
	MOVE?CB	001h, _satir_reg
	MOVE?CB	001h, _x
	LABEL?L	L00015	
	CMPGT?BCL	_x, 00Ah, L00016
	MOVE?CB	000h, _i
	LABEL?L	L00017	
	CMPGT?BCL	_i, 00Fh, L00018
	AOUT?BWB	_sutun_reg, _y, PORTC
	MOVE?BB	_i, PORTA
	SHIFTL?BCB	_satir_reg, 004h, PORTB
	PAUSEUS?C	032h
	MOVE?CB	000h, PORTB
	ADD?WCW	_y, 001h, _y
	NEXT?BCL	_i, 001h, L00017
	LABEL?L	L00018	
	ADD?BCB	_satir_reg, 001h, _satir_reg
	NEXT?BCL	_x, 001h, L00015
	LABEL?L	L00016	
	MOVE?CW	000h, _y
	MOVE?CB	001h, _satir_reg
	NEXT?WCL	_z, 001h, L00009
	LABEL?L	L00010	
	MOVE?CB	001h, _satir_reg
	MOVE?CW	000h, _kay_reg
	RETURN?	

	LABEL?L	_loop1	
	MOVE?CW	001h, _z
	LABEL?L	L00019	
	CMPGT?WCL	_z, 00140h, L00020
	MOVE?CB	001h, _x
	LABEL?L	L00021	
	CMPGT?BCL	_x, 00Ah, L00022
	MOVE?CB	000h, _i
	LABEL?L	L00023	
	CMPGT?BCL	_i, 00Fh, L00024
	AOUT?BWB	_sutun_reg, _y, PORTC
	MOVE?BB	_i, PORTA
	MOVE?BB	_satir_reg, PORTB
	PAUSEUS?C	064h
	MOVE?CB	000h, PORTB
	ADD?WCW	_y, 001h, _y
	NEXT?BCL	_i, 001h, L00023
	LABEL?L	L00024	
	ADD?BCB	_satir_reg, 001h, _satir_reg
	NEXT?BCL	_x, 001h, L00021
	LABEL?L	L00022	
	MOVE?CB	001h, _satir_reg
	MOVE?CB	001h, _x
	LABEL?L	L00025	
	CMPGT?BCL	_x, 00Ah, L00026
	MOVE?CB	000h, _i
	LABEL?L	L00027	
	CMPGT?BCL	_i, 00Fh, L00028
	AOUT?BWB	_sutun_reg, _y, PORTC
	MOVE?BB	_i, PORTA
	SHIFTL?BCB	_satir_reg, 004h, PORTB
	PAUSEUS?C	064h
	MOVE?CB	000h, PORTB
	ADD?WCW	_y, 001h, _y
	NEXT?BCL	_i, 001h, L00027
	LABEL?L	L00028	
	ADD?BCB	_satir_reg, 001h, _satir_reg
	NEXT?BCL	_x, 001h, L00025
	LABEL?L	L00026	
	ADD?WCW	_kay_reg, 001h, _kay_reg
	MOVE?WW	_kay_reg, _y
	MOVE?CB	001h, _satir_reg
	NEXT?WCL	_z, 001h, L00019
	LABEL?L	L00020	
	MOVE?CB	001h, _satir_reg
	MOVE?CW	000h, _kay_reg
	MOVE?CW	000h, _y
	CALL?L	_logo
	GOTO?L	_loop

	LABEL?L	_logo	
	MOVE?CB	001h, _w
	LABEL?L	L00029	
	CMPGT?BCL	_w, 003h, L00030
	CALL?L	_logo_goster
	NEXT?BCL	_w, 001h, L00029
	LABEL?L	L00030	
	RETURN?	

	LABEL?L	_yazi	
	LOOKUP?BCLB	_yazi_reg, 036h, L00001, _harf_reg
	LURET?C	035h
	LURET?C	020h
	LURET?C	050h
	LURET?C	069h
	LURET?C	043h
	LURET?C	050h
	LURET?C	052h
	LURET?C	04Fh
	LURET?C	04Ah
	LURET?C	045h
	LURET?C	020h
	LURET?C	04Fh
	LURET?C	052h
	LURET?C	047h
	LURET?C	020h
	LURET?C	054h
	LURET?C	075h
	LURET?C	052h
	LURET?C	04Bh
	LURET?C	069h
	LURET?C	059h
	LURET?C	045h
	LURET?C	04Eh
	LURET?C	069h
	LURET?C	04Eh
	LURET?C	020h
	LURET?C	045h
	LURET?C	04Eh
	LURET?C	020h
	LURET?C	020h
	LURET?C	020h
	LURET?C	042h
	LURET?C	075h
	LURET?C	059h
	LURET?C	075h
	LURET?C	04Bh
	LURET?C	020h
	LURET?C	045h
	LURET?C	04Ch
	LURET?C	045h
	LURET?C	04Bh
	LURET?C	054h
	LURET?C	052h
	LURET?C	04Fh
	LURET?C	04Eh
	LURET?C	069h
	LURET?C	04Bh
	LURET?C	020h
	LURET?C	046h
	LURET?C	04Fh
	LURET?C	052h
	LURET?C	055h
	LURET?C	04Dh
	LURET?C	055h

	LABEL?L	L00001	
	RETURN?	

	LABEL?L	_data_sec	
	CMPNE?BCL	_harf_reg, 041h, L00033
	MOVE?CB	000h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00033	
	CMPNE?BCL	_harf_reg, 042h, L00034
	MOVE?CB	006h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00034	
	CMPNE?BCL	_harf_reg, 043h, L00035
	MOVE?CB	00Ch, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00035	
	CMPNE?BCL	_harf_reg, 044h, L00036
	MOVE?CB	012h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00036	
	CMPNE?BCL	_harf_reg, 045h, L00037
	MOVE?CB	018h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00037	
	CMPNE?BCL	_harf_reg, 046h, L00038
	MOVE?CB	01Eh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00038	
	CMPNE?BCL	_harf_reg, 047h, L00039
	MOVE?CB	024h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00039	
	CMPNE?BCL	_harf_reg, 048h, L00040
	MOVE?CB	02Ah, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00040	
	CMPNE?BCL	_harf_reg, 049h, L00041
	MOVE?CB	030h, _adres_sec
	MOVE?CB	003h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00041	
	CMPNE?BCL	_harf_reg, 069h, L00042
	MOVE?CB	034h, _adres_sec
	MOVE?CB	003h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00042	
	CMPNE?BCL	_harf_reg, 04Ah, L00043
	MOVE?CB	038h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00043	
	CMPNE?BCL	_harf_reg, 04Bh, L00044
	MOVE?CB	03Eh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00044	
	CMPNE?BCL	_harf_reg, 04Ch, L00045
	MOVE?CB	044h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00045	
	CMPNE?BCL	_harf_reg, 04Dh, L00046
	MOVE?CB	04Ah, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00046	
	CMPNE?BCL	_harf_reg, 04Eh, L00047
	MOVE?CB	050h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00047	
	CMPNE?BCL	_harf_reg, 04Fh, L00048
	MOVE?CB	056h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00048	
	CMPNE?BCL	_harf_reg, 050h, L00049
	MOVE?CB	05Ch, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00049	
	CMPNE?BCL	_harf_reg, 071h, L00050
	MOVE?CB	062h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00050	
	CMPNE?BCL	_harf_reg, 052h, L00051
	MOVE?CB	068h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00051	
	CMPNE?BCL	_harf_reg, 053h, L00052
	MOVE?CB	06Eh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00052	
	CMPNE?BCL	_harf_reg, 054h, L00053
	MOVE?CB	074h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00053	
	CMPNE?BCL	_harf_reg, 055h, L00054
	MOVE?CB	07Ah, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00054	
	CMPNE?BCL	_harf_reg, 075h, L00055
	MOVE?CB	080h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00055	
	CMPNE?BCL	_harf_reg, 056h, L00056
	MOVE?CB	086h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00056	
	CMPNE?BCL	_harf_reg, 057h, L00057
	MOVE?CB	08Ch, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00057	
	CMPNE?BCL	_harf_reg, 058h, L00058
	MOVE?CB	092h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00058	
	CMPNE?BCL	_harf_reg, 059h, L00059
	MOVE?CB	098h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00059	
	CMPNE?BCL	_harf_reg, 05Ah, L00060
	MOVE?CB	09Eh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00060	
	CMPNE?BCL	_harf_reg, 020h, L00061
	MOVE?CB	0A4h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00061	
	CMPNE?BCL	_harf_reg, 030h, L00062
	MOVE?CB	0AAh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00062	
	CMPNE?BCL	_harf_reg, 031h, L00063
	MOVE?CB	0B0h, _adres_sec
	MOVE?CB	003h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00063	
	CMPNE?BCL	_harf_reg, 032h, L00064
	MOVE?CB	0B4h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00064	
	CMPNE?BCL	_harf_reg, 033h, L00065
	MOVE?CB	0BAh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00065	
	CMPNE?BCL	_harf_reg, 034h, L00066
	MOVE?CB	0C0h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00066	
	CMPNE?BCL	_harf_reg, 035h, L00067
	MOVE?CB	0C6h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00067	
	CMPNE?BCL	_harf_reg, 036h, L00068
	MOVE?CB	0CCh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00068	
	CMPNE?BCL	_harf_reg, 037h, L00069
	MOVE?CB	0D2h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00069	
	CMPNE?BCL	_harf_reg, 038h, L00070
	MOVE?CB	0D8h, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	GOTO?L	L00032
	LABEL?L	L00070	
	CMPNE?BCL	_harf_reg, 039h, L00071
	MOVE?CB	0DEh, _adres_sec
	MOVE?CB	005h, _yinele
	RETURN?	
	LABEL?L	L00071	
	LABEL?L	L00032	

	LABEL?L	_datalar	
	LOOKUP?BCLB	_adres_sec, 0E4h, L00002, _veri
	LURET?C	03Fh
	LURET?C	048h
	LURET?C	048h
	LURET?C	048h
	LURET?C	03Fh
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	049h
	LURET?C	049h
	LURET?C	049h
	LURET?C	036h
	LURET?C	000h
	LURET?C	03Eh
	LURET?C	041h
	LURET?C	041h
	LURET?C	041h
	LURET?C	022h
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	041h
	LURET?C	041h
	LURET?C	041h
	LURET?C	03Eh
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	049h
	LURET?C	049h
	LURET?C	049h
	LURET?C	041h
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	048h
	LURET?C	048h
	LURET?C	048h
	LURET?C	040h
	LURET?C	000h
	LURET?C	03Eh
	LURET?C	041h
	LURET?C	049h
	LURET?C	049h
	LURET?C	02Eh
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	008h
	LURET?C	008h
	LURET?C	008h
	LURET?C	07Fh
	LURET?C	000h
	LURET?C	041h
	LURET?C	07Fh
	LURET?C	041h
	LURET?C	000h
	LURET?C	011h
	LURET?C	05Fh
	LURET?C	011h
	LURET?C	000h
	LURET?C	002h
	LURET?C	001h
	LURET?C	041h
	LURET?C	07Eh
	LURET?C	040h
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	008h
	LURET?C	014h
	LURET?C	022h
	LURET?C	041h
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	001h
	LURET?C	001h
	LURET?C	001h
	LURET?C	001h
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	020h
	LURET?C	018h
	LURET?C	020h
	LURET?C	07Fh
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	010h
	LURET?C	008h
	LURET?C	004h
	LURET?C	07Fh
	LURET?C	000h
	LURET?C	03Eh
	LURET?C	041h
	LURET?C	041h
	LURET?C	041h
	LURET?C	03Eh
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	048h
	LURET?C	048h
	LURET?C	048h
	LURET?C	030h
	LURET?C	000h
	LURET?C	03Eh
	LURET?C	041h
	LURET?C	045h
	LURET?C	042h
	LURET?C	03Dh
	LURET?C	000h
	LURET?C	07Fh
	LURET?C	048h
	LURET?C	04Ch
	LURET?C	04Ah
	LURET?C	031h
	LURET?C	000h
	LURET?C	032h
	LURET?C	049h
	LURET?C	049h
	LURET?C	049h
	LURET?C	026h
	LURET?C	000h
	LURET?C	040h
	LURET?C	040h
	LURET?C	07Fh
	LURET?C	040h
	LURET?C	040h
	LURET?C	000h
	LURET?C	07Eh
	LURET?C	001h
	LURET?C	001h
	LURET?C	001h
	LURET?C	07Eh
	LURET?C	000h
	LURET?C	01Eh
	LURET?C	041h
	LURET?C	001h
	LURET?C	041h
	LURET?C	01Eh
	LURET?C	000h
	LURET?C	07Ch
	LURET?C	002h
	LURET?C	001h
	LURET?C	002h
	LURET?C	07Ch
	LURET?C	000h
	LURET?C	07Eh
	LURET?C	001h
	LURET?C	00Eh
	LURET?C	001h
	LURET?C	07Eh
	LURET?C	000h
	LURET?C	063h
	LURET?C	014h
	LURET?C	008h
	LURET?C	014h
	LURET?C	063h
	LURET?C	000h
	LURET?C	070h
	LURET?C	008h
	LURET?C	007h
	LURET?C	008h
	LURET?C	070h
	LURET?C	000h
	LURET?C	043h
	LURET?C	045h
	LURET?C	049h
	LURET?C	051h
	LURET?C	061h
	LURET?C	000h
	LURET?C	000h
	LURET?C	000h
	LURET?C	000h
	LURET?C	000h
	LURET?C	000h
	LURET?C	000h
	LURET?C	03Eh
	LURET?C	045h
	LURET?C	049h
	LURET?C	051h
	LURET?C	03Eh
	LURET?C	000h
	LURET?C	021h
	LURET?C	07Fh
	LURET?C	001h
	LURET?C	000h
	LURET?C	021h
	LURET?C	043h
	LURET?C	045h
	LURET?C	049h
	LURET?C	031h
	LURET?C	000h
	LURET?C	042h
	LURET?C	041h
	LURET?C	051h
	LURET?C	069h
	LURET?C	046h
	LURET?C	000h
	LURET?C	00Ch
	LURET?C	014h
	LURET?C	024h
	LURET?C	07Fh
	LURET?C	004h
	LURET?C	000h
	LURET?C	072h
	LURET?C	051h
	LURET?C	051h
	LURET?C	051h
	LURET?C	04Eh
	LURET?C	000h
	LURET?C	01Eh
	LURET?C	029h
	LURET?C	049h
	LURET?C	049h
	LURET?C	006h
	LURET?C	000h
	LURET?C	040h
	LURET?C	047h
	LURET?C	048h
	LURET?C	050h
	LURET?C	060h
	LURET?C	000h
	LURET?C	036h
	LURET?C	049h
	LURET?C	049h
	LURET?C	049h
	LURET?C	036h
	LURET?C	000h
	LURET?C	030h
	LURET?C	049h
	LURET?C	049h
	LURET?C	04Ah
	LURET?C	03Ch
	LURET?C	000h

	LABEL?L	L00002	
	RETURN?	

	LABEL?L	_gonder	
	CMPNE?BCL	_tekrar, 008h, L00072
	MOVE?CB	000h, _tekrar
	HIGH?T	_izin
	PAUSEUS?C	001h
	LOW?T	_izin
	RETURN?	
	LABEL?L	L00072	
	CMPNE?TCL	_lcd_reg_7, 001h, L00074
	MOVE?CT	001h, _sda
	MOVE?CT	001h, _scl
	PAUSEUS?C	001h
	MOVE?CT	000h, _scl
	SHIFTL?BCB	_lcd_reg, 001h, _lcd_reg
	ADD?BCB	_tekrar, 001h, _tekrar
	GOTO?L	_gonder
	LABEL?L	L00074	
	MOVE?CT	000h, _sda
	MOVE?CT	001h, _scl
	PAUSEUS?C	001h
	MOVE?CT	000h, _scl
	SHIFTL?BCB	_lcd_reg, 001h, _lcd_reg
	ADD?BCB	_tekrar, 001h, _tekrar
	GOTO?L	_gonder

	END

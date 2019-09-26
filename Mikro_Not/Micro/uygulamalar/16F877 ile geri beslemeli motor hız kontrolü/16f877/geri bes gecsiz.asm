
; PicBasic Pro Compiler 2.43, (c) 1998, 2002 microEngineering Labs, Inc. All Rights Reserved. 
PM_USED			EQU	1

	INCLUDE	"16F877.INC"


; Define statements.
#define		CODE_SIZE		 8
#define		ADC_BITS		  12    
#define		ADC_CLOCK		 3    
#define		ADC_SAMPLES		 5  

RAM_START       		EQU	00020h
RAM_END         		EQU	001EFh
RAM_BANKS       		EQU	00004h
BANK0_START     		EQU	00020h
BANK0_END       		EQU	0007Fh
BANK1_START     		EQU	000A0h
BANK1_END       		EQU	000EFh
BANK2_START     		EQU	00110h
BANK2_END       		EQU	0016Fh
BANK3_START     		EQU	00190h
BANK3_END       		EQU	001EFh
EEPROM_START    		EQU	02100h
EEPROM_END      		EQU	021FFh

R0              		EQU	RAM_START + 000h
R1              		EQU	RAM_START + 002h
R2              		EQU	RAM_START + 004h
R3              		EQU	RAM_START + 006h
R4              		EQU	RAM_START + 008h
R5              		EQU	RAM_START + 00Ah
R6              		EQU	RAM_START + 00Ch
R7              		EQU	RAM_START + 00Eh
R8              		EQU	RAM_START + 010h
FLAGS           		EQU	RAM_START + 012h
GOP             		EQU	RAM_START + 013h
RM1             		EQU	RAM_START + 014h
RM2             		EQU	RAM_START + 015h
RR1             		EQU	RAM_START + 016h
RR2             		EQU	RAM_START + 017h
_SAY             		EQU	RAM_START + 018h
_SAYA            		EQU	RAM_START + 01Ah
_SAYB            		EQU	RAM_START + 01Ch
_PORTL           		EQU	 PORTB
_PORTH           		EQU	 PORTC
_TRISL           		EQU	 TRISB
_TRISH           		EQU	 TRISC
	INCLUDE	"GERIBE~1.MAC"
	INCLUDE	"PBPPIC14.LIB"

	MOVE?CB	00Eh, ADCON1
	MOVE?CB	03Fh, TRISA
	MOVE?CB	000h, TRISB
	MOVE?CB	000h, TRISC
	MOVE?CB	000h, TRISD
	MOVE?CB	000h, TRISE
	MOVE?CB	00Ch, CCP1CON
	MOVE?CB	00Ch, CCP2CON
	MOVE?CB	005h, T2CON
	MOVE?CB	000h, PORTB
	MOVE?CB	000h, PORTD

	LABEL?L	_BASLA	
	MOVE?CB	080h, CCPR1L

	LABEL?L	_BIR	
	ADCIN?CW	000h, _SAY
	MOVE?WB	_SAY, PORTB
	ADCIN?CW	001h, _SAYA
	MOVE?WB	_SAYA, PORTD
	CMPEQ?WWL	_SAY, _SAYA, _BIR
	CMPGT?WWL	_SAY, _SAYA, _IKI
	CMPLT?WWL	_SAY, _SAYA, _UC
	GOTO?L	_BIR

	LABEL?L	_IKI	
	ADD?BCB	CCPR1L, 001h, CCPR1L
	CMPEQ?BCL	CCPR1L, 0FFh, _DORT
	GOTO?L	_BIR

	LABEL?L	_UC	
	SUB?BCB	CCPR1L, 001h, CCPR1L
	CMPEQ?BCL	CCPR1L, 000h, _BES
	GOTO?L	_BIR

	LABEL?L	_DORT	
	ADCIN?CW	000h, _SAY
	MOVE?WB	_SAY, PORTB
	ADCIN?CW	001h, _SAYA
	MOVE?WB	_SAYA, PORTD
	CMPLE?WWL	_SAY, _SAYA, _UC
	GOTO?L	_DORT

	LABEL?L	_BES	
	ADCIN?CW	000h, _SAY
	MOVE?WB	_SAY, PORTB
	ADCIN?CW	001h, _SAYA
	MOVE?WB	_SAYA, PORTD
	CMPGE?WWL	_SAY, _SAYA, _IKI
	GOTO?L	_BES

	END

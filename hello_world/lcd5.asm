;LCD text demo - 4 bit mode
;Nigel Goodwin 2002

	LIST	p=16F877		;tell assembler what chip we are using
	include "P16F877.inc"		;include the defaults for the chip
	;ERRORLEVEL	0,	-302	;suppress bank selection messages
	;__config 0x3D18			;sets the configuration settings (oscillator type etc.)




		cblock	0x20			;start of general purpose registers
			count			;used in looping routines
			count1			;used in delay routine
			counta			;used in delay routine
			countb			;used in delay routine
			tmp1			;temporary storage
			tmp2
			templcd			;temp store for 4 bit mode
			templcd2	
		
		endc

LCD_PORT	Equ	PORTB
LCD_TRIS	Equ	TRISB

LCD_RS		Equ	4			;LCD handshake lines
;LCD_RW		Equ	6
LCD_E		Equ	5

		org	0x0000

		;movlw	0x07
		;movwf	CMCON			;turn comparators off (make it like a 16F84)

Initialise	
		clrf	count
		clrf	PORTD
		clrf	PORTB



SetPorts	
		bsf 	STATUS,		RP0	;select bank 1
		movlw	0x00			;make all pins outputs
		movwf	LCD_TRIS
		
		bcf 	STATUS,		RP0	;select bank 0

		call	Delay100		;wait for LCD to settle


		call	LCD_Init		;setup LCD


		clrf	count			;set counter register to zero
Message		
		movf	count, w		;put counter value in W
		call	Text			;get a character from the text table
		xorlw	0x00			;is it a zero?
		btfsc	STATUS, Z
		goto	NextMessage
		call	LCD_Char
		;call	Delay255
		incf	count, f
		goto	Message
		

NextMessage	
		call	LCD_Line2		;move to 2nd row, first column


		clrf	count			;set counter register to zero
Message2	
		movf	count, w		;put counter value in W
		call	Text2			;get a character from the text table
		xorlw	0x00			;is it a zero?
		btfsc	STATUS, Z
		goto	EndMessage
		call	LCD_Char
		incf	count, f
		goto	Message2

EndMessage	
		
Stop		
		goto	Stop			;endless loop




;Subroutines and text tables

;LCD routines

;Initialise LCD
LCD_Init	

		call	Delay100
		call	Delay100

		movlw	0x03
		movwf	LCD_PORT
		bsf	LCD_PORT,LCD_E
		bcf	LCD_PORT,LCD_E
		call	Delay50

		bsf	LCD_PORT,LCD_E
		bcf	LCD_PORT,LCD_E
		call	d1
		call	d1


		bsf	LCD_PORT,LCD_E
		bcf	LCD_PORT,LCD_E
		call	d1
		call	d1

		movlw	0x02
		movwf	LCD_PORT
		bsf	LCD_PORT,LCD_E
		bcf	LCD_PORT,LCD_E
		call	d1
		call	d1



		
		
		movlw	0x28			;Set display shift
		call	LCD_Cmd
		movlw	0x08			;Set display shift
		call	LCD_Cmd
		movlw	0x01			;Set display shift
		call	LCD_Cmd

		movlw	0x06			;Set display shift
		call	LCD_Cmd
		movlw	0x0C			;Set display shift
		call	LCD_Cmd
		




		call	LCD_Clr			;clear display

		retlw	0x00

; command set routine
LCD_Cmd		
		movwf	templcd
		swapf	templcd,	w	
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bcf	LCD_PORT, LCD_RS	;RS line to 0
		
		call	Pulse_e			;Pulse the E line high

		movf	templcd,	w	;send lower nibble
		;swapf	templcd,	w	;send upper nibble
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bcf	LCD_PORT, LCD_RS	;RS line to 0
	
		call	Pulse_e			;Pulse the E line high
		call 	Delay5
		retlw	0x00

LCD_CharD	addlw	0x30
LCD_Char	
		;addlw	0x30
		movwf	templcd
		swapf	templcd,	w	
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bsf	LCD_PORT, LCD_RS	;RS line to 1
		
		call	Pulse_e			;Pulse the E line high

		movf	templcd,	w	;send lower nibble
		;swapf	templcd,	w	;send upper nibble
		
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bsf	LCD_PORT, LCD_RS	;RS line to 1
		
		call	Pulse_e			;Pulse the E line high
		call 	Delay5
		retlw	0x00

LCD_Line1	movlw	0x80			;move to 1st row, first column
		call	LCD_Cmd
		retlw	0x00

LCD_Line2	movlw	0xc0			;move to 2nd row, first column
		call	LCD_Cmd
		retlw	0x00

LCD_Line1W	addlw	0x80			;move to 1st row, column W
		call	LCD_Cmd
		retlw	0x00

LCD_Line2W	addlw	0xc0			;move to 2nd row, column W
		call	LCD_Cmd
		retlw	0x00

LCD_CurOn	movlw	0x0d			;Set display on/off and cursor command
		call	LCD_Cmd
		retlw	0x00

LCD_CurOff	movlw	0x0c			;Set display on/off and cursor command
		call	LCD_Cmd
		retlw	0x00

LCD_Clr		movlw	0x01			;Clear display
		call	LCD_Cmd
		retlw	0x00

LCD_HEX		movwf	tmp1
		swapf	tmp1,	w
		andlw	0x0f
		call	HEX_Table
		call	LCD_Char
		movf	tmp1, w
		andlw	0x0f
		call	HEX_Table
		call	LCD_Char
		retlw	0x00

Delay255	movlw	0xff		;delay 255 mS
		goto	d0
Delay100	movlw	d'100'		;delay 100mS
		goto	d0
Delay50		movlw	d'50'		;delay 50mS
		goto	d0
Delay20		movlw	d'20'		;delay 20mS
		goto	d0
Delay5		movlw	0x05		;delay 5.000 ms (4 MHz clock)
d0		movwf	count1
d1		movlw	0xC7			;delay 1mS
		movwf	counta
		movlw	0x01
		movwf	countb
Delay_0
		decfsz	counta, f
		goto	$+2
		decfsz	countb, f
		goto	Delay_0

		decfsz	count1	,f
		goto	d1
		return

Pulse_e		
		bsf	LCD_PORT, LCD_E
		call	Delay5
		
		bcf	LCD_PORT, LCD_E
		;CALL	Delay5
		retlw	0x00

;end of LCD routines

HEX_Table  	ADDWF   PCL       , f
            	RETLW   0x30
            	RETLW   0x31
            	RETLW   0x32
            	RETLW   0x33
            	RETLW   0x34
            	RETLW   0x35
            	RETLW   0x36
            	RETLW   0x37
            	RETLW   0x38
            	RETLW   0x39
            	RETLW   0x41
            	RETLW   0x42
            	RETLW   0x43
            	RETLW   0x44
            	RETLW   0x45
            	RETLW   0x46


Text		
		addwf	PCL, f
		retlw	'H'
		retlw	'e'
		retlw	'l'
		retlw	'l'
		retlw	'o'
		retlw	0x00

Text2		
		ADDWF   PCL, f
        RETLW   'R'
        RETLW   'e'
        RETLW   'a'
        RETLW   'd'
        RETLW   'y'
        RETLW   '.'
        RETLW   '.'
        RETLW   '.'
        RETLW   0x00





		end
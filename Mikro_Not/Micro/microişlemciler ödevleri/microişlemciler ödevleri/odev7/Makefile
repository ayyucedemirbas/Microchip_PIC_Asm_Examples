# MPLAB IDE generated this makefile for use with GNU make.
# Project: odev7.mcp
# Date: Mon Dec 12 12:55:28 2011

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

odev7.cof : EPROMOKU.o
	$(CC) /p16F877A "EPROMOKU.o" /z__MPLAB_BUILD=1 /o"odev7.cof" /M"odev7.map" /W

EPROMOKU.o : EPROMOKU.ASM C:/Program\ Files/Microchip/MPASM\ Suite/P16F877A.INC
	$(AS) /q /p16F877A "EPROMOKU.ASM" /l"EPROMOKU.lst" /e"EPROMOKU.err" /o"EPROMOKU.o"

clean : 
	$(CC) "EPROMOKU.o" "EPROMOKU.err" "EPROMOKU.lst" "odev7.cof" "odev7.hex"


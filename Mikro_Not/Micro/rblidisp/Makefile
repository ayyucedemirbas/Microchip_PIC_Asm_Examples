# MPLAB IDE generated this makefile for use with GNU make.
# Project: rb.mcp
# Date: Sat Dec 29 23:57:22 2012

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

rb.cof : rb.o
	$(CC) /p16F877A "rb.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"rb.cof" /M"rb.map" /W /x

rb.o : rb.asm ../../../Program\ Files\ (x86)/Microchip/MPASM\ Suite/P16F877A.INC
	$(AS) /q /p16F877A "rb.asm" /l"rb.lst" /e"rb.err" /d__DEBUG=1

clean : 
	$(CC) "rb.o" "rb.hex" "rb.err" "rb.lst" "rb.cof"


# MPLAB IDE generated this makefile for use with GNU make.
# Project: lab3.mcp
# Date: Mon Oct 31 23:20:39 2011

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

lab3.cof : lab3.o
	$(CC) /p16F877A "lab3.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"lab3.cof" /M"lab3.map" /W /x

lab3.o : lab3.asm C:/Program\ Files/Microchip/MPASM\ Suite/P16F877A.inc
	$(AS) /q /p16F877A "lab3.asm" /l"lab3.lst" /e"lab3.err" /d__DEBUG=1

clean : 
	$(CC) "lab3.o" "lab3.hex" "lab3.err" "lab3.lst" "lab3.cof"


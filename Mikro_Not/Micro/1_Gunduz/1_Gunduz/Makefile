# MPLAB IDE generated this makefile for use with GNU make.
# Project: Proje.mcp
# Date: Sun Oct 16 22:28:01 2011

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

Proje.cof : Proje.o
	$(CC) /p16F877 "Proje.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"Proje.cof" /M"Proje.map" /W /x

Proje.o : Proje.asm ../../../../Program\ Files/Microchip/MPASM\ Suite/p16f877.inc
	$(AS) /q /p16F877 "Proje.asm" /l"Proje.lst" /e"Proje.err" /d__DEBUG=1

clean : 
	$(CC) "Proje.o" "Proje.hex" "Proje.err" "Proje.lst" "Proje.cof"


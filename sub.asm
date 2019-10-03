LIST P = 16F87A ;Kullanacagimiz PIC
CLRF A
CLRF B
A EQU d'4' ;A=5
B EQU d'50' ;B=7
MOVLW A ;A yi working'e tasidik W=A oldu
SUBLW B 
END

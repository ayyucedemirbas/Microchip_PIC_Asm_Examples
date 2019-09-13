LIST P = 16F87A
CLRF A
CLRF B
A EQU d'4' ;A=5
B EQU d'27' ;B=7
MOVLW A ;A yi working'e tasidik W=A oldu
ADDLW B 
END

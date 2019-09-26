	list p=16F877
	include "p16f877.inc"

	Degisken equ 0x21

	ORG 0
	goto Ana_program
	clrf PCLATH
	ORG 4

Kesme	
 	movf Degisken,0           ; Workinge de�i�ken de�eri at�l�yor
	movwf PORTD               ; Portd ye working de�eri at�l�yor

	btfss Degisken,7	      ; Son led yan�yorsa bir komut atl�yarak 2 defa sola kayarak t�m ledler s�nmeden tekrar ilk ledi yakar hale geliyor.
	goto Bir_Defa_Sola_Kay
	rlf Degisken,1            ; Buraya son led yan�kken ancak gelir.

Bir_Defa_Sola_Kay
	rlf Degisken,1
	bcf INTCON,INTF           ; Flag indiriliyor tekrar kesmeyi alg�layabilsin
	retfie                    ; D�n��

Ana_program 
	clrf PORTD                ; Portd s�f�rlan�yor
	clrf PORTB                ; Portb s�f�rlan�yor  

	movlw d'1'                ; De�i�kene 1 de�eri veriliyor
	movwf Degisken
	
	banksel TRISD             
	clrf TRISD                ; D Portu ��k��
 	
	movlw d'1'
	movwf TRISB               ; B portunun ilk pini buton i�in giri� olarak ayarlan�yor

	movlw b'01000000'         ; Pull-up diren�leri aktif
	movwf OPTION_REG       

	movlw b'11010000'         ; Kesmelere aktif, RB0 flag indiriliyor
	movwf INTCON
	
	banksel PORTD			

Dongu	
	goto Dongu                ; Dongu
end
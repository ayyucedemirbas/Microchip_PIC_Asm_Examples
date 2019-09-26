	list p=16F877
	include "p16f877.inc"

	Degisken equ 0x21

	ORG 0
	goto Ana_program
	clrf PCLATH
	ORG 4

Kesme	
 	movf Degisken,0           ; Workinge deðiþken deðeri atýlýyor
	movwf PORTD               ; Portd ye working deðeri atýlýyor

	btfss Degisken,7	      ; Son led yanýyorsa bir komut atlýyarak 2 defa sola kayarak tüm ledler sönmeden tekrar ilk ledi yakar hale geliyor.
	goto Bir_Defa_Sola_Kay
	rlf Degisken,1            ; Buraya son led yanýkken ancak gelir.

Bir_Defa_Sola_Kay
	rlf Degisken,1
	bcf INTCON,INTF           ; Flag indiriliyor tekrar kesmeyi algýlayabilsin
	retfie                    ; Dönüþ

Ana_program 
	clrf PORTD                ; Portd sýfýrlanýyor
	clrf PORTB                ; Portb sýfýrlanýyor  

	movlw d'1'                ; Deðiþkene 1 deðeri veriliyor
	movwf Degisken
	
	banksel TRISD             
	clrf TRISD                ; D Portu çýkýþ
 	
	movlw d'1'
	movwf TRISB               ; B portunun ilk pini buton için giriþ olarak ayarlanýyor

	movlw b'01000000'         ; Pull-up dirençleri aktif
	movwf OPTION_REG       

	movlw b'11010000'         ; Kesmelere aktif, RB0 flag indiriliyor
	movwf INTCON
	
	banksel PORTD			

Dongu	
	goto Dongu                ; Dongu
end
	list p=16F877A
	include "p16F877A.inc"	

	ORG 	0			
	clrf 	PCLATH			
	goto 	ana_program		
	ORG	4	

Kesme
	Retfie

Yazma_Ayari
	banksel EEADR 
	movlw 0X50                                                    
	movwf 	EEADR 
	movlw 0x55        ; 01010101         ; Adres bilgisi y�klendi.
	movwf	EEDATA                       ;EEDATA ya yani EEPROM a yaz�lacak veri 
                                         ;ADC De d�n��t�r�len en de�ersiz 8 bit.
	banksel EECON1                      
	bcf	EECON1,EEPGD                     ;Veri belle�ine eri�im izni.
	bcf	INTCON, GIE                      ;Genel kesmeler pasif. (Yazmada i�lem ak��� bozulmamal�.)
	bsf	EECON1, WREN                     ;Yazma etkinle�tirme bit�i set edildi.
	movlw	0x55                         ;Yazma i�in buradan itibaren 5 sat�r aynen korunmal�.                                  
	movwf	EECON2
	movlw	0xAA
	movwf	EECON2
	bsf	EECON1, WR                       ;Yaz komutu verildi.
	
Yazma_Bekle
	btfsc 	EECON1, WR                   ;Yazma i�lemi tamamlanana kadar bekle (WR=0 olana kadar).
	goto 	Yazma_Bekle
	bcf 	EECON1, WREN                 ;Yazma izni kald�r�ld�.
	return

Okuma_Ayari
	banksel EEADR 
	movlw 0x50                                                         
	movwf 	EEADR 
	banksel EECON1
	bcf	EECON1,EEPGD                     ;Veri belle�ine eri�im izni.
	bsf	EECON1, RD                       ;EEPROM Okuma modunda.
	banksel EEDATA
	movf	EEDATA, W
	banksel PORTD                        
	movwf	PORTD                        ;EEDATA daki de�er PORTD ye g�nderiliyor.
	return

ana_program
	BSF STATUS,RP0
	clrf	TRISD                        ;PORTD ��k��a y�nlendirildi.
	bcf 	STATUS, RP0                                      
	clrf	PORTD
                       
	call Yazma_Ayari
	call Okuma_Ayari

Dongu					                 ;Gecikme Program�
	goto Dongu                              
 
END

